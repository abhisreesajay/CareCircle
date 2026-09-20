import 'package:flutter/material.dart';
import '../../models/check_in_history_model.dart';
import '../../services/caregiver/check_in_history_service.dart';

class CheckInHistoryScreen extends StatelessWidget {
  final String elderId;

  const CheckInHistoryScreen({
    super.key,
    required this.elderId,
  });

  static const Color darkSage = Color(0xFF46695A);
  static const Color sage = Color(0xFF7FA68F);
  static const Color cream = Color(0xFFFFFBF4);
  static const Color background = Color(0xFFF4EFE5);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    final service = CheckInHistoryService();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textDark,
        elevation: 0,
        title: const Text(
          'Check-in History',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<List<CheckInHistory>>(
        stream: service.getCheckInHistory(elderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: darkSage),
            );
          }

          if (snapshot.hasError) {
            return const _ErrorState();
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return const _EmptyState();
          }

          final completed = history
              .where((item) => item.status.toLowerCase() == 'completed')
              .length;

          final missed = history
              .where((item) => item.status.toLowerCase() == 'missed')
              .length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: darkSage,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Check-in overview',
                      style: TextStyle(
                        color: cream,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _SummaryPill(
                          value: '${history.length}',
                          label: 'Total',
                        ),
                        const SizedBox(width: 10),
                        _SummaryPill(
                          value: '$completed',
                          label: 'Completed',
                        ),
                        const SizedBox(width: 10),
                        _SummaryPill(
                          value: '$missed',
                          label: 'Missed',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent check-ins',
                style: TextStyle(
                  color: textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...history.map(
                (item) => _CheckInCard(item: item),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryPill({
    required this.value,
    required this.label,
  });

  static const Color cream = Color(0xFFFFFBF4);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cream.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: cream,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: cream.withValues(alpha: 0.70),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  final CheckInHistory item;

  const _CheckInCard({
    required this.item,
  });

  static const Color sage = Color(0xFF7FA68F);
  static const Color darkSage = Color(0xFF46695A);
  static const Color cream = Color(0xFFFFFBF4);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    final completed = item.status.toLowerCase() == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: completed
              ? sage.withValues(alpha: 0.20)
              : terracotta.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: completed
                  ? sage.withValues(alpha: 0.13)
                  : terracotta.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed
                  ? Icons.check_circle_rounded
                  : Icons.warning_rounded,
              color: completed ? darkSage : terracotta,
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.date,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Scheduled: ${item.scheduledTime}',
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.status,
                  style: TextStyle(
                    color: completed ? darkSage : terracotta,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  static const Color sage = Color(0xFF7FA68F);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 65,
              color: sage,
            ),
            const SizedBox(height: 18),
            const Text(
              'No check-ins yet',
              style: TextStyle(
                color: textDark,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check-in history will appear here.',
              style: TextStyle(color: mutedText),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  static const Color terracotta = Color(0xFFC85C50);
  static const Color textDark = Color(0xFF26352F);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 55,
              color: terracotta,
            ),
            SizedBox(height: 16),
            Text(
              'Unable to load check-in history',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}