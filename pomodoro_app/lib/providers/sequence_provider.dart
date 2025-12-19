import 'package:flutter/foundation.dart';
import '../models/study_sequence.dart';
import '../models/study_wave.dart';
import '../services/storage_service.dart';

/// Provider para gerenciar as sequências de estudo
class SequenceProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<StudySequence> _sequences = [];
  StudySequence? _selectedSequence;
  bool _isLoading = false;

  // Getters
  List<StudySequence> get sequences => _sequences;
  StudySequence? get selectedSequence => _selectedSequence;
  bool get isLoading => _isLoading;

  /// Carrega todas as sequências do banco de dados
  Future<void> loadSequences() async {
    _isLoading = true;
    notifyListeners();

    try {
      _sequences = await _storageService.getSequences();

      // Se não houver sequência selecionada, seleciona a padrão
      if (_selectedSequence == null && _sequences.isNotEmpty) {
        _selectedSequence = _sequences.firstWhere(
          (s) => s.isDefault,
          orElse: () => _sequences.first,
        );
      }
    } catch (e) {
      debugPrint('Erro ao carregar sequências: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Seleciona uma sequência
  void selectSequence(StudySequence sequence) {
    _selectedSequence = sequence;
    notifyListeners();
  }

  /// Cria uma nova sequência
  Future<void> createSequence({
    required String name,
    required List<StudyWave> waves,
  }) async {
    final sequence = StudySequence(name: name, waves: waves, isDefault: false);

    final id = await _storageService.insertSequence(sequence);
    final newSequence = sequence.copyWith(id: id);
    _sequences.add(newSequence);
    notifyListeners();
  }

  /// Atualiza uma sequência existente
  Future<void> updateSequence(StudySequence sequence) async {
    await _storageService.updateSequence(sequence);

    final index = _sequences.indexWhere((s) => s.id == sequence.id);
    if (index != -1) {
      _sequences[index] = sequence;

      if (_selectedSequence?.id == sequence.id) {
        _selectedSequence = sequence;
      }
    }
    notifyListeners();
  }

  /// Deleta uma sequência
  Future<void> deleteSequence(int id) async {
    await _storageService.deleteSequence(id);
    _sequences.removeWhere((s) => s.id == id);

    if (_selectedSequence?.id == id) {
      _selectedSequence = _sequences.isNotEmpty ? _sequences.first : null;
    }
    notifyListeners();
  }

  /// Cria uma sequência simples (sem ondas adicionais)
  Future<void> createSimpleTimer({
    required String name,
    required int workMinutes,
    required int breakMinutes,
  }) async {
    await createSequence(
      name: name,
      waves: [
        StudyWave(
          workDuration: workMinutes,
          breakDuration: breakMinutes,
          name: 'Única Onda',
        ),
      ],
    );
  }
}
