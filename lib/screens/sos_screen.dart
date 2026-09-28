import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/sos_record.dart';
import '../services/sos_service.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final SosService _sosService = SosService();

  bool _sosActive = false;
  bool _loading = false;
  String? _sosId;

  @override
  void initState() {
    super.initState();
    _loadActiveSOS();
  }

  // Loads an active SOS belonging to the currently logged-in user.
  Future<void> _loadActiveSOS() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      final SosRecord? activeSos = await _sosService.getActiveSos(
        userId: user.uid,
      );

      if (!mounted) {
        return;
      }

      if (activeSos != null) {
        setState(() {
          _sosId = activeSos.id;
          _sosActive = true;
        });
      }
    } catch (e) {
      // Do not prevent the screen from opening if loading fails.
    }
  }

  Future<void> _triggerSOS() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Emergency SOS'),
          content: const Text(
            'Are you sure you want to send an emergency SOS?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('SEND SOS'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Please login before sending SOS.');
      }

      final SosRecord sos = await _sosService.createSos(
        userId: user.uid,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _sosId = sos.id;
        _sosActive = true;
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SOS sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send SOS: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelSOS() async {
    if (_sosId == null) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _sosService.cancelSos(_sosId!);

      if (!mounted) {
        return;
      }

      setState(() {
        _sosActive = false;
        _sosId = null;
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SOS cancelled'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel SOS: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency & Safety'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _loading
              ? const CircularProgressIndicator(
                  color: Colors.red,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_sosActive) ...[
                      const Icon(
                        Icons.warning_rounded,
                        size: 90,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'SOS ACTIVE',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Your emergency SOS has been sent.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _cancelSOS,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'CANCEL SOS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.emergency,
                        size: 100,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Emergency SOS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Press the button below if you need emergency help.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 35),
                      SizedBox(
                        width: double.infinity,
                        height: 65,
                        child: ElevatedButton(
                          onPressed: _triggerSOS,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'SEND SOS',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}