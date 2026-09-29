
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
import 'login_screen.dart';
=======
<<<<<<< HEAD
=======
>>>>>>> origin/main
import '../../services/care_circle_service.dart';
>>>>>>> main
=======
import '../../services/caregiver/care_circle_service.dart';

>>>>>>> develop

<<<<<<< HEAD
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedRole = 'elder';
  bool _isLoading = false;

<<<<<<< HEAD
  final Color _primaryColor = const Color(0xFF164A63);
  final Color _accentColor = const Color(0xFF16845B);
=======
  final AuthService _authService = AuthService();
  final CareCircleService _careCircleService = CareCircleService();

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // 1. Create the user using the updated signUp method
      final credential = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
        name: _nameController.text.trim(),
      );

      // 2. If Caregiver provided an invite code, link them to the Elder
      if (_selectedRole == 'caregiver' && _inviteCodeController.text.isNotEmpty) {
        await _careCircleService.linkCaregiverWithInviteCode(
          inviteCode: _inviteCodeController.text,
          caregiverUid: credential.user!.uid,
        );
      }

      // 3. Return to previous screen (AuthWrapper will auto-route to dashboard)
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup Failed: ${e.toString().split(']').last}')),
<<<<<<< HEAD
=======

=======
>>>>>>> origin/main
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
<<<<<<< HEAD
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService().registerUser(
        email: _emailController.text,
        password: _passwordController.text,
        role: _selectedRole,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
>>>>>>> main

  @override
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
  void dispose() {
=======
>>>>>>> origin/main
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _inviteCodeController.dispose();

    super.dispose();
  }

<<<<<<< HEAD
    void _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential = await AuthService().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
        name: _nameController.text.trim(),
        inviteCode: _selectedRole == 'caregiver'
            ? _inviteCodeController.text.trim()
            : null,
      );

      final user = credential.user;

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final bool isCaregiver = _selectedRole == 'caregiver';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Text(
                            '[Login]',
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        border: Border(
                          bottom: BorderSide(
                            color: _primaryColor,
                            width: 3,
                          ),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '[Register]',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Input: Full Name',
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Input: Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Input: Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (val) => val == null || val.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Account Role',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildRoleCard(
                              roleKey: 'elder',
                              title: '[ELDER USER]',
                              icon: Icons.accessible_forward,
                            ),
                            const SizedBox(height: 10),
                            _buildRoleCard(
                              roleKey: 'caregiver',
                              title: '[CAREGIVER]',
                              icon: Icons.health_and_safety,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (isCaregiver) ...[
                        TextFormField(
                          controller: _inviteCodeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'Input: Elder Invite Code (Optional)',
                            hintText: '6-character code e.g. AB12CD',
                            prefixIcon: const Icon(Icons.vpn_key),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                '[REGISTER]',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? '),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              '[Login]',
                              style: TextStyle(
                                color: _primaryColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
<<<<<<< HEAD
=======
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
=======
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
>>>>>>> origin/main

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
<<<<<<< HEAD
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
>>>>>>> origin/main
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleKey,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == roleKey;
    return InkWell(
      onTap: () => setState(() => _selectedRole = roleKey),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? _accentColor.withValues(alpha: 0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _accentColor : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? _accentColor : Colors.black87,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? _accentColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// BACKWARD COMPATIBILITY
// ================================================================

typedef SignupScreen = SignUpScreen;