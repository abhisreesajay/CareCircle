import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/safe_zone.dart';
import '../services/location_service.dart';
import '../services/safe_zone_service.dart';
import 'emergency_screen.dart';

class SafeZoneScreen extends StatefulWidget {
  const SafeZoneScreen({super.key});

  @override
  State<SafeZoneScreen> createState() => _SafeZoneScreenState();
}

class _SafeZoneScreenState extends State<SafeZoneScreen> {
  final SafeZoneService _safeZoneService = SafeZoneService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _radiusController =
      TextEditingController(text: '100');

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isSaving = false;
  bool _isChecking = false;

  @override
  void dispose() {
    _nameController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<bool> _checkLocationPermission() async {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      _showMessage('Please turn on location services.');
      return false;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _showMessage('Location permission was denied.');
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      _showMessage(
        'Location permission is permanently denied. '
        'Enable it from Settings.',
      );
      return false;
    }

    return true;
  }

  Future<void> _saveSafeZone() async {
    final name = _nameController.text.trim();
    final radiusText = _radiusController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter a safe zone name.');
      return;
    }

    final radius = double.tryParse(radiusText);

    if (radius == null || radius < 50) {
      _showMessage(
        'Please enter a radius of at least 50 meters.',
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please log in first.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final hasPermission = await _checkLocationPermission();

      if (!hasPermission) {
        return;
      }

      final position = await LocationService.getCurrentLocation();

      if (position == null) {
        _showMessage(
          'Could not get your current location. '
          'Please try again.',
        );
        return;
      }

      final safeZone = SafeZone(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        elderId: user.uid,
        name: name,
        latitude: position.latitude,
        longitude: position.longitude,
        radiusInMeters: radius,
        createdBy: user.uid,
      );

      await _safeZoneService.createSafeZone(safeZone);

      if (!mounted) return;

      _showMessage('Safe zone saved successfully.');

      _nameController.clear();
      _radiusController.text = '100';
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Could not save safe zone: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteSafeZone(SafeZone safeZone) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete safe zone?'),
          content: Text(
            'Are you sure you want to delete '
            '"${safeZone.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _safeZoneService.cancelSafeZone(safeZone.id);

      if (!mounted) return;

      _showMessage('Safe zone deleted.');
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Could not delete safe zone: $error',
      );
    }
  }

