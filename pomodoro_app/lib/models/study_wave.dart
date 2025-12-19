/// Modelo de uma "onda" de estudo (período de trabalho + descanso)
class StudyWave {
  final int workDuration; // em minutos
  final int breakDuration; // em minutos
  final String? name;

  StudyWave({
    required this.workDuration,
    required this.breakDuration,
    this.name,
  });

  /// Duração total da onda em minutos
  int get totalDuration => workDuration + breakDuration;

  /// Converter para Map para salvar no SQLite
  Map<String, dynamic> toMap() {
    return {
      'workDuration': workDuration,
      'breakDuration': breakDuration,
      'name': name,
    };
  }

  /// Criar a partir de Map do SQLite
  factory StudyWave.fromMap(Map<String, dynamic> map) {
    return StudyWave(
      workDuration: map['workDuration'] as int,
      breakDuration: map['breakDuration'] as int,
      name: map['name'] as String?,
    );
  }

  /// Converter lista de ondas para JSON string
  static String listToJson(List<StudyWave> waves) {
    final list = waves.map((w) => w.toMap()).toList();
    return list.toString();
  }

  StudyWave copyWith({
    int? workDuration,
    int? breakDuration,
    String? name,
  }) {
    return StudyWave(
      workDuration: workDuration ?? this.workDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      name: name ?? this.name,
    );
  }
}
