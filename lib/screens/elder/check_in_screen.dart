import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD

import '../../services/check_in_service.dart';
=======
import '../../services/caregiver/check_in_history_service.dart';
import '../../services/check_in_reminder_service.dart';
>>>>>>> develop

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({
    super.key,
<<<<<<< HEAD
  });

  @override
  State<CheckInScreen> createState() =>
      _CheckInScreenState();
}

class _CheckInScreenState
    extends State<CheckInScreen> {
  final CheckInService _service =
      CheckInService();

  bool _loading = false;

  Future<void> _submit({
    required String response,
    required String status,
  }) async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please log in again.',
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _service.recordCheckIn(
        elderId: user.uid,
        method: 'button',
        response: response,
        status: status,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              status == 'COMPLETED'
                  ? 'Check-in Complete'
                  : 'Help Requested',
            ),
            content: Text(
              status == 'COMPLETED'
                  ? 'Your caregiver has been notified that you are okay.'
                  : 'Your caregiver has been notified that you need help.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child:
                    const Text('OK'),
              ),
            ],
          );
        },
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showMessage(
        'Could not save check-in: $e',
=======
    required this.elderId,
  });

  final String elderId;

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool _saving = false;

  Future<void> _saveCheckIn(String status) async {
    setState(() {
      _saving = true;
    });

    try {
      await CheckInHistoryService().saveCheckIn(
        elderId: widget.elderId,
        status: status,
      );

      if (status == 'COMPLETED') {
        final reminderService = CheckInReminderService();

        final reminderId =
            await reminderService.getPendingReminderId(widget.elderId);

        if (reminderId != null) {
          await reminderService.completeReminder(
            elderId: widget.elderId,
            reminderId: reminderId,
          );
        }
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            status == 'COMPLETED'
                ? 'Check-in Complete'
                : 'Help Requested',
          ),
          content: Text(
            status == 'COMPLETED'
                ? 'Your daily check-in has been recorded.'
                : 'Your request for help has been recorded.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save check-in: $e'),
        ),
>>>>>>> develop
      );
    } finally {
      if (mounted) {
        setState(() {
<<<<<<< HEAD
          _loading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
=======
          _saving = false;
        });
      }
    }
>>>>>>> develop
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor:
          const Color(0xFFF4EFE5),
=======
      backgroundColor: const Color(0xFFF4F8FA),
>>>>>>> develop
      appBar: AppBar(
        title: const Text(
          'Daily Check-in',
        ),
        backgroundColor:
            const Color(0xFF46695A),
        foregroundColor:
            Colors.white,
      ),
      body: SafeArea(
        child: Padding(
<<<<<<< HEAD
          padding:
              const EdgeInsets.all(24),
=======
          padding: const EdgeInsets.all(24),
>>>>>>> develop
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),

              const Text(
                'How are you today?',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Color(0xFF26352F),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              const Text(
                'Choose the option that best describes what you need.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color:
                      Color(0xFF7A827D),
                ),
              ),

              const Spacer(),

              SizedBox(
                width:
                    double.infinity,
                height: 110,
<<<<<<< HEAD
                child:
                    ElevatedButton(
                  onPressed:
                      _loading
                          ? null
                          : () {
                              _submit(
                                response:
                                    "I'm OK",
                                status:
                                    'COMPLETED',
                              );
                            },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF46695A,
                    ),
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        22,
                      ),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                          color:
                              Colors.white,
                        )
                      : const Text(
                          "I'M OK",
                          style:
                              TextStyle(
                            fontSize: 30,
                            fontWeight:
                                FontWeight
                                    .w800,
=======
                child: ElevatedButton(
                  onPressed:
                      _saving ? null : () => _saveCheckIn('COMPLETED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16845B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "I'M OK",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
>>>>>>> develop
                          ),
                        ),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 110,
<<<<<<< HEAD
                child:
                    ElevatedButton(
                  onPressed:
                      _loading
                          ? null
                          : () {
                              _submit(
                                response:
                                    'Need help',
                                status:
                                    'HELP_REQUESTED',
                              );
                            },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFFC85C50,
                    ),
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        22,
                      ),
=======
                child: ElevatedButton(
                  onPressed:
                      _saving ? null : () => _saveCheckIn('HELP_REQUESTED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
>>>>>>> develop
                    ),
                  ),
                  child:
                      const Text(
                    'NEED HELP',
                    style:
                        TextStyle(
                      fontSize: 30,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              const Text(
<<<<<<< HEAD
                'Your caregiver will receive your check-in status.',
                textAlign:
                    TextAlign.center,
=======
                'Your check-in will be saved securely.',
                textAlign: TextAlign.center,
>>>>>>> develop
                style: TextStyle(
                  fontSize: 16,
                  color:
                      Color(0xFF7A827D),
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}