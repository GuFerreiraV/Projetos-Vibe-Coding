import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/sequence_provider.dart';
import '../widgets/circular_timer.dart';
import '../theme/app_theme.dart';

/// Tela 1 - Cronômetro Principal
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  Future<void> _initializeTimer() async {
    final sequenceProvider = context.read<SequenceProvider>();
    final timerProvider = context.read<TimerProvider>();

    // Carrega as sequências se ainda não carregadas
    if (sequenceProvider.sequences.isEmpty) {
      await sequenceProvider.loadSequences();
    }

    // Define a sequência padrão no timer se não houver uma
    if (timerProvider.currentSequence == null &&
        sequenceProvider.selectedSequence != null) {
      timerProvider.setSequence(sequenceProvider.selectedSequence!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer2<TimerProvider, SequenceProvider>(
          builder: (context, timerProvider, sequenceProvider, child) {
            return Column(
              children: [
                // Seletor de sequência
                _buildSequenceSelector(
                  context,
                  timerProvider,
                  sequenceProvider,
                ),

                // Timer
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Indicador de progresso da sequência
                        if (timerProvider.currentSequence != null)
                          _buildSequenceProgress(timerProvider),

                        const SizedBox(height: 24),

                        // Cronômetro circular
                        CircularTimer(
                          progress: timerProvider.progress,
                          time: timerProvider.formattedTime,
                          phaseName: timerProvider.currentPhaseName,
                          isBreak: timerProvider.isBreak,
                          isRunning: timerProvider.state == TimerState.running,
                        ),

                        const SizedBox(height: 40),

                        // Controles
                        _buildControls(context, timerProvider),
                      ],
                    ),
                  ),
                ),

                // Estatísticas da sessão
                _buildSessionStats(timerProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSequenceSelector(
    BuildContext context,
    TimerProvider timerProvider,
    SequenceProvider sequenceProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showSequenceBottomSheet(
                context,
                timerProvider,
                sequenceProvider,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.playlist_play_rounded,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        timerProvider.currentSequence?.name ??
                            'Selecione uma sequência',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceProgress(TimerProvider timerProvider) {
    final waves = timerProvider.currentSequence!.waves;
    final currentIndex = timerProvider.currentWaveIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(waves.length, (index) {
          final isCompleted = index < currentIndex;
          final isCurrent = index == currentIndex;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isCurrent ? 32 : 24,
              height: isCurrent ? 32 : 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppTheme.primary
                    : (isCurrent
                          ? (timerProvider.isBreak
                                ? AppTheme.timerBreak
                                : AppTheme.primary)
                          : Colors.grey.shade200),
                border: isCurrent
                    ? Border.all(
                        color: timerProvider.isBreak
                            ? AppTheme.timerBreak.withOpacity(0.3)
                            : AppTheme.primary.withOpacity(0.3),
                        width: 3,
                      )
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: isCurrent ? 12 : 10,
                          fontWeight: FontWeight.bold,
                          color: isCurrent
                              ? Colors.white
                              : AppTheme.textSecondary,
                        ),
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildControls(BuildContext context, TimerProvider timerProvider) {
    final state = timerProvider.state;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botão Reset
        _buildControlButton(
          icon: Icons.refresh_rounded,
          onPressed: timerProvider.resetSequence,
          isSecondary: true,
        ),

        const SizedBox(width: 24),

        // Botão Play/Pause
        _buildMainControlButton(
          icon: state == TimerState.running || state == TimerState.breakTime
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          onPressed: () {
            if (state == TimerState.running || state == TimerState.breakTime) {
              timerProvider.pause();
            } else if (state == TimerState.paused) {
              timerProvider.resume();
            } else {
              timerProvider.start();
            }
          },
        ),

        const SizedBox(width: 24),

        // Botão Skip
        _buildControlButton(
          icon: Icons.skip_next_rounded,
          onPressed: timerProvider.skip,
          isSecondary: true,
        ),
      ],
    );
  }

  Widget _buildMainControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, size: 40, color: Colors.white),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isSecondary = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSecondary ? AppTheme.surface : AppTheme.primary,
          shape: BoxShape.circle,
          border: isSecondary ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Icon(
          icon,
          size: 28,
          color: isSecondary ? AppTheme.textSecondary : Colors.white,
        ),
      ),
    );
  }

  Widget _buildSessionStats(TimerProvider timerProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            label: 'Sessão Atual',
            value: '${timerProvider.sessionMinutes} min',
            icon: Icons.timer_outlined,
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          _buildStatItem(
            label: 'Onda',
            value: () {
              final waveCount = timerProvider.currentSequence?.waveCount ?? 0;
              final currentWave = (timerProvider.currentWaveIndex + 1).clamp(
                1,
                waveCount,
              );
              return '$currentWave/$waveCount';
            }(),
            icon: Icons.waves_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppTheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSequenceBottomSheet(
    BuildContext context,
    TimerProvider timerProvider,
    SequenceProvider sequenceProvider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Selecionar Sequência',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...sequenceProvider.sequences.map((sequence) {
              final isSelected =
                  timerProvider.currentSequence?.id == sequence.id;
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.playlist_play_rounded,
                    color: isSelected ? Colors.white : AppTheme.primary,
                  ),
                ),
                title: Text(
                  sequence.name,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  '${sequence.waveCount} ondas • ${sequence.totalDuration} min',
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.primary,
                      )
                    : null,
                onTap: () {
                  timerProvider.setSequence(sequence);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
