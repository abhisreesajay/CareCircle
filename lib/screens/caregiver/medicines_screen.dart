import 'package:flutter/material.dart';

import '../../models/medicine_model.dart';
import '../../services/caregiver/medicine_service.dart';

// ============================================================
// COLORS
// ============================================================

const Color medicineBackground =
    Color(0xFFF4EFE5);

const Color medicineSage =
    Color(0xFF7FA68F);

const Color medicineDarkSage =
    Color(0xFF46695A);

const Color medicineTerracotta =
    Color(0xFFC85C50);

const Color medicineCream =
    Color(0xFFFFFBF4);

const Color medicineTextDark =
    Color(0xFF26352F);

// ============================================================
// SCREEN
// ============================================================

class MedicinesScreen extends StatefulWidget {
  final String elderId;

  const MedicinesScreen({
    super.key,
    required this.elderId,
  });

  @override
  State<MedicinesScreen> createState() =>
      _MedicinesScreenState();
}

class _MedicinesScreenState
    extends State<MedicinesScreen> {
  final MedicineService _medicineService =
      MedicineService();

  // ============================================================
  // ADD / EDIT MEDICINE
  // ============================================================

  void _showMedicineDialog({
    Medicine? medicine,
  }) {
    final nameController =
        TextEditingController(
      text: medicine?.name ?? '',
    );

    final dosageController =
        TextEditingController(
      text: medicine?.dosage ?? '',
    );

    int frequency =
        medicine?.frequency ?? 1;

    List<String> doseTimes =
        medicine != null
            ? List<String>.from(
                medicine.doseTimes,
              )
            : [''];

    while (doseTimes.length <
        frequency) {
      doseTimes.add('');
    }

    if (doseTimes.length >
        frequency) {
      doseTimes =
          doseTimes.sublist(
        0,
        frequency,
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return Dialog(
              backgroundColor:
                  medicineCream,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  28,
                ),
              ),
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    // ------------------------------------------------
                    // HEADER
                    // ------------------------------------------------

                    Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFE3E9E1,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                          ),
                          child:
                              const Icon(
                            Icons
                                .medication_rounded,
                            color:
                                medicineDarkSage,
                          ),
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: Text(
                            medicine == null
                                ? 'Add medicine'
                                : 'Edit medicine',
                            style:
                                const TextStyle(
                              fontSize: 23,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              color:
                                  medicineTextDark,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // ------------------------------------------------
                    // MEDICINE NAME
                    // ------------------------------------------------

                    _InputField(
                      controller:
                          nameController,
                      label:
                          'Medicine name',
                      icon: Icons
                          .medication_rounded,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ------------------------------------------------
                    // DOSAGE
                    // ------------------------------------------------

                    _InputField(
                      controller:
                          dosageController,
                      label: 'Dosage',
                      icon: Icons
                          .medical_information_rounded,
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // ------------------------------------------------
                    // FREQUENCY
                    // ------------------------------------------------

                    const Text(
                      'Times per day',
                      style:
                          TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            medicineTextDark,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF1ECE2,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          17,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child:
                            DropdownButton<int>(
                          value:
                              frequency,
                          isExpanded:
                              true,
                          icon:
                              const Icon(
                            Icons
                                .keyboard_arrow_down_rounded,
                            color:
                                medicineDarkSage,
                          ),
                          items:
                              List.generate(
                            6,
                            (index) {
                              final value =
                                  index +
                                      1;

                              return DropdownMenuItem<
                                  int>(
                                value:
                                    value,
                                child:
                                    Text(
                                  '$value time${value == 1 ? '' : 's'} per day',
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.w600,
                                    color:
                                        medicineTextDark,
                                  ),
                                ),
                              );
                            },
                          ),
                          onChanged:
                              (value) {
                            if (value ==
                                null) {
                              return;
                            }

                            setDialogState(
                              () {
                                frequency =
                                    value;

                                while (doseTimes
                                        .length <
                                    frequency) {
                                  doseTimes
                                      .add(
                                    '',
                                  );
                                }

                                if (doseTimes
                                        .length >
                                    frequency) {
                                  doseTimes =
                                      doseTimes.sublist(
                                    0,
                                    frequency,
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ------------------------------------------------
                    // DOSE TIMES
                    // ------------------------------------------------

                    Text(
                      'Dose times',
                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            medicineTextDark,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Set a separate time for each dose.',
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color:
                            Colors.black54,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    ...List.generate(
                      frequency,
                      (index) {
                        return Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom: 10,
                          ),
                          child:
                              _DoseTimeField(
                            doseNumber:
                                index + 1,
                            value:
                                doseTimes[
                                    index],
                            onChanged:
                                (value) {
                              doseTimes[
                                      index] =
                                  value;
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // ------------------------------------------------
                    // BUTTONS
                    // ------------------------------------------------

                    Row(
                      children: [
                        Expanded(
                          child:
                              OutlinedButton(
                            onPressed: () {
                              Navigator.pop(
                                dialogContext,
                              );
                            },
                            style:
                                OutlinedButton
                                    .styleFrom(
                              foregroundColor:
                                  medicineDarkSage,
                              side:
                                  const BorderSide(
                                color:
                                    medicineSage,
                              ),
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical:
                                    14,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  16,
                                ),
                              ),
                            ),
                            child:
                                const Text(
                              'Cancel',
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child:
                              ElevatedButton(
                            onPressed:
                                () async {
                              final name =
                                  nameController
                                      .text
                                      .trim();

                              if (name.isEmpty) {
                                ScaffoldMessenger
                                    .of(
                                  dialogContext,
                                ).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text(
                                      'Enter a medicine name.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final cleanedDoseTimes =
                                  doseTimes
                                      .map(
                                        (time) =>
                                            time.trim(),
                                      )
                                      .toList();

                              final newMedicine =
                                  Medicine(
                                id: medicine
                                        ?.id ??
                                    DateTime
                                        .now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                name: name,
                                dosage:
                                    dosageController
                                        .text
                                        .trim(),
                                frequency:
                                    frequency,
                                doseTimes:
                                    cleanedDoseTimes,
                                takenDoses:
                                    medicine
                                            ?.takenDoses ??
                                        const {},
                              );

                              try {
                                if (medicine ==
                                    null) {
                                  await _medicineService
                                      .addMedicine(
                                    widget
                                        .elderId,
                                    newMedicine,
                                  );
                                } else {
                                  await _medicineService
                                      .updateMedicine(
                                    widget
                                        .elderId,
                                    newMedicine,
                                  );
                                }

                                if (!dialogContext
                                    .mounted) {
                                  return;
                                }

                                Navigator.pop(
                                  dialogContext,
                                );
                              } catch (e) {
                                if (!dialogContext
                                    .mounted) {
                                  return;
                                }

                                ScaffoldMessenger
                                    .of(
                                  dialogContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text(
                                      'Unable to save medicine: $e',
                                    ),
                                    backgroundColor:
                                        medicineTerracotta,
                                  ),
                                );
                              }
                            },
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  medicineDarkSage,
                              foregroundColor:
                                  Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical:
                                    14,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  16,
                                ),
                              ),
                            ),
                            child: Text(
                              medicine == null
                                  ? 'Add medicine'
                                  : 'Save changes',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteMedicine(
    String medicineId,
  ) async {
    try {
      await _medicineService
          .deleteMedicine(
        widget.elderId,
        medicineId,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to delete medicine: $e',
          ),
          backgroundColor:
              medicineTerracotta,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          medicineBackground,

      appBar: AppBar(
        backgroundColor:
            medicineBackground,
        foregroundColor:
            medicineTextDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Medicines',
          style: TextStyle(
            fontSize: 22,
            fontWeight:
                FontWeight.w800,
            color:
                medicineTextDark,
          ),
        ),
      ),

      body: StreamBuilder<List<Medicine>>(
        stream:
            _medicineService
                .getMedicines(
          widget.elderId,
        ),
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color:
                    medicineDarkSage,
              ),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(
              error:
                  snapshot.error.toString(),
            );
          }

          final medicines =
              snapshot.data ?? [];

          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  22,
                  4,
                  22,
                  18,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Text(
                            'Medication',
                            style:
                                TextStyle(
                              fontSize: 29,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              color:
                                  medicineTextDark,
                              letterSpacing:
                                  -1,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            medicines.isEmpty
                                ? 'No medicines scheduled yet'
                                : '${medicines.length} medicine${medicines.length == 1 ? '' : 's'} scheduled',
                            style:
                                const TextStyle(
                              fontSize: 13,
                              color:
                                  Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFE5D3C8,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          17,
                        ),
                      ),
                      child:
                          const Icon(
                        Icons
                            .medication_rounded,
                        color:
                            medicineTerracotta,
                        size: 27,
                      ),
                    ),
                  ],
                ),
              ),

              if (medicines.isEmpty)
                const Expanded(
                  child: Center(
                    child:
                        _EmptyMedicineState(),
                  ),
                )
              else
                Expanded(
                  child:
                      ListView.builder(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      22,
                      0,
                      22,
                      110,
                    ),
                    itemCount:
                        medicines.length,
                    itemBuilder:
                        (
                      context,
                      index,
                    ) {
                      final medicine =
                          medicines[index];

                      return _MedicineCard(
                        medicine:
                            medicine,
                        onEdit: () {
                          _showMedicineDialog(
                            medicine:
                                medicine,
                          );
                        },
                        onDelete: () {
                          _deleteMedicine(
                            medicine.id,
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            medicineDarkSage,
        foregroundColor:
            Colors.white,
        elevation: 4,
        onPressed: () {
          _showMedicineDialog();
        },
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Add medicine',
          style: TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MEDICINE CARD
// ============================================================

class _MedicineCard
    extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MedicineCard({
    required this.medicine,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final takenCount =
        medicine.takenDosesTodayCount;

    final allTaken =
        medicine.allDosesTakenToday;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: allTaken
            ? const Color(0xFFE5EDE2)
            : medicineCream,
        borderRadius:
            BorderRadius.circular(26),
        border: Border.all(
          color: allTaken
              ? const Color(0xFFD0DDCB)
              : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          // ------------------------------------------------------
          // HEADER
          // ------------------------------------------------------

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                height: 58,
                width: 58,
                decoration:
                    BoxDecoration(
                  color: allTaken
                      ? const Color(
                          0xFFD3E1D0,
                        )
                      : const Color(
                          0xFFE5D3C8,
                        ),
                  borderRadius:
                      BorderRadius.circular(
                    19,
                  ),
                ),
                child: Icon(
                  allTaken
                      ? Icons
                          .check_circle_rounded
                      : Icons
                          .medication_rounded,
                  color: allTaken
                      ? medicineDarkSage
                      : medicineTerracotta,
                  size: 29,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      medicine.name,
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            medicineTextDark,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      medicine.dosage.isEmpty
                          ? 'Dosage not specified'
                          : medicine.dosage,
                      style:
                          const TextStyle(
                        fontSize: 13,
                        color:
                            Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(
                  Icons
                      .more_horiz_rounded,
                  color:
                      medicineDarkSage,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value ==
                      'delete') {
                    onDelete();
                  }
                },
                itemBuilder:
                    (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .edit_rounded,
                          color:
                              medicineDarkSage,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .delete_outline_rounded,
                          color:
                              medicineTerracotta,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          // ------------------------------------------------------
          // FREQUENCY SUMMARY
          // ------------------------------------------------------

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFF1ECE2),
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.repeat_rounded,
                  color:
                      medicineDarkSage,
                  size: 21,
                ),
                const SizedBox(
                  width: 9,
                ),
                Expanded(
                  child: Text(
                    '${medicine.frequency} time${medicine.frequency == 1 ? '' : 's'} per day',
                    style:
                        const TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          medicineTextDark,
                    ),
                  ),
                ),
                Text(
                  '$takenCount/${medicine.frequency} taken',
                  style:
                      TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w800,
                    color: allTaken
                        ? medicineDarkSage
                        : medicineTextDark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          // ------------------------------------------------------
          // EACH DOSE
          // ------------------------------------------------------

          ...List.generate(
            medicine.frequency,
            (doseIndex) {
              final isTaken =
                  medicine.isDoseTakenToday(
                doseIndex,
              );

              final time =
                  medicine.getTimeForDose(
                doseIndex,
              );

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 10,
                ),
                child: _CaregiverDoseRow(
                  doseNumber:
                      doseIndex + 1,
                  time: time,
                  isTaken: isTaken,
                ),
              );
            },
          ),

          // ------------------------------------------------------
          // ALL TAKEN
          // ------------------------------------------------------

          if (allTaken)
            Container(
              width:
                  double.infinity,
              margin:
                  const EdgeInsets.only(
                top: 2,
              ),
              padding:
                  const EdgeInsets.all(
                13,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(0xFFD3E1D0),
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons
                        .check_circle_rounded,
                    color:
                        medicineDarkSage,
                  ),
                  SizedBox(
                    width: 9,
                  ),
                  Expanded(
                    child: Text(
                      'All doses taken today.',
                      style:
                          TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            medicineDarkSage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// CAREGIVER DOSE ROW
// ============================================================

class _CaregiverDoseRow
    extends StatelessWidget {
  final int doseNumber;
  final String time;
  final bool isTaken;

  const _CaregiverDoseRow({
    required this.doseNumber,
    required this.time,
    required this.isTaken,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isTaken
            ? const Color(0xFFE7EFE4)
            : const Color(0xFFF9F4EA),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: isTaken
              ? const Color(0xFFC8D9C3)
              : const Color(0xFFE8DFD0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
              color: isTaken
                  ? const Color(
                      0xFFD3E1D0,
                    )
                  : const Color(
                      0xFFE5D3C8,
                    ),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              isTaken
                  ? Icons
                      .check_circle_rounded
                  : Icons
                      .access_time_rounded,
              color: isTaken
                  ? medicineDarkSage
                  : medicineTerracotta,
              size: 21,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Dose $doseNumber',
                  style:
                      const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Colors.black54,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  time,
                  style:
                      const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        medicineTextDark,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration:
                BoxDecoration(
              color: isTaken
                  ? const Color(
                      0xFFD3E1D0,
                    )
                  : const Color(
                      0xFFF0D5CE,
                    ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Text(
              isTaken
                  ? 'TAKEN'
                  : 'PENDING',
              style:
                  TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w900,
                color: isTaken
                    ? medicineDarkSage
                    : const Color(
                        0xFF9C5047,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DOSE TIME FIELD
// ============================================================

class _DoseTimeField
    extends StatelessWidget {
  final int doseNumber;
  final String value;
  final ValueChanged<String>
      onChanged;

  const _DoseTimeField({
    required this.doseNumber,
    required this.value,
    required this.onChanged,
  });

  Future<void> _selectTime(
    BuildContext context,
  ) async {
    TimeOfDay? initialTime;

    if (value.trim().isNotEmpty) {
      final parsed =
          _parseTime(value);

      if (parsed != null) {
        initialTime = parsed;
      }
    }

    final selected =
        await showTimePicker(
      context: context,
      initialTime:
          initialTime ??
              const TimeOfDay(
                hour: 9,
                minute: 0,
              ),
    );

    if (selected == null) {
      return;
    }

    final formatted =
        selected.format(context);

    onChanged(formatted);
  }

  TimeOfDay? _parseTime(
    String value,
  ) {
    try {
      final parts =
          value.trim().split(' ');

      if (parts.length != 2) {
        return null;
      }

      final timeParts =
          parts[0].split(':');

      if (timeParts.length != 2) {
        return null;
      }

      int hour =
          int.parse(timeParts[0]);

      final minute =
          int.parse(timeParts[1]);

      final period =
          parts[1].toUpperCase();

      if (period == 'PM' &&
          hour != 12) {
        hour += 12;
      }

      if (period == 'AM' &&
          hour == 12) {
        hour = 0;
      }

      return TimeOfDay(
        hour: hour,
        minute: minute,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: () {
        _selectTime(context);
      },
      borderRadius:
          BorderRadius.circular(17),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        decoration:
            BoxDecoration(
          color:
              const Color(0xFFF1ECE2),
          borderRadius:
              BorderRadius.circular(
            17,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons
                  .access_time_rounded,
              color:
                  medicineDarkSage,
            ),
            const SizedBox(
              width: 11,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dose $doseNumber',
                    style:
                        const TextStyle(
                      fontSize: 10,
                      color:
                          Colors.black45,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    value.trim().isEmpty
                        ? 'Select time'
                        : value,
                    style:
                        TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                      color: value
                              .trim()
                              .isEmpty
                          ? Colors.black45
                          : medicineTextDark,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons
                  .keyboard_arrow_down_rounded,
              color:
                  medicineDarkSage,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INPUT FIELD
// ============================================================

class _InputField
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return TextField(
      controller: controller,
      decoration:
          InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(
          icon,
          color:
              medicineDarkSage,
          size: 21,
        ),
        filled: true,
        fillColor:
            const Color(0xFFF1ECE2),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            17,
          ),
          borderSide:
              BorderSide.none,
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            17,
          ),
          borderSide:
              const BorderSide(
            color:
                medicineSage,
            width: 2,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyMedicineState
    extends StatelessWidget {
  const _EmptyMedicineState();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.all(
        30,
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Container(
            height: 92,
            width: 92,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFE5D3C8,
              ),
              borderRadius:
                  BorderRadius.circular(
                30,
              ),
            ),
            child: const Icon(
              Icons
                  .medication_rounded,
              size: 45,
              color:
                  medicineTerracotta,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'No medicines yet',
            style:
                TextStyle(
              fontSize: 21,
              fontWeight:
                  FontWeight.w800,
              color:
                  medicineTextDark,
            ),
          ),
          const SizedBox(
            height: 7,
          ),
          const Text(
            'Add the medicines your elder needs to take.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontSize: 13,
              height: 1.5,
              color:
                  Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

class _ErrorState
    extends StatelessWidget {
  final String error;

  const _ErrorState({
    required this.error,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          28,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF0D5CE,
                ),
                borderRadius:
                    BorderRadius.circular(
                  26,
                ),
              ),
              child: const Icon(
                Icons
                    .error_outline_rounded,
                color:
                    medicineTerracotta,
                size: 40,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            const Text(
              'Something went wrong',
              style:
                  TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
                color:
                    medicineTextDark,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              error,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 12,
                color:
                    Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}