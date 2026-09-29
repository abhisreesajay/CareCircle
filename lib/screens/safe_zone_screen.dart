import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/safe_zone.dart';
import '../services/location_service.dart';
import '../services/safe_zone_service.dart';
import 'elder/emergency_screen.dart';

class SafeZoneScreen extends StatefulWidget {
  final String? elderId;

  const SafeZoneScreen({
    super.key,
    this.elderId,
  });

  @override
  State<SafeZoneScreen> createState() =>
      _SafeZoneScreenState();
}

class _SafeZoneScreenState
    extends State<SafeZoneScreen> {
  final SafeZoneService _safeZoneService =
      SafeZoneService();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _latitudeController =
      TextEditingController();

  final TextEditingController _longitudeController =
      TextEditingController();

  final TextEditingController _radiusController =
      TextEditingController(
    text: '100',
  );

  bool _isSaving = false;
  bool _isChecking = false;

  bool get _isCaregiverMode =>
      widget.elderId != null &&
      widget.elderId!.trim().isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOCATION PERMISSION
  // ============================================================

  Future<bool> _checkLocationPermission() async {
    final bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      _showMessage(
        'Please turn on location services.',
      );
      return false;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission ==
        LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
        LocationPermission.denied) {
      _showMessage(
        'Location permission was denied.',
      );
      return false;
    }

    if (permission ==
        LocationPermission.deniedForever) {
      _showMessage(
        'Location permission is permanently denied. '
        'Enable it from Settings.',
      );
      return false;
    }

    return true;
  }

  // ============================================================
  // SAVE SAFE ZONE
  // ============================================================

  Future<void> _saveSafeZone() async {
    final String name =
        _nameController.text.trim();

    final String latitudeText =
        _latitudeController.text.trim();

    final String longitudeText =
        _longitudeController.text.trim();

    final String radiusText =
        _radiusController.text.trim();

    if (name.isEmpty) {
      _showMessage(
        'Please enter a safe zone name.',
      );
      return;
    }

    if (!_isCaregiverMode) {
      _showMessage(
        'Only a caregiver can create a safe zone.',
      );
      return;
    }

    final double? latitude =
        double.tryParse(latitudeText);

    final double? longitude =
        double.tryParse(longitudeText);

    final double? radius =
        double.tryParse(radiusText);

    if (latitude == null ||
        latitude < -90 ||
        latitude > 90) {
      _showMessage(
        'Please enter a valid latitude '
        'between -90 and 90.',
      );
      return;
    }

    if (longitude == null ||
        longitude < -180 ||
        longitude > 180) {
      _showMessage(
        'Please enter a valid longitude '
        'between -180 and 180.',
      );
      return;
    }

    if (radius == null || radius < 50) {
      _showMessage(
        'Please enter a radius of at least 50 meters.',
      );
      return;
    }

    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please log in first.',
      );
      return;
    }

    final String elderId =
        widget.elderId!.trim();

    if (elderId.isEmpty) {
      _showMessage(
        'Elder ID is missing.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final SafeZone safeZone =
          SafeZone(
        id: '',
        elderId: elderId,
        name: name,
        latitude: latitude,
        longitude: longitude,
        radiusInMeters: radius,
        createdBy: user.uid,
      );

      await _safeZoneService.createSafeZone(
        safeZone,
      );

      if (!mounted) return;

      _nameController.clear();
      _latitudeController.clear();
      _longitudeController.clear();
      _radiusController.text = '100';

      _showMessage(
        'Safe zone saved successfully.',
      );
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

  // ============================================================
  // DELETE SAFE ZONE
  // ============================================================

  Future<void> _deleteSafeZone(
    SafeZone safeZone,
  ) async {
    final bool? shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete safe zone?',
          ),
          content: Text(
            'Are you sure you want to delete '
            '"${safeZone.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _safeZoneService.cancelSafeZone(
        safeZone.id,
      );

      if (!mounted) return;

      _showMessage(
        'Safe zone deleted.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Could not delete safe zone: $error',
      );
    }
  }

  // ============================================================
  // CHECK ONE SAFE ZONE
  // ============================================================

  Future<void> _checkSafeZone(
    SafeZone safeZone,
  ) async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please log in first.',
      );
      return;
    }

    setState(() {
      _isChecking = true;
    });

    try {
      final bool hasPermission =
          await _checkLocationPermission();

      if (!hasPermission) {
        return;
      }

      final Position? position =
          await LocationService
              .getCurrentLocation();

      if (position == null) {
        _showMessage(
          'Could not get your current location.',
        );
        return;
      }

      final double distanceInMeters =
          Geolocator.distanceBetween(
        safeZone.latitude,
        safeZone.longitude,
        position.latitude,
        position.longitude,
      );

      final bool isInside =
          distanceInMeters <=
              safeZone.radiusInMeters;

      if (isInside) {
        if (!mounted) return;

        _showMessage(
          'You are inside "${safeZone.name}". '
          'Distance: '
          '${distanceInMeters.toStringAsFixed(1)} m',
        );
      } else {
        await _safeZoneService
            .createSafeZoneViolation(
          elderId: user.uid,
          safeZone: safeZone,
          latitude: position.latitude,
          longitude: position.longitude,
          distanceInMeters: distanceInMeters,
        );

        if (!mounted) return;

        _showMessage(
          'WARNING: You are outside '
          '"${safeZone.name}". '
          'Distance: '
          '${distanceInMeters.toStringAsFixed(1)} m',
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

  // ============================================================
  // CHECK ALL SAFE ZONES
  // ============================================================

  Future<void> _handleImOut() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please log in first.',
      );
      return;
    }

    setState(() {
      _isChecking = true;
    });

    try {
      final bool hasPermission =
          await _checkLocationPermission();

      if (!hasPermission) {
        return;
      }

      final Position? position =
          await LocationService
              .getCurrentLocation();

      if (position == null) {
        _showMessage(
          'Could not get your current location. '
          'Please try again.',
        );
        return;
      }

      final List<SafeZone> safeZones =
          await _safeZoneService.getSafeZones(
        user.uid,
      );

      if (safeZones.isEmpty) {
        _showMessage(
          'No safe zones have been created yet.',
        );
        return;
      }

      bool isInsideAnySafeZone = false;

      SafeZone? currentSafeZone;
      double? currentDistance;

      for (final SafeZone safeZone
          in safeZones) {
        final double distanceInMeters =
            Geolocator.distanceBetween(
          safeZone.latitude,
          safeZone.longitude,
          position.latitude,
          position.longitude,
        );

        if (distanceInMeters <=
            safeZone.radiusInMeters) {
          isInsideAnySafeZone = true;
          currentSafeZone = safeZone;
          currentDistance =
              distanceInMeters;
          break;
        }
      }

      if (isInsideAnySafeZone) {
        if (!mounted) return;

        _showMessage(
          'You are inside '
          '"${currentSafeZone!.name}". '
          'Distance: '
          '${currentDistance!.toStringAsFixed(1)} m',
        );
      } else {
        for (final SafeZone safeZone
            in safeZones) {
          final double distanceInMeters =
              Geolocator.distanceBetween(
            safeZone.latitude,
            safeZone.longitude,
            position.latitude,
            position.longitude,
          );

          await _safeZoneService
              .createSafeZoneViolation(
            elderId: user.uid,
            safeZone: safeZone,
            latitude: position.latitude,
            longitude: position.longitude,
            distanceInMeters:
                distanceInMeters,
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

  // ============================================================
  // SAFE ZONE STREAM
  // ============================================================

  Stream<List<SafeZone>> _safeZonesStream(
    String elderId,
  ) {
    return _firestore
        .collection('safeZones')
        .where(
          'elderId',
          isEqualTo: elderId,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  (doc) =>
                      SafeZone.fromMap(
                    doc.id,
                    doc.data(),
                  ),
                )
                .toList();
          },
        );
  }

  // ============================================================
  // VIOLATION STREAM
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      _violationsStream(
    String elderId,
  ) {
    return _firestore
        .collection('safeZoneViolations')
        .where(
          'elderId',
          isEqualTo: elderId,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(10)
        .snapshots();
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // EMERGENCY
  // ============================================================

  void _openEmergencyScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const EmergencyScreen(),
      ),
    );
  }

  // ============================================================
  // TIMESTAMP
  // ============================================================

  String _formatTimestamp(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate().toString();
    }

    return 'Time unavailable';
  }

  // ============================================================
  // CAREGIVER CREATE FORM
  // ============================================================

  Widget _buildCaregiverCreateSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.shield_rounded,
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
          'Set the safe-zone name, latitude, '
          'longitude and radius for the elder.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        TextField(
          controller: _nameController,
          decoration:
              const InputDecoration(
            labelText: 'Safe zone name',
            hintText: 'Example: Home',
            border: OutlineInputBorder(),
            prefixIcon:
                Icon(Icons.home),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller:
              _latitudeController,
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration:
              const InputDecoration(
            labelText: 'Latitude',
            hintText:
                'Example: 10.123456',
            border: OutlineInputBorder(),
            prefixIcon:
                Icon(Icons.location_on),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller:
              _longitudeController,
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration:
              const InputDecoration(
            labelText: 'Longitude',
            hintText:
                'Example: 76.123456',
            border: OutlineInputBorder(),
            prefixIcon:
                Icon(Icons.location_on),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller:
              _radiusController,
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration:
              const InputDecoration(
            labelText:
                'Radius in meters',
            hintText:
                'Example: 100',
            helperText:
                'Use at least 50 meters.',
            border: OutlineInputBorder(),
            prefixIcon:
                Icon(Icons.radar),
          ),
        ),

        const SizedBox(height: 20),

        ElevatedButton.icon(
          onPressed: _isSaving
              ? null
              : _saveSafeZone,
          icon: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(
            _isSaving
                ? 'Saving...'
                : 'Save Safe Zone',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SAFE ZONE CARD
  // ============================================================

  Widget _buildSafeZoneCard(
    SafeZone safeZone,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(12),
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
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                if (_isCaregiverMode)
                  IconButton(
                    onPressed: () =>
                        _deleteSafeZone(
                      safeZone,
                    ),
                    icon:
                        const Icon(
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
              'Latitude: '
              '${safeZone.latitude}',
            ),

            Text(
              'Longitude: '
              '${safeZone.longitude}',
            ),

            if (!_isCaregiverMode) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child:
                    ElevatedButton.icon(
                  onPressed: _isChecking
                      ? null
                      : () =>
                          _checkSafeZone(
                            safeZone,
                          ),
                  icon:
                      const Icon(
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
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text('Safe Zone'),
        ),
        body: const Center(
          child: Text(
            'Please log in first.',
          ),
        ),
      );
    }

    final String elderId =
        _isCaregiverMode
            ? widget.elderId!.trim()
            : user.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isCaregiverMode
              ? 'Manage Safe Zone'
              : 'Safe Zone',
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            if (_isCaregiverMode) ...[
              _buildCaregiverCreateSection(),

              const SizedBox(height: 30),

              const Divider(),

              const SizedBox(height: 16),

              const Text(
                'Assigned Safe Zones',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),
            ] else ...[
              const Icon(
                Icons.shield_rounded,
                size: 80,
                color: Colors.green,
              ),

              const SizedBox(height: 16),

              const Text(
                'My Safe Zones',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Your caregiver can create safe zones '
                'for you. You can perform a one-time '
                'location check to see whether you are '
                'inside or outside a zone.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
            ],

            StreamBuilder<List<SafeZone>>(
              stream:
                  _safeZonesStream(
                elderId,
              ),
              builder:
                  (context, snapshot) {
                if (snapshot
                        .connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Could not load safe zones: '
                    '${snapshot.error}',
                  );
                }

                final List<SafeZone>
                    safeZones =
                    snapshot.data ?? [];

                if (safeZones.isEmpty) {
                  return const Text(
                    'No safe zones created yet.',
                  );
                }

                return Column(
                  children: safeZones
                      .map(
                        _buildSafeZoneCard,
                      )
                      .toList(),
                );
              },
            ),

            if (!_isCaregiverMode) ...[
              const SizedBox(height: 30),

              const Divider(),

              const SizedBox(height: 16),

              const Text(
                'Leaving Safe Zone',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Use this button for a one-time '
                'location check when you leave '
                'your saved safe zones.',
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 60,
                width: double.infinity,
                child:
                    ElevatedButton.icon(
                  onPressed: _isChecking
                      ? null
                      : _handleImOut,
                  icon: _isChecking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons
                              .directions_walk,
                        ),
                  label: Text(
                    _isChecking
                        ? 'CHECKING LOCATION...'
                        : 'I’M OUT',
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.orange,
                    foregroundColor:
                        Colors.white,
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
                  fontWeight:
                      FontWeight.bold,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(height: 12),

              StreamBuilder<
                  QuerySnapshot<
                      Map<String,
                          dynamic>>>(
                stream:
                    _violationsStream(
                  user.uid,
                ),
                builder:
                    (context, snapshot) {
                  if (snapshot
                          .connectionState ==
                      ConnectionState
                          .waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Could not load violations: '
                      '${snapshot.error}',
                    );
                  }

                  final violations =
                      snapshot.data?.docs ??
                          [];

                  if (violations.isEmpty) {
                    return const Text(
                      'No safe-zone '
                      'violations recorded.',
                    );
                  }

                  return Column(
                    children:
                        violations.map(
                      (doc) {
                        final data =
                            doc.data();

                        final String
                            zoneName =
                            data[
                                        'safeZoneName']
                                    ?.toString() ??
                                'Unknown zone';

                        final dynamic
                            distance =
                            data[
                                'distanceInMeters'];

                        final String
                            createdAt =
                            _formatTimestamp(
                          data[
                              'createdAt'],
                        );

                        return Card(
                          color: Colors
                              .orange
                              .shade50,
                          child:
                              ListTile(
                            leading:
                                const Icon(
                              Icons.warning,
                              color: Colors
                                  .orange,
                            ),
                            title:
                                Text(
                              'Outside '
                              '$zoneName',
                            ),
                            subtitle:
                                Text(
                              'Distance: '
                              '${distance ?? 'Unknown'} meters\n'
                              'Time: '
                              '$createdAt',
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  );
                },
              ),
            ],

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 20),

            const Text(
              'Emergency Assistance',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Use this button during an emergency '
              'to send an SOS alert.',
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 60,
              width: double.infinity,
              child:
                  ElevatedButton.icon(
                onPressed:
                    _openEmergencyScreen,
                icon: const Icon(
                  Icons.sos,
                ),
                label: const Text(
                  'EMERGENCY / SOS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,
                  foregroundColor:
                      Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}