  Future<void> _checkSafeZone(SafeZone safeZone) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please log in first.');
      return;
    }

    setState(() {
      _isChecking = true;
    });

    try {
      final hasPermission = await _checkLocationPermission();

      if (!hasPermission) {
        return;
      }

      final position = await LocationService.getCurrentLocation();

      if (position == null) {
        _showMessage(
          'Could not get your current location.',
        );
        return;
      }

      final distanceInMeters = Geolocator.distanceBetween(
        safeZone.latitude,
        safeZone.longitude,
        position.latitude,
        position.longitude,
      );

      final isInside =
          distanceInMeters <= safeZone.radiusInMeters;

      if (isInside) {
        if (!mounted) return;

        _showMessage(
          'You are inside "${safeZone.name}". '
          'Distance: ${distanceInMeters.toStringAsFixed(1)} m',
        );
      } else {
        await _createSafeZoneViolation(
          userId: user.uid,
          safeZone: safeZone,
          currentLatitude: position.latitude,
          currentLongitude: position.longitude,
          distanceInMeters: distanceInMeters,
        );

        if (!mounted) return;

        _showMessage(
          'WARNING: You are outside "${safeZone.name}". '
          'Distance: ${distanceInMeters.toStringAsFixed(1)} m',
        );
      }
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Could not check safe zone: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _handleImOut() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please log in first.');
      return;
    }

    setState(() {
      _isChecking = true;
    });

    try {
      final hasPermission = await _checkLocationPermission();

      if (!hasPermission) {
        return;
      }

      final position = await LocationService.getCurrentLocation();

      if (position == null) {
        _showMessage(
          'Could not get your current location. '
          'Please try again.',
        );
        return;
      }

      final safeZones =
          await _safeZoneService.getSafeZones(user.uid);

      if (safeZones.isEmpty) {
        _showMessage(
          'No safe zones have been created yet.',
        );
        return;
      }

      bool isInsideAnySafeZone = false;
      SafeZone? currentSafeZone;
      double? currentDistance;

      for (final safeZone in safeZones) {
        final distanceInMeters = Geolocator.distanceBetween(
          safeZone.latitude,
          safeZone.longitude,
          position.latitude,
          position.longitude,
        );

        if (distanceInMeters <= safeZone.radiusInMeters) {
          isInsideAnySafeZone = true;
          currentSafeZone = safeZone;
          currentDistance = distanceInMeters;
          break;
        }
      }

      if (isInsideAnySafeZone) {
        if (!mounted) return;

        _showMessage(
          'You are inside "${currentSafeZone!.name}". '
          'Distance: ${currentDistance!.toStringAsFixed(1)} m',
        );
      } else {
        for (final safeZone in safeZones) {
          final distanceInMeters = Geolocator.distanceBetween(
            safeZone.latitude,
            safeZone.longitude,
            position.latitude,
            position.longitude,
          );

          await _createSafeZoneViolation(
            userId: user.uid,
            safeZone: safeZone,
            currentLatitude: position.latitude,
            currentLongitude: position.longitude,
            distanceInMeters: distanceInMeters,
          );
        }

        if (!mounted) return;

        _showMessage(
          'I’M OUT warning recorded. '
          'You are outside all safe zones.',
        );
      }
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Could not check your location: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _createSafeZoneViolation({
    required String userId,
    required SafeZone safeZone,
    required double currentLatitude,
    required double currentLongitude,
    required double distanceInMeters,
  }) async {
    await _firestore
        .collection('safeZoneViolations')
        .add({
      'elderId': userId,
      'safeZoneId': safeZone.id,
      'safeZoneName': safeZone.name,
      'safeZoneLatitude': safeZone.latitude,
      'safeZoneLongitude': safeZone.longitude,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'distanceInMeters': distanceInMeters,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<SafeZone>> _safeZonesStream(String userId) {
    return _firestore
        .collection('safeZones')
        .where('elderId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => SafeZone.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      _violationsStream(String userId) {
    return _firestore
        .collection('safeZoneViolations')
        .where('elderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _openEmergencyScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmergencyScreen(),
      ),
    );
  }

  String _formatTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toString();
    }

    return 'Time unavailable';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Safe Zone'),
        ),
        body: const Center(
          child: Text('Please log in first.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Zone'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.location_on,
              size: 80,
              color: Colors.green,
            ),

            const SizedBox(height: 16),

            const Text(
              'Create Safe Zone',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your current location will be saved '
              'as the safe-zone centre.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Safe zone name',
                hintText: 'Example: Home',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _radiusController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Radius in meters',
                hintText: 'Example: 100',
                helperText: 'Use at least 50 meters.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.radar),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveSafeZone,
              icon: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _isSaving ? 'Saving...' : 'Save Safe Zone',
              ),
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 16),

            const Text(
              'Saved Safe Zones',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            StreamBuilder<List<SafeZone>>(
              stream: _safeZonesStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Could not load safe zones: '
                    '${snapshot.error}',
                  );
                }

                final safeZones = snapshot.data ?? [];

                if (safeZones.isEmpty) {
                  return const Text(
                    'No safe zones created yet.',
                  );
                }

                return Column(
                  children: safeZones.map((safeZone) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_pin,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    safeZone.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _deleteSafeZone(safeZone),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),

                            Text(
                              'Radius: '
                              '${safeZone.radiusInMeters} meters',
                            ),

                            Text(
                              'Latitude: ${safeZone.latitude}',
                            ),

                            Text(
                              'Longitude: ${safeZone.longitude}',
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isChecking
                                    ? null
                                    : () => _checkSafeZone(
                                          safeZone,
                                        ),
                                icon: const Icon(
                                  Icons.my_location,
                                ),
                                label: Text(
                                  _isChecking
                                      ? 'Checking...'
                                      : 'Check Current Location',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 16),

            const Text(
              'Leaving Safe Zone',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Use this button when you leave your saved '
              'safe zones.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isChecking ? null : _handleImOut,
                icon: _isChecking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.directions_walk),
                label: Text(
                  _isChecking
                      ? 'CHECKING LOCATION...'
                      : 'I’M OUT',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 16),

            const Text(
              'Recent Safe-Zone Violations',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _violationsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Could not load violations: '
                    '${snapshot.error}',
                  );
                }

                final violations =
                    snapshot.data?.docs ?? [];

                if (violations.isEmpty) {
                  return const Text(
                    'No safe-zone violations recorded.',
                  );
                }

                return Column(
                  children: violations.map((doc) {
                    final data = doc.data();

                    final zoneName =
                        data['safeZoneName'] ?? 'Unknown zone';

                    final distance =
                        data['distanceInMeters'];

                    final createdAt =
                        _formatTimestamp(data['createdAt']);

                    return Card(
                      color: Colors.orange.shade50,
                      child: ListTile(
                        leading: const Icon(
                          Icons.warning,
                          color: Colors.orange,
                        ),
                        title: Text(
                          'Outside $zoneName',
                        ),
                        subtitle: Text(
                          'Distance: '
                          '${distance ?? 'Unknown'} meters\n'
                          'Time: $createdAt',
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 20),

            const Text(
              'Emergency Assistance',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Use this button during an emergency '
              'to send an SOS alert.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openEmergencyScreen,
                icon: const Icon(Icons.sos),
                label: const Text(
                  'EMERGENCY / SOS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}