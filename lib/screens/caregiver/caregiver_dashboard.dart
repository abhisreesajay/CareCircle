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

class CaregiverDashboard extends StatelessWidget {
  final String elderId;

  const CaregiverDashboard({
    super.key,
    required this.elderId,
  });

  // ---------------- COLORS ----------------

  static const Color primaryGreen = Color(0xFF6F9B83);
  static const Color darkGreen = Color(0xFF385B4A);
  static const Color backgroundColor = Color(0xFFF4F0E7);
  static const Color cardColor = Color(0xFFFFFCF7);
  static const Color textColor = Color(0xFF28332D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ---------------- APP BAR ----------------

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,

        title: const Text(
          'CareCircle',
          style: TextStyle(
            color: darkGreen,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CircleAvatar(
              radius: 21,
              backgroundColor: primaryGreen.withValues(alpha: 0.15),
              child: const Icon(
                Icons.person_outline,
                color: darkGreen,
              ),
            ),
          ),
        ],
      ),

      // ---------------- BODY ----------------

      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;

          if (constraints.maxWidth >= 1200) {
            crossAxisCount = 3;
          } else if (constraints.maxWidth >= 700) {
            crossAxisCount = 2;
          } else {
            crossAxisCount = 1;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth < 600 ? 18 : 35,
              vertical: 20,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ---------------- WELCOME SECTION ----------------

                _welcomeSection(),

                const SizedBox(height: 35),

                // ---------------- CARE MANAGEMENT ----------------

                const Text(
                  'Care Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Manage your elder\'s daily care',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 18),

                GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,

                  // Bigger cards like the reference image
                  childAspectRatio:
                      crossAxisCount == 1 ? 2.1 : 1.55,

                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  children: [

                    // MEDICINES
                    _dashboardCard(
                      context,

                      title: 'Medicines',

                      description:
                          'Manage medicines and schedules',

                      imagePath:
                          'assets/images/medicines.png',

                      fallbackIcon:
                          Icons.medication_outlined,

                      cardBackground:
                          const Color(0xFFE8F1E6),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MedicinesScreen(
                              elderId: elderId,
                            ),
                          ),
                        );
                      },
                    ),

                    // APPOINTMENTS
                    _dashboardCard(
                      context,

                      title: 'Appointments',

                      description:
                          'Manage upcoming appointments',

                      imagePath:
                          'assets/images/appointments.png',

                      fallbackIcon:
                          Icons.calendar_month_outlined,

                      cardBackground:
                          const Color(0xFFE8EDF3),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AppointmentsScreen(
                              elderId: elderId,
                            ),
                          ),
                        );
                      },
                    ),

                    // EMERGENCY CONTACTS
                    _dashboardCard(
                      context,

                      title: 'Emergency Contacts',

                      description:
                          'Manage important contacts',

                      imagePath:
                          'assets/images/emergency_contacts.png',

                      fallbackIcon:
                          Icons.contact_phone_outlined,

                      cardBackground:
                          const Color(0xFFF4E5E2),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EmergencyContactsScreen(
                              elderId: elderId,
                            ),
                          ),
                        );
                      },
                    ),

                    // NEARBY SERVICES
                    _dashboardCard(
                      context,

                      title: 'Nearby Services',

                      description:
                          'Hospitals, shops and care centres',

                      imagePath:
                          'assets/images/nearby_services.png',

                      fallbackIcon:
                          Icons.location_on_outlined,

                      cardBackground:
                          const Color(0xFFE6F0EC),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NearbyServicesScreen(
                              elderId: elderId,
                            ),
                          ),
                        );
                      },
                    ),

                    // MEDICAL SUMMARY
                    _dashboardCard(
                      context,

                      title: 'Medical Summary',

                      description:
                          'View important medical information',

                      imagePath:
                          'assets/images/medical_summary.png',

                      fallbackIcon:
                          Icons.medical_information_outlined,

                      cardBackground:
                          const Color(0xFFEDE8F2),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MedicalSummaryScreen(
                              elderId: elderId,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ---------------- MONITORING ----------------

                const Text(
                  'Monitoring & History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Keep track of your elder\'s activities',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 18),

                GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,

                  childAspectRatio:
                      crossAxisCount == 1 ? 2.1 : 1.55,

                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  children: [

                    // ELDER STATUS
                    _dashboardCard(
                      context,

                      title: 'Elder Status',

                      description:
                          'View current elder status',

                      imagePath:
                          'assets/images/elder_status.png',

                      fallbackIcon:
                          Icons.person_outline,

                      cardBackground:
                          const Color(0xFFE7EFEA),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ElderStatusScreen(
                              elderId: elderId,
                            ),
                          ),
                        );
                      },
                    ),

                    // CHECK-IN HISTORY
                    _dashboardCard(
                      context,

                      title: 'Check-in History',

                      description:
                          'View previous check-in records',

                      imagePath:
                          'assets/images/checkin_history.png',

                      fallbackIcon:
                          Icons.check_circle_outline,

                      cardBackground:
                          const Color(0xFFE8F0E4),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CheckInHistoryScreen(
                              elderId: elderId,
                            ),
                          ),
                        );
                      },
                    ),

                    // ACTIVITY HISTORY
                    _dashboardCard(
                      context,

                      title: 'Activity History',

                      description:
                          'View elder activities',

                      imagePath:
                          'assets/images/activity_history.png',

                      fallbackIcon:
                          Icons.history,

                      cardBackground:
                          const Color(0xFFE8EBF1),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ActivityHistoryScreen(
                              elderId: elderId,
                            ),
                          ),
                        );
                      },
                    ),

                    // ALERTS
                    _dashboardCard(
                      context,

                      title: 'Alerts',

                      description:
                          'View important care alerts',

                      imagePath:
                          'assets/images/alerts.png',

                      fallbackIcon:
                          Icons.notifications_outlined,

                      cardBackground:
                          const Color(0xFFF3E5E1),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AlertsScreen(
                              elderId: elderId,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // WELCOME SECTION
  // ============================================================

  Widget _welcomeSection() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 26,
      ),

      decoration: BoxDecoration(
        color: primaryGreen,

        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [

          // LEFT ICON
          Container(
            width: 65,
            height: 65,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),

            child: const Icon(
              Icons.favorite_outline,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(width: 20),

          // TEXT
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  'Welcome to CareCircle',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 7),

                Text(
                  'Manage and monitor your elder\'s care in one place.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DASHBOARD CARD
  // ============================================================

  Widget _dashboardCard(
    BuildContext context, {
    required String title,
    required String description,
    required String imagePath,
    required IconData fallbackIcon,
    required Color cardBackground,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,

      elevation: 0,

      color: cardColor,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(25),

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Row(
            children: [

              // ==================================================
              // IMAGE AREA
              // ==================================================

              Container(
                width: 95,
                height: 95,

                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius:
                      BorderRadius.circular(22),
                ),

                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(22),

                  child: Image.asset(
                    imagePath,

                    fit: BoxFit.contain,

                    // If image isn't available yet,
                    // show the icon instead.
                    errorBuilder:
                        (context, error, stackTrace) {
                      return Icon(
                        fallbackIcon,
                        size: 45,
                        color: darkGreen,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // ==================================================
              // TEXT
              // ==================================================

              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      title,

                      maxLines: 2,

                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      description,

                      maxLines: 2,

                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.3,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // SMALL ARROW
                    Row(
                      children: [
                        Text(
                          'Open',
                          style: TextStyle(
                            color: darkGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(width: 5),

                        const Icon(
                          Icons.arrow_forward,
                          size: 15,
                          color: darkGreen,
                        ),
                      ],
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
