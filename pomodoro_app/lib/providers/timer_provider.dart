import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/study_sequence.dart';
import '../models/study_wave.dart';
import '../models/study_session.dart';
import '../services/storage_service.dart';

/// Estado do timer
enum TimerState { idle, running, paused, breakTime }

/// Provider para gerenciar o estado do cronômetro
class TimerProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Estado do timer
  TimerState _state = TimerState.idle;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  Timer? _timer;

  // Sequência atual
  StudySequence? _currentSequence;
  int _currentWaveIndex = 0;
  bool _isBreak = false;

  // Tempo total estudado na sessão atual
  int _sessionMinutes = 0;

  // Getters
  TimerState get state => _state;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  double get progress => _totalSeconds > 0
      ? (_totalSeconds - _remainingSeconds) / _totalSeconds
      : 0;
  StudySequence? get currentSequence => _currentSequence;
  int get currentWaveIndex => _currentWaveIndex;
  bool get isBreak => _isBreak;
  int get sessionMinutes => _sessionMinutes;

  StudyWave? get currentWave {
    if (_currentSequence == null ||
        _currentWaveIndex >= _currentSequence!.waves.length) {
      return null;
    }
    return _currentSequence!.waves[_currentWaveIndex];
  }

  String get currentPhaseName {
    if (_currentSequence == null) return '';
    if (currentWave == null) return 'Concluído!';

    final waveName = currentWave!.name ?? '${_currentWaveIndex + 1}ª Onda';
    return _isBreak ? '$waveName - Descanso' : '$waveName - Foco';
  }

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Define a sequência atual
  void setSequence(StudySequence sequence) {
    _currentSequence = sequence;
    _currentWaveIndex = 0;
    _isBreak = false;
    _sessionMinutes = 0;
    _loadCurrentPhase();
    notifyListeners();
  }

  /// Carrega a fase atual (trabalho ou descanso)
  void _loadCurrentPhase() {
    if (currentWave == null) {
      _state = TimerState.idle;
      return;
    }

    final duration = _isBreak
        ? currentWave!.breakDuration
        : currentWave!.workDuration;
    _totalSeconds = duration * 60;
    _remainingSeconds = _totalSeconds;
    _state = TimerState.idle;
  }

  /// Inicia o timer
  void start() {
    if (_state == TimerState.running) return;
    if (currentSequence == null) return;

    _state = _isBreak ? TimerState.breakTime : TimerState.running;
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  /// Pausa o timer
  void pause() {
    _timer?.cancel();
    _state = TimerState.paused;
    notifyListeners();
  }

  /// Continua o timer após pausa
  void resume() {
    if (_state != TimerState.paused) return;
    start();
  }

  /// Reseta o timer da fase atual
  void reset() {
    _timer?.cancel();
    _loadCurrentPhase();
    notifyListeners();
  }

  /// Reseta toda a sequência
  void resetSequence() {
    _timer?.cancel();
    _currentWaveIndex = 0;
    _isBreak = false;
    _sessionMinutes = 0;
    _loadCurrentPhase();
    notifyListeners();
  }

  /// Pula para a próxima fase
  void skip() {
    // Não permite skip se já finalizou a sequência
    if (_currentWaveIndex >= (_currentSequence?.waves.length ?? 0)) {
      return;
    }
    _timer?.cancel();
    _advanceToNextPhase();
    notifyListeners();
  }

  /// Tick do timer
  void _tick(Timer timer) {
    if (_remainingSeconds > 0) {
      _remainingSeconds--;

      // Contabiliza tempo de trabalho (não descanso)
      if (!_isBreak && _remainingSeconds % 60 == 0) {
        _sessionMinutes++;
      }

      notifyListeners();
    } else {
      _playNotificationSound();
      _advanceToNextPhase();
      notifyListeners();
    }
  }

  /// Avança para a próxima fase
  void _advanceToNextPhase() {
    _timer?.cancel();

    if (_isBreak) {
      // Estava no descanso, vai para próxima onda
      _isBreak = false;
      _currentWaveIndex++;

      if (_currentWaveIndex >= (_currentSequence?.waves.length ?? 0)) {
        // Sequência concluída
        _saveSession();
        _state = TimerState.idle;
        return;
      }
    } else {
      // Estava no trabalho, vai para descanso
      _isBreak = true;
    }

    _loadCurrentPhase();
  }

  /// Salva a sessão de estudo no banco de dados
  Future<void> _saveSession() async {
    if (_sessionMinutes > 0 && _currentSequence != null) {
      final session = StudySession(
        date: DateTime.now(),
        durationMinutes: _sessionMinutes,
        sequenceName: _currentSequence!.name,
      );
      await _storageService.insertSession(session);
    }
  }

  /// Toca som de notificação (desabilitado - sem arquivo de áudio)
  Future<void> _playNotificationSound() async {
    // TODO: Adicionar arquivo de som em assets/sounds/notification.mp3
    // try {
    //   await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    // } catch (e) {
    //   debugPrint('Erro ao tocar som: $e');
    // }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
