import 'package:flutter/material.dart';
import '../services/sos_service.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final SosService _sosService = SosService();

  bool _sosActive = false;
  bool _loading = false;
  String? _sosId;

  Future<void> _triggerSOS() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency SOS'),
        content: const Text(
          'Are you sure you want to send an emergency SOS?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SEND SOS'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _loading = true;
    });

    try {
      final sos = await _sosService.createSos('demo-user-001');

      setState(() {
        _sosId = sos.id;
        _sosActive = true;
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS sent successfully!'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send SOS: $e'),
          ),
        );
      }
    }
  }

  Future<void> _cancelSOS() async {
    if (_sosId == null) return;

    setState(() {
      _loading = true;
    });

    try {
      await _sosService.cancelSos(_sosId!);

      setState(() {
        _sosActive = false;
        _sosId = null;
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS cancelled'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel SOS: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency & Safety'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_sosActive) ...[
                      const Icon(
                        Icons.warning_rounded,
                        size: 90,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'SOS ACTIVE',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _cancelSOS,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text(
                            'CANCEL SOS',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.emergency,
                        size: 100,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Emergency SOS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Press the button below if you need emergency help.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 35),
                      SizedBox(
                        width: double.infinity,
                        height: 65,
                        child: ElevatedButton(
                          onPressed: _triggerSOS,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'SEND SOS',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}