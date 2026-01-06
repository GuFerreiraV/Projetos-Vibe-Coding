import 'package:hive/hive.dart';

part 'study_wave.g.dart';

/// Modelo de uma "onda" de estudo (período de trabalho + descanso)
@HiveType(typeId: 2)
class StudyWave extends HiveObject {
  @HiveField(0)
  final int workDuration; // em minutos
  @HiveField(1)
  final int breakDuration; // em minutos
  @HiveField(2)
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

  StudyWave copyWith({int? workDuration, int? breakDuration, String? name}) {
    return StudyWave(
      workDuration: workDuration ?? this.workDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      name: name ?? this.name,
    );
  }
}
