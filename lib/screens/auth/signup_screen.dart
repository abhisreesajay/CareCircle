
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/care_circle_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
  });

  @override
  State<SignUpScreen> createState() =>
      _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final TextEditingController _inviteCodeController =
      TextEditingController();

  final AuthService _authService =
      AuthService();

  final CareCircleService _careCircleService =
      CareCircleService();

  String _selectedRole = 'elder';

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _inviteCodeController.dispose();

    super.dispose();
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String name =
        _nameController.text.trim();

    final String email =
        _emailController.text.trim();

    final String password =
        _passwordController.text;

    final String inviteCode =
        _inviteCodeController.text
            .trim()
            .toUpperCase();

    setState(() {
      _isLoading = true;
    });

    try {
      // ----------------------------------------------------------
      // CREATE FIREBASE ACCOUNT
      // ----------------------------------------------------------

      final credential =
          await _authService.signUp(
        email: email,
        password: password,
        role: _selectedRole,
        name: name,
      );

      final firebaseUser =
          credential.user;

      if (firebaseUser == null) {
        throw Exception(
          'Account creation failed.',
        );
      }

      // ----------------------------------------------------------
      // CAREGIVER CONNECTION
      // ----------------------------------------------------------

      if (_selectedRole == 'caregiver') {
        if (inviteCode.isEmpty) {
          throw Exception(
            'Please enter the elder invite code.',
          );
        }

        await _careCircleService
            .linkCaregiverWithInviteCode(
          inviteCode: inviteCode,
          caregiverUid: firebaseUser.uid,
        );
      }

      if (!mounted) {
        return;
      }

      // AuthWrapper in main.dart will detect
      // the Firebase authentication state.
      Navigator.pop(context);

      // ----------------------------------------------------------
      // SUCCESS MESSAGE
      // ----------------------------------------------------------

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _selectedRole == 'caregiver'
                ? 'Caregiver account created and connected to the elder.'
                : 'Elder account created successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      final String errorMessage =
          e.toString().replaceFirst(
                'Exception: ',
                '',
              );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Signup Failed: $errorMessage',
          ),
          backgroundColor:
              Theme.of(context)
                  .colorScheme
                  .error,
          duration:
              const Duration(seconds: 5),
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [

                  // ==================================================
                  // HEADER
                  // ==================================================

                  Text(
                    'Join CareCircle',
                    style: theme
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                      color:
                          theme.colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Create your CareCircle account and select your role.',
                    style: theme
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // NAME
                  // ==================================================

                  TextFormField(
                    controller:
                        _nameController,
                    textInputAction:
                        TextInputAction.next,
                    decoration:
                        InputDecoration(
                      labelText:
                          'Full Name',
                      prefixIcon:
                          const Icon(
                        Icons
                            .person_outline,
                      ),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter your name';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // ROLE
                  // ==================================================

                  Text(
                    'I am signing up as:',
                    style: theme
                        .textTheme
                        .labelLarge
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'elder',
                        label:
                            Text('Elder'),
                        icon: Icon(
                          Icons.elderly,
                        ),
                      ),
                      ButtonSegment<String>(
                        value: 'caregiver',
                        label:
                            Text('Caregiver'),
                        icon: Icon(
                          Icons
                              .medical_services_outlined,
                        ),
                      ),
                    ],
                    selected: {
                      _selectedRole,
                    },
                    onSelectionChanged:
                        (Set<String>
                            selection) {
                      setState(() {
                        _selectedRole =
                            selection.first;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // EMAIL
                  // ==================================================

                  TextFormField(
                    controller:
                        _emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    textInputAction:
                        TextInputAction.next,
                    decoration:
                        InputDecoration(
                      labelText:
                          'Email Address',
                      prefixIcon:
                          const Icon(
                        Icons
                            .email_outlined,
                      ),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter an email';
                      }

                      if (!RegExp(
                        r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(
                        value.trim(),
                      )) {
                        return 'Enter a valid email address';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // PASSWORD
                  // ==================================================

                  TextFormField(
                    controller:
                        _passwordController,
                    obscureText:
                        _obscurePassword,
                    textInputAction:
                        TextInputAction.next,
                    decoration:
                        InputDecoration(
                      labelText:
                          'Password',
                      prefixIcon:
                          const Icon(
                        Icons.lock_outline,
                      ),
                      suffixIcon:
                          IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons
                                  .visibility_off
                              : Icons
                                  .visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                      ),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Please enter a password';
                      }

                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // CONFIRM PASSWORD
                  // ==================================================

                  TextFormField(
                    controller:
                        _confirmPasswordController,
                    obscureText:
                        _obscureConfirmPassword,
                    textInputAction:
                        TextInputAction.next,
                    decoration:
                        InputDecoration(
                      labelText:
                          'Confirm Password',
                      prefixIcon:
                          const Icon(
                        Icons.lock_reset,
                      ),
                      suffixIcon:
                          IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons
                                  .visibility_off
                              : Icons
                                  .visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Please confirm your password';
                      }

                      if (value !=
                          _passwordController
                              .text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                    onFieldSubmitted:
                        (_) => _handleSignUp(),
                  ),

                  // ==================================================
                  // CAREGIVER INVITE CODE
                  // ==================================================

                  if (_selectedRole ==
                      'caregiver') ...[
                    const SizedBox(height: 20),

                    Container(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      decoration:
                          BoxDecoration(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                        color: theme
                            .colorScheme
                            .primary
                            .withValues(
                          alpha: 0.06,
                        ),
                        border:
                            Border.all(
                          color: theme
                              .colorScheme
                              .primary
                              .withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [

                          Row(
                            children: [
                              Icon(
                                Icons
                                    .link_rounded,
                                color: theme
                                    .colorScheme
                                    .primary,
                              ),

                              const SizedBox(
                                width: 10,
                              ),

                              Expanded(
                                child: Text(
                                  'Connect to Elder',
                                  style: theme
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            'Enter the 6-character invite code provided by the elder. You will be connected immediately after creating your account.',
                            style: theme
                                .textTheme
                                .bodyMedium,
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          TextFormField(
                            controller:
                                _inviteCodeController,
                            textInputAction:
                                TextInputAction
                                    .done,
                            textCapitalization:
                                TextCapitalization
                                    .characters,
                            maxLength: 6,
                            decoration:
                                InputDecoration(
                              labelText:
                                  'Elder Invite Code',
                              hintText:
                                  'Example: AB12CD',
                              prefixIcon:
                                  const Icon(
                                Icons
                                    .vpn_key_outlined,
                              ),
                              counterText:
                                  '',
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),
                            ),
                            validator:
                                (value) {
                              if (_selectedRole !=
                                  'caregiver') {
                                return null;
                              }

                              final String
                                  code =
                                  value
                                      ?.trim() ??
                                      '';

                              if (code.isEmpty) {
                                return 'Please enter the elder invite code';
                              }

                              if (code.length !=
                                  6) {
                                return 'Invite code must contain 6 characters';
                              }

                              return null;
                            },
                            onChanged:
                                (value) {
                              final String
                                  upper =
                                  value
                                      .toUpperCase();

                              if (value !=
                                  upper) {
                                _inviteCodeController
                                  ..text =
                                      upper
                                  ..selection =
                                      TextSelection
                                          .fromPosition(
                                    TextPosition(
                                      offset:
                                          upper.length,
                                    ),
                                  );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // ==================================================
                  // CREATE ACCOUNT
                  // ==================================================

                  SizedBox(
                    height: 54,
                    child:
                        ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : _handleSignUp,
                      style:
                          ElevatedButton.styleFrom(
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                        backgroundColor:
                            theme
                                .colorScheme
                                .primary,
                        foregroundColor:
                            theme
                                .colorScheme
                                .onPrimary,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style:
                                  TextStyle(
                                fontSize:
                                    16,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// BACKWARD COMPATIBILITY
// ================================================================

typedef SignupScreen = SignUpScreen;