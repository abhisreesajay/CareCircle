import 'package:flutter/material.dart';
import '../../models/appointment_model.dart';
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
import '../../services/appointment_service.dart';
=======
import '../../services/caregiver/appointment_service.dart';
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
import '../../services/caregiver/appointment_service.dart';
>>>>>>> develop
=======
import '../../services/caregiver/appointment_service.dart';
>>>>>>> origin/main

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

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
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
<<<<<<< HEAD
=======
=======
>>>>>>> origin/main
  static const Color cream = Color(0xFFF4EFE5);
  static const Color darkSage = Color(0xFF46695A);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color cardCream = Color(0xFFFFFBF4);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  Future<void> _showAppointmentDialog({
    Appointment? appointment,
  }) async {
    final doctorController = TextEditingController(
      text: appointment?.doctorName ?? '',
    );

    final hospitalController = TextEditingController(
      text: appointment?.hospitalName ?? '',
    );

    final dateController = TextEditingController(
      text: appointment?.date ?? '',
    );

    final timeController = TextEditingController(
      text: appointment?.time ?? '',
    );

    final purposeController = TextEditingController(
      text: appointment?.purpose ?? '',
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            appointment == null
                ? 'Add appointment'
                : 'Edit appointment',
            style: const TextStyle(
              color: textDark,
              fontWeight: FontWeight.w800,
<<<<<<< HEAD
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
>>>>>>> origin/main
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
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
<<<<<<< HEAD
=======
=======
>>>>>>> origin/main
                _DialogField(
                  controller: doctorController,
                  label: 'Doctor name',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                _DialogField(
                  controller: hospitalController,
                  label: 'Hospital / clinic',
                  icon: Icons.local_hospital_outlined,
                ),
                const SizedBox(height: 12),
                _DialogField(
                  controller: dateController,
                  label: 'Date',
                  icon: Icons.calendar_today_outlined,
                  hint: 'e.g. 18/09/2026',
                ),
                const SizedBox(height: 12),
                _DialogField(
                  controller: timeController,
                  label: 'Time',
                  icon: Icons.schedule_outlined,
                  hint: 'e.g. 10:30 AM',
                ),
                const SizedBox(height: 12),
                _DialogField(
                  controller: purposeController,
                  label: 'Purpose',
                  icon: Icons.notes_rounded,
                  maxLines: 2,
                  hint: 'e.g. Routine check-up',
<<<<<<< HEAD
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
>>>>>>> origin/main
                ),
              ],
            ),
          ),
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
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
<<<<<<< HEAD
=======
=======
>>>>>>> origin/main
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: mutedText),
<<<<<<< HEAD
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
>>>>>>> origin/main
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (doctorController.text.trim().isEmpty) {
<<<<<<< HEAD
=======
=======
>>>>>>> origin/main
                backgroundColor: darkSage,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                if (doctorController.text.trim().isEmpty ||
                    hospitalController.text.trim().isEmpty ||
                    dateController.text.trim().isEmpty ||
                    timeController.text.trim().isEmpty ||
                    purposeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields.'),
                    ),
                  );
<<<<<<< HEAD
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
>>>>>>> origin/main
                  return;
                }

                final newAppointment = Appointment(
                  id: appointment?.id ??
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
                      DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
=======
                      DateTime.now().millisecondsSinceEpoch.toString(),
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
                      DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
>>>>>>> develop
=======
                      DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
>>>>>>> origin/main
                  doctorName: doctorController.text.trim(),
                  hospitalName: hospitalController.text.trim(),
                  date: dateController.text.trim(),
                  time: timeController.text.trim(),
                  purpose: purposeController.text.trim(),
                );

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
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
<<<<<<< HEAD
=======
=======
>>>>>>> origin/main
                try {
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

                  if (!dialogContext.mounted) return;

                  Navigator.pop(dialogContext);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        appointment == null
                            ? 'Appointment added'
                            : 'Appointment updated',
                      ),
                    ),
                  );
                } catch (e) {
                  if (!dialogContext.mounted) return;

                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                    ),
                  );
                }
              },
              child: Text(
                appointment == null ? 'Add' : 'Save',
<<<<<<< HEAD
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
>>>>>>> origin/main
              ),
            ),
          ],
        );
      },
    );
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    await _appointmentService.deleteAppointment(
      widget.elderId,
      appointmentId,
    );
