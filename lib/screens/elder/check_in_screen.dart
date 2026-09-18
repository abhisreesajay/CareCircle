import 'package:flutter/material.dart';
import '../../services/check_in_history_service.dart';
import '../../services/check_in_reminder_service.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({
    super.key,
    required this.elderId,
  });

  final String elderId;

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool _saving = false;

  Future<void> _saveCheckIn(String status) async {
    setState(() {
      _saving = true;
    });

    try {
      await CheckInHistoryService().saveCheckIn(
        elderId: widget.elderId,
        status: status,
      );

      if (status == 'COMPLETED') {
        final reminderService = CheckInReminderService();

        final reminderId =
            await reminderService.getPendingReminderId(widget.elderId);

        if (reminderId != null) {
          await reminderService.completeReminder(
            elderId: widget.elderId,
            reminderId: reminderId,
          );
        }
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            status == 'COMPLETED'
                ? 'Check-in Complete'
                : 'Help Requested',
          ),
          content: Text(
            status == 'COMPLETED'
                ? 'Your daily check-in has been recorded.'
                : 'Your request for help has been recorded.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save check-in: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
      appBar: AppBar(
        title: const Text(
          'Daily Check-in',
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
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              const Text(
                'How are you feeling today?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF163B4D),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Please select one option.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  color: Color(0xFF63747B),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 110,
                child: ElevatedButton(
                  onPressed:
                      _saving ? null : () => _saveCheckIn('COMPLETED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16845B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "I'M OK",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 110,
                child: ElevatedButton(
                  onPressed:
                      _saving ? null : () => _saveCheckIn('HELP_REQUESTED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'NEED HELP',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              const Text(
                'Your check-in will be saved securely.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF63747B),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
