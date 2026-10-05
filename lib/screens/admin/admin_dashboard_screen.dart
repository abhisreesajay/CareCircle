import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/admin/admin_service.dart';
import 'tabs/admin_overview_tab.dart';
import 'tabs/admin_users_tab.dart';
import 'tabs/admin_circles_tab.dart';
import 'tabs/admin_alerts_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();

  int _selectedIndex = 0;

  static const Color _navy = Color(0xFF172033);
  static const Color _blue = Color(0xFF4F7CFF);
  static const Color _background = Color(0xFFF5F7FB);

  static const List<String> _pageTitles = [
    'Overview',
    'Users',
    'Care Circles',
    'System Alerts',
  ];

  static const List<String> _pageDescriptions = [
    'Monitor the CareCircle platform at a glance.',
    'Manage platform users and their roles.',
    'View active elder-caregiver relationships.',
    'Monitor and manage active system alerts.',
  ];

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _selectPage(int index) {
    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return AdminOverviewTab(
          adminService: _adminService,
        );

      case 1:
        return AdminUsersTab(
          adminService: _adminService,
        );

      case 2:
        return AdminCirclesTab(
          adminService: _adminService,
        );

      case 3:
        return AdminAlertsTab(
          adminService: _adminService,
        );

      default:
        return AdminOverviewTab(
          adminService: _adminService,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isDesktop = width >= 1100;
        final bool isTablet = width >= 700;

        return Scaffold(
          backgroundColor: _background,
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSidebar(
                  isDesktop: isDesktop,
                  isTablet: isTablet,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopBar(
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),

                      Expanded(
                        child: Container(
                          color: _background,
                          child: _buildCurrentPage(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SIDEBAR
  // ============================================================

  Widget _buildSidebar({
    required bool isDesktop,
    required bool isTablet,
  }) {
    final double width;

    if (isDesktop) {
      width = 270;
    } else if (isTablet) {
      width = 220;
    } else {
      width = 76;
    }

    final bool showLabels = isDesktop || isTablet;

    return SizedBox(
      width: width,
      child: ColoredBox(
        color: _navy,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ----------------------------------------------------
            // BRAND
            // ----------------------------------------------------

            Padding(
              padding: EdgeInsets.fromLTRB(
                showLabels ? 24 : 10,
                22,
                showLabels ? 24 : 10,
                20,
              ),
              child: showLabels
                  ? Row(
                      children: [
                        _buildBrandIcon(),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CareCircle',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'ADMIN CONSOLE',
                                style: TextStyle(
                                  color: Color(0xFF8D99AE),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: _buildBrandIcon(),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),

            const SizedBox(height: 20),

            // ----------------------------------------------------
            // NAVIGATION
            // ----------------------------------------------------

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: showLabels ? 14 : 8,
                ),
                child: Column(
                  children: [
                    if (showLabels)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 12,
                            bottom: 10,
                          ),
                          child: Text(
                            'WORKSPACE',
                            style: TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),

                    _buildNavItem(
                      index: 0,
                      icon: Icons.dashboard_outlined,
                      selectedIcon: Icons.dashboard_rounded,
                      label: 'Overview',
                      showLabel: showLabels,
                    ),

                    _buildNavItem(
                      index: 1,
                      icon: Icons.people_outline_rounded,
                      selectedIcon: Icons.people_rounded,
                      label: 'Users',
                      showLabel: showLabels,
                    ),

                    _buildNavItem(
                      index: 2,
                      icon: Icons.diversity_3_outlined,
                      selectedIcon: Icons.diversity_3_rounded,
                      label: 'Care Circles',
                      showLabel: showLabels,
                    ),

                    _buildNavItem(
                      index: 3,
                      icon: Icons.notifications_none_rounded,
                      selectedIcon: Icons.notifications_rounded,
                      label: 'System Alerts',
                      showLabel: showLabels,
                      alert: true,
                    ),
                  ],
                ),
              ),
            ),

            // ----------------------------------------------------
            // ADMIN ACCOUNT
            // ----------------------------------------------------

            Padding(
              padding: EdgeInsets.fromLTRB(
                showLabels ? 16 : 8,
                10,
                showLabels ? 16 : 8,
                16,
              ),
              child: showLabels
                  ? _buildExpandedAdminCard()
                  : _buildCompactAdminCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Icon(
        Icons.favorite_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildExpandedAdminCard() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administrator',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Platform Admin',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF8D99AE),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Sign Out',
            onPressed: _signOut,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 34,
              minHeight: 34,
            ),
            icon: const Icon(
              Icons.logout_rounded,
              size: 19,
              color: Color(0xFFB6BFCE),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactAdminCard() {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: _signOut,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Color(0xFFB6BFCE),
              size: 21,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION ITEM
  // ============================================================

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool showLabel,
    bool alert = false,
  }) {
    final bool selected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: () => _selectPage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            height: 50,
            padding: EdgeInsets.symmetric(
              horizontal: showLabel ? 13 : 0,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? _blue
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              mainAxisAlignment: showLabel
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  size: 22,
                  color: selected
                      ? Colors.white
                      : alert
                          ? const Color(0xFFE56B6F)
                          : const Color(0xFFAAB3C2),
                ),

                if (showLabel) ...[
                  const SizedBox(width: 13),

                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFFCBD2DD),
                        fontSize: 13.5,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),

                  if (alert && !selected)
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE56B6F),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar({
    required bool isDesktop,
    required bool isTablet,
  }) {
    final bool showActions = isDesktop || isTablet;

    return Container(
      height: 82,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 30
            : isTablet
                ? 22
                : 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8ECF2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pageTitles[_selectedIndex],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _pageDescriptions[_selectedIndex],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF7A8496),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),

          if (showActions)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEFFAF3),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: const Color(0xFFD8F0E0),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: Color(0xFF2EAD67),
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Platform Online',
                    style: TextStyle(
                      color: Color(0xFF267B4D),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(width: 10),

          SizedBox(
            width: 42,
            height: 42,
            child: Material(
              color: const Color(0xFFF4F6FA),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {});
                },
                child: const Icon(
                  Icons.refresh_rounded,
                  size: 21,
                  color: Color(0xFF4D586B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}