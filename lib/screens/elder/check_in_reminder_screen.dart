import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/check_in_reminder_service.dart';

class CheckInReminderScreen extends StatefulWidget {
  const CheckInReminderScreen({
    super.key,
    required this.elderId,
  });

  final String elderId;

  @override
  State<CheckInReminderScreen> createState() =>
      _CheckInReminderScreenState();
}

class _CheckInReminderScreenState extends State<CheckInReminderScreen> {
  final CheckInReminderService _reminderService =
      CheckInReminderService();

  Timer? _firstTimer;
  Timer? _secondTimer;
  Timer? _caregiverTimer;

  String? _runningReminderId;
  TimeOfDay? _selectedTime;

  Future<void> _selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (!mounted) return;
    if (selectedTime == null) return;

    setState(() {
      _selectedTime = selectedTime;
    });
  }

  Future<void> _createReminder() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a check-in time first.'),
        ),
      );
      return;
    }

    final now = DateTime.now();

    DateTime scheduledLocal = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // If the selected time has already passed today,
    // schedule it for tomorrow.
    if (scheduledLocal.isBefore(now)) {
      scheduledLocal = scheduledLocal.add(
        const Duration(days: 1),
      );
    }

    // Store the exact time in UTC for Cloud Functions.
    final scheduledUtc = scheduledLocal.toUtc().toIso8601String();

    try {
      await _reminderService.createReminder(
        elderId: widget.elderId,
        scheduledTime: scheduledUtc,
      );

      if (!mounted) return;

      setState(() {
        _selectedTime = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Daily check-in reminder saved to Firebase.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to create reminder: $e',
          ),
        ),
      );
    }
  }

  void _startReminder(String reminderId) {
    if (_runningReminderId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A reminder is already running.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _runningReminderId = reminderId;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Demo started. First reminder in 10 seconds.',
        ),
      ),
    );

    // First reminder after 10 seconds
    _firstTimer = Timer(
      const Duration(seconds: 10),
      () {
        if (!mounted) return;

        _showNotification(
          'Daily Check-in Reminder',
          'Please complete your daily check-in.',
        );
      },
    );

    // Second reminder after 25 seconds
    _secondTimer = Timer(
      const Duration(seconds: 25),
      () {
        if (!mounted) return;

        _showNotification(
          'Second Check-in Reminder',
          'You have not completed your check-in yet.',
        );
      },
    );

    // Caregiver notification after 40 seconds
    _caregiverTimer = Timer(
      const Duration(seconds: 40),
      () async {
        if (!mounted) return;

        _showNotification(
          'Caregiver Notification',
          'The elder has not completed the scheduled check-in.',
        );

        try {
          await _reminderService.markCaregiverNotified(
            widget.elderId,
            reminderId,
          );
        } catch (_) {
          // Ignore notification update errors during demo.
        }

        if (mounted) {
          setState(() {
            _runningReminderId = null;
          });
        }
      },
    );
  }

  void _showNotification(
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.notifications_active,
                color: Color(0xFF164A63),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 17,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _firstTimer?.cancel();
    _secondTimer?.cancel();
    _caregiverTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
      appBar: AppBar(
        title: const Text(
          'Check-in Reminders',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF164A63),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Daily Check-in Reminder',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF163B4D),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Set the time for the daily check-in.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF63747B),
                ),
              ),
              const SizedBox(height: 25),

              // Time selection
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: _selectTime,
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    _selectedTime == null
                        ? 'SELECT CHECK-IN TIME'
                        : 'TIME: ${_selectedTime!.format(context)}',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Create reminder
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _createReminder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16845B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'CREATE REMINDER',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Reminders',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF163B4D),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: StreamBuilder(
                  stream: _reminderService
                      .getReminders(widget.elderId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Unable to load reminders: '
                          '${snapshot.error}',
                        ),
                      );
                    }

                    final reminders = snapshot.data ?? [];

                    if (reminders.isEmpty) {
                      return const Center(
                        child: Text(
                          'No reminders created yet.',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = reminders[index];

                        final completed =
                            reminder.status == 'COMPLETED';

                        final running =
                            _runningReminderId == reminder.id;

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: ListTile(
                            leading: Icon(
                              completed
                                  ? Icons.check_circle
                                  : Icons.alarm,
                              color: completed
                                  ? Colors.green
                                  : Colors.orange,
                              size: 32,
                            ),
                            title: Text(
                              reminder.scheduledTime,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Status: ${reminder.status}',
                            ),
                            trailing: completed
                                ? const Icon(
                                    Icons.done,
                                    color: Colors.green,
                                  )
                                : running
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child:
                                            CircularProgressIndicator(),
                                      )
                                    : ElevatedButton(
                                        onPressed: () {
                                          _startReminder(
                                            reminder.id,
                                          );
                                        },
                                        child: const Text(
                                          'START',
                                        ),
                                      ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}