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
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: doctorController,
                  decoration: const InputDecoration(
                    labelText: 'Doctor Name',
                  ),
                ),
                TextField(
                  controller: hospitalController,
                  decoration: const InputDecoration(
                    labelText: 'Hospital / Clinic',
                  ),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                  ),
                ),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time',
                  ),
                ),
                TextField(
                  controller: purposeController,
                  decoration: const InputDecoration(
                    labelText: 'Purpose',
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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
      appBar: AppBar(
        title: const Text('Appointments'),
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: _appointmentService.getAppointments(
          widget.elderId,
        ),
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
                'Error: ${snapshot.error}',
              ),
            );
          }

          final appointments = snapshot.data ?? [];

          if (appointments.isEmpty) {
            return const Center(
              child: Text(
                'No appointments added yet.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(
                    Icons.calendar_month,
                    size: 35,
                  ),
                  title: Text(
                    appointment.doctorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${appointment.hospitalName}\n'
                    '${appointment.date} • '
                    '${appointment.time}\n'
                    '${appointment.purpose}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
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
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
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
        onPressed: () {
          _showAppointmentDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}