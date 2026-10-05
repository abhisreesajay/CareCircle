import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String? role;

  const ProfileScreen({super.key, this.role});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  String _email = '';
  String _role = 'user';
  String? _inviteCode;
  List<String> _linkedElders = [];
  List<String> _caregivers = [];

  static const Color _blue = Color(0xFF356DFF);
  static const Color _navy = Color(0xFF172B4D);
  static const Color _background = Color(0xFFF4F7FD);

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _user;

    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data() ?? <String, dynamic>{};

      if (!mounted) return;

      setState(() {
        _email = (data['email'] as String?) ?? user.email ?? '';
        _role = widget.role ?? (data['role'] as String?) ?? 'user';

        _nameController.text =
            (data['name'] as String?) ?? user.displayName ?? '';

        _inviteCode = data['inviteCode'] as String?;

        _linkedElders =
            (data['linkedElders'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [];

        _caregivers =
            (data['caregivers'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [];
      });
    } catch (e) {
      _message('Could not load profile: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveName() async {
    final user = _user;
    final name = _nameController.text.trim();

    if (user == null || name.isEmpty) {
      _message('Please enter your name.');
      return;
    }

    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'name': name}, SetOptions(merge: true));

      await user.updateDisplayName(name);

      if (mounted) _message('Profile updated successfully.');
    } catch (e) {
      if (mounted) _message('Could not update profile: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String get _roleLabel {
    if (_role.isEmpty) return 'User';
    return '${_role[0].toUpperCase()}${_role.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE7ECF5)),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _blue),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // PROFILE HEADER
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF356DFF),
                        Color(0xFF244CCB),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _blue.withValues(alpha: 0.20),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.7),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 49,
                          color: _blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _nameController.text.trim().isEmpty
                            ? 'Welcome to CareCircle'
                            : _nameController.text.trim(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.17),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              '$_roleLabel Account',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const _SectionHeading(
                  title: 'Personal information',
                  subtitle: 'Manage your account details',
                ),

                const SizedBox(height: 14),

                _ProfileCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(
                          label: 'Full name',
                          icon: Icons.badge_outlined,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        key: ValueKey(_email),
                        initialValue: _email,
                        readOnly: true,
                        decoration: _inputDecoration(
                          label: 'Email address',
                          icon: Icons.alternate_email_rounded,
                        ).copyWith(
                          helperText:
                              'Email changes require a separate verified flow.',
                        ),
                      ),
                    ],
                  ),
                ),

                if (_inviteCode != null && _inviteCode!.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  const _SectionHeading(
                    title: 'Account details',
                    subtitle: 'Your CareCircle information',
                  ),
                  const SizedBox(height: 14),
                  _InfoTile(
                    icon: Icons.qr_code_rounded,
                    title: 'Invite code',
                    value: _inviteCode!,
                  ),
                ],

                if (_role == 'caregiver') ...[
                  const SizedBox(height: 14),
                  _InfoTile(
                    icon: Icons.people_alt_rounded,
                    title: 'Connected elders',
                    value: '${_linkedElders.length}',
                  ),
                ],

                if (_role == 'elder') ...[
                  const SizedBox(height: 14),
                  _InfoTile(
                    icon: Icons.volunteer_activism_rounded,
                    title: 'Connected caregivers',
                    value: '${_caregivers.length}',
                  ),
                ],

                const SizedBox(height: 28),

                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _saveName,
                    style: FilledButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: _saving
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(
                      _saving ? 'Saving changes...' : 'Save changes',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _blue),
      filled: true,
      fillColor: const Color(0xFFF7F9FE),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE3EAF6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE3EAF6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _blue, width: 1.5),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF172B4D),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF7A879C),
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Widget child;

  const _ProfileCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7ECF5)),
      ),
      child: child,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE7ECF5)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF356DFF)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF7A879C),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF172B4D),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}