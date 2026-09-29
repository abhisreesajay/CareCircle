import 'package:flutter/material.dart';

import '../../models/alert_model.dart';
import '../../services/caregiver/alert_service.dart';

class AlertsScreen extends StatelessWidget {
  final String elderId;

  const AlertsScreen({
    super.key,
    required this.elderId,
  });

  // ============================================================
  // CARECIRCLE PALETTE
  // ============================================================

  static const Color darkSage = Color(0xFF46695A);
  static const Color sage = Color(0xFF7FA68F);
  static const Color cream = Color(0xFFFFFBF4);
  static const Color background = Color(0xFFF4EFE5);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color safeZoneOrange = Color(0xFFE58F3D);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    final AlertService service = AlertService();

    return Scaffold(
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
      body: StreamBuilder<List<CareAlert>>(
        stream: service.getAlerts(elderId),
        builder: (context, snapshot) {
          // ======================================================
          // LOADING
          // ======================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: darkSage,
              ),
            );
          }

          // ======================================================
          // ERROR
          // ======================================================

          if (snapshot.hasError) {
            return const _ErrorState();
          }

          // ======================================================
          // ALERTS
          // ======================================================

          final List<CareAlert> alerts =
              snapshot.data ?? <CareAlert>[];

          if (alerts.isEmpty) {
            return const _EmptyAlertState();
          }

          // ======================================================
          // ALERT COUNTS
          // ======================================================

          final int sosCount = alerts
              .where(
                (alert) => alert.type == 'sos',
              )
              .length;

          final int safeZoneCount = alerts
              .where(
                (alert) =>
                    alert.type == 'safe_zone' ||
                    alert.type == 'safezone',
              )
              .length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              100,
            ),
            children: [
              // ==================================================
              // INTRO CARD
              // ==================================================

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
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
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
                            '${alerts.length} alert'
                            '${alerts.length == 1 ? '' : 's'} '
                            'in your care circle',
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

              // ==================================================
              // SOS SUMMARY
              // ==================================================

              if (sosCount > 0)
                _AlertSummaryCard(
                  count: sosCount,
                  label:
                      'SOS alert'
                      '${sosCount == 1 ? '' : 's'} '
                      'need attention',
                  icon: Icons.warning_rounded,
                  color: terracotta,
                ),

              if (sosCount > 0)
                const SizedBox(height: 12),

              // ==================================================
              // SAFE ZONE SUMMARY
              // ==================================================

              if (safeZoneCount > 0)
                _AlertSummaryCard(
                  count: safeZoneCount,
                  label:
                      'safe zone alert'
                      '${safeZoneCount == 1 ? '' : 's'} '
                      'need attention',
                  icon: Icons.location_off_rounded,
                  color: safeZoneOrange,
                ),

              if (safeZoneCount > 0)
                const SizedBox(height: 24),

              // ==================================================
              // RECENT ALERTS
              // ==================================================

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
                (alert) => _AlertCard(
                  alert: alert,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// ALERT SUMMARY CARD
// ============================================================

class _AlertSummaryCard extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color color;

  const _AlertSummaryCard({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
  });

  static const Color textDark = Color(0xFF26352F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              '$count $label',
              style: const TextStyle(
                color: textDark,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ALERT CARD
// ============================================================

class _AlertCard extends StatelessWidget {
  final CareAlert alert;

  const _AlertCard({
    required this.alert,
  });

  static const Color sage = Color(0xFF7FA68F);
  static const Color darkSage = Color(0xFF46695A);
  static const Color cream = Color(0xFFFFFBF4);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color safeZoneOrange = Color(0xFFE58F3D);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // ALERT TYPES
    // ==========================================================

    final bool isSos = alert.type == 'sos';

    final bool isCheckIn =
        alert.type == 'checkin';

    final bool isSafeZone =
        alert.type == 'safe_zone' ||
        alert.type == 'safezone';

    final bool isMedicine =
        alert.type == 'medicine';

    // ==========================================================
    // ICON
    // ==========================================================

    final IconData icon = isSos
        ? Icons.warning_rounded
        : isSafeZone
            ? Icons.location_off_rounded
            : isCheckIn
                ? Icons.check_circle_rounded
                : isMedicine
                    ? Icons.medication_rounded
                    : Icons.notifications_rounded;

    // ==========================================================
    // ICON COLOR
    // ==========================================================

    final Color iconColor = isSos
        ? terracotta
        : isSafeZone
            ? safeZoneOrange
            : isCheckIn
                ? darkSage
                : sage;

    // ==========================================================
    // ICON BACKGROUND
    // ==========================================================

    final Color iconBackground = isSos
        ? terracotta.withValues(alpha: 0.12)
        : isSafeZone
            ? safeZoneOrange.withValues(alpha: 0.12)
            : sage.withValues(alpha: 0.14);

    // ==========================================================
    // CARD
    // ==========================================================

    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSos
              ? terracotta.withValues(alpha: 0.25)
              : isSafeZone
                  ? safeZoneOrange.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ======================================================
          // ICON
          // ======================================================

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

          // ======================================================
          // CONTENT
          // ======================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ==================================================
                // TITLE + BADGE
                // ==================================================

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                      const _AlertBadge(
                        label: 'SOS',
                        color: terracotta,
                      ),

                    if (isSafeZone)
                      const _AlertBadge(
                        label: 'SAFE ZONE',
                        color: safeZoneOrange,
                      ),

                    if (isCheckIn)
                      const _AlertBadge(
                        label: 'CHECK-IN',
                        color: darkSage,
                      ),

                    if (isMedicine)
                      const _AlertBadge(
                        label: 'MEDICINE',
                        color: sage,
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // ==================================================
                // MESSAGE
                // ==================================================

                Text(
                  alert.message,
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // DATE
                // ==================================================

                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: darkSage.withValues(
                        alpha: 0.75,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        alert.date,
                        style: TextStyle(
                          color: darkSage.withValues(
                            alpha: 0.85,
                          ),
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

// ============================================================
// ALERT BADGE
// ============================================================

class _AlertBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _AlertBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

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
          mainAxisAlignment:
              MainAxisAlignment.center,
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
              'New alerts from the care circle '
              'will appear here.',
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

// ============================================================
// ERROR STATE
// ============================================================

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  static const Color terracotta =
      Color(0xFFC85C50);
  static const Color textDark =
      Color(0xFF26352F);
  static const Color mutedText =
      Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: terracotta.withValues(
                  alpha: 0.10,
                ),
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
              'Please check your connection '
              'and try again.',
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
}