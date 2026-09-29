class Medicine {
  final String id;
  final String name;
  final String dosage;

  /// Number of doses per day.
  final int frequency;

  /// One time for each daily dose.
  ///
  /// Example:
  /// [
  ///   "09:00 AM",
  ///   "09:00 PM"
  /// ]
  final List<String> doseTimes;

  /// Stores which doses were taken on which date.
  ///
  /// Example:
  /// {
  ///   "2026-09-29": [0],
  /// }
  ///
  /// Means dose 0 was taken today, but dose 1 wasn't.
  final Map<String, List<int>> takenDoses;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.doseTimes,
    this.takenDoses = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'doseTimes': doseTimes,
      'takenDoses': takenDoses.map(
        (key, value) => MapEntry(
          key,
          value,
        ),
      ),
    };
  }

  factory Medicine.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final rawFrequency = map['frequency'];

    int parsedFrequency;

    if (rawFrequency is int) {
      parsedFrequency = rawFrequency;
    } else if (rawFrequency is double) {
      parsedFrequency = rawFrequency.toInt();
    } else {
      parsedFrequency =
          int.tryParse(
                rawFrequency?.toString() ?? '',
              ) ??
              1;
    }

    if (parsedFrequency < 1) {
      parsedFrequency = 1;
    }

    final rawDoseTimes = map['doseTimes'];

    List<String> parsedDoseTimes = [];

    if (rawDoseTimes is List) {
      parsedDoseTimes = rawDoseTimes
          .map(
            (item) => item.toString(),
          )
          .toList();
    }

    /*
     * Backward compatibility:
     *
     * If an older medicine document still has:
     *
     * time: "09:00 AM"
     *
     * convert it into the new doseTimes format.
     */
    if (parsedDoseTimes.isEmpty &&
        map['time'] != null &&
        map['time']
            .toString()
            .trim()
            .isNotEmpty) {
      parsedDoseTimes = [
        map['time'].toString(),
      ];
    }

    /*
     * Make sure there are enough time slots
     * for the selected frequency.
     */
    while (parsedDoseTimes.length <
        parsedFrequency) {
      parsedDoseTimes.add('');
    }

    final rawTakenDoses =
        map['takenDoses'];

    final Map<String, List<int>>
        parsedTakenDoses = {};

    if (rawTakenDoses
        is Map) {
      rawTakenDoses.forEach(
        (key, value) {
          if (value is List) {
            parsedTakenDoses[
                key.toString()] = value
                .map(
                  (item) {
                    if (item is int) {
                      return item;
                    }

                    return int.tryParse(
                          item.toString(),
                        ) ??
                        0;
                  },
                )
                .toList();
          }
        },
      );
    }

    return Medicine(
      id: id,
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: parsedFrequency,
      doseTimes: parsedDoseTimes,
      takenDoses: parsedTakenDoses,
    );
  }

  String getTimeForDose(int doseIndex) {
    if (doseIndex < 0 ||
        doseIndex >= doseTimes.length) {
      return 'Not set';
    }

    final time = doseTimes[doseIndex];

    if (time.trim().isEmpty) {
      return 'Not set';
    }

    return time;
  }

  bool isDoseTakenToday(
    int doseIndex,
  ) {
    final today = _todayString();

    final todayDoses =
        takenDoses[today] ?? [];

    return todayDoses.contains(
      doseIndex,
    );
  }

  int get takenDosesTodayCount {
    final today = _todayString();

    final todayDoses =
        takenDoses[today] ?? [];

    return todayDoses.length;
  }

  bool get allDosesTakenToday {
    if (frequency <= 0) {
      return false;
    }

    return takenDosesTodayCount >=
        frequency;
  }

  static String _todayString() {
    final now = DateTime.now();

    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    int? frequency,
    List<String>? doseTimes,
    Map<String, List<int>>? takenDoses,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      doseTimes:
          doseTimes ?? this.doseTimes,
      takenDoses:
          takenDoses ?? this.takenDoses,
    );
  }
}