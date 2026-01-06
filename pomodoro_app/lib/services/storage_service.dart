import 'package:hive/hive.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/study_sequence.dart';
import '../models/study_session.dart';

/// Serviço de armazenamento local usando SharedPreferences (localStorage no web)
class StorageService {
  /// Inicializa o serviço com dados padrão se necessário
  Future<void> initialize() async {
    final box = await Hive.openBox<StudySequence>('sequences');

    // Se não houver sequências, adiciona a padrão
    if (box.isEmpty) {
      final defaultSequence = StudySequence.defaultSequence.copyWith(id: 1);
      await box.add(defaultSequence);
    }
  }

  // ==================== OPERAÇÕES DE SEQUÊNCIAS ====================

  /// Obtém todas as sequências
  Future<List<StudySequence>> getSequences() async {
    final box = await Hive.openBox<StudySequence>('sequences');
    return box.values.toList();
  }

  // /// Salva todas as sequências
  // Future<void> _saveSequences(List<StudySequence> sequences) async {
  //   final p = await prefs;
  //   final jsonList = sequences.map((s) => s.toMap()).toList();
  //   await p.setString(_sequencesKey, jsonEncode(jsonList));
  // }

  /// Obtém sequência por ID
  Future<StudySequence?> getSequenceById(int id) async {
    final sequences = await getSequences();
    try {
      return sequences.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Insere uma nova sequência
  Future<int> insertSequence(StudySequence sequence) async {
    final box = await Hive.openBox<StudySequence>('sequences');
    final sequences = box.values.toList();

    // Gera novo ID
    final maxId = sequences.isEmpty
        ? 0
        : sequences.map((s) => s.id ?? 0).reduce((a, b) => a > b ? a : b);
    final newId = maxId + 1;

    final newSequence = sequence.copyWith(id: newId);

    await box.add(newSequence);

    return newId;
  }

  /// Atualiza uma sequência existente
  Future<void> updateSequence(StudySequence sequence) async {
    final box = await Hive.openBox<StudySequence>('sequences');

    // Encontra a sequência pelo ID
    try {
      final sequenceInDb = box.values.firstWhere((s) => s.id == sequence.id);

      // Substitui o valor usando a chave do Hive
      await box.put(sequenceInDb.key, sequence);
    } catch (e) {
      print('Erro ao atualizar sequência: ${sequence.id} não encontrada.');
    }
  }

  /// Deleta uma sequência
  Future<void> deleteSequence(int id) async {
    final box = await Hive.openBox<StudySequence>('sequences');

    try {
      final sequenceInDb = box.values.firstWhere((s) => s.id == id);
      await sequenceInDb.delete();
    } catch (e) {
      // Sequência não encontrada ou já deletada
    }
  }

  // ==================== OPERAÇÕES DE SESSÕES ====================

  /// Obtém todas as sessões de estudo
  Future<List<StudySession>> getSessions() async {
    final box = await Hive.openBox<StudySession>('sessions');
    return box.values.toList();
  }

  /// Salva todas as sessões
  // Future<void> _saveSessions(List<StudySession> sessions) async {
  //   final p = await prefs;
  //   final jsonList = sessions.map((s) => s.toMap()).toList();
  //   await p.setString(_sessionsKey, jsonEncode(jsonList));
  // }

  /// Obtém sessões de um mês específico
  Future<List<StudySession>> getSessionsByMonth(int year, int month) async {
    final sessions = await getSessions();
    return sessions
        .where((s) => s.date.year == year && s.date.month == month)
        .toList();
  }

  /// Obtém sessões de um dia específico
  Future<List<StudySession>> getSessionsByDate(DateTime date) async {
    final sessions = await getSessions();
    return sessions
        .where(
          (s) =>
              s.date.year == date.year &&
              s.date.month == date.month &&
              s.date.day == date.day,
        )
        .toList();
  }

  /// Obtém o total de minutos estudados em um dia
  Future<int> getTotalMinutesByDate(DateTime date) async {
    final sessions = await getSessions();

    return sessions
        .where((s) => isSameDay(s.date, date)) // Logica de comparação de data
        .fold<int>(0, (sum, s) => sum + s.durationMinutes);
  }

  /// Obtém mapa de minutos estudados por dia do mês
  Future<Map<DateTime, int>> getMinutesMapByMonth(int year, int month) async {
    final sessions = await getSessionsByMonth(year, month);
    final Map<DateTime, int> minutesMap = {};

    for (final session in sessions) {
      final dateKey = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      minutesMap[dateKey] =
          (minutesMap[dateKey] ?? 0) + session.durationMinutes;
    }

    return minutesMap;
  }

  /// Insere uma nova sessão de estudo
  Future<void> insertSession(StudySession session) async {
    final box = Hive.box<StudySession>('sessions');
    // Adiciona ao banco. O Hive retorna a chave (int) gerada.
    await box.add(session);
  }

  /// Deleta uma sessão
  Future<void> deleteSession(StudySession session) async {
    await session.delete();
  }
}
