import 'package:flutter/foundation.dart';
import '../models/study_session.dart';
import '../services/storage_service.dart';

/// Provider para gerenciar o histórico de sessões de estudo
class HistoryProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  Map<DateTime, int> _minutesMap = {};
  List<StudySession> _monthSessions = [];
  DateTime _focusedMonth = DateTime.now();
  bool _isLoading = false;

  // Getters
  Map<DateTime, int> get minutesMap => _minutesMap;
  List<StudySession> get monthSessions => _monthSessions;
  DateTime get focusedMonth => _focusedMonth;
  bool get isLoading => _isLoading;

  /// Total de minutos do mês focado
  int get totalMonthMinutes => _minutesMap.values.fold(0, (sum, m) => sum + m);

  /// Formata o total de minutos para exibição
  String get formattedTotalTime {
    final hours = totalMonthMinutes ~/ 60;
    final minutes = totalMonthMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '$minutes minutos';
  }

  /// Carrega os dados do mês focado
  Future<void> loadMonth(DateTime month) async {
    _isLoading = true;
    _focusedMonth = month;
    notifyListeners();

    try {
      _minutesMap = await _storageService.getMinutesMapByMonth(
        month.year,
        month.month,
      );
      _monthSessions = await _storageService.getSessionsByMonth(
        month.year,
        month.month,
      );
    } catch (e) {
      debugPrint('Erro ao carregar histórico: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Obtém os minutos de um dia específico
  int getMinutesForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _minutesMap[dateKey] ?? 0;
  }

  /// Obtém as sessões de um dia específico
  Future<List<StudySession>> getSessionsForDay(DateTime day) async {
    return await _storageService.getSessionsByDate(day);
  }

  /// Muda para o mês anterior
  Future<void> previousMonth() async {
    final newMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    await loadMonth(newMonth);
  }

  /// Muda para o próximo mês
  Future<void> nextMonth() async {
    final newMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    await loadMonth(newMonth);
  }

  /// Obtém a cor de intensidade baseada nos minutos estudados
  double getIntensity(DateTime day) {
    final minutes = getMinutesForDay(day);
    if (minutes == 0) return 0;
    if (minutes <= 30) return 0.25;
    if (minutes <= 60) return 0.5;
    if (minutes <= 120) return 0.75;
    return 1.0;
  }
}
