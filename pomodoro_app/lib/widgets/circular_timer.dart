import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget de cronômetro circular animado
class CircularTimer extends StatelessWidget {
  final double progress;
  final String time;
  final String phaseName;
  final bool isBreak;
  final bool isRunning;

  const CircularTimer({
    super.key,
    required this.progress,
    required this.time,
    required this.phaseName,
    this.isBreak = false,
    this.isRunning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isBreak ? AppTheme.timerBreak : AppTheme.timerProgress;
    
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Círculo de fundo
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.timerBackground,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          
          // Arco de progresso
          CustomPaint(
            size: const Size(260, 260),
            painter: _CircularProgressPainter(
              progress: progress,
              color: color,
              backgroundColor: Colors.grey.shade200,
              strokeWidth: 12,
            ),
          ),
          
          // Conteúdo central
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone de estado
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isBreak 
                    ? Icons.coffee_rounded 
                    : (isRunning ? Icons.local_fire_department_rounded : Icons.timer_rounded),
                  key: ValueKey('$isBreak-$isRunning'),
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              
              // Tempo
              Text(
                time,
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 8),
              
              // Nome da fase
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  phaseName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Painter customizado para o arco de progresso
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Fundo do círculo
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Arco de progresso
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
