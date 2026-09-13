import 'package:flutter/material.dart';
// Note: Import your AuthService here based on your file structure
// import '../../services/auth_service.dart'; 

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'elder'; // Default role

  void _signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    
    // TODO: Call your AuthService here
    // await AuthService().registerUser(email, password, _selectedRole);
    print('Signing up $email as $_selectedRole');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CareCircle - Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedRole,
              items: [
                DropdownMenuItem(value: 'elder', child: Text('I am an Elder')),
                DropdownMenuItem(value: 'caregiver', child: Text('I am a Caregiver')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
