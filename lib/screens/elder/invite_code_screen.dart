import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  String? _code;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCode();
  }

  Future<void> _loadCode() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    final ref =
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);

    final snapshot =
        await ref.get();

    String? code =
        snapshot.data()?['inviteCode']
            ?.toString();

    if (code == null ||
        code.trim().isEmpty) {
      code = _generateCode();

      await ref.set(
        {
          'inviteCode': code,
        },
        SetOptions(merge: true),
      );
    }

    if (!mounted) return;

    setState(() {
      _code = code;
      _loading = false;
    });
  }

  String _generateCode() {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

    final now =
        DateTime.now().millisecondsSinceEpoch;

    String code = '';

    for (int i = 0; i < 6; i++) {
      code += chars[
          (now + i * 17) % chars.length];
    }

    return code;
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
          padding:
              const EdgeInsets.all(24),
          child: _loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Your Connection Code',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
                      decoration:
                          BoxDecoration(
                        borderRadius:
                            BorderRadius
                                .circular(16),
                        border:
                            Border.all(
                          width: 2,
                        ),
                      ),
                      child: Text(
                        _code ?? '------',
                        style:
                            const TextStyle(
                          fontSize: 36,
                          fontWeight:
                              FontWeight.bold,
                          letterSpacing: 6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Give this code to your '
                      'caregiver so they can '
                      'connect to your account.',
                      textAlign:
                          TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}