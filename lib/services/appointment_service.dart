import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addAppointment(
    String elderId,
    Appointment appointment,
  ) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('appointments')
        .doc(appointment.id)
        .set(appointment.toMap());
  }

  Future<void> updateAppointment(
    String elderId,
    Appointment appointment,
  ) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('appointments')
        .doc(appointment.id)
        .update(appointment.toMap());
  }

  Future<void> deleteAppointment(
    String elderId,
    String appointmentId,
  ) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('appointments')
        .doc(appointmentId)
        .delete();
  }

  Stream<List<Appointment>> getAppointments(String elderId) {
    return _firestore
        .collection('elders')
        .doc(elderId)
        .collection('appointments')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Appointment.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }
}