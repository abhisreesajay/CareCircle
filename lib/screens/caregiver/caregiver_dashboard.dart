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
import '../safe_zone_screen.dart';

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

class _CaregiverDashboardState
    extends State<CaregiverDashboard> {
  StreamSubscription<
      QuerySnapshot<Map<String, dynamic>>>?
      _sosSubscription;

  @override
  void initState() {
    super.initState();

    _startSosListener();
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
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type ==
            DocumentChangeType.added) {
          _showSosDialog(change.doc);
        }
      }
    });
  }

  // =====================================================================
  // SOS DIALOG
  // =====================================================================

  void _showSosDialog(
    DocumentSnapshot<Map<String, dynamic>>
        document,
  ) {
    if (!mounted) return;

    final data =
        document.data() ??
            <String, dynamic>{};

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color:
                    Color(0xFFC85C50),
                size: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'SOS Alert',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF26352F),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'The elder has triggered an emergency SOS.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      Color(0xFF26352F),
                ),
              ),

              const SizedBox(height: 18),

              if (data['timestamp'] != null)
                _SosDetailRow(
                  icon:
                      Icons.access_time_rounded,
                  label: 'Time',
                  value: data[
                          'timestamp']
                      .toString(),
                ),

              if (data['latitude'] != null)
                _SosDetailRow(
                  icon:
                      Icons.location_on_rounded,
                  label: 'Latitude',
                  value: data[
                          'latitude']
                      .toString(),
                ),

              if (data['longitude'] != null)
                _SosDetailRow(
                  icon:
                      Icons.location_on_rounded,
                  label: 'Longitude',
                  value: data[
                          'longitude']
                      .toString(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color:
                      Color(0xFF46695A),
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =====================================================================
  // DISPOSE SOS LISTENER
  // =====================================================================

  @override
  void dispose() {
    _sosSubscription?.cancel();
    super.dispose();
  }

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

  @override
  Widget build(
    BuildContext context,
  ) {
    const background =
        Color(0xFFF4EFE5);
    const sage =
        Color(0xFF7FA68F);
    const darkSage =
        Color(0xFF46695A);
    const terracotta =
        Color(0xFFC85C50);
    const cream =
        Color(0xFFFFFBF4);
    const textDark =
        Color(0xFF26352F);

    return Scaffold(
      backgroundColor:
          background,
      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            22,
            18,
            22,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // ---------------------------------------------------------
              // HEADER
              // ---------------------------------------------------------

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Good morning',
                        style: TextStyle(
                          fontSize: 15,
                          color: textDark
                              .withValues(
                            alpha: .60,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      const Text(
                        'Care Circle',
                        style: TextStyle(
                          fontSize: 31,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              textDark,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 48,
                    width: 48,
                    decoration:
                        BoxDecoration(
                      color:
                          terracotta,
                      borderRadius:
                          BorderRadius
                              .circular(
                        16,
                      ),
                    ),
                    child:
                        const Icon(
                      Icons
                          .favorite_rounded,
                      color:
                          Colors.white,
                      size: 25,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 25,
              ),

              // ---------------------------------------------------------
              // ELDER PROFILE CARD
              // ---------------------------------------------------------

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                decoration:
                    BoxDecoration(
                  color: sage,
                  borderRadius:
                      BorderRadius
                          .circular(
                    28,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -35,
                      top: -40,
                      child:
                          Container(
                        height: 145,
                        width: 145,
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .white
                              .withValues(
                            alpha: .10,
                          ),
                          shape:
                              BoxShape
                                  .circle,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 58,
                              width: 58,
                              decoration:
                                  BoxDecoration(
                                color:
                                    cream,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  20,
                                ),
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .person_rounded,
                                size: 32,
                                color:
                                    darkSage,
                              ),
                            ),
                            const SizedBox(
                              width: 14,
                            ),
                            const Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  'Elder profile',
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white70,
                                    fontSize:
                                        13,
                                  ),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  'Today at a glance',
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize:
                                        20,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        Row(
                          children: [
                            _MiniStatus(
                              icon: Icons
                                  .check_circle_rounded,
                              title:
                                  'Check-in',
                              value:
                                  'Pending',
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            _MiniStatus(
                              icon: Icons
                                  .shield_rounded,
                              title:
                                  'Safe zone',
                              value:
                                  'Active',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 26,
              ),

              // ---------------------------------------------------------
              // TODAY SECTION
              // ---------------------------------------------------------

              const Text(
                'Today',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight:
                      FontWeight.w800,
                  color: textDark,
                  letterSpacing: -.5,
                ),
              ),

              const SizedBox(
                height: 13,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        _DashboardCard(
                      color: cream,
                      iconBackground:
                          const Color(
                        0xFFE5D3C8,
                      ),
                      icon: Icons
                          .medication_rounded,
                      title:
                          'Medicines',
                      subtitle:
                          'Manage medication',
                      onTap: () {
                        _openPage(
                          context,
                          MedicinesScreen(
                            elderId:
                                widget.elderId,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child:
                        _DashboardCard(
                      color: cream,
                      iconBackground:
                          const Color(
                        0xFFD8E4D9,
                      ),
                      icon: Icons
                          .calendar_month_rounded,
                      title:
                          'Appointments',
                      subtitle:
                          'Upcoming visits',
                      onTap: () {
                        _openPage(
                          context,
                          AppointmentsScreen(
                            elderId:
                                widget.elderId,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              // ---------------------------------------------------------
              // EMERGENCY CONTACTS
              // ---------------------------------------------------------

              _WideCard(
                color:
                    const Color(
                  0xFFF0D5CE,
                ),
                icon:
                    Icons.phone_in_talk_rounded,
                title:
                    'Care circle',
                subtitle:
                    'Emergency contacts & trusted people',
                trailing:
                    Icons.arrow_forward_rounded,
                onTap: () {
                  _openPage(
                    context,
                    EmergencyContactsScreen(
                      elderId:
                          widget.elderId,
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 12,
              ),

              // ---------------------------------------------------------
              // SAFE ZONE
              // ---------------------------------------------------------

              _WideCard(
                color:
                    const Color(
                  0xFFDCE8DD,
                ),
                icon:
                    Icons.shield_rounded,
                title:
                    'Safe zone',
                subtitle:
                    'Create and manage the elder safe zone',
                trailing:
                    Icons.arrow_forward_rounded,
                darkIcon: true,
                onTap: () {
                  _openPage(
                    context,
                    SafeZoneScreen(
                      elderId:
                          widget.elderId,
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 26,
              ),

              // ---------------------------------------------------------
              // CARE OVERVIEW
              // ---------------------------------------------------------

              const Text(
                'Care overview',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight:
                      FontWeight.w800,
                  color: textDark,
                  letterSpacing: -.5,
                ),
              ),

              const SizedBox(
                height: 13,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        _SmallFeatureCard(
                      color: darkSage,
                      icon: Icons
                          .favorite_rounded,
                      title:
                          'Elder status',
                      onTap: () {
                        _openPage(
                          context,
                          ElderStatusScreen(
                            elderId:
                                widget.elderId,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child:
                        _SmallFeatureCard(
                      color:
                          terracotta,
                      icon: Icons
                          .notifications_rounded,
                      title:
                          'Alerts',
                      onTap: () {
                        _openPage(
                          context,
                          AlertsScreen(
                            elderId:
                                widget.elderId,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        _SmallFeatureCard(
                      color:
                          const Color(
                        0xFF657C91,
                      ),
                      icon: Icons
                          .history_rounded,
                      title:
                          'Check-in history',
                      onTap: () {
                        _openPage(
                          context,
                          CheckInHistoryScreen(
                            elderId:
                                widget.elderId,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child:
                        _SmallFeatureCard(
                      color:
                          const Color(
                        0xFF8A7460,
                      ),
                      icon: Icons
                          .timeline_rounded,
                      title:
                          'Activity',
                      onTap: () {
                        _openPage(
                          context,
                          ActivityHistoryScreen(
                            elderId:
                                widget.elderId,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 26,
              ),

              // ---------------------------------------------------------
              // MEDICAL SUMMARY
              // ---------------------------------------------------------

              GestureDetector(
                onTap: () {
                  _openPage(
                    context,
                    MedicalSummaryScreen(
                      elderId:
                          widget.elderId,
                    ),
                  );
                },
                child:
                    Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  decoration:
                      BoxDecoration(
                    color: cream,
                    borderRadius:
                        BorderRadius
                            .circular(
                      28,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 58,
                        width: 58,
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFE3E9E1,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            19,
                          ),
                        ),
                        child:
                            const Icon(
                          Icons
                              .medical_information_rounded,
                          color:
                              darkSage,
                          size: 28,
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      const Expanded(
                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Medical summary',
                              style:
                                  TextStyle(
                                fontSize:
                                    18,
                                fontWeight:
                                    FontWeight
                                        .w800,
                                color:
                                    textDark,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Health information at a glance',
                              style:
                                  TextStyle(
                                fontSize:
                                    13,
                                color:
                                    Colors
                                        .black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons
                            .arrow_forward_ios_rounded,
                        size: 17,
                        color:
                            Colors.black45,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // ---------------------------------------------------------
              // NEARBY SERVICES
              // ---------------------------------------------------------

              _WideCard(
                color:
                    const Color(
                  0xFFE4DCCB,
                ),
                icon:
                    Icons.location_on_rounded,
                title:
                    'Nearby services',
                subtitle:
                    'Hospitals, care centres & local services',
                trailing:
                    Icons.arrow_forward_rounded,
                darkIcon: true,
                onTap: () {
                  _openPage(
                    context,
                    NearbyServicesScreen(
                      elderId:
                          widget.elderId,
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 28,
              ),

              // ---------------------------------------------------------
              // FOOTER
              // ---------------------------------------------------------

              Center(
                child: Text(
                  'Taking care, one day at a time ♥',
                  style: TextStyle(
                    color: textDark
                        .withValues(
                      alpha: .45,
                    ),
                    fontSize: 13,
                    fontStyle:
                        FontStyle.italic,
                  ),
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
// SOS DETAIL ROW
// =======================================================================

class _SosDetailRow
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SosDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color:
                const Color(
              0xFF46695A,
            ),
          ),
          const SizedBox(
            width: 9,
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        '$label: ',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w700,
                      color:
                          Color(
                        0xFF26352F,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style:
                        const TextStyle(
                      color:
                          Colors.black54,
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

class _MiniStatus
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MiniStatus({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        decoration:
            BoxDecoration(
          color: Colors.white
              .withValues(
            alpha: .18,
          ),
          borderRadius:
              BorderRadius.circular(
            17,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  Colors.white,
              size: 20,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    value,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontWeight:
                          FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// DASHBOARD CARD
// =======================================================================

class _DashboardCard
    extends StatelessWidget {
  final Color color;
  final Color iconBackground;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.color,
    required this.iconBackground,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 170,
        padding:
            const EdgeInsets.all(
          17,
        ),
        decoration:
            BoxDecoration(
          color: color,
          borderRadius:
              BorderRadius.circular(
            25,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration:
                  BoxDecoration(
                color:
                    iconBackground,
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child: Icon(
                icon,
                color:
                    const Color(
                  0xFF34453E,
                ),
                size: 25,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(
                  0xFF26352F,
                ),
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              subtitle,
              style:
                  const TextStyle(
                fontSize: 11,
                color:
                    Colors.black54,
              ),
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

class _WideCard
    extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final IconData trailing;
  final VoidCallback onTap;
  final bool darkIcon;

  const _WideCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    this.darkIcon = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.all(
          18,
        ),
        decoration:
            BoxDecoration(
          color: color,
          borderRadius:
              BorderRadius.circular(
            25,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withValues(
                  alpha: .55,
                ),
                borderRadius:
                    BorderRadius.circular(
                  17,
                ),
              ),
              child: Icon(
                icon,
                color: darkIcon
                    ? const Color(
                        0xFF46695A,
                      )
                    : const Color(
                        0xFF9C5047,
                      ),
                size: 26,
              ),
            ),
            const SizedBox(
              width: 14,
            ),
            Expanded(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          Color(
                        0xFF26352F,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      fontSize: 11.5,
                      color:
                          Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              trailing,
              size: 20,
              color:
                  Colors.black54,
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

class _SmallFeatureCard
    extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SmallFeatureCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 125,
        padding:
            const EdgeInsets.all(
          17,
        ),
        decoration:
            BoxDecoration(
          color: color,
          borderRadius:
              BorderRadius.circular(
            24,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color:
                  Colors.white,
              size: 27,
            ),
            const Spacer(),
            Text(
              title,
              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize: 15,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            const Row(
              children: [
                Text(
                  'Open',
                  style:
                      TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 11,
                  ),
                ),
                SizedBox(
                  width: 4,
                ),
                Icon(
                  Icons
                      .arrow_forward_rounded,
                  color:
                      Colors.white70,
                  size: 13,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}