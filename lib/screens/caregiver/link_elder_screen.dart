import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/care_circle_service.dart';

class LinkElderScreen extends StatefulWidget {
  const LinkElderScreen({
    super.key,
  });

  @override
  State<LinkElderScreen> createState() =>
      _LinkElderScreenState();
}

class _LinkElderScreenState
    extends State<LinkElderScreen> {
  final TextEditingController _codeController =
      TextEditingController();

  final CareCircleService _service =
      CareCircleService();

  bool _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _linkElder() async {
    final String code =
        _codeController.text.trim();

    if (code.isEmpty) {
      _showMessage(
        'Please enter the elder invite code.',
      );
      return;
    }

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
      await _service.linkCaregiverToElder(
        caregiverUid: user.uid,
        inviteCode: code,
      );

      if (!mounted) return;

      _showMessage(
        'Elder linked successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
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
    ScaffoldMessenger.of(context).showSnackBar(
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
        backgroundColor:
            const Color(0xFF46695A),
        foregroundColor: Colors.white,
        title: const Text(
          'Link an Elder',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 35),

              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFE5F0EA),
                  borderRadius:
                      BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.link_rounded,
                  size: 45,
                  color:
                      Color(0xFF46695A),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Connect to an Elder',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color:
                      Color(0xFF26352F),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Ask the elder for their 6-character CareCircle invite code.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color:
                      Color(0xFF7A827D),
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller:
                    _codeController,
                textCapitalization:
                    TextCapitalization.characters,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 5,
                ),
                decoration:
                    InputDecoration(
                  labelText:
                      'Invite Code',
                  hintText:
                      'ABC123',
                  filled: true,
                  fillColor:
                      const Color(0xFFFFFBF4),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed:
                      _loading
                          ? null
                          : _linkElder,
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
                          BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                          color:
                              Colors.white,
                        )
                      : const Text(
                          'LINK ELDER',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}