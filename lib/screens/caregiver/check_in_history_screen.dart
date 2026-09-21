import 'package:flutter/material.dart';

import '../../models/check_in_history_model.dart';
import '../../services/check_in_service.dart';
import '../../services/caregiver/check_in_history_service.dart';

class CheckInHistoryScreen extends StatefulWidget {
  final String elderId;

  const CheckInHistoryScreen({
    super.key,
    required this.elderId,
  });

  @override
  State<CheckInHistoryScreen> createState() =>
      _CheckInHistoryScreenState();
}

class _CheckInHistoryScreenState
    extends State<CheckInHistoryScreen> {
  final CheckInService _checkInService =
      CheckInService();

  static const Color darkSage =
      Color(0xFF46695A);

  static const Color sage =
      Color(0xFF7FA68F);

  static const Color cream =
      Color(0xFFFFFBF4);

  static const Color background =
      Color(0xFFF4EFE5);

  static const Color terracotta =
      Color(0xFFC85C50);

  static const Color textDark =
      Color(0xFF26352F);

  static const Color mutedText =
      Color(0xFF7A827D);

  Future<void> _markCheckedIn(
    CheckInHistory item,
  ) async {
    try {
      await _checkInService.markCheckedIn(
        elderId: widget.elderId,
        checkInId: item.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Check-in marked as completed.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not update check-in: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final service =
        CheckInHistoryService();

    return Scaffold(
      backgroundColor:
          background,
      appBar: AppBar(
        backgroundColor:
            background,
        foregroundColor:
            textDark,
        elevation: 0,
        title: const Text(
          'Check-in History',
          style: TextStyle(
            fontSize: 26,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<
          List<CheckInHistory>>(
        stream:
            service.getCheckInHistory(
          widget.elderId,
        ),
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color: darkSage,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load check-in history.',
              ),
            );
          }

          final history =
              snapshot.data ?? [];

          if (history.isEmpty) {
            return const Center(
              child: Text(
                'No check-ins yet.',
                style: TextStyle(
                  fontSize: 18,
                  color: mutedText,
                ),
              ),
            );
          }

          final completed =
              history.where(
            (item) =>
                item.status
                    .toLowerCase() ==
                'completed',
          ).length;

          final missed =
              history.where(
            (item) =>
                item.status
                    .toLowerCase() ==
                'missed',
          ).length;

          return ListView(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              100,
            ),
            children: [
              Container(
                padding:
                    const EdgeInsets.all(22),
                decoration:
                    BoxDecoration(
                  color: darkSage,
                  borderRadius:
                      BorderRadius.circular(
                    28,
                  ),
                ),
                child: Row(
                  children: [
                    _SummaryPill(
                      value:
                          '${history.length}',
                      label: 'Total',
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    _SummaryPill(
                      value:
                          '$completed',
                      label:
                          'Completed',
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    _SummaryPill(
                      value: '$missed',
                      label: 'Missed',
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              ...history.map(
                (item) {
                  final bool completed =
                      item.status
                              .toLowerCase() ==
                          'completed';

                  return Container(
                    margin:
                        const EdgeInsets.only(
                      bottom: 14,
                    ),
                    padding:
                        const EdgeInsets.all(
                      18,
                    ),
                    decoration:
                        BoxDecoration(
                      color: cream,
                      borderRadius:
                          BorderRadius.circular(
                        24,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              completed
                                  ? Icons
                                      .check_circle_rounded
                                  : Icons
                                      .warning_rounded,
                              color: completed
                                  ? darkSage
                                  : terracotta,
                              size: 30,
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
                                    item.date,
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          16,
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                      color:
                                          textDark,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Scheduled: ${item.scheduledTime}',
                                    style:
                                        const TextStyle(
                                      color:
                                          mutedText,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    item.status,
                                    style:
                                        TextStyle(
                                      color:
                                          completed
                                              ? darkSage
                                              : terracotta,
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        if (!completed)
                          const SizedBox(
                            height: 14,
                          ),

                        if (!completed)
                          SizedBox(
                            width:
                                double.infinity,
                            child:
                                ElevatedButton.icon(
                              onPressed:
                                  () =>
                                      _markCheckedIn(
                                item,
                              ),
                              icon:
                                  const Icon(
                                Icons
                                    .check_circle_outline,
                              ),
                              label:
                                  const Text(
                                'MARK AS CHECKED IN',
                              ),
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    darkSage,
                                foregroundColor:
                                    Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryPill
    extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryPill({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            label,
            style:
                const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}