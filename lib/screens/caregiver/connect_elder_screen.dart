import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/caregiver/care_circle_service.dart';
import '../../services/messaging_service.dart';

class CaregiverConnectElderScreen
    extends StatefulWidget {
  const CaregiverConnectElderScreen({
    super.key,
  });

  @override
  State<CaregiverConnectElderScreen>
      createState() =>
          _CaregiverConnectElderScreenState();
}

class _CaregiverConnectElderScreenState
    extends State<CaregiverConnectElderScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _codeController =
      TextEditingController();

  final _careCircleService =
      CareCircleService();

  final _messagingService =
      MessagingService();

  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _messagingService.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please log in again.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _careCircleService
          .linkCaregiverToElder(
        caregiverUid: user.uid,
        inviteCode:
            _codeController.text
                .trim()
                .toUpperCase(),
      );

      if (!mounted) return;

      _showMessage(
        'Caregiver connected successfully.',
      );

      _codeController.clear();

      // RoleRouter listens to the caregiver
      // document and will automatically open
      // the caregiver dashboard.
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString()
            .replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user != null) {
      await _messagingService
          .removeToken(user.uid);
    }

    await AuthService().signOut();
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
      appBar: AppBar(
        title: const Text(
          'Connect to Elder',
        ),
        actions: [
          IconButton(
            onPressed: _isLoading
                ? null
                : _logout,
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                const Icon(
                  Icons.link,
                  size: 70,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Connect to an Elder',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Ask the elder for their '
                  '6-character CareCircle '
                  'connection code.',
                  textAlign:
                      TextAlign.center,
                ),

                const SizedBox(height: 32),

                TextFormField(
                  controller:
                      _codeController,
                  textCapitalization:
                      TextCapitalization
                          .characters,
                  maxLength: 6,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Connection Code',
                    hintText: 'ABC123',
                    border:
                        OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final code =
                        value
                            ?.trim()
                            .toUpperCase() ??
                            '';

                    if (code.isEmpty) {
                      return 'Enter the connection code';
                    }

                    if (code.length != 6) {
                      return 'Code must contain 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _connect,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Connect',
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