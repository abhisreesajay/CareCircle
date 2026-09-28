import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/medical_service.dart';

class MedicalInformationScreen extends StatefulWidget {
  const MedicalInformationScreen({
    super.key,
  });

  @override
  State<MedicalInformationScreen> createState() =>
      _MedicalInformationScreenState();
}

class _MedicalInformationScreenState
    extends State<MedicalInformationScreen> {
  final MedicalService _medicalService =
      MedicalService();

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _bloodGroupController =
      TextEditingController();

  final TextEditingController _allergiesController =
      TextEditingController();

  final TextEditingController _conditionsController =
      TextEditingController();

  final TextEditingController _medicationsController =
      TextEditingController();

  final TextEditingController _emergencyNotesController =
      TextEditingController();

  final TextEditingController _doctorNameController =
      TextEditingController();

  final TextEditingController _doctorPhoneController =
      TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadMedicalInformation();
  }

  Future<void> _loadMedicalInformation() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final Map<String, dynamic>? data =
          await _medicalService.getMedicalInformation(
        user.uid,
      );

      if (data != null) {
        _bloodGroupController.text =
            data['bloodGroup'] ?? '';

        _allergiesController.text =
            data['allergies'] ?? '';

        _conditionsController.text =
            data['medicalConditions'] ?? '';

        _medicationsController.text =
            data['medications'] ?? '';

        _emergencyNotesController.text =
            data['emergencyNotes'] ?? '';

        _doctorNameController.text =
            data['doctorName'] ?? '';

        _doctorPhoneController.text =
            data['doctorPhone'] ?? '';
      }
    } catch (error) {
      _showMessage(
        'Unable to load medical information.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveMedicalInformation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final User? user = _auth.currentUser;

    if (user == null) {
      _showMessage(
        'Please log in first.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _medicalService.saveMedicalInformation(
        elderId: user.uid,
        bloodGroup: _bloodGroupController.text,
        allergies: _allergiesController.text,
        medicalConditions:
            _conditionsController.text,
        medications: _medicationsController.text,
        emergencyNotes:
            _emergencyNotesController.text,
        doctorName: _doctorNameController.text,
        doctorPhone: _doctorPhoneController.text,
      );

      _showMessage(
        'Medical information saved successfully.',
      );
    } catch (error) {
      _showMessage(
        'Unable to save medical information.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    _bloodGroupController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    _emergencyNotesController.dispose();
    _doctorNameController.dispose();
    _doctorPhoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Information',
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller:
                          _bloodGroupController,
                      decoration:
                          const InputDecoration(
                        labelText: 'Blood Group',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller:
                          _allergiesController,
                      decoration:
                          const InputDecoration(
                        labelText: 'Allergies',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller:
                          _conditionsController,
                      decoration:
                          const InputDecoration(
                        labelText: 'Medical Conditions',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller:
                          _medicationsController,
                      decoration:
                          const InputDecoration(
                        labelText: 'Medications',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller:
                          _emergencyNotesController,
                      decoration:
                          const InputDecoration(
                        labelText: 'Emergency Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller:
                          _doctorNameController,
                      decoration:
                          const InputDecoration(
                        labelText: 'Doctor Name',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller:
                          _doctorPhoneController,
                      keyboardType:
                          TextInputType.phone,
                      decoration:
                          const InputDecoration(
                        labelText: 'Doctor Phone',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : _saveMedicalInformation,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Medical Information',
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}