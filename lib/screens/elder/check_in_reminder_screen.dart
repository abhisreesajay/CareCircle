<<<<<<< HEAD
import 'package:flutter/material.dart';

class CheckInReminderScreen extends StatelessWidget {
=======
import 'dart:async';

import 'package:flutter/material.dart';

class CheckInReminderScreen extends StatefulWidget {
>>>>>>> develop
  const CheckInReminderScreen({
    super.key,
    required this.elderId,
  });

  final String elderId;

  @override
<<<<<<< HEAD
=======
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
>>>>>>> develop
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
<<<<<<< HEAD
              const SizedBox(height: 30),

              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F6EF),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  size: 50,
                  color: Color(0xFF16845B),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Daily Check-in Reminders',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 27,
=======
              const Text(
                'Daily Check-in Reminder',
                style: TextStyle(
                  fontSize: 28,
>>>>>>> develop
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF163B4D),
                ),
              ),

<<<<<<< HEAD
              const SizedBox(height: 15),

              const Text(
                'Your daily check-in reminders are scheduled automatically.',
=======
              const SizedBox(height: 12),

              const Text(
                'Set the time for the daily check-in.',
>>>>>>> develop
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF63747B),
<<<<<<< HEAD
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 35),

              _buildReminderCard(
                icon: Icons.wb_sunny_rounded,
                time: '10:00 AM',
                label: 'Morning Check-in',
              ),

              const SizedBox(height: 15),

              _buildReminderCard(
                icon: Icons.wb_cloudy_rounded,
                time: '2:00 PM',
                label: 'Afternoon Check-in',
              ),

              const SizedBox(height: 15),

              _buildReminderCard(
                icon: Icons.nightlight_round,
                time: '9:00 PM',
                label: 'Night Check-in',
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF3867A6),
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You do not need to set or start a reminder. Care Circle will automatically send your check-in notification at the scheduled times.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF38566F),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF164A63),
=======
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
>>>>>>> develop
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
<<<<<<< HEAD
                    'BACK',
                    style: TextStyle(
                      fontSize: 18,
=======
                    'CREATE REMINDER',
                    style: TextStyle(
                      fontSize: 20,
>>>>>>> develop
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
<<<<<<< HEAD
=======

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
>>>>>>> develop
            ],
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD

  Widget _buildReminderCard({
    required IconData icon,
    required String time,
    required String label,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2DE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFB36B00),
              size: 32,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF163B4D),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF164A63),
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle,
            color: Color(0xFF16845B),
            size: 30,
          ),
        ],
      ),
    );
  }
=======
>>>>>>> develop
}