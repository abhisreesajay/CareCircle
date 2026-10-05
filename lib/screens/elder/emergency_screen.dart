import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/sos_service.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final SosService _sosService = SosService();

  bool isSendingSOS = false;
  bool isCancellingSOS = false;
  bool sosActive = false;

  String? activeSosId;

  @override
  void initState() {
    super.initState();
    _checkExistingActiveSOS();
  }

  // ------------------------------------------------------------
  // CHECK EXISTING ACTIVE SOS
  // ------------------------------------------------------------

  Future<void> _checkExistingActiveSOS() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      final activeSos = await _sosService.getActiveSos(
        userId: user.uid,
      );

      if (!mounted) {
        return;
      }

      if (activeSos != null) {
        setState(() {
          sosActive = true;
          activeSosId = activeSos.id;
        });
      }
    } catch (_) {
      // The user can still try sending an SOS.
    }
  }

  // ------------------------------------------------------------
  // SEND SOS
  // ------------------------------------------------------------

  Future<void> sendSOS() async {
    if (isSendingSOS || isCancellingSOS) {
      return;
    }

    setState(() {
      isSendingSOS = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Please log in first.');
      }

      // ----------------------------------------------------------
      // STEP 1: CHECK EXISTING ACTIVE SOS
      // ----------------------------------------------------------

      final existingActiveSOS = await _sosService.getActiveSos(
        userId: user.uid,
      );

      if (existingActiveSOS != null) {
        if (!mounted) {
          return;
        }

        setState(() {
          sosActive = true;
          activeSosId = existingActiveSOS.id;
        });

        _showMessage(
          'You already have an active SOS.',
        );

        return;
      }

      // ----------------------------------------------------------
      // STEP 2: CREATE SOS
      // ----------------------------------------------------------

      final sosRecord = await _sosService.createSos(
        userId: user.uid,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        sosActive = true;
        activeSosId = sosRecord.id;
      });

      _showMessage(
        'SOS sent successfully. '
        'Your location has been saved.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'SOS failed: ${_cleanErrorMessage(error)}',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSendingSOS = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // CANCEL SOS
  // ------------------------------------------------------------

  Future<void> cancelSOS() async {
    if (isCancellingSOS || isSendingSOS) {
      return;
    }

    setState(() {
      isCancellingSOS = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Please log in first.');
      }

      String? sosId = activeSosId;

      // Find the latest active SOS if needed.
      if (sosId == null || sosId.isEmpty) {
        final activeSos = await _sosService.getActiveSos(
          userId: user.uid,
        );

        if (activeSos == null) {
          throw Exception('No active SOS found.');
        }

        sosId = activeSos.id;
      }

      await _sosService.cancelSos(sosId);

      if (!mounted) {
        return;
      }

      setState(() {
        sosActive = false;
        activeSosId = null;
      });

      _showMessage(
        'SOS cancelled successfully.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not cancel SOS: '
        '${_cleanErrorMessage(error)}',
      );
    } finally {
      if (mounted) {
        setState(() {
          isCancellingSOS = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // SOS CONFIRMATION DIALOG
  // ------------------------------------------------------------

  void showSOSConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm SOS'),
          content: const Text(
            'Are you sure you want to send '
            'an emergency SOS alert?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                sendSOS();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('SEND SOS'),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // ERROR MESSAGE HELPER
  // ------------------------------------------------------------

  String _cleanErrorMessage(Object error) {
    final String message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }

  // ------------------------------------------------------------
  // SNACKBAR MESSAGE
  // ------------------------------------------------------------

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ------------------------------------------------------------
  // USER INTERFACE
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool isBusy = isSendingSOS || isCancellingSOS;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency & SOS'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                sosActive
                    ? Icons.warning_rounded
                    : Icons.health_and_safety,
                color: Colors.red,
                size: 100,
              ),

              const SizedBox(height: 20),

              Text(
                sosActive
                    ? 'SOS ACTIVE'
                    : 'Emergency Assistance',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                sosActive
                    ? 'Your emergency SOS record '
                        'has been saved.'
                    : 'Press the button below only '
                        'during an emergency.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 35),

              // ------------------------------------------------
              // SOS BUTTON
              // ------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: isBusy
                      ? null
                      : sosActive
                          ? cancelSOS
                          : showSOSConfirmation,
                  icon: Icon(
                    sosActive
                        ? Icons.cancel
                        : Icons.sos,
                  ),
                  label: Text(
                    isSendingSOS
                        ? 'GETTING LOCATION...'
                        : isCancellingSOS
                            ? 'CANCELLING SOS...'
                            : sosActive
                                ? 'CANCEL SOS'
                                : 'SEND SOS',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        Colors.red.shade200,
                    disabledForegroundColor:
                        Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // ACTIVE SOS INFORMATION
              // ------------------------------------------------

              if (sosActive)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.shade200,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Colors.red,
                        size: 28,
                      ),

                      SizedBox(height: 8),

                      Text(
                        'Emergency alert is active.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'Your SOS location has been saved. '
                        'Caregiver notification will be '
                        'handled through the Firebase '
                        'notification system.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
