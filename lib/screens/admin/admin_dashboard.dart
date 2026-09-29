import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
  });

  @override
  State<AdminDashboard> createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState
    extends State<AdminDashboard> {
  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  int _selectedPage = 0;

  String _searchText = '';

  String _roleFilter = 'all';

  bool _checkingAccess = true;

  bool _isAdmin = false;

  String _adminName = 'Administrator';

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  // ============================================================
  // ADMIN ACCESS
  // ============================================================

  Future<void> _checkAdminAccess() async {
    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _checkingAccess = false;
          _isAdmin = false;
        });

        return;
      }

      final DocumentSnapshot<
          Map<String, dynamic>> snapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .get();

      if (!snapshot.exists) {
        if (!mounted) return;

        setState(() {
          _checkingAccess = false;
          _isAdmin = false;
        });

        return;
      }

      final Map<String, dynamic> data =
          snapshot.data() ?? {};

      final String role =
          data['role']
                  ?.toString()
                  .toLowerCase()
                  .trim() ??
              '';

      final String name =
          data['name']?.toString().trim() ??
              data['displayName']
                  ?.toString()
                  .trim() ??
              'Administrator';

      if (!mounted) return;

      setState(() {
        _checkingAccess = false;
        _isAdmin = role == 'admin';
        _adminName =
            name.isEmpty ? 'Administrator' : name;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _checkingAccess = false;
        _isAdmin = false;
      });
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    try {
      await _auth.signOut();

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to sign out: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      final DateTime date =
          value.toDate();

      final String day =
          date.day
              .toString()
              .padLeft(2, '0');

      final String month =
          date.month
              .toString()
              .padLeft(2, '0');

      final String hour =
          date.hour
              .toString()
              .padLeft(2, '0');

      final String minute =
          date.minute
              .toString()
              .padLeft(2, '0');

      return '$day/$month/${date.year} '
          '$hour:$minute';
    }

    return 'Not available';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_checkingAccess) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAdmin) {
      return _buildAccessDenied();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CareCircle Admin',
        ),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: const [
                      Icon(
                        Icons.logout,
                      ),
                      SizedBox(width: 10),
                      Text('Logout'),
                    ],
                  ),
                ),
              ];
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 17,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _adminName,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide =
              constraints.maxWidth >= 900;

          if (isWide) {
            return Row(
              children: [
                _buildNavigationRail(),
                Expanded(
                  child: _buildPage(),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildMobileNavigation(),
              Expanded(
                child: _buildPage(),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // ACCESS DENIED
  // ============================================================

  Widget _buildAccessDenied() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.all(24),
                decoration:
                    BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red
                      .withOpacity(0.10),
                ),
                child: const Icon(
                  Icons
                      .lock_outline,
                  size: 60,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Admin Access Required',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This account does not have administrator '
                'permissions.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _logout,
                icon: const Icon(
                  Icons.arrow_back,
                ),
                label: const Text(
                  'Return to Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION RAIL
  // ============================================================

  Widget _buildNavigationRail() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context)
                .dividerColor,
          ),
        ),
      ),
      child: NavigationRail(
        extended: true,
        selectedIndex:
            _selectedPage,
        onDestinationSelected:
            (int index) {
          setState(() {
            _selectedPage = index;
          });
        },
        leading: Padding(
          padding:
              const EdgeInsets.only(
            top: 20,
            bottom: 20,
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                child: const Icon(
                  Icons
                      .admin_panel_settings,
                  size: 30,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Administration',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        destinations: const [
          NavigationRailDestination(
            icon: Icon(
              Icons.dashboard_outlined,
            ),
            selectedIcon: Icon(
              Icons.dashboard,
            ),
            label: Text('Overview'),
          ),
          NavigationRailDestination(
            icon: Icon(
              Icons.people_outline,
            ),
            selectedIcon: Icon(
              Icons.people,
            ),
            label: Text('Users'),
          ),
          NavigationRailDestination(
            icon: Icon(
              Icons.health_and_safety_outlined,
            ),
            selectedIcon: Icon(
              Icons.health_and_safety,
            ),
            label: Text('Safety'),
          ),
          NavigationRailDestination(
            icon: Icon(
              Icons.notifications_none,
            ),
            selectedIcon: Icon(
              Icons.notifications,
            ),
            label: Text('Alerts'),
          ),
          NavigationRailDestination(
            icon: Icon(
              Icons.settings_outlined,
            ),
            selectedIcon: Icon(
              Icons.settings,
            ),
            label: Text('Settings'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE NAVIGATION
  // ============================================================

  Widget _buildMobileNavigation() {
    return Material(
      elevation: 1,
      child: SingleChildScrollView(
        scrollDirection:
            Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        child: Row(
          children: [
            _mobileNavButton(
              0,
              Icons.dashboard,
              'Overview',
            ),
            _mobileNavButton(
              1,
              Icons.people,
              'Users',
            ),
            _mobileNavButton(
              2,
              Icons.health_and_safety,
              'Safety',
            ),
            _mobileNavButton(
              3,
              Icons.notifications,
              'Alerts',
            ),
            _mobileNavButton(
              4,
              Icons.settings,
              'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileNavButton(
    int index,
    IconData icon,
    String label,
  ) {
    final bool selected =
        _selectedPage == index;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) {
          setState(() {
            _selectedPage = index;
          });
        },
        avatar: Icon(
          icon,
          size: 18,
        ),
        label: Text(label),
      ),
    );
  }

  // ============================================================
  // PAGE ROUTER
  // ============================================================

  Widget _buildPage() {
    switch (_selectedPage) {
      case 1:
        return _buildUsersPage();

      case 2:
        return _buildSafetyPage();

      case 3:
        return _buildAlertsPage();

      case 4:
        return _buildSettingsPage();

      default:
        return _buildOverviewPage();
    }
  }

  // ============================================================
  // OVERVIEW PAGE
  // ============================================================

  Widget _buildOverviewPage() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('users')
          .snapshots(),
      builder:
          (context, userSnapshot) {
        return StreamBuilder<
            QuerySnapshot<
                Map<String, dynamic>>>(
          stream: _firestore
              .collection(
                'safeZoneViolations',
              )
              .where(
                'status',
                isEqualTo: 'active',
              )
              .snapshots(),
          builder:
              (context, violationSnapshot) {
            return StreamBuilder<
                QuerySnapshot<
                    Map<String, dynamic>>>(
              stream: _firestore
                  .collection(
                    'sosAlerts',
                  )
                  .where(
                    'status',
                    isEqualTo: 'active',
                  )
                  .snapshots(),
              builder:
                  (context, sosSnapshot) {
                if (userSnapshot
                        .connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final List<
                        QueryDocumentSnapshot<
                            Map<String,
                                dynamic>>>
                    users =
                    userSnapshot.data?.docs ??
                        [];

                int elders = 0;
                int caregivers = 0;
                int admins = 0;

                for (final document
                    in users) {
                  final data =
                      document.data();

                  final role =
                      data['role']
                              ?.toString()
                              .toLowerCase() ??
                          '';

                  if (role == 'elder') {
                    elders++;
                  } else if (role ==
                      'caregiver') {
                    caregivers++;
                  } else if (role ==
                      'admin') {
                    admins++;
                  }
                }

                final int activeGeofence =
                    violationSnapshot
                            .data
                            ?.docs
                            .length ??
                        0;

                final int activeSos =
                    sosSnapshot
                            .data
                            ?.docs
                            .length ??
                        0;

                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      _buildWelcomeHeader(),
                      const SizedBox(
                        height: 24,
                      ),

                      _buildStatsGrid(
                        totalUsers:
                            users.length,
                        elders: elders,
                        caregivers:
                            caregivers,
                        admins: admins,
                        activeSos:
                            activeSos,
                        activeGeofence:
                            activeGeofence,
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      _buildQuickActions(),

                      const SizedBox(
                        height: 28,
                      ),

                      _buildRecentUsers(
                        users,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ============================================================
  // WELCOME HEADER
  // ============================================================

  Widget _buildWelcomeHeader() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Good day, $_adminName',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                'Monitor CareCircle users, safety activity '
                'and system status from one place.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(
                        0.65,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(14),
            color: Colors.green
                .withOpacity(0.10),
          ),
          child: const Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                size: 11,
                color: Colors.green,
              ),
              SizedBox(width: 8),
              Text(
                'System connected',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStatsGrid({
    required int totalUsers,
    required int elders,
    required int caregivers,
    required int admins,
    required int activeSos,
    required int activeGeofence,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 1;

        if (constraints.maxWidth >=
            1200) {
          columns = 4;
        } else if (constraints
                .maxWidth >=
            700) {
          columns = 2;
        }

        final double width =
            (constraints.maxWidth -
                    ((columns - 1) * 14)) /
                columns;

        final cards = [
          _statCard(
            width: width,
            title: 'Total Users',
            value: '$totalUsers',
            icon: Icons.people,
            subtitle:
                'All registered accounts',
          ),
          _statCard(
            width: width,
            title: 'Elders',
            value: '$elders',
            icon: Icons.elderly,
            subtitle:
                'Elder accounts',
          ),
          _statCard(
            width: width,
            title: 'Caregivers',
            value: '$caregivers',
            icon: Icons.support_agent,
            subtitle:
                'Caregiver accounts',
          ),
          _statCard(
            width: width,
            title: 'Active SOS',
            value: '$activeSos',
            icon: Icons.warning_amber,
            subtitle:
                activeSos == 0
                    ? 'No active SOS alerts'
                    : 'Requires attention',
          ),
          _statCard(
            width: width,
            title: 'Safe-Zone Alerts',
            value: '$activeGeofence',
            icon: Icons.location_off,
            subtitle:
                activeGeofence == 0
                    ? 'No active violations'
                    : 'Active violations',
          ),
          _statCard(
            width: width,
            title: 'Administrators',
            value: '$admins',
            icon:
                Icons.admin_panel_settings,
            subtitle:
                'Admin accounts',
          ),
        ];

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: cards,
        );
      },
    );
  }

  Widget _statCard({
    required double width,
    required String title,
    required String value,
    required IconData icon,
    required String subtitle,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 1,
        child: Padding(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets
                            .all(11),
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .primary
                          .withOpacity(
                            0.10,
                          ),
                    ),
                    child: Icon(
                      icon,
                      color:
                          Theme.of(
                        context,
                      )
                              .colorScheme
                              .primary,
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(
                      context,
                    )
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              Text(
                title,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                subtitle,
                style:
                    TextStyle(
                  color:
                      Theme.of(
                    context,
                  )
                          .colorScheme
                          .onSurface
                          .withOpacity(
                            0.60,
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _quickAction(
              icon: Icons.people,
              title: 'Manage Users',
              onTap: () {
                setState(() {
                  _selectedPage = 1;
                });
              },
            ),
            _quickAction(
              icon:
                  Icons.health_and_safety,
              title: 'Safety Monitor',
              onTap: () {
                setState(() {
                  _selectedPage = 2;
                });
              },
            ),
            _quickAction(
              icon: Icons.notifications,
              title: 'View Alerts',
              onTap: () {
                setState(() {
                  _selectedPage = 3;
                });
              },
            ),
            _quickAction(
              icon: Icons.settings,
              title: 'System Settings',
              onTap: () {
                setState(() {
                  _selectedPage = 4;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 190,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(title),
        style:
            OutlinedButton.styleFrom(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RECENT USERS
  // ============================================================

  Widget _buildRecentUsers(
    List<QueryDocumentSnapshot<
            Map<String, dynamic>>>
        users,
  ) {
    final List<
            QueryDocumentSnapshot<
                Map<String, dynamic>>>
        recentUsers =
        users.length <= 8
            ? users
            : users.sublist(
                users.length - 8,
              );

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Text(
                  'Registered Users',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedPage = 1;
                    });
                  },
                  child:
                      const Text('View all'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (recentUsers.isEmpty)
              const Padding(
                padding:
                    EdgeInsets.symmetric(
                  vertical: 20,
                ),
                child: Text(
                  'No users found.',
                ),
              )
            else
              Column(
                children:
                    recentUsers
                        .reversed
                        .map(
                          (document) {
                    return _userTile(
                      document,
                    );
                  },
                        )
                        .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _userTile(
    QueryDocumentSnapshot<
            Map<String, dynamic>>
        document,
  ) {
    final data =
        document.data();

    final String name =
        data['name']
                ?.toString()
                .trim() ??
            data['displayName']
                ?.toString()
                .trim() ??
            'Unnamed user';

    final String email =
        data['email']
                ?.toString()
                .trim() ??
            'No email';

    final String role =
        data['role']
                ?.toString()
                .trim()
                .toLowerCase() ??
            'unknown';

    final String date =
        _formatDate(
      data['createdAt'],
    );

    return ListTile(
      contentPadding:
          EdgeInsets.zero,
      leading: CircleAvatar(
        child: Icon(
          _roleIcon(role),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight:
              FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '$email\n$date',
      ),
      isThreeLine: true,
      trailing: _roleBadge(
        role,
      ),
      onTap: () {
        _showUserDetails(
          document,
        );
      },
    );
  }

  IconData _roleIcon(
    String role,
  ) {
    switch (role) {
      case 'elder':
        return Icons.elderly;

      case 'caregiver':
        return Icons.support_agent;

      case 'admin':
        return Icons.admin_panel_settings;

      default:
        return Icons.person;
    }
  }

  Widget _roleBadge(
    String role,
  ) {
    String label;

    switch (role) {
      case 'elder':
        label = 'Elder';
        break;

      case 'caregiver':
        label = 'Caregiver';
        break;

      case 'admin':
        label = 'Admin';
        break;

      default:
        label = 'Unknown';
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),
        color: Theme.of(context)
            .colorScheme
            .primary
            .withOpacity(0.10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight:
              FontWeight.w600,
          color: Theme.of(context)
              .colorScheme
              .primary,
        ),
      ),
    );
  }

  // ============================================================
  // USERS PAGE
  // ============================================================

  Widget _buildUsersPage() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('users')
          .snapshots(),
      builder:
          (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return _errorView(
            'Unable to load users.',
          );
        }

        final documents =
            snapshot.data?.docs ?? [];

        final filtered =
            documents.where(
          (document) {
            final data =
                document.data();

            final String name =
                data['name']
                        ?.toString()
                        .toLowerCase() ??
                    '';

            final String email =
                data['email']
                        ?.toString()
                        .toLowerCase() ??
                    '';

            final String role =
                data['role']
                        ?.toString()
                        .toLowerCase() ??
                    '';

            final bool matchesSearch =
                _searchText
                        .trim()
                        .isEmpty ||
                    name.contains(
                      _searchText
                          .trim()
                          .toLowerCase(),
                    ) ||
                    email.contains(
                      _searchText
                          .trim()
                          .toLowerCase(),
                    );

            final bool matchesRole =
                _roleFilter ==
                        'all' ||
                    role ==
                        _roleFilter;

            return matchesSearch &&
                matchesRole;
          },
        ).toList();

        return Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                'User Management',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${filtered.length} users shown',
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged:
                          (value) {
                        setState(() {
                          _searchText =
                              value;
                        });
                      },
                      decoration:
                          InputDecoration(
                        hintText:
                            'Search by name or email',
                        prefixIcon:
                            const Icon(
                          Icons.search,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  DropdownButtonHideUnderline(
                    child:
                        DropdownButton<String>(
                      value:
                          _roleFilter,
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text(
                            'All Roles',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'elder',
                          child: Text(
                            'Elders',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'caregiver',
                          child: Text(
                            'Caregivers',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text(
                            'Admins',
                          ),
                        ),
                      ],
                      onChanged:
                          (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _roleFilter =
                              value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),

              Expanded(
                child: filtered.isEmpty
                    ? _emptyView(
                        'No matching users',
                        Icons.people_outline,
                      )
                    : ListView.separated(
                        itemCount:
                            filtered.length,
                        separatorBuilder:
                            (context, index) {
                          return const Divider(
                            height: 1,
                          );
                        },
                        itemBuilder:
                            (context, index) {
                          final document =
                              filtered[index];

                          return _userManagementTile(
                            document,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _userManagementTile(
    QueryDocumentSnapshot<
            Map<String, dynamic>>
        document,
  ) {
    final data =
        document.data();

    final String name =
        data['name']
                ?.toString()
                .trim() ??
            data['displayName']
                ?.toString()
                .trim() ??
            'Unnamed user';

    final String email =
        data['email']
                ?.toString()
                .trim() ??
            'No email';

    final String role =
        data['role']
                ?.toString()
                .toLowerCase() ??
            'unknown';

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 4,
      ),
      leading: CircleAvatar(
        radius: 25,
        child: Icon(
          _roleIcon(role),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight:
              FontWeight.w700,
        ),
      ),
      subtitle: Text(
        email,
      ),
      trailing: Wrap(
        crossAxisAlignment:
            WrapCrossAlignment.center,
        spacing: 8,
        children: [
          _roleBadge(role),
          IconButton(
            tooltip: 'View details',
            onPressed: () {
              _showUserDetails(
                document,
              );
            },
            icon: const Icon(
              Icons.visibility_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Change role',
            onPressed: () {
              _showRoleDialog(
                document,
              );
            },
            icon: const Icon(
              Icons.manage_accounts,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // USER DETAILS
  // ============================================================

  Future<void> _showUserDetails(
    QueryDocumentSnapshot<
            Map<String, dynamic>>
        document,
  ) async {
    final data =
        document.data();

    final String name =
        data['name']
                ?.toString() ??
            data['displayName']
                ?.toString() ??
            'Unnamed user';

    final String email =
        data['email']
                ?.toString() ??
            'Not available';

    final String role =
        data['role']
                ?.toString() ??
            'Not available';

    final String phone =
        data['phone']
                ?.toString() ??
            'Not available';

    final String created =
        _formatDate(
      data['createdAt'],
    );

    final String uid =
        document.id;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'User Details',
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                _detailRow(
                  'Name',
                  name,
                ),
                _detailRow(
                  'Email',
                  email,
                ),
                _detailRow(
                  'Role',
                  role,
                ),
                _detailRow(
                  'Phone',
                  phone,
                ),
                _detailRow(
                  'User ID',
                  uid,
                ),
                _detailRow(
                  'Created',
                  created,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Text(
            label,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          SelectableText(value),
        ],
      ),
    );
  }

  // ============================================================
  // CHANGE ROLE
  // ============================================================

  Future<void> _showRoleDialog(
    QueryDocumentSnapshot<
            Map<String, dynamic>>
        document,
  ) async {
    final data =
        document.data();

    String selectedRole =
        data['role']
                ?.toString()
                .toLowerCase() ??
            'elder';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Change User Role',
              ),
              content: DropdownButtonFormField<
                  String>(
                value: selectedRole,
                decoration:
                    const InputDecoration(
                  border:
                      OutlineInputBorder(),
                  labelText: 'Role',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'elder',
                    child:
                        Text('Elder'),
                  ),
                  DropdownMenuItem(
                    value: 'caregiver',
                    child:
                        Text('Caregiver'),
                  ),
                  DropdownMenuItem(
                    value: 'admin',
                    child:
                        Text('Admin'),
                  ),
                ],
                onChanged:
                    (value) {
                  if (value == null) {
                    return;
                  }

                  setDialogState(() {
                    selectedRole =
                        value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                      const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      await _firestore
                          .collection(
                            'users',
                          )
                          .doc(
                            document.id,
                          )
                          .update({
                        'role':
                            selectedRole,
                        'updatedAt':
                            FieldValue
                                .serverTimestamp(),
                      });

                      if (!mounted) return;

                      Navigator.pop(
                        dialogContext,
                      );

                      ScaffoldMessenger
                          .of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'User role updated.',
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) {
                        return;
                      }

                      ScaffoldMessenger
                          .of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            'Unable to update role: $e',
                          ),
                        ),
                      );
                    }
                  },
                  child:
                      const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // SAFETY PAGE
  // ============================================================

  Widget _buildSafetyPage() {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Text(
            'Safety Monitor',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Monitor active SOS alerts, safe-zone violations '
            'and configured safe zones.',
          ),
          const SizedBox(height: 24),

          _buildActiveSosSection(),

          const SizedBox(
            height: 20,
          ),

          _buildActiveViolationsSection(),

          const SizedBox(
            height: 20,
          ),

          _buildSafeZonesSection(),
        ],
      ),
    );
  }

  Widget _buildActiveSosSection() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: Colors.red,
                ),
                const SizedBox(width: 10),
                Text(
                  'Active SOS Alerts',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            StreamBuilder<
                QuerySnapshot<
                    Map<String,
                        dynamic>>>(
              stream: _firestore
                  .collection(
                    'sosAlerts',
                  )
                  .where(
                    'status',
                    isEqualTo: 'active',
                  )
                  .snapshots(),
              builder:
                  (context, snapshot) {
                if (snapshot
                        .connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final docs =
                    snapshot.data?.docs ??
                        [];

                if (docs.isEmpty) {
                  return _emptyView(
                    'No active SOS alerts',
                    Icons
                        .check_circle_outline,
                  );
                }

                return Column(
                  children:
                      docs.map(
                  (document) {
                    return _alertTile(
                      document,
                      isSos: true,
                    );
                  },
                ).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveViolationsSection() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_off,
                  color: Colors.orange,
                ),
                const SizedBox(width: 10),
                Text(
                  'Active Safe-Zone Violations',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            StreamBuilder<
                QuerySnapshot<
                    Map<String,
                        dynamic>>>(
              stream: _firestore
                  .collection(
                    'safeZoneViolations',
                  )
                  .where(
                    'status',
                    isEqualTo: 'active',
                  )
                  .snapshots(),
              builder:
                  (context, snapshot) {
                if (snapshot
                        .connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final docs =
                    snapshot.data?.docs ??
                        [];

                if (docs.isEmpty) {
                  return _emptyView(
                    'No active safe-zone violations',
                    Icons
                        .verified_user_outlined,
                  );
                }

                return Column(
                  children:
                      docs.map(
                  (document) {
                    return _alertTile(
                      document,
                      isSos: false,
                    );
                  },
                ).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertTile(
    QueryDocumentSnapshot<
            Map<String, dynamic>>
        document, {
    required bool isSos,
  }) {
    final data =
        document.data();

    final String title =
        isSos
            ? 'SOS Alert'
            : data['safeZoneName']
                    ?.toString() ??
                'Safe-Zone Violation';

    final String elderId =
        data['elderId']
                ?.toString() ??
            'Unknown elder';

    final String status =
        data['status']
                ?.toString() ??
            'active';

    final String date =
        _formatDate(
      data['createdAt'],
    );

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: isSos
              ? Colors.red
                  .withOpacity(0.30)
              : Colors.orange
                  .withOpacity(0.30),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isSos
                  ? Colors.red
                      .withOpacity(
                        0.10,
                      )
                  : Colors.orange
                      .withOpacity(
                        0.10,
                      ),
          child: Icon(
            isSos
                ? Icons.warning
                : Icons.location_off,
            color: isSos
                ? Colors.red
                : Colors.orange,
          ),
        ),
        title: Text(
          title,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Elder: $elderId\n'
          'Status: $status\n'
          'Created: $date',
        ),
        isThreeLine: true,
        trailing: FilledButton(
          onPressed:
              status == 'resolved'
                  ? null
                  : () {
                      _resolveAlert(
                        document.reference,
                      );
                    },
          child: const Text(
            'Resolve',
          ),
        ),
      ),
    );
  }

  Future<void> _resolveAlert(
    DocumentReference<
            Map<String, dynamic>>
        reference,
  ) async {
    try {
      await reference.update({
        'status': 'resolved',
        'resolvedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Alert resolved.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to resolve alert: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SAFE ZONES
  // ============================================================

  Widget _buildSafeZonesSection() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                ),
                const SizedBox(width: 10),
                Text(
                  'Configured Safe Zones',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            StreamBuilder<
                QuerySnapshot<
                    Map<String,
                        dynamic>>>(
              stream: _firestore
                  .collection(
                    'safeZones',
                  )
                  .snapshots(),
              builder:
                  (context, snapshot) {
                if (snapshot
                        .connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final docs =
                    snapshot.data?.docs ??
                        [];

                if (docs.isEmpty) {
                  return _emptyView(
                    'No safe zones configured',
                    Icons.shield_outlined,
                  );
                }

                return Column(
                  children:
                      docs.map(
                  (document) {
                    final data =
                        document.data();

                    final String name =
                        data['name']
                                ?.toString() ??
                            'Safe Zone';

                    final String elderId =
                        data['elderId']
                                ?.toString() ??
                            'Unknown elder';

                    final dynamic radiusValue =
                        data['radiusInMeters'] ??
                            data['radius'];

                    return ListTile(
                      leading:
                          const CircleAvatar(
                        child: Icon(
                          Icons.shield,
                        ),
                      ),
                      title: Text(
                        name,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      subtitle:
                          Text(
                        'Elder: $elderId\n'
                        'Radius: ${radiusValue ?? 'N/A'} m',
                      ),
                      isThreeLine: true,
                    );
                  },
                ).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ALERTS PAGE
  // ============================================================

  Widget _buildAlertsPage() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('safeZoneViolations')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .limit(50)
          .snapshots(),
      builder:
          (context, violationSnapshot) {
        return StreamBuilder<
            QuerySnapshot<
                Map<String, dynamic>>>(
          stream: _firestore
              .collection(
                'sosAlerts',
              )
              .orderBy(
                'createdAt',
                descending: true,
              )
              .limit(50)
              .snapshots(),
          builder:
              (context, sosSnapshot) {
            if (violationSnapshot
                        .connectionState ==
                    ConnectionState.waiting ||
                sosSnapshot.connectionState ==
                    ConnectionState.waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            final violations =
                violationSnapshot
                        .data?.docs ??
                    [];

            final sos =
                sosSnapshot.data?.docs ??
                    [];

            final List<_AdminAlert>
                alerts = [];

            for (final document
                in sos) {
              final data =
                  document.data();

              alerts.add(
                _AdminAlert(
                  document: document,
                  title: 'SOS Alert',
                  type: 'SOS',
                  timestamp:
                      data['createdAt'],
                ),
              );
            }

            for (final document
                in violations) {
              final data =
                  document.data();

              alerts.add(
                _AdminAlert(
                  document: document,
                  title: data['safeZoneName']
                          ?.toString() ??
                      'Safe-Zone Violation',
                  type: 'Geofence',
                  timestamp:
                      data['createdAt'],
                ),
              );
            }

            alerts.sort(
              (a, b) {
                final DateTime aDate =
                    _timestampToDate(
                  a.timestamp,
                );

                final DateTime bDate =
                    _timestampToDate(
                  b.timestamp,
                );

                return bDate
                    .compareTo(aDate);
              },
            );

            return Padding(
              padding:
                  const EdgeInsets.all(
                24,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'Alert Centre',
                    style: Theme.of(
                      context,
                    )
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    '${alerts.length} recent alerts',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: alerts.isEmpty
                        ? _emptyView(
                            'No alerts available',
                            Icons.notifications_none,
                          )
                        : ListView.separated(
                            itemCount:
                                alerts.length,
                            separatorBuilder:
                                (context,
                                    index) {
                              return const SizedBox(
                                height: 10,
                              );
                            },
                            itemBuilder:
                                (context,
                                    index) {
                              final alert =
                                  alerts[index];

                              return _alertHistoryTile(
                                alert,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  DateTime _timestampToDate(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return DateTime.fromMillisecondsSinceEpoch(
      0,
    );
  }

  Widget _alertHistoryTile(
    _AdminAlert alert,
  ) {
    final data =
        alert.document.data();

    final String status =
        data['status']
                ?.toString() ??
            'unknown';

    final String elderId =
        data['elderId']
                ?.toString() ??
            'Unknown';

    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(
          14,
        ),
        leading: CircleAvatar(
          child: Icon(
            alert.type == 'SOS'
                ? Icons.warning
                : Icons.location_off,
          ),
        ),
        title: Text(
          alert.title,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Type: ${alert.type}\n'
          'Elder: $elderId\n'
          'Status: $status\n'
          'Time: ${_formatDate(alert.timestamp)}',
        ),
        isThreeLine: true,
        trailing:
            status == 'resolved'
                ? const Chip(
                    avatar: Icon(
                      Icons.check,
                      size: 17,
                    ),
                    label:
                        Text('Resolved'),
                  )
                : FilledButton.tonal(
                    onPressed: () {
                      _resolveAlert(
                        alert.document.reference,
                      );
                    },
                    child:
                        const Text(
                      'Resolve',
                    ),
                  ),
      ),
    );
  }

  // ============================================================
  // SETTINGS PAGE
  // ============================================================

  Widget _buildSettingsPage() {
    final User? user =
        _auth.currentUser;

    return SingleChildScrollView(
      padding:
          const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Text(
            'Admin Settings',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          const Text(
            'Review administrator account information and '
            'application settings.',
          ),
          const SizedBox(
            height: 24,
          ),

          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(
                20,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Text(
                    'Administrator Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  _settingRow(
                    'Name',
                    _adminName,
                    Icons.person,
                  ),
                  _settingRow(
                    'Email',
                    user?.email ??
                        'Not available',
                    Icons.email,
                  ),
                  _settingRow(
                    'Role',
                    'Admin',
                    Icons
                        .admin_panel_settings,
                  ),
                  _settingRow(
                    'User ID',
                    user?.uid ??
                        'Not available',
                    Icons.fingerprint,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: true,
                  onChanged: (_) {},
                  title: const Text(
                    'Firebase connectivity',
                  ),
                  subtitle:
                      const Text(
                    'Cloud Firestore backend is enabled.',
                  ),
                  secondary:
                      const Icon(
                    Icons.cloud_done,
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                ListTile(
                  leading:
                      const Icon(
                    Icons.security,
                  ),
                  title:
                      const Text(
                    'Role-based access',
                  ),
                  subtitle:
                      const Text(
                    'Administrator access is checked against '
                    'the user role stored in Firestore.',
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                ListTile(
                  leading:
                      const Icon(
                    Icons.logout,
                  ),
                  title:
                      const Text(
                    'Sign out',
                  ),
                  subtitle:
                      const Text(
                    'End the current administrator session.',
                  ),
                  trailing:
                      FilledButton.tonal(
                    onPressed:
                        _logout,
                    child:
                        const Text(
                      'Logout',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingRow(
    String title,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Icon(icon),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                SelectableText(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR VIEW
  // ============================================================

  Widget _errorView(
    String message,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 55,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              message,
              textAlign:
                  TextAlign.center,
            ),
            const SizedBox(
              height: 16,
            ),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(
                Icons.refresh,
              ),
              label:
                  const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY VIEW
  // ============================================================

  Widget _emptyView(
    String message,
    IconData icon,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          30,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 55,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(
                    0.35,
                  ),
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              message,
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(
                      0.60,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ADMIN ALERT MODEL
// ================================================================

class _AdminAlert {
  final QueryDocumentSnapshot<
      Map<String, dynamic>> document;

  final String title;

  final String type;

  final dynamic timestamp;

  _AdminAlert({
    required this.document,
    required this.title,
    required this.type,
    required this.timestamp,
  });
}