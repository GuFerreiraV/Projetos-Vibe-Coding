import 'package:flutter/material.dart';
import '../models/study_wave.dart';
import '../theme/app_theme.dart';

/// Card de uma onda de estudo
class WaveCard extends StatelessWidget {
  final StudyWave wave;
  final int index;
  final bool isActive;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const WaveCard({
    super.key,
    required this.wave,
    required this.index,
    this.isActive = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppTheme.primary : Colors.grey.shade200,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Número da onda
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primary : AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Informações da onda
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wave.name ?? '${index + 1}ª Onda',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildDurationChip(
                        Icons.local_fire_department_rounded,
                        '${wave.workDuration} min',
                        AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildDurationChip(
                        Icons.coffee_rounded,
                        '${wave.breakDuration} min',
                        AppTheme.timerBreak,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Botões de ação
            if (onEdit != null || onDelete != null) ...[
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded),
                  iconSize: 20,
                  color: AppTheme.textSecondary,
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_rounded),
                  iconSize: 20,
                  color: AppTheme.error,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDurationChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
