import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String? role;

  const SettingsScreen({super.key, this.role});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _medicationReminders = true;
  bool _checkInReminders = true;
  bool _sosAlerts = true;

  static const Color _blue = Color(0xFF356DFF);
  static const Color _navy = Color(0xFF172B4D);
  static const Color _background = Color(0xFFF4F7FD);

  Future<void> _changePassword() async {
    final controller = TextEditingController();

    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Change password',
          style: TextStyle(
            color: _navy,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'New password',
            helperText: 'Use at least 6 characters.',
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: _blue,
            ),
            filled: true,
            fillColor: _background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: _blue,
                width: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _blue,
            ),
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (password == null || !mounted) return;

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(password);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      final message = e.code == 'requires-recent-login'
          ? 'Sign in again before changing your password.'
          : (e.message ?? 'Could not update password.');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Sign out?',
          style: TextStyle(
            color: _navy,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'You will need to sign in again to access CareCircle.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE34D59),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role ?? 'user';

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE7ECF5)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // SETTINGS HEADER
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF356DFF),
                  Color(0xFF244CCB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(23),
              boxShadow: [
                BoxShadow(
                  color: _blue.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.settings_rounded,
                  color: Colors.white,
                  size: 38,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Make it yours',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Manage your account and preferences.',
                        style: TextStyle(
                          color: Color(0xFFE2EAFF),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          _section('ACCOUNT', 'Your profile and security'),

          const SizedBox(height: 12),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.person_rounded,
                title: 'My profile',
                subtitle: 'Edit your name and account details',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(role: role),
                    ),
                  );
                },
              ),
              const _TileDivider(),
              _SettingsTile(
                icon: Icons.lock_rounded,
                title: 'Change password',
                subtitle: 'Keep your account secure',
                onTap: _changePassword,
              ),
            ],
          ),

          const SizedBox(height: 28),

          _section('NOTIFICATIONS', 'Choose your reminder preferences'),

          const SizedBox(height: 12),

          _SettingsCard(
            children: [
              _SettingsSwitchTile(
                icon: Icons.medication_rounded,
                title: 'Medication reminders',
                subtitle: 'Stay on track with medications',
                value: _medicationReminders,
                onChanged: (value) {
                  setState(() => _medicationReminders = value);
                },
              ),
              const _TileDivider(),
              _SettingsSwitchTile(
                icon: Icons.event_available_rounded,
                title: 'Check-in reminders',
                subtitle: 'Keep up with regular check-ins',
                value: _checkInReminders,
                onChanged: (value) {
                  setState(() => _checkInReminders = value);
                },
              ),
              if (role != 'admin') ...[
                const _TileDivider(),
                _SettingsSwitchTile(
                  icon: Icons.sos_rounded,
                  title: 'SOS alerts',
                  subtitle: 'Emergency notification preference',
                  value: _sosAlerts,
                  onChanged: (value) {
                    setState(() => _sosAlerts = value);
                  },
                ),
              ],
            ],
          ),

          const SizedBox(height: 28),

          _section('ABOUT', 'A little about CareCircle'),

          const SizedBox(height: 12),

          _SettingsCard(
            children: [
              const _SettingsTile(
                icon: Icons.favorite_rounded,
                title: 'CareCircle',
                subtitle: 'Care and connection in one place',
              ),
            ],
          ),

          const SizedBox(height: 28),

          OutlinedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
            label: const Text(
              'Sign out',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD94350),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFF1CDD1)),
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _section(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _blue,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: _navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7ECF5)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF0FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: const Color(0xFF356DFF)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF172B4D),
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF7A879C),
            fontSize: 12,
          ),
        ),
      ),
      trailing: onTap == null
          ? null
          : const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF8B9AB3),
            ),
      onTap: onTap,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 7,
      ),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF0FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: const Color(0xFF356DFF)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF172B4D),
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF7A879C),
            fontSize: 12,
          ),
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeTrackColor: const Color(0xFF356DFF),
        onChanged: onChanged,
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Color(0xFFEDF0F6)),
    );
  }
}