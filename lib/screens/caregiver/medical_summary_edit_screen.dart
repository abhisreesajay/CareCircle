import 'package:flutter/material.dart';

import '../../models/medical_summary_model.dart';
import '../../services/caregiver/medical_summary_service.dart';

class MedicalSummaryEditScreen extends StatefulWidget {
  final String elderId;

  const MedicalSummaryEditScreen({
    super.key,
    required this.elderId,
  });

  @override
  State<MedicalSummaryEditScreen> createState() =>
      _MedicalSummaryEditScreenState();
}

class _MedicalSummaryEditScreenState
    extends State<MedicalSummaryEditScreen> {
  final MedicalSummaryService _service =
      MedicalSummaryService();

  final _formKey =
      GlobalKey<FormState>();

  final _bloodGroupController =
      TextEditingController();

  final _allergiesController =
      TextEditingController();

  final _conditionsController =
      TextEditingController();

  final _notesController =
      TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadMedicalSummary();
  }

  Future<void> _loadMedicalSummary() async {
    try {
      final MedicalSummary? summary =
          await _service.getMedicalSummary(
        widget.elderId,
      );

      if (summary != null) {
        _bloodGroupController.text =
            summary.bloodGroup;

        _allergiesController.text =
            summary.allergies;

        _conditionsController.text =
            summary.conditions;

        _notesController.text =
            summary.notes;
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to load medical information.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _service.saveMedicalSummary(
        elderId: widget.elderId,
        bloodGroup:
            _bloodGroupController.text,
        allergies:
            _allergiesController.text,
        conditions:
            _conditionsController.text,
        notes:
            _notesController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Medical information updated.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update medical information.',
          ),
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
  void dispose() {
    _bloodGroupController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4EFE5),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF4EFE5),
        foregroundColor:
            const Color(0xFF26352F),
        elevation: 0,
        title: const Text(
          'Edit Medical Summary',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _field(
                      controller:
                          _bloodGroupController,
                      label: 'Blood Group',
                      icon:
                          Icons.bloodtype_rounded,
                    ),

                    const SizedBox(height: 16),

                    _field(
                      controller:
                          _allergiesController,
                      label: 'Allergies',
                      icon:
                          Icons.warning_amber_rounded,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    _field(
                      controller:
                          _conditionsController,
                      label:
                          'Medical Conditions',
                      icon:
                          Icons.health_and_safety_rounded,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    _field(
                      controller:
                          _notesController,
                      label: 'Medical Notes',
                      icon:
                          Icons.notes_rounded,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed:
                            _saving ? null : _save,
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF46695A,
                          ),
                          foregroundColor:
                              Colors.white,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Medical Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
      ),
    );
  }
}