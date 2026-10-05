import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/caregiver/elder_status_service.dart';

class ElderStatusScreen extends StatelessWidget {
  final String elderId;

  ElderStatusScreen({
    super.key,
    required this.elderId,
  });

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const Color backgroundColor = Color(0xFFF4EFE5);
  static const Color sage = Color(0xFF7FA68F);
  static const Color darkSage = Color(0xFF46695A);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color cream = Color(0xFFFFFBF4);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Time unavailable';

    final date = dateTime.toLocal();
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}, $hour:$minute $period';
  }

  String _checkInLabel(Map<String, dynamic> data) {
    final raw = data['checkInStatus']?.toString();

    if (raw == null || raw.trim().isEmpty) {
      return 'No check-in recorded';
    }

    switch (raw.toUpperCase()) {
      case 'COMPLETED':
        return 'Completed';
      case 'HELP_REQUESTED':
        return 'Help requested';
      case 'MISSED':
        return 'Missed';
      case 'PENDING':
        return 'Pending';
      default:
        return raw.replaceAll('_', ' ');
    }
  }

  String _safeZoneLabel(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> zones,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> violations,
  ) {
    if (zones.isEmpty) return 'No safe zone configured';
    if (violations.isEmpty) return 'No location check recorded';

    final latestByZone = <String, Map<String, dynamic>>{};

    for (final doc in violations) {
      final data = doc.data();
      final zoneId = data['safeZoneId']?.toString();

      if (zoneId == null || zoneId.isEmpty) continue;

      final currentTime = _toDate(data['lastCheckedAt']) ??
          _toDate(data['timestamp']) ??
          _toDate(data['createdAt']);

      final previous = latestByZone[zoneId];
      final previousTime = previous == null
          ? null
          : (_toDate(previous['lastCheckedAt']) ??
              _toDate(previous['timestamp']) ??
              _toDate(previous['createdAt']));

      if (previous == null ||
          (currentTime != null &&
              (previousTime == null ||
                  currentTime.isAfter(previousTime)))) {
        latestByZone[zoneId] = data;
      }
    }

    final outside = latestByZone.values.where(
      (data) => data['status']?.toString().toUpperCase() == 'OUTSIDE',
    );

    if (outside.isNotEmpty) {
      return 'Last reported outside';
    }

    final safe = latestByZone.values.where(
      (data) => data['status']?.toString().toUpperCase() == 'SAFE',
    );

    if (safe.isNotEmpty && safe.length == zones.length) {
      return 'Last reported inside';
    }

    return 'Location status incomplete';
  }

  String _medicineLabel(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> medicines,
  ) {
    if (medicines.isEmpty) return 'No medicines configured';

    final now = DateTime.now();

    final today = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    int total = 0;
    int taken = 0;

    for (final doc in medicines) {
      final data = doc.data();
      final frequencyValue = data['frequency'];

      final frequency = frequencyValue is num
          ? frequencyValue.toInt()
          : int.tryParse(frequencyValue?.toString() ?? '') ?? 0;

      if (frequency <= 0) continue;

      total += frequency;

      final takenDoses = data['takenDoses'];

      if (takenDoses is! Map) continue;

      final dosesToday = takenDoses[today];

      if (dosesToday is! List) continue;

      final validIndexes = dosesToday
          .whereType<num>()
          .map((value) => value.toInt())
          .where((index) => index >= 0 && index < frequency)
          .toSet();

      taken += validIndexes.length;
    }

    if (total == 0) return 'No scheduled doses';

    return '$taken of $total doses taken today';
  }

  String _activityLabel(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> activities,
  ) {
    if (activities.isEmpty) return 'No activity recorded';

    final data = activities.first.data();

    final description = data['description']?.toString();
    final activity = data['activity']?.toString();
    final type = data['type']?.toString();

    final label = (description != null && description.trim().isNotEmpty)
        ? description.trim()
        : (activity != null && activity.trim().isNotEmpty)
            ? activity.trim()
            : (type != null && type.trim().isNotEmpty)
                ? type.replaceAll('_', ' ')
                : 'Activity recorded';

    final timestamp = _toDate(data['timestamp']);

    if (timestamp == null) return label;

    return '$label · ${_formatDateTime(timestamp)}';
  }

  @override
  Widget build(BuildContext context) {
    final statusStream = ElderStatusService().getStatus(elderId);

    final zonesStream = _firestore
        .collection('safeZones')
        .where('elderId', isEqualTo: elderId)
        .snapshots();

    final violationsStream = _firestore
        .collection('safeZoneViolations')
        .where('elderId', isEqualTo: elderId)
        .snapshots();

    final medicinesStream = _firestore
        .collection('elders')
        .doc(elderId)
        .collection('medicines')
        .snapshots();

    final activitiesStream = _firestore
        .collection('elders')
        .doc(elderId)
        .collection('activityHistory')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Text(
          'Elder status',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: statusStream,
        builder: (context, statusSnapshot) {
          if (statusSnapshot.hasError) {
            return const _ErrorState();
          }

          if (statusSnapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingState();
          }

          final statusData =
              statusSnapshot.data?.data() ?? <String, dynamic>{};

          final checkIn = _checkInLabel(statusData);

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: zonesStream,
            builder: (context, zonesSnapshot) {
              if (zonesSnapshot.hasError) {
                return const _ErrorState();
              }

              if (zonesSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const _LoadingState();
              }

              final zones = zonesSnapshot.data?.docs ?? [];

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: violationsStream,
                builder: (context, violationsSnapshot) {
                  if (violationsSnapshot.hasError) {
                    return const _ErrorState();
                  }

                  if (violationsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const _LoadingState();
                  }

                  final violations = violationsSnapshot.data?.docs ?? [];

                  final safeZone = _safeZoneLabel(zones, violations);

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: medicinesStream,
                    builder: (context, medicinesSnapshot) {
                      if (medicinesSnapshot.hasError) {
                        return const _ErrorState();
                      }

                      if (medicinesSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const _LoadingState();
                      }

                      final medicines = medicinesSnapshot.data?.docs ?? [];

                      final medicine = _medicineLabel(medicines);

                      return StreamBuilder<
                          QuerySnapshot<Map<String, dynamic>>>(
                        stream: activitiesStream,
                        builder: (context, activitiesSnapshot) {
                          if (activitiesSnapshot.hasError) {
                            return const _ErrorState();
                          }

                          if (activitiesSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const _LoadingState();
                          }

                          final activities =
                              activitiesSnapshot.data?.docs ?? [];

                          final activity = _activityLabel(activities);

                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              8,
                              20,
                              30,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _OverviewCard(
                                  checkInStatus: checkIn,
                                  safeZoneStatus: safeZone,
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Today at a glance',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'A quick view of your elder\'s latest '
                                  'recorded information.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: mutedText,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _StatusCard(
                                  icon: Icons.check_circle_outline,
                                  title: 'Check-in',
                                  value: checkIn,
                                  accentColor: darkSage,
                                ),
                                const SizedBox(height: 14),
                                _StatusCard(
                                  icon: Icons.home_outlined,
                                  title: 'Safe zone',
                                  value: safeZone,
                                  accentColor: sage,
                                ),
                                const SizedBox(height: 14),
                                _StatusCard(
                                  icon: Icons.medication_outlined,
                                  title: 'Medicine',
                                  value: medicine,
                                  accentColor: terracotta,
                                ),
                                const SizedBox(height: 14),
                                _StatusCard(
                                  icon: Icons.access_time_outlined,
                                  title: 'Last activity',
                                  value: activity,
                                  accentColor: darkSage,
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
            },
          );
        },
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String checkInStatus;
  final String safeZoneStatus;

  const _OverviewCard({
    required this.checkInStatus,
    required this.safeZoneStatus,
  });

  static const Color darkSage = Color(0xFF46695A);
  static const Color cream = Color(0xFFFFFBF4);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: darkSage,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cream.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.favorite_outline,
                  color: cream,
                  size: 29,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Text(
                  'How are things?',
                  style: TextStyle(
                    color: cream,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Here is the latest information available for your elder.',
            style: TextStyle(
              color: cream.withValues(alpha: 0.72),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _OverviewPill(
                  label: 'Check-in',
                  value: checkInStatus,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OverviewPill(
                  label: 'Safe zone',
                  value: safeZoneStatus,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewPill extends StatelessWidget {
  final String label;
  final String value;

  const _OverviewPill({
    required this.label,
    required this.value,
  });

  static const Color cream = Color(0xFFFFFBF4);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cream.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: cream.withValues(alpha: 0.62),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: cream,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accentColor;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accentColor,
  });

  static const Color cream = Color(0xFFFFFBF4);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    // This card is intentionally non-interactive.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 29,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: mutedText,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textDark,
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

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF46695A),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  static const Color cream = Color(0xFFFFFBF4);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: terracotta.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 34,
                  color: terracotta,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Unable to load elder status',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Please check your connection and permissions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}