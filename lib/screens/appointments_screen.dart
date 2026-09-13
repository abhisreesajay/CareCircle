import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';

class AppointmentsScreen extends StatefulWidget {
  final String elderId;

  const AppointmentsScreen({
    super.key,
    required this.elderId,
  });

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final AppointmentService _appointmentService = AppointmentService();

  static const Color primaryGreen = Color(0xFF738F52);
  static const Color darkGreen = Color(0xFF536B3A);
  static const Color lightGreen = Color(0xFFE8EFDF);
  static const Color backgroundColor = Color(0xFFF7F9F3);
  static const Color textColor = Color(0xFF26301F);

  void _showAppointmentDialog({Appointment? appointment}) {
    final doctorController =
        TextEditingController(text: appointment?.doctorName ?? '');
    final hospitalController =
        TextEditingController(text: appointment?.hospitalName ?? '');
    final dateController =
        TextEditingController(text: appointment?.date ?? '');
    final timeController =
        TextEditingController(text: appointment?.time ?? '');
    final purposeController =
        TextEditingController(text: appointment?.purpose ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            appointment == null
                ? 'Add Appointment'
                : 'Edit Appointment',
            style: const TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: doctorController,
                  decoration: InputDecoration(
                    labelText: 'Doctor Name',
                    prefixIcon: const Icon(
                      Icons.person,
                      color: primaryGreen,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primaryGreen,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hospitalController,
                  decoration: InputDecoration(
                    labelText: 'Hospital / Clinic',
                    prefixIcon: const Icon(
                      Icons.local_hospital,
                      color: primaryGreen,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primaryGreen,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: primaryGreen,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primaryGreen,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: 'Time',
                    prefixIcon: const Icon(
                      Icons.access_time,
                      color: primaryGreen,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primaryGreen,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: purposeController,
                  decoration: InputDecoration(
                    labelText: 'Purpose',
                    prefixIcon: const Icon(
                      Icons.description,
                      color: primaryGreen,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primaryGreen,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: darkGreen,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (doctorController.text.trim().isEmpty) {
                  return;
                }

                final newAppointment = Appointment(
                  id: appointment?.id ??
                      DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
                  doctorName: doctorController.text.trim(),
                  hospitalName: hospitalController.text.trim(),
                  date: dateController.text.trim(),
                  time: timeController.text.trim(),
                  purpose: purposeController.text.trim(),
                );

                if (appointment == null) {
                  await _appointmentService.addAppointment(
                    widget.elderId,
                    newAppointment,
                  );
                } else {
                  await _appointmentService.updateAppointment(
                    widget.elderId,
                    newAppointment,
                  );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(
                appointment == null ? 'Add' : 'Update',
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    await _appointmentService.deleteAppointment(
      widget.elderId,
      appointmentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: _appointmentService.getAppointments(
          widget.elderId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: darkGreen,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final appointments = snapshot.data ?? [];

          if (appointments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 70,
                    color: primaryGreen,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No appointments added yet.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tap + to add an appointment.',
                    style: TextStyle(
                      color: darkGreen,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];

              return Card(
                color: lightGreen,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      size: 28,
                      color: darkGreen,
                    ),
                  ),
                  title: Text(
                    appointment.doctorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: textColor,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${appointment.hospitalName}\n'
                      '${appointment.date} • '
                      '${appointment.time}\n'
                      '${appointment.purpose}',
                      style: const TextStyle(
                        height: 1.5,
                      ),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: darkGreen,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAppointmentDialog(
                          appointment: appointment,
                        );
                      } else if (value == 'delete') {
                        _deleteAppointment(
                          appointment.id,
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: darkGreen,
                            ),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: darkGreen,
                            ),
                            SizedBox(width: 10),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          _showAppointmentDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}