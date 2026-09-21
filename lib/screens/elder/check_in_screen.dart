import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/check_in_service.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({
    super.key,
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
      );
    } finally {
      if (mounted) {
        setState(() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4EFE5),
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
          padding:
              const EdgeInsets.all(24),
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
                'Your caregiver will receive your check-in status.',
                textAlign:
                    TextAlign.center,
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