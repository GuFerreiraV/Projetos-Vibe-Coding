import 'dart:convert';
import 'study_wave.dart';

/// Modelo de uma sequência de estudo (contém múltiplas ondas)
class StudySequence {
  final int? id;
  final String name;
  final List<StudyWave> waves;
  final bool isDefault;

  StudySequence({
    this.id,
    required this.name,
    required this.waves,
    this.isDefault = false,
  });

  /// Duração total da sequência em minutos
  int get totalDuration => waves.fold(0, (sum, wave) => sum + wave.totalDuration);

  /// Número de ondas na sequência
  int get waveCount => waves.length;

  /// Converter para Map para salvar no SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'waves': jsonEncode(waves.map((w) => w.toMap()).toList()),
      'isDefault': isDefault ? 1 : 0,
    };
  }

  /// Criar a partir de Map do SQLite
  factory StudySequence.fromMap(Map<String, dynamic> map) {
    final wavesJson = jsonDecode(map['waves'] as String) as List<dynamic>;
    return StudySequence(
      id: map['id'] as int?,
      name: map['name'] as String,
      waves: wavesJson.map((w) => StudyWave.fromMap(w as Map<String, dynamic>)).toList(),
      isDefault: (map['isDefault'] as int) == 1,
    );
  }

  StudySequence copyWith({
    int? id,
    String? name,
    List<StudyWave>? waves,
    bool? isDefault,
  }) {
    return StudySequence(
      id: id ?? this.id,
      name: name ?? this.name,
      waves: waves ?? this.waves,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  /// Sequência padrão Pomodoro clássica (25 min trabalho, 5 min descanso)
  static StudySequence get defaultSequence => StudySequence(
        name: 'Pomodoro Clássico',
        waves: [
          StudyWave(workDuration: 25, breakDuration: 5, name: '1ª Onda'),
          StudyWave(workDuration: 25, breakDuration: 5, name: '2ª Onda'),
          StudyWave(workDuration: 25, breakDuration: 5, name: '3ª Onda'),
          StudyWave(workDuration: 25, breakDuration: 15, name: '4ª Onda'),
        ],
        isDefault: true,
      );
}
