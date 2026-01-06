import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sequence_provider.dart';
import '../models/study_sequence.dart';
import '../models/study_wave.dart';
import '../widgets/sequence_card.dart';
import '../widgets/wave_card.dart';
import '../theme/app_theme.dart';

/// Tela 2 - Configurações de Sequências
class SequencesScreen extends StatefulWidget {
  const SequencesScreen({super.key});

  @override
  State<SequencesScreen> createState() => _SequencesScreenState();
}

class _SequencesScreenState extends State<SequencesScreen> {
  @override
  void initState() {
    super.initState();
    // Adia o carregamento para após o primeiro frame ser construído
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSequences();
    });
  }

  Future<void> _loadSequences() async {
    if (!mounted) return;
    await context.read<SequenceProvider>().loadSequences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Minhas Sequências'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateSequenceDialog(context),
          ),
        ],
      ),
      body: Consumer<SequenceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          if (provider.sequences.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.sequences.length,
            itemBuilder: (context, index) {
              final sequence = provider.sequences[index];
              return SequenceCard(
                sequence: sequence,
                isSelected: provider.selectedSequence?.id == sequence.id,
                onTap: () => provider.selectSequence(sequence),
                onEdit: sequence.isDefault
                    ? null
                    : () => _showEditSequenceDialog(context, sequence),
                onDelete: sequence.isDefault
                    ? null
                    : () => _confirmDeleteSequence(context, sequence),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSequenceDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova Sequência'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.playlist_add_rounded,
              size: 48,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nenhuma sequência',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crie sua primeira sequência de estudo',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateSequenceDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Criar Sequência'),
          ),
        ],
      ),
    );
  }

  void _showCreateSequenceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SequenceEditorSheet(),
    );
  }

  void _showEditSequenceDialog(BuildContext context, StudySequence sequence) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SequenceEditorSheet(sequence: sequence),
    );
  }

  void _confirmDeleteSequence(BuildContext context, StudySequence sequence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Sequência'),
        content: Text('Deseja excluir a sequência "${sequence.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<SequenceProvider>().deleteSequence(sequence.id!);
              Navigator.pop(context);
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sheet para criar/editar sequências
class _SequenceEditorSheet extends StatefulWidget {
  final StudySequence? sequence;

  const _SequenceEditorSheet({this.sequence});

  @override
  State<_SequenceEditorSheet> createState() => _SequenceEditorSheetState();
}

class _SequenceEditorSheetState extends State<_SequenceEditorSheet> {
  final _nameController = TextEditingController();
  List<StudyWave> _waves = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.sequence != null;

    if (_isEditing) {
      _nameController.text = widget.sequence!.name;
      _waves = List.from(widget.sequence!.waves);
    } else {
      // Adiciona uma onda padrão
      _waves = [StudyWave(workDuration: 25, breakDuration: 5, name: '1ª Onda')];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'Editar Sequência' : 'Nova Sequência',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome da sequência
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Sequência',
                      hintText: 'Ex: Estudo intensivo',
                      prefixIcon: Icon(Icons.edit_rounded),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ondas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ondas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addWave,
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Lista de ondas
                  ..._waves.asMap().entries.map((entry) {
                    final index = entry.key;
                    final wave = entry.value;
                    return WaveCard(
                      wave: wave,
                      index: index,
                      onEdit: () => _editWave(index),
                      onDelete: _waves.length > 1
                          ? () => _deleteWave(index)
                          : null,
                    );
                  }),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveSequence,
                      child: Text(_isEditing ? 'Salvar' : 'Criar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addWave() {
    setState(() {
      _waves.add(
        StudyWave(
          workDuration: 25,
          breakDuration: 5,
          name: '${_waves.length + 1}ª Onda',
        ),
      );
    });
  }

  void _deleteWave(int index) {
    setState(() {
      _waves.removeAt(index);
      // Renomeia as ondas
      for (var i = 0; i < _waves.length; i++) {
        _waves[i] = _waves[i].copyWith(name: '${i + 1}ª Onda');
      }
    });
  }

  void _editWave(int index) {
    final wave = _waves[index];
    final workController = TextEditingController(
      text: wave.workDuration.toString(),
    );
    final breakController = TextEditingController(
      text: wave.breakDuration.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${wave.name ?? "${index + 1}ª Onda"}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: workController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tempo de trabalho (min)',
                prefixIcon: Icon(
                  Icons.local_fire_department_rounded,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: breakController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tempo de descanso (min)',
                prefixIcon: Icon(
                  Icons.coffee_rounded,
                  color: AppTheme.timerBreak,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final work = int.tryParse(workController.text) ?? 25;
              final breakTime = int.tryParse(breakController.text) ?? 5;

              setState(() {
                _waves[index] = StudyWave(
                  workDuration: work,
                  breakDuration: breakTime,
                  name: wave.name,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _saveSequence() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para a sequência')),
      );
      return;
    }

    final provider = context.read<SequenceProvider>();

    if (_isEditing) {
      await provider.updateSequence(
        widget.sequence!.copyWith(name: name, waves: _waves),
      );
    } else {
      await provider.createSequence(name: name, waves: _waves);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
