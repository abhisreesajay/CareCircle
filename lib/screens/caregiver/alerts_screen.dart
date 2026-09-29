import 'package:flutter/material.dart';
import '../../models/alert_model.dart';
<<<<<<< HEAD
<<<<<<< HEAD
import '../../services/alert_service.dart';
=======
import '../../services/caregiver/alert_service.dart';
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
import '../../services/caregiver/alert_service.dart';
>>>>>>> develop

class AlertsScreen extends StatelessWidget {
  final String elderId;

  const AlertsScreen({
    super.key,
    required this.elderId,
  });

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
  static const Color primaryGreen = Color(0xFF738F52);
  static const Color darkGreen = Color(0xFF536B3A);
  static const Color lightGreen = Color(0xFFE8EFDF);
  static const Color backgroundColor = Color(0xFFF7F9F3);
  static const Color textColor = Color(0xFF26301F);
<<<<<<< HEAD
=======
  // CareCircle palette
  static const Color darkSage = Color(0xFF46695A);
  static const Color cream = Color(0xFFFFFBF4);
  static const Color background = Color(0xFFF4EFE5);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop

  @override
  Widget build(BuildContext context) {
    final service = AlertService();

    return Scaffold(
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Alerts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
<<<<<<< HEAD
=======
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Alerts',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
      ),

>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
      body: StreamBuilder<List<CareAlert>>(
        stream: service.getAlerts(elderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
<<<<<<< HEAD
<<<<<<< HEAD
                color: primaryGreen,
=======
                color: darkSage,
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
                color: primaryGreen,
>>>>>>> develop
              ),
            );
          }

          if (snapshot.hasError) {
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 55,
                      color: darkGreen,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Unable to load alerts',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
<<<<<<< HEAD
=======
            return const _ErrorState();
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
          }

          final alerts = snapshot.data ?? [];

          if (alerts.isEmpty) {
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 70,
                    color: primaryGreen,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No alerts available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'New alerts will appear here.',
                    style: TextStyle(
                      color: darkGreen,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];

              final bool isSos = alert.type == 'sos';

              return Card(
                color: isSos ? Colors.white : lightGreen,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSos
                          ? Icons.warning
                          : alert.type == 'checkin'
                              ? Icons.check_circle
                              : Icons.medication,
                      size: 28,
                      color: darkGreen,
                    ),
                  ),
                  title: Text(
                    alert.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: textColor,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${alert.message}\n${alert.date}',
                      style: const TextStyle(
                        height: 1.5,
                      ),
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
<<<<<<< HEAD
=======
            return const _EmptyAlertState();
          }

          final sosCount =
              alerts.where((alert) => alert.type == 'sos').length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              // Intro card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: darkSage,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: cream.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: cream,
                        size: 29,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stay in the loop',
                            style: TextStyle(
                              color: cream,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${alerts.length} alert${alerts.length == 1 ? '' : 's'} in your care circle',
                            style: TextStyle(
                              color: cream.withValues(alpha: 0.78),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SOS summary
              if (sosCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: terracotta.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: terracotta.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: terracotta.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_rounded,
                          color: terracotta,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          '$sosCount SOS alert${sosCount == 1 ? '' : 's'} need attention',
                          style: const TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (sosCount > 0) const SizedBox(height: 24),

              const Text(
                'Recent alerts',
                style: TextStyle(
                  color: textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              ...alerts.map(
                (alert) => _AlertCard(alert: alert),
              ),
            ],
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
          );
        },
      ),
    );
  }
<<<<<<< HEAD
<<<<<<< HEAD
=======
}

// ------------------------------------------------------------
// Alert Card
// ------------------------------------------------------------

class _AlertCard extends StatelessWidget {
  final CareAlert alert;

  const _AlertCard({
    required this.alert,
  });

  static const Color sage = Color(0xFF7FA68F);
  static const Color darkSage = Color(0xFF46695A);
  static const Color cream = Color(0xFFFFFBF4);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    final bool isSos = alert.type == 'sos';
    final bool isCheckIn = alert.type == 'checkin';

    final IconData icon = isSos
        ? Icons.warning_rounded
        : isCheckIn
            ? Icons.check_circle_rounded
            : Icons.medication_rounded;

    final Color iconColor = isSos
        ? terracotta
        : isCheckIn
            ? darkSage
            : sage;

    final Color iconBackground = isSos
        ? terracotta.withValues(alpha: 0.12)
        : sage.withValues(alpha: 0.14);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSos
              ? terracotta.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 25,
            ),
          ),

          const SizedBox(width: 15),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    if (isSos)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: terracotta.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'SOS',
                          style: TextStyle(
                            color: terracotta,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  alert.message,
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 12),

                // Date pill
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: darkSage.withValues(alpha: 0.75),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        alert.date,
                        style: TextStyle(
                          color: darkSage.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// Empty State
// ------------------------------------------------------------

class _EmptyAlertState extends StatelessWidget {
  const _EmptyAlertState();

  static const Color sage = Color(0xFF7FA68F);
  static const Color darkSage = Color(0xFF46695A);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: sage.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 45,
                color: darkSage,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'All clear for now',
              style: TextStyle(
                color: textDark,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'New alerts from the care circle will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// Error State
// ------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  static const Color terracotta = Color(0xFFC85C50);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: terracotta.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: terracotta,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Unable to load alerts',
              style: TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
}