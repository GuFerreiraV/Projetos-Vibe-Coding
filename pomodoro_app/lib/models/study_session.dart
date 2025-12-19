/// Modelo de uma sessão de estudo (registro no histórico)
class StudySession {
  final int? id;
  final DateTime date;
  final int durationMinutes;
  final String sequenceName;

  StudySession({
    this.id,
    required this.date,
    required this.durationMinutes,
    required this.sequenceName,
  });

  /// Converter para Map para salvar no SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'sequenceName': sequenceName,
    };
  }

  /// Criar a partir de Map do SQLite
  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      durationMinutes: map['durationMinutes'] as int,
      sequenceName: map['sequenceName'] as String,
    );
  }

  StudySession copyWith({
    int? id,
    DateTime? date,
    int? durationMinutes,
    String? sequenceName,
  }) {
    return StudySession(
      id: id ?? this.id,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      sequenceName: sequenceName ?? this.sequenceName,
    );
  }
}
