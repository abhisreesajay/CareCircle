import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../services/admin/admin_service.dart';

class AdminUsersTab extends StatefulWidget {
  final AdminService adminService;

  const AdminUsersTab({
    super.key,
    required this.adminService,
  });

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  String _selectedRole = 'all';

  static const Color _backgroundColor = Color(0xFFF5F7FB);
  static const Color _primaryColor = Color(0xFF355070);
  static const Color _successColor = Color(0xFF2E7D5B);
  static const Color _dangerColor = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: widget.adminService.streamUsers(
                roleFilter: _selectedRole,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error);
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();

                    final uid = doc.id;

                    final name =
                        data['name']?.toString().trim();

                    final email =
                        data['email']?.toString().trim();

                    final role =
                        data['role']?.toString() ?? 'unknown';

                    final isDisabled =
                        data['disabled'] == true;

                    return _buildUserCard(
                      context,
                      uid: uid,
                      name: name?.isNotEmpty == true
                          ? name!
                          : email?.isNotEmpty == true
                              ? email!
                              : 'Unnamed User',
                      email: email ?? '',
                      role: role,
                      isDisabled: isDisabled,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 650;

        final titleSection = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.people_alt_outlined,
                color: _primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Accounts',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF172033),
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Manage registered CareCircle users and roles.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color: const Color(0xFF687386),
                        ),
                  ),
                ],
              ),
            ),
          ],
        );

        final filter = _buildRoleFilter(context);

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleSection,
              const SizedBox(height: 16),
              filter,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: titleSection),
            const SizedBox(width: 20),
            filter,
          ],
        );
      },
    );
  }

  Widget _buildRoleFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE1E6ED),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
          ),
          borderRadius: BorderRadius.circular(12),
          items: const [
            DropdownMenuItem(
              value: 'all',
              child: Row(
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Text('All Roles'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'admin',
              child: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Text('Admins'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'caregiver',
              child: Row(
                children: [
                  Icon(
                    Icons.volunteer_activism_outlined,
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Text('Caregivers'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'elder',
              child: Row(
                children: [
                  Icon(
                    Icons.elderly_outlined,
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Text('Elders'),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _selectedRole = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context, {
    required String uid,
    required String name,
    required String email,
    required String role,
    required bool isDisabled,
  }) {
    final validRole = const [
      'admin',
      'caregiver',
      'elder',
    ].contains(role);

    final displayRole = validRole ? role : 'unknown';

    final roleLabel = switch (displayRole) {
      'admin' => 'Admin',
      'caregiver' => 'Caregiver',
      'elder' => 'Elder',
      _ => 'Unknown',
    };

    final roleIcon = switch (displayRole) {
      'admin' => Icons.admin_panel_settings_outlined,
      'caregiver' => Icons.volunteer_activism_outlined,
      'elder' => Icons.elderly_outlined,
      _ => Icons.person_outline,
    };

    final roleColor = switch (displayRole) {
      'admin' => const Color(0xFF6D597A),
      'caregiver' => const Color(0xFF2E7D5B),
      'elder' => const Color(0xFF355070),
      _ => const Color(0xFF687386),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4E8EF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 700;

            if (isCompact) {
              return _buildCompactUserCard(
                context,
                uid: uid,
                name: name,
                email: email,
                role: role,
                displayRole: displayRole,
                roleLabel: roleLabel,
                roleIcon: roleIcon,
                roleColor: roleColor,
                isDisabled: isDisabled,
              );
            }

            return _buildDesktopUserCard(
              context,
              uid: uid,
              name: name,
              email: email,
              role: role,
              displayRole: displayRole,
              roleLabel: roleLabel,
              roleIcon: roleIcon,
              roleColor: roleColor,
              isDisabled: isDisabled,
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopUserCard(
    BuildContext context, {
    required String uid,
    required String name,
    required String email,
    required String role,
    required String displayRole,
    required String roleLabel,
    required IconData roleIcon,
    required Color roleColor,
    required bool isDisabled,
  }) {
    return Row(
      children: [
        _buildAvatar(
          name: name,
          roleColor: roleColor,
          roleIcon: roleIcon,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildUserInformation(
            context,
            uid: uid,
            name: name,
            email: email,
            roleLabel: roleLabel,
            roleColor: roleColor,
          ),
        ),
        const SizedBox(width: 20),
        _buildRoleDropdown(
          context,
          uid: uid,
          currentRole: role,
          displayRole: displayRole,
        ),
        const SizedBox(width: 20),
        _buildAccountStatus(
          context,
          uid: uid,
          isDisabled: isDisabled,
        ),
      ],
    );
  }

  Widget _buildCompactUserCard(
    BuildContext context, {
    required String uid,
    required String name,
    required String email,
    required String role,
    required String displayRole,
    required String roleLabel,
    required IconData roleIcon,
    required Color roleColor,
    required bool isDisabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildAvatar(
              name: name,
              roleColor: roleColor,
              roleIcon: roleIcon,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildUserInformation(
                context,
                uid: uid,
                name: name,
                email: email,
                roleLabel: roleLabel,
                roleColor: roleColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Divider(
          height: 1,
          color: Color(0xFFE8ECF1),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRoleDropdown(
                context,
                uid: uid,
                currentRole: role,
                displayRole: displayRole,
                expanded: true,
              ),
            ),
            const SizedBox(width: 12),
            _buildAccountStatus(
              context,
              uid: uid,
              isDisabled: isDisabled,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar({
    required String name,
    required Color roleColor,
    required IconData roleIcon,
  }) {
    final initial = name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : '?';

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: roleColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: roleColor,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInformation(
    BuildContext context, {
    required String uid,
    required String name,
    required String email,
    required String roleLabel,
    required Color roleColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF172033),
          ),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF687386),
            ),
          ),
        ],
        const SizedBox(height: 7),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                roleLabel,
                style: TextStyle(
                  color: roleColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                'UID: $uid',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF8A94A6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleDropdown(
    BuildContext context, {
    required String uid,
    required String currentRole,
    required String displayRole,
    bool expanded = false,
  }) {
    final validRole = const [
      'admin',
      'caregiver',
      'elder',
    ].contains(currentRole);

    return Container(
      width: expanded ? double.infinity : 155,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE1E6ED),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: validRole ? currentRole : null,
          isExpanded: expanded,
          hint: const Text(
            'Select Role',
            style: TextStyle(fontSize: 13),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 19,
          ),
          borderRadius: BorderRadius.circular(10),
          items: const [
            DropdownMenuItem(
              value: 'admin',
              child: Text(
                'Admin',
                style: TextStyle(fontSize: 13),
              ),
            ),
            DropdownMenuItem(
              value: 'caregiver',
              child: Text(
                'Caregiver',
                style: TextStyle(fontSize: 13),
              ),
            ),
            DropdownMenuItem(
              value: 'elder',
              child: Text(
                'Elder',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
          onChanged: (newRole) async {
            if (newRole == null ||
                newRole == currentRole) {
              return;
            }

            await _updateUserRole(
              context,
              uid,
              newRole,
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccountStatus(
    BuildContext context, {
    required String uid,
    required bool isDisabled,
  }) {
    final isActive = !isDisabled;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? _successColor.withValues(alpha: 0.08)
            : _dangerColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive
              ? _successColor.withValues(alpha: 0.18)
              : _dangerColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isActive ? 'Active' : 'Disabled',
            style: TextStyle(
              color: isActive
                  ? _successColor
                  : _dangerColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 5),
          Switch.adaptive(
            value: isActive,
            activeTrackColor: _successColor,
            onChanged: (enabled) async {
              await _toggleUserStatus(
                context,
                uid,
                enabled,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserRole(
    BuildContext context,
    String uid,
    String newRole,
  ) async {
    try {
      await widget.adminService.updateUserRole(
        uid,
        newRole,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'User role changed to $newRole.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _dangerColor,
          content: Text(
            'Failed to update role: $e',
          ),
        ),
      );
    }
  }

  Future<void> _toggleUserStatus(
    BuildContext context,
    String uid,
    bool enabled,
  ) async {
    try {
      await widget.adminService.toggleUserAccountStatus(
        uid,
        enabled,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            enabled
                ? 'User account enabled.'
                : 'User account disabled.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _dangerColor,
          content: Text(
            'Failed to update account status: $e',
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE4E8EF),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                size: 32,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Users Found',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No users match the selected role.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF687386),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 520,
        ),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFF0D4D4),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _dangerColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 31,
                color: _dangerColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to Load Users',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF687386),
              ),
            ),
          ],
        ),
      ),
    );
  }
}