import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/care_circle_service.dart';

class InviteCodeScreen extends StatefulWidget {
  const InviteCodeScreen({
    super.key,
  });

  @override
  State<InviteCodeScreen> createState() =>
      _InviteCodeScreenState();
}

class _InviteCodeScreenState
    extends State<InviteCodeScreen> {
  final CareCircleService _careCircleService =
      CareCircleService();

  String? _code;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCode();
  }

  Future<void> _loadCode() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      return;
    }

    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final String code =
          await _careCircleService.createElderInviteCode(
        user.uid,
      );

      if (!mounted) return;

      setState(() {
        _code = code;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Caregiver Connection',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _loading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.link_rounded,
                        size: 80,
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Your Connection Code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Give this code to your caregiver '
                        'so they can connect to your '
                        'CareCircle account.',
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 28),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            width: 2,
                          ),
                        ),
                        child: Text(
                          _code ?? '------',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              _loading ? null : _loadCode,
                          icon: const Icon(
                            Icons.refresh,
                          ),
                          label: const Text(
                            'Refresh Code',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}