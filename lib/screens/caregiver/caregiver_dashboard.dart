import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'medicines_screen.dart';
import 'appointments_screen.dart';
import 'emergency_contacts_screen.dart';
import 'nearby_services_screen.dart';
import 'elder_status_screen.dart';
import 'check_in_history_screen.dart';
import 'activity_history_screen.dart';
import 'medical_summary_screen.dart';
import 'alerts_screen.dart';
import 'hospital_documents_screen.dart';
import '../safe_zone_screen.dart';
import '../../services/auth_service.dart';
import '../common/profile_screen.dart';
import '../common/settings_screen.dart';

class CaregiverDashboard extends StatefulWidget {
  final String elderId;

  const CaregiverDashboard({
    super.key,
    required this.elderId,
  });

  @override
  State<CaregiverDashboard> createState() =>
      _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _sosSubscription;

  // =====================================================================
  // COLOUR PALETTE
  // =====================================================================

  static const background = Color(0xFFFFF9F1);
  static const cream = Color(0xFFFFFCF7);
  static const darkText = Color(0xFF173B36);
  static const mutedText = Color(0xFF60736E);

  static const green = Color(0xFF39A982);
  static const greenDark = Color(0xFF21866A);
  static const mint = Color(0xFFDDF4E8);

  static const orange = Color(0xFFFFA62B);
  static const orangeLight = Color(0xFFFFE1B5);

  static const blue = Color(0xFF4C9FEF);
  static const blueLight = Color(0xFFD7EAFF);

  static const coral = Color(0xFFF06464);
  static const coralLight = Color(0xFFFFD1D1);

  static const purple = Color(0xFF8172D6);
  static const purpleLight = Color(0xFFE5DEFF);

  static const yellow = Color(0xFFFFC857);
  static const yellowLight = Color(0xFFFFE8B5);

  static const teal = Color(0xFF28A9A0);
  static const tealLight = Color(0xFFD2F2EF);

  // =====================================================================
  // LIFECYCLE
  // =====================================================================

  @override
  void initState() {
    super.initState();
    _startSosListener();
  }

  @override
  void dispose() {
    _sosSubscription?.cancel();
    super.dispose();
  }

  // =====================================================================
  // SOS LISTENER
  // =====================================================================

