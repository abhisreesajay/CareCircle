import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/caregiver/care_circle_service.dart';

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
  final CareCircleService _service =
      CareCircleService();

  String? _code;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrCreateCode();
  }

  Future<void> _loadOrCreateCode() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final codeSnapshot =
          await _getUserDocument(user.uid);

      final existing =
          codeSnapshot['inviteCode']
              ?.toString()
              .trim();

      if (existing != null &&
          existing.isNotEmpty) {
        if (mounted) {
          setState(() {
            _code = existing;
            _loading = false;
          });
        }
        return;
      }

      final String newCode =
          await _service.createElderInviteCode(
        user.uid,
      );

      if (mounted) {
        setState(() {
          _code = newCode;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>>
      _getUserDocument(
    String uid,
  ) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

    return snapshot.data() ?? {};
  }

  Future<void> _generateNewCode() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() {
      _loading = true;
    });

    try {
      final String code =
          await _service.createElderInviteCode(
        user.uid,
      );

      if (mounted) {
        setState(() {
          _code = code;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Could not create code: $e',
            ),
          ),
        );
      }
    }
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
          'Caregiver Connection',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _loading
                ? const CircularProgressIndicator(
                    color:
                        Color(0xFF46695A),
                  )
                : Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_alt_rounded,
                        size: 70,
                        color:
                            Color(0xFF46695A),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      const Text(
                        'Your CareCircle Code',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              Color(0xFF26352F),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      const Text(
                        'Give this code to your caregiver so they can connect to your account.',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color:
                              Color(0xFF7A827D),
                        ),
                      ),

                      const SizedBox(
                        height: 35,
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 28,
                          vertical: 22,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFFFFBF4,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            24,
                          ),
                        ),
                        child: Text(
                          _code ?? '------',
                          style:
                              const TextStyle(
                            fontSize: 38,
                            letterSpacing: 7,
                            fontWeight:
                                FontWeight.w900,
                            color:
                                Color(
                              0xFF46695A,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      OutlinedButton.icon(
                        onPressed:
                            _generateNewCode,
                        icon: const Icon(
                          Icons.refresh,
                        ),
                        label: const Text(
                          'Generate New Code',
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