import 'package:flutter/material.dart';
import '../../models/activity_history_model.dart';
<<<<<<< HEAD
import '../../services/activity_history_service.dart';
=======
import '../../services/caregiver/activity_history_service.dart';
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317

class ActivityHistoryScreen extends StatelessWidget {
  final String elderId;

  const ActivityHistoryScreen({
    super.key,
    required this.elderId,
  });

<<<<<<< HEAD
  static const Color primaryGreen = Color(0xFF738F52);
  static const Color darkGreen = Color(0xFF536B3A);
  static const Color lightGreen = Color(0xFFE8EFDF);
  static const Color backgroundColor = Color(0xFFF7F9F3);
  static const Color textColor = Color(0xFF26301F);
=======
  // CareCircle palette
  static const Color sage = Color(0xFF7FA68F);
  static const Color darkSage = Color(0xFF46695A);
  static const Color cream = Color(0xFFFFFBF4);
  static const Color background = Color(0xFFF4EFE5);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317

  @override
  Widget build(BuildContext context) {
    final service = ActivityHistoryService();

    return Scaffold(
<<<<<<< HEAD
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Activity History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
=======
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Activity History',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
      ),

>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
      body: StreamBuilder<List<ActivityHistory>>(
        stream: service.getActivityHistory(elderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
<<<<<<< HEAD
                color: primaryGreen,
=======
                color: darkSage,
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
              ),
            );
          }

          if (snapshot.hasError) {
<<<<<<< HEAD
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
                    SizedBox(height: 16),
                    Text(
                      'Unable to load activity history',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
=======
            return const _ErrorState();
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
          }

          final activities = snapshot.data ?? [];

          if (activities.isEmpty) {
<<<<<<< HEAD
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 65,
                      color: primaryGreen,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No activity history available',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: textColor,
=======
            return const _EmptyActivityState();
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              // Header / summary card
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
                        Icons.auto_graph_rounded,
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
                            'A look back',
                            style: TextStyle(
                              color: cream,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${activities.length} recorded activit${activities.length == 1 ? 'y' : 'ies'}',
                            style: TextStyle(
                              color: cream.withValues(alpha: 0.78),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
                      ),
                    ),
                  ],
                ),
              ),
<<<<<<< HEAD
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 2,
                shadowColor: Colors.black12,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.history,
                          size: 28,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.activity,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 15,
                                  color: darkGreen,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    activity.date,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.access_time,
                                  size: 15,
                                  color: darkGreen,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  activity.time,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
=======

              const SizedBox(height: 24),

              const Text(
                'Recent activity',
                style: TextStyle(
                  color: textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              ...activities.map(
                (activity) => _ActivityCard(
                  activity: activity,
                ),
              ),
            ],
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
          );
        },
      ),
    );
  }
<<<<<<< HEAD
=======
}

// ------------------------------------------------------------
// Activity Card
// ------------------------------------------------------------

class _ActivityCard extends StatelessWidget {
  final ActivityHistory activity;

  const _ActivityCard({
    required this.activity,
  });

  static const Color sage = Color(0xFF7FA68F);
  static const Color darkSage = Color(0xFF46695A);
  static const Color cream = Color(0xFFFFFBF4);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: sage.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              color: darkSage,
              size: 26,
            ),
          ),

          const SizedBox(width: 15),

          // Activity information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.activity,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                // Date
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: sage.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: darkSage,
                      ),
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        activity.date,
                        style: const TextStyle(
                          color: mutedText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Time
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: sage.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: darkSage,
                      ),
                    ),

                    const SizedBox(width: 9),

                    Text(
                      activity.time,
                      style: const TextStyle(
                        color: mutedText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
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

class _EmptyActivityState extends StatelessWidget {
  const _EmptyActivityState();

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
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: sage.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 46,
                color: darkSage,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No activity yet',
              style: TextStyle(
                color: textDark,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Recorded activities will appear here as they happen.',
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
              'Unable to load activity history',
              textAlign: TextAlign.center,
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
}