  void _startSosListener() {
    _sosSubscription = FirebaseFirestore.instance
        .collection('sosAlerts')
        .where(
          'userId',
          isEqualTo: widget.elderId,
        )
        .where(
          'status',
          isEqualTo: 'ACTIVE',
        )
        .snapshots()
        .listen(
      (snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            _showSosDialog(change.doc);
          }
        }
      },
      onError: (error) {
        debugPrint('SOS listener error: $error');
      },
    );
  }

  // =====================================================================
  // SOS DIALOG
  // =====================================================================

  void _showSosDialog(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    if (!mounted) return;

    final data = document.data() ?? <String, dynamic>{};

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: coral,
                size: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'SOS Alert',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The elder has triggered an emergency SOS.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 18),
              if (data['timestamp'] != null)
                _SosDetailRow(
                  icon: Icons.access_time_rounded,
                  label: 'Time',
                  value: _formatValue(data['timestamp']),
                ),
              if (data['latitude'] != null)
                _SosDetailRow(
                  icon: Icons.location_on_rounded,
                  label: 'Latitude',
                  value: _formatValue(data['latitude']),
                ),
              if (data['longitude'] != null)
                _SosDetailRow(
                  icon: Icons.location_on_rounded,
                  label: 'Longitude',
                  value: _formatValue(data['longitude']),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: greenDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toString();
    }

    return value.toString();
  }

  // =====================================================================
  // LOGOUT
  // =====================================================================

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: coral,
                size: 27,
              ),
              SizedBox(width: 10),
              Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 16,
              color: mutedText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: mutedText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: coral,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) return;

    await AuthService().signOut();

  }

  // =====================================================================
  // NAVIGATION
  // =====================================================================

  void _openPage(
    BuildContext context,
    Widget page,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  // =====================================================================
  // BUILD
  // =====================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===========================================================
              // HEADER
              // ===========================================================

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: yellowLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.wb_sunny_rounded,
                                color: orange,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 9),
                            const Text(
                              'Good morning',
                              style: TextStyle(
                                fontSize: 15,
                                color: mutedText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Care Circle',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: darkText,
                            letterSpacing: -1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Better care. Brighter days.',
                          style: TextStyle(
                            fontSize: 14,
                            color: mutedText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Logout button
                  GestureDetector(
                    onTap: _logout,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            coral,
                            Color(0xFFFF7770),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: [
                          BoxShadow(
                            color: coral.withValues(alpha: .22),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 23,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Profile',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(role: 'caregiver'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_outline_rounded),
                  ),
                  IconButton(
                    tooltip: 'Settings',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(role: 'caregiver'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ===========================================================
              // ELDER PROFILE HERO
              // ===========================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF36A981),
                      Color(0xFF299B7A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(29),
                  boxShadow: [
                    BoxShadow(
                      color: green.withValues(alpha: .20),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -45,
                      top: -45,
                      child: Container(
                        height: 170,
                        width: 170,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 15,
                      bottom: -30,
                      child: Icon(
                        Icons.favorite_outline_rounded,
                        color: Colors.white.withValues(alpha: .10),
                        size: 120,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 62,
                              width: 62,
                              decoration: BoxDecoration(
                                color: cream,
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 34,
                                color: greenDark,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Elder profile',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Today at a glance',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(
                              child: StreamBuilder<
                                  DocumentSnapshot<
                                      Map<String, dynamic>>>(
                                stream: FirebaseFirestore.instance
                                    .collection('elders')
                                    .doc(widget.elderId)
                                    .collection('status')
                                    .doc('current')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  String status = 'Pending';

                                  if (snapshot.hasData &&
                                      snapshot.data!.exists) {
                                    final data =
                                        snapshot.data!.data();

                                    final String firestoreStatus =
                                        data?['checkInStatus']
                                                ?.toString()
                                                .toUpperCase() ??
                                            'PENDING';

                                    switch (firestoreStatus) {
                                      case 'COMPLETED':
                                        status = 'Completed';
                                        break;

                                      case 'HELP_REQUESTED':
                                        status = 'Help requested';
                                        break;

                                      case 'MISSED':
                                        status = 'Missed';
                                        break;

                                      default:
                                        status = 'Pending';
                                    }
                                  }

                                  return _MiniStatus(
                                    icon: status == 'Completed'
                                        ? Icons.check_circle_rounded
                                        : status ==
                                                'Help requested'
                                            ? Icons.warning_rounded
                                            : Icons.schedule_rounded,
                                    title: 'Check-in',
                                    value: status,
                                    iconColor: status == 'Completed'
                                        ? Colors.green
                                        : status ==
                                                'Help requested'
                                            ? Colors.red
                                            : Colors.orange,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MiniStatus(
                                icon: Icons.shield_rounded,
                                title: 'Safe zone',
                                value: 'Active',
                                iconColor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 27),

              // ===========================================================
              // TODAY
              // ===========================================================

              const _SectionTitle(title: 'Today'),

              const SizedBox(height: 13),

              Row(
                children: [
                  Expanded(
                    child: _DashboardCard(
                      color: orangeLight,
                      iconBackground: orange,
                      icon: Icons.medication_rounded,
                      iconColor: Colors.white,
                      title: 'Medicines',
                      subtitle: 'Manage medication',
                      titleColor: darkText,
                      onTap: () {
                        _openPage(
                          context,
                          MedicinesScreen(
                            elderId: widget.elderId,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DashboardCard(
                      color: blueLight,
                      iconBackground: blue,
                      icon: Icons.calendar_month_rounded,
                      iconColor: Colors.white,
                      title: 'Appointments',
                      subtitle: 'Upcoming visits',
                      titleColor: const Color(0xFF174C7D),
                      onTap: () {
                        _openPage(
                          context,
                          AppointmentsScreen(
                            elderId: widget.elderId,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ===========================================================
              // CARE CIRCLE
              // ===========================================================

              _WideCard(
                color: coralLight,
                iconBackground: coral,
                icon: Icons.phone_in_talk_rounded,
                iconColor: Colors.white,
                title: 'Care circle',
                titleColor: const Color(0xFFA52D38),
                subtitle: 'Emergency contacts & trusted people',
                trailing: Icons.arrow_forward_rounded,
                trailingColor: coral,
                onTap: () {
                  _openPage(
                    context,
                    EmergencyContactsScreen(
                      elderId: widget.elderId,
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // ===========================================================
              // SAFE ZONE
              // ===========================================================

              _WideCard(
                color: mint,
                iconBackground: green,
                icon: Icons.shield_rounded,
                iconColor: Colors.white,
                title: 'Safe zone',
                titleColor: greenDark,
                subtitle: 'Create and manage the elder safe zone',
                trailing: Icons.arrow_forward_rounded,
                trailingColor: greenDark,
                onTap: () {
                  _openPage(
                    context,
                    SafeZoneScreen(
                      elderId: widget.elderId,
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // ===========================================================
              // HOSPITAL DOCUMENTS
              // ===========================================================

              _WideCard(
                color: tealLight,
                iconBackground: teal,
                icon: Icons.folder_shared_rounded,
                iconColor: Colors.white,
                title: 'Hospital documents',
                titleColor: const Color(0xFF176C68),
                subtitle: 'Medical reports & hospital records',
                trailing: Icons.arrow_forward_rounded,
                trailingColor: teal,
                onTap: () {
                  _openPage(
                    context,
                    CaregiverHospitalDocumentsScreen(
                      elderId: widget.elderId,
                    )
                  );
                },
              ),

              const SizedBox(height: 28),

              // ===========================================================
              // CARE OVERVIEW
              // ===========================================================

              const _SectionTitle(title: 'Care overview'),

              const SizedBox(height: 13),

              Row(
                children: [
                  Expanded(
                    child: _SmallFeatureCard(
                      color: tealLight,
                      iconBackground: teal,
                      icon: Icons.favorite_rounded,
                      title: 'Elder status',
                      titleColor: const Color(0xFF176C68),
                      onTap: () {
                        _openPage(
                          context,
                          ElderStatusScreen(
                            elderId: widget.elderId,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SmallFeatureCard(
                      color: coralLight,
                      iconBackground: coral,
                      icon: Icons.notifications_rounded,
                      title: 'Alerts',
                      titleColor: const Color(0xFFA52D38),
                      onTap: () {
                        _openPage(
                          context,
                          AlertsScreen(
                            elderId: widget.elderId,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _SmallFeatureCard(
                      color: blueLight,
                      iconBackground: blue,
                      icon: Icons.history_rounded,
                      title: 'Check-in history',
                      titleColor: const Color(0xFF245A96),
                      onTap: () {
                        _openPage(
                          context,
                          CheckInHistoryScreen(
                            elderId: widget.elderId,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SmallFeatureCard(
                      color: yellowLight,
                      iconBackground: orange,
                      icon: Icons.timeline_rounded,
                      title: 'Activity',
                      titleColor: const Color(0xFF9A6300),
                      onTap: () {
                        _openPage(
                          context,
                          ActivityHistoryScreen(
                            elderId: widget.elderId,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // ===========================================================
              // MEDICAL SUMMARY
              // ===========================================================

              GestureDetector(
                onTap: () {
                  _openPage(
                    context,
                    MedicalSummaryScreen(
                      elderId: widget.elderId,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(19),
                  decoration: BoxDecoration(
                    color: cream,
                    borderRadius: BorderRadius.circular(27),
                    border: Border.all(
                      color: const Color(0xFFEEDCC8),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 58,
                        width: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              tealLight,
                              Color(0xFFB7E8DF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: const Icon(
                          Icons.medical_information_rounded,
                          color: teal,
                          size: 29,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Medical summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: darkText,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Health information at a glance',
                              style: TextStyle(
                                fontSize: 13,
                                color: mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _ArrowCircle(
                        color: orangeLight,
                        iconColor: orange,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ===========================================================
              // NEARBY SERVICES
              // ===========================================================

              _WideCard(
                color: purpleLight,
                iconBackground: purple,
                icon: Icons.location_on_rounded,
                iconColor: Colors.white,
                title: 'Nearby services',
                titleColor: const Color(0xFF50439B),
                subtitle:
                    'Hospitals, care centres & local services',
                trailing: Icons.arrow_forward_rounded,
                trailingColor: purple,
                onTap: () {
                  _openPage(
                    context,
                    NearbyServicesScreen(
                      elderId: widget.elderId,
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // ===========================================================
              // FOOTER
              // ===========================================================

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 35,
                      height: 1,
                      color: green.withValues(alpha: .35),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Taking care, one day at a time ♥',
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 35,
                      height: 1,
                      color: green.withValues(alpha: .35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// SECTION TITLE
// =======================================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: Color(0xFF173B36),
        letterSpacing: -.6,
      ),
    );
  }
}

// =======================================================================
// SOS DETAIL ROW
// =======================================================================

class _SosDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SosDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Icon(
              icon,
              size: 16,
              color: const Color(0xFF39A982),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF173B36),
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================================
// MINI STATUS
// =======================================================================

class _MiniStatus extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  const _MiniStatus({
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: .14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 19,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF60736E),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
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

// =======================================================================
// DASHBOARD CARD
// =======================================================================

class _DashboardCard extends StatelessWidget {
  final Color color;
  final Color iconBackground;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color titleColor;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.color,
    required this.iconBackground,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 158,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -25,
              bottom: -30,
              child: Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .20),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 49,
                  width: 49,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            iconBackground.withValues(alpha: .20),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 25,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: titleColor.withValues(alpha: .70),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// WIDE CARD
// =======================================================================

class _WideCard extends StatelessWidget {
  final Color color;
  final Color iconBackground;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final String subtitle;
  final IconData trailing;
  final Color trailingColor;
  final VoidCallback onTap;

  const _WideCard({
    required this.color,
    required this.iconBackground,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
    required this.subtitle,
    required this.trailing,
    required this.trailingColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        iconBackground.withValues(alpha: .18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color:
                          titleColor.withValues(alpha: .70),
                    ),
                  ),
                ],
              ),
            ),
            _ArrowCircle(
              color: Colors.white.withValues(alpha: .60),
              iconColor: trailingColor,
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// SMALL FEATURE CARD
// =======================================================================

class _SmallFeatureCard extends StatelessWidget {
  final Color color;
  final Color iconBackground;
  final IconData icon;
  final String title;
  final Color titleColor;
  final VoidCallback onTap;

  const _SmallFeatureCard({
    required this.color,
    required this.iconBackground,
    required this.icon,
    required this.title,
    required this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 125,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18,
              bottom: -25,
              child: Container(
                height: 75,
                width: 75,
                decoration: BoxDecoration(
                  color:
                      Colors.white.withValues(alpha: .30),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      'Open',
                      style: TextStyle(
                        color:
                            titleColor.withValues(alpha: .72),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color:
                          titleColor.withValues(alpha: .72),
                      size: 13,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// ARROW CIRCLE
// =======================================================================

class _ArrowCircle extends StatelessWidget {
  final Color color;
  final Color iconColor;

  const _ArrowCircle({
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 38,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.arrow_forward_rounded,
        color: iconColor,
        size: 20,
      ),
    );
  }
}