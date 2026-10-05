import 'package:flutter_test/flutter_test.dart';

import 'package:care_circle/models/appointment_model.dart';
import 'package:care_circle/models/check_in_history_model.dart';
import 'package:care_circle/models/check_in_reminder_model.dart';
import 'package:care_circle/models/medicine_model.dart';
import 'package:care_circle/models/nearby_service_model.dart';
import 'package:care_circle/models/safe_zone.dart';

void main() {
  group('Appointment model', () {
    test('fromMap reads all fields', () {
      final appointment = Appointment.fromMap('apt-1', {
        'doctorName': 'Dr. Anu',
        'hospitalName': 'City Hospital',
        'date': '2026-10-05',
        'time': '10:30 AM',
        'purpose': 'Routine check-up',
      });

      expect(appointment.id, 'apt-1');
      expect(appointment.doctorName, 'Dr. Anu');
      expect(appointment.hospitalName, 'City Hospital');
      expect(appointment.date, '2026-10-05');
      expect(appointment.time, '10:30 AM');
      expect(appointment.purpose, 'Routine check-up');
    });

    test('fromMap supplies empty defaults', () {
      final appointment = Appointment.fromMap('apt-2', {});

      expect(appointment.doctorName, '');
      expect(appointment.hospitalName, '');
      expect(appointment.date, '');
      expect(appointment.time, '');
      expect(appointment.purpose, '');
    });

    test('toMap serializes appointment fields', () {
      final appointment = Appointment(
        id: 'apt-3',
        doctorName: 'Dr. Ravi',
        hospitalName: 'General Hospital',
        date: '2026-10-06',
        time: '11:00 AM',
        purpose: 'Follow-up',
      );

      expect(appointment.toMap(), {
        'doctorName': 'Dr. Ravi',
        'hospitalName': 'General Hospital',
        'date': '2026-10-06',
        'time': '11:00 AM',
        'purpose': 'Follow-up',
      });
    });
  });

  group('CheckInHistory model', () {
    test('fromMap reads history fields', () {
      final history = CheckInHistory.fromMap('history-1', {
        'date': '2026-10-05',
        'scheduledTime': '09:00 AM',
        'status': 'COMPLETED',
      });

      expect(history.id, 'history-1');
      expect(history.date, '2026-10-05');
      expect(history.scheduledTime, '09:00 AM');
      expect(history.status, 'COMPLETED');
    });

    test('fromMap converts values to strings', () {
      final history = CheckInHistory.fromMap('history-2', {
        'date': 20261005,
        'scheduledTime': 900,
        'status': 1,
      });

      expect(history.date, '20261005');
      expect(history.scheduledTime, '900');
      expect(history.status, '1');
    });

    test('fromMap uses defaults for missing fields', () {
      final history = CheckInHistory.fromMap('history-3', {});

      expect(history.date, '');
      expect(history.scheduledTime, '');
      expect(history.status, 'PENDING');
    });
  });

  group('CheckInReminder model', () {
    test('fromMap reads all fields', () {
      final reminder = CheckInReminder.fromMap('reminder-1', {
        'elderId': 'elder-1',
        'scheduledTime': '09:00 AM',
        'status': 'PENDING',
        'firstReminderSent': true,
        'secondReminderSent': false,
        'caregiverNotified': true,
      });

      expect(reminder.id, 'reminder-1');
      expect(reminder.elderId, 'elder-1');
      expect(reminder.scheduledTime, '09:00 AM');
      expect(reminder.status, 'PENDING');
      expect(reminder.firstReminderSent, isTrue);
      expect(reminder.secondReminderSent, isFalse);
      expect(reminder.caregiverNotified, isTrue);
    });

    test('fromMap uses defaults for missing fields', () {
      final reminder = CheckInReminder.fromMap('reminder-2', {});

      expect(reminder.elderId, '');
      expect(reminder.scheduledTime, '');
      expect(reminder.status, 'PENDING');
      expect(reminder.firstReminderSent, isFalse);
      expect(reminder.secondReminderSent, isFalse);
      expect(reminder.caregiverNotified, isFalse);
    });

    test('toMap serializes reminder fields', () {
      final reminder = CheckInReminder(
        id: 'reminder-3',
        elderId: 'elder-2',
        scheduledTime: '08:00 AM',
        status: 'COMPLETED',
        firstReminderSent: true,
        secondReminderSent: true,
        caregiverNotified: false,
      );

      expect(reminder.toMap(), {
        'elderId': 'elder-2',
        'scheduledTime': '08:00 AM',
        'status': 'COMPLETED',
        'firstReminderSent': true,
        'secondReminderSent': true,
        'caregiverNotified': false,
      });
    });
  });

  group('Medicine model', () {
    test('fromMap reads medicine fields', () {
      final medicine = Medicine.fromMap('medicine-1', {
        'name': 'Paracetamol',
        'dosage': '500 mg',
        'frequency': 2,
        'doseTimes': ['09:00 AM', '09:00 PM'],
        'takenDoses': {
          '2026-10-05': [0],
        },
      });

      expect(medicine.id, 'medicine-1');
      expect(medicine.name, 'Paracetamol');
      expect(medicine.dosage, '500 mg');
      expect(medicine.frequency, 2);
      expect(medicine.doseTimes, ['09:00 AM', '09:00 PM']);
      expect(medicine.takenDoses['2026-10-05'], [0]);
    });

    test('fromMap handles double and string frequencies', () {
      final doubleFrequency = Medicine.fromMap('medicine-2', {
        'frequency': 2.8,
        'doseTimes': ['08:00 AM', '08:00 PM'],
      });

      final stringFrequency = Medicine.fromMap('medicine-3', {
        'frequency': '3',
        'doseTimes': ['08:00 AM', '02:00 PM', '08:00 PM'],
      });

      expect(doubleFrequency.frequency, 2);
      expect(stringFrequency.frequency, 3);
    });

    test('fromMap defaults invalid frequency to one', () {
      final medicine = Medicine.fromMap('medicine-4', {
        'frequency': 'invalid',
      });

      expect(medicine.frequency, 1);
      expect(medicine.name, '');
      expect(medicine.dosage, '');
      expect(medicine.doseTimes, ['']);
    });

    test('fromMap corrects frequency below one', () {
      final medicine = Medicine.fromMap('medicine-5', {
        'frequency': 0,
      });

      expect(medicine.frequency, 1);
      expect(medicine.doseTimes, ['']);
    });

    test('fromMap supports the legacy time field', () {
      final medicine = Medicine.fromMap('medicine-6', {
        'frequency': 1,
        'time': '10:00 AM',
      });

      expect(medicine.doseTimes, ['10:00 AM']);
    });

    test('fromMap fills missing dose time slots', () {
      final medicine = Medicine.fromMap('medicine-7', {
        'frequency': 3,
        'doseTimes': ['09:00 AM'],
      });

      expect(medicine.doseTimes, ['09:00 AM', '', '']);
    });

    test('fromMap parses taken doses', () {
      final medicine = Medicine.fromMap('medicine-8', {
        'frequency': 2,
        'takenDoses': {
          '2026-10-05': [0, '1', 'invalid'],
        },
      });

      expect(medicine.takenDoses['2026-10-05'], [0, 1, 0]);
    });

    test('toMap serializes medicine fields', () {
      final medicine = Medicine(
        id: 'medicine-9',
        name: 'Vitamin D',
        dosage: '1000 IU',
        frequency: 1,
        doseTimes: ['09:00 AM'],
        takenDoses: {
          '2026-10-05': [0],
        },
      );

      expect(medicine.toMap(), {
        'name': 'Vitamin D',
        'dosage': '1000 IU',
        'frequency': 1,
        'doseTimes': ['09:00 AM'],
        'takenDoses': {
          '2026-10-05': [0],
        },
      });
    });

    test('getTimeForDose returns the correct time', () {
      final medicine = Medicine(
        id: 'medicine-10',
        name: 'Medicine',
        dosage: '1 tablet',
        frequency: 2,
        doseTimes: ['09:00 AM', '09:00 PM'],
      );

      expect(medicine.getTimeForDose(0), '09:00 AM');
      expect(medicine.getTimeForDose(1), '09:00 PM');
    });

    test('getTimeForDose handles invalid indexes and empty times', () {
      final medicine = Medicine(
        id: 'medicine-11',
        name: 'Medicine',
        dosage: '1 tablet',
        frequency: 2,
        doseTimes: ['09:00 AM', '  '],
      );

      expect(medicine.getTimeForDose(-1), 'Not set');
      expect(medicine.getTimeForDose(2), 'Not set');
      expect(medicine.getTimeForDose(1), 'Not set');
    });

    test('dose tracking works for the current date', () {
      final now = DateTime.now();
      final today =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';

      final medicine = Medicine(
        id: 'medicine-12',
        name: 'Medicine',
        dosage: '1 tablet',
        frequency: 2,
        doseTimes: ['09:00 AM', '09:00 PM'],
        takenDoses: {
          today: [0],
        },
      );

      expect(medicine.isDoseTakenToday(0), isTrue);
      expect(medicine.isDoseTakenToday(1), isFalse);
      expect(medicine.takenDosesTodayCount, 1);
      expect(medicine.allDosesTakenToday, isFalse);
    });

    test('allDosesTakenToday is true when every dose is recorded', () {
      final now = DateTime.now();
      final today =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';

      final medicine = Medicine(
        id: 'medicine-13',
        name: 'Medicine',
        dosage: '1 tablet',
        frequency: 2,
        doseTimes: ['09:00 AM', '09:00 PM'],
        takenDoses: {
          today: [0, 1],
        },
      );

      expect(medicine.takenDosesTodayCount, 2);
      expect(medicine.allDosesTakenToday, isTrue);
    });

    test('copyWith updates selected fields', () {
      final medicine = Medicine(
        id: 'medicine-14',
        name: 'Original',
        dosage: '1 tablet',
        frequency: 1,
        doseTimes: ['09:00 AM'],
      );

      final updated = medicine.copyWith(
        name: 'Updated',
        frequency: 2,
        doseTimes: ['08:00 AM', '08:00 PM'],
      );

      expect(updated.id, 'medicine-14');
      expect(updated.name, 'Updated');
      expect(updated.dosage, '1 tablet');
      expect(updated.frequency, 2);
      expect(updated.doseTimes, ['08:00 AM', '08:00 PM']);
    });
  });

  group('NearbyService model', () {
    test('fromMap reads all fields', () {
      final service = NearbyService.fromMap('service-1', {
        'name': 'City Pharmacy',
        'type': 'Pharmacy',
        'phone': '1234567890',
        'address': 'Main Road',
        'preferred': true,
      });

      expect(service.id, 'service-1');
      expect(service.name, 'City Pharmacy');
      expect(service.type, 'Pharmacy');
      expect(service.phone, '1234567890');
      expect(service.address, 'Main Road');
      expect(service.preferred, isTrue);
    });

    test('fromMap supplies defaults', () {
      final service = NearbyService.fromMap('service-2', {});

      expect(service.name, '');
      expect(service.type, '');
      expect(service.phone, '');
      expect(service.address, '');
      expect(service.preferred, isFalse);
    });

    test('toMap serializes service fields', () {
      final service = NearbyService(
        id: 'service-3',
        name: 'Local Clinic',
        type: 'Hospital',
        phone: '9876543210',
        address: 'Town Centre',
        preferred: true,
      );

      expect(service.toMap(), {
        'name': 'Local Clinic',
        'type': 'Hospital',
        'phone': '9876543210',
        'address': 'Town Centre',
        'preferred': true,
      });
    });
  });

  group('SafeZone model', () {
    test('fromMap reads all fields', () {
      final zone = SafeZone.fromMap('zone-1', {
        'elderId': 'elder-1',
        'name': 'Home',
        'latitude': 9.5916,
        'longitude': 76.5222,
        'radiusInMeters': 150,
        'createdBy': 'caregiver-1',
      });

      expect(zone.id, 'zone-1');
      expect(zone.elderId, 'elder-1');
      expect(zone.name, 'Home');
      expect(zone.latitude, 9.5916);
      expect(zone.longitude, 76.5222);
      expect(zone.radiusInMeters, 150.0);
      expect(zone.createdBy, 'caregiver-1');
    });

    test('fromMap converts numeric values to doubles', () {
      final zone = SafeZone.fromMap('zone-2', {
        'latitude': 10,
        'longitude': 76,
        'radiusInMeters': 200,
      });

      expect(zone.latitude, 10.0);
      expect(zone.longitude, 76.0);
      expect(zone.radiusInMeters, 200.0);
    });

    test('fromMap supplies defaults for missing fields', () {
      final zone = SafeZone.fromMap('zone-3', {});

      expect(zone.elderId, '');
      expect(zone.name, '');
      expect(zone.latitude, 0.0);
      expect(zone.longitude, 0.0);
      expect(zone.radiusInMeters, 100.0);
      expect(zone.createdBy, '');
    });

    test('toMap serializes safe zone fields', () {
      final zone = SafeZone(
        id: 'zone-4',
        elderId: 'elder-2',
        name: 'Garden',
        latitude: 9.5,
        longitude: 76.5,
        radiusInMeters: 120,
        createdBy: 'caregiver-2',
      );

      expect(zone.toMap(), {
        'elderId': 'elder-2',
        'name': 'Garden',
        'latitude': 9.5,
        'longitude': 76.5,
        'radiusInMeters': 120,
        'createdBy': 'caregiver-2',
      });
    });
  });
}