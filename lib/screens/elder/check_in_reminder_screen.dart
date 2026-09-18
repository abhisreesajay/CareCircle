import 'dart:async';

import 'package:flutter/material.dart';

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

class _CheckInReminderScreenState
    extends State<CheckInReminderScreen> {
  final TextEditingController _timeController =
      TextEditingController();

  final List<Map<String, String>> _reminders = [];

  Timer? _firstTimer;
  Timer? _secondTimer;
  Timer? _caregiverTimer;

  bool _running = false;

  void _createReminder() {
    if (_timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a scheduled time.'),
        ),
      );
      return;
    }

    setState(() {
      _reminders.add({
        'time': _timeController.text.trim(),
        'status': 'PENDING',
      });
    });

    _timeController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Daily check-in reminder created.'),
      ),
    );
  }

  void _startReminder(int index) {
    if (_running) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A reminder is already running.'),
        ),
      );
      return;
    }

    setState(() {
      _running = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Demo started. First reminder in 10 seconds.',
        ),
      ),
    );

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

    _caregiverTimer = Timer(
      const Duration(seconds: 40),
      () {
        if (!mounted) return;

        _showNotification(
          'Caregiver Notification',
          'The elder has not completed the scheduled check-in.',
        );

        setState(() {
          _running = false;
        });
      },
    );
  }

  void _completeReminder(int index) {
    _firstTimer?.cancel();
    _secondTimer?.cancel();
    _caregiverTimer?.cancel();

    setState(() {
      _reminders[index]['status'] = 'COMPLETED';
      _running = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Check-in completed. Caregiver notification cancelled.',
        ),
      ),
    );
  }

  void _showNotification(String title, String message) {
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
            style: const TextStyle(fontSize: 17),
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
    _timeController.dispose();
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

              TextField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: 'Scheduled time',
                  hintText: 'Example: 09:00 AM',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.access_time),
                ),
              ),

              const SizedBox(height: 20),

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
                child: _reminders.isEmpty
                    ? const Center(
                        child: Text(
                          'No reminders created yet.',
                          style: TextStyle(fontSize: 17),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _reminders.length,
                        itemBuilder: (context, index) {
                          final reminder = _reminders[index];

                          final completed =
                              reminder['status'] == 'COMPLETED';

                          return Card(
                            margin:
                                const EdgeInsets.only(bottom: 12),
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
                                reminder['time']!,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Status: ${reminder['status']}',
                              ),
                              trailing: completed
                                  ? const Icon(
                                      Icons.done,
                                      color: Colors.green,
                                    )
                                  : ElevatedButton(
                                      onPressed: _running
                                          ? null
                                          : () => _startReminder(
                                                index,
                                              ),
                                      child: const Text('START'),
                                    ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 10),

              if (_reminders.isNotEmpty && !_running)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      final index = _reminders.length - 1;

                      _completeReminder(index);
                    },
                    child: const Text(
                      'MARK CHECK-IN COMPLETE',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

              if (_running)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Reminder sequence is running...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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