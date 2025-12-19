import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_sequence.dart';
import '../models/study_session.dart';

/// Serviço de armazenamento local usando SharedPreferences (localStorage no web)
class StorageService {
  static const String _sequencesKey = 'pomodoro_sequences';
  static const String _sessionsKey = 'pomodoro_sessions';

  SharedPreferences? _prefs;

  /// Obtém instância do SharedPreferences
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Inicializa o serviço com dados padrão se necessário
  Future<void> initialize() async {
    final p = await prefs;

    // Se não houver sequências, adiciona a padrão
    if (!p.containsKey(_sequencesKey)) {
      final defaultSequence = StudySequence.defaultSequence.copyWith(id: 1);
      await _saveSequences([defaultSequence]);
    }
  }

  // ==================== OPERAÇÕES DE SEQUÊNCIAS ====================

  /// Obtém todas as sequências
  Future<List<StudySequence>> getSequences() async {
    final p = await prefs;
    final jsonString = p.getString(_sequencesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => StudySequence.fromMap(json)).toList();
  }

  /// Salva todas as sequências
  Future<void> _saveSequences(List<StudySequence> sequences) async {
    final p = await prefs;
    final jsonList = sequences.map((s) => s.toMap()).toList();
    await p.setString(_sequencesKey, jsonEncode(jsonList));
  }

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
    final sequences = await getSequences();

    // Gera novo ID
    final maxId = sequences.isEmpty
        ? 0
        : sequences.map((s) => s.id ?? 0).reduce((a, b) => a > b ? a : b);
    final newId = maxId + 1;

    final newSequence = sequence.copyWith(id: newId);
    sequences.add(newSequence);

    await _saveSequences(sequences);
    return newId;
  }

  /// Atualiza uma sequência existente
  Future<void> updateSequence(StudySequence sequence) async {
    final sequences = await getSequences();
    final index = sequences.indexWhere((s) => s.id == sequence.id);

    if (index != -1) {
      sequences[index] = sequence;
      await _saveSequences(sequences);
    }
  }

  /// Deleta uma sequência
  Future<void> deleteSequence(int id) async {
    final sequences = await getSequences();
    sequences.removeWhere((s) => s.id == id);
    await _saveSequences(sequences);
  }

  // ==================== OPERAÇÕES DE SESSÕES ====================

  /// Obtém todas as sessões de estudo
  Future<List<StudySession>> getSessions() async {
    final p = await prefs;
    final jsonString = p.getString(_sessionsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => StudySession.fromMap(json)).toList();
  }

  /// Salva todas as sessões
  Future<void> _saveSessions(List<StudySession> sessions) async {
    final p = await prefs;
    final jsonList = sessions.map((s) => s.toMap()).toList();
    await p.setString(_sessionsKey, jsonEncode(jsonList));
  }

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
    final sessions = await getSessionsByDate(date);
    return sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationMinutes,
    );
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
  Future<int> insertSession(StudySession session) async {
    final sessions = await getSessions();

    // Gera novo ID
    final maxId = sessions.isEmpty
        ? 0
        : sessions.map((s) => s.id ?? 0).reduce((a, b) => a > b ? a : b);
    final newId = maxId + 1;

    final newSession = session.copyWith(id: newId);
    sessions.add(newSession);

    await _saveSessions(sessions);
    return newId;
  }

  /// Deleta uma sessão
  Future<void> deleteSession(int id) async {
    final sessions = await getSessions();
    sessions.removeWhere((s) => s.id == id);
    await _saveSessions(sessions);
  }

  /// Limpa todos os dados (para debug)
  Future<void> clearAll() async {
    final p = await prefs;
    await p.remove(_sequencesKey);
    await p.remove(_sessionsKey);
  }
}