<<<<<<< HEAD
=======
=======
>>>>>>> origin/main

    doctorController.dispose();
    hospitalController.dispose();
    dateController.dispose();
    timeController.dispose();
    purposeController.dispose();
  }

  Future<void> _deleteAppointment(
    Appointment appointment,
  ) async {
    try {
      await _appointmentService.deleteAppointment(
        widget.elderId,
        appointment.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment deleted'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting appointment: $e'),
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    Appointment appointment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Delete appointment?',
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'This appointment will be permanently removed.',
            style: TextStyle(
              color: mutedText,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                false,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: mutedText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                true,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: terracotta,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteAppointment(appointment);
    }
<<<<<<< HEAD
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
>>>>>>> origin/main
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
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
<<<<<<< HEAD
=======
=======
>>>>>>> origin/main
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        foregroundColor: textDark,
        title: const Text(
          'Appointments',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAppointmentDialog(),
        backgroundColor: terracotta,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add appointment',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
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
                color: darkSage,
<<<<<<< HEAD
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
>>>>>>> origin/main
              ),
            );
          }

          if (snapshot.hasError) {
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
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
<<<<<<< HEAD
=======
            return _ErrorState(
              message: 'Could not load appointments.',
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
            return const _ErrorState(
              message: 'Could not load appointments.',
>>>>>>> origin/main
            );
          }

          final appointments = snapshot.data ?? [];

          if (appointments.isEmpty) {
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
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
<<<<<<< HEAD
=======
=======
>>>>>>> origin/main
            return const _EmptyState();
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              110,
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: darkSage,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.14,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upcoming care',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${appointments.length} appointment'
                            '${appointments.length == 1 ? '' : 's'} scheduled',
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Your appointments',
                style: TextStyle(
                  color: textDark,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 14),

              ...appointments.map(
                (appointment) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 14,
                  ),
                  child: _AppointmentCard(
                    appointment: appointment,
                    onEdit: () => _showAppointmentDialog(
                      appointment: appointment,
                    ),
                    onDelete: () => _confirmDelete(
                      appointment,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------
// Appointment Card
// ------------------------------------------------------------

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AppointmentCard({
    required this.appointment,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color cardCream = Color(0xFFFFFBF4);
  static const Color darkSage = Color(0xFF46695A);
  static const Color sage = Color(0xFF7FA68F);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardCream,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: sage.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: sage.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: darkSage,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.purpose,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        appointment.doctorName,
                        style: const TextStyle(
                          color: mutedText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
<<<<<<< HEAD
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
>>>>>>> origin/main
                        ),
                      ),
                    ],
                  ),
                ),
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
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
<<<<<<< HEAD
=======
=======

>>>>>>> origin/main
                PopupMenuButton<String>(
                  color: cardCream,
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline),
                          SizedBox(width: 10),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(
                  icon: Icons.calendar_today_outlined,
                  text: appointment.date,
                ),
                _InfoPill(
                  icon: Icons.schedule_outlined,
                  text: appointment.time,
                ),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: sage.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.local_hospital_outlined,
                    size: 20,
                    color: darkSage,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      appointment.hospitalName,
                      style: const TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// Info Pill
// ------------------------------------------------------------

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({
    required this.icon,
    required this.text,
  });

  static const Color sage = Color(0xFF7FA68F);
  static const Color textDark = Color(0xFF26352F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: sage.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: textDark,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: textDark,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// Dialog Field
// ------------------------------------------------------------

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final int maxLines;

  const _DialogField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.maxLines = 1,
  });

  static const Color darkSage = Color(0xFF46695A);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: darkSage,
        ),
        labelStyle: const TextStyle(
          color: darkSage,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: darkSage,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// Empty State
// ------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  static const Color darkSage = Color(0xFF46695A);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: darkSage.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 42,
                color: darkSage,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'No appointments yet',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: darkSage,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add an appointment to keep upcoming care organised.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedText,
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
  final String message;

  const _ErrorState({
    required this.message,
  });

  static const Color terracotta = Color(0xFFC85C50);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: terracotta,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: terracotta,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
<<<<<<< HEAD
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
>>>>>>> origin/main
      ),
    );
  }
}