import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/caregiver/care_circle_service.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _inviteCodeController = TextEditingController(); 

  String _selectedRole = 'caregiver'; // Default role
  bool _isLoading = false;

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
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty || !v.contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'Password must be 6+ chars' : null,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(labelText: 'I am a...', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'caregiver', child: Text('Caregiver (I monitor an elder)')),
                  DropdownMenuItem(value: 'elder', child: Text('Elder (I need the simplified app)')),
                ],
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              if (_selectedRole == 'caregiver') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _inviteCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Elder Invite Code (Optional)',
                    hintText: 'Enter 6-character code to link now',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Sign Up', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
