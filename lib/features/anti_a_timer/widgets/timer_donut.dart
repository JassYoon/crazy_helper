import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../models/breathing_mode.dart';

class TimerDonut extends StatelessWidget {
  final BreathingMode mode;
  final double cycleElapsed;
  final bool running;
  final double size;

  const TimerDonut({
    super.key,
    required this.mode,
    required this.cycleElapsed,
    required this.running,
    this.size = 260,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          mode: mode,
          cycleElapsed: cycleElapsed,
          running: running,
        ),
        child: Center(child: _buildCenterText()),
      ),
    );
  }

  Widget _buildCenterText() {
    if (!running) {
      return Text(
        mode.name,
        style: TextStyle(
          fontSize: 15,
          color: AppColors.textHint,
          fontWeight: FontWeight.w400,
        ),
      );
    }
    final phase = _getCurrentPhase();
    final timeLeft = (mode.phases[phase.index].seconds - phase.elapsed).ceil();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          mode.phases[phase.index].label,
          style: TextStyle(
            fontSize: 17,
            color: mode.phases[phase.index].color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$timeLeft',
          style: TextStyle(
            fontSize: 46,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  ({int index, double elapsed}) _getCurrentPhase() {
    double acc = 0;
    for (int i = 0; i < mode.phases.length; i++) {
      if (cycleElapsed < acc + mode.phases[i].seconds) {
        return (index: i, elapsed: cycleElapsed - acc);
      }
      acc += mode.phases[i].seconds;
    }
    return (index: mode.phases.length - 1, elapsed: mode.phases.last.seconds.toDouble());
  }
}

class _DonutPainter extends CustomPainter {
  final BreathingMode mode;
  final double cycleElapsed;
  final bool running;

  static const double strokeWidth = 36;
  static const double guideOpacity = 0.18;

  _DonutPainter({
    required this.mode,
    required this.cycleElapsed,
    required this.running,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    // Background ring — light green
    final bgPaint = Paint()
      ..color = AppColors.primaryVeryLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawCircle(center, radius, bgPaint);

    // Segments
    final totalPerCycle = mode.totalPerCycle;
    final segments = <_Segment>[];
    double startAngle = -pi / 2;
    for (int i = 0; i < mode.phases.length; i++) {
      final sweepAngle = (mode.phases[i].seconds / totalPerCycle) * 2 * pi;
      segments.add(_Segment(
        startAngle: startAngle,
        sweepAngle: sweepAngle,
        color: mode.phases[i].color,
        duration: mode.phases[i].seconds.toDouble(),
      ));
      startAngle += sweepAngle;
    }

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Guide arcs (faded)
    for (final seg in segments) {
      final guidePaint = Paint()
        ..color = seg.color.withValues(alpha: guideOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, seg.startAngle, seg.sweepAngle, false, guidePaint);
    }

    // Progress arcs
    if (running) {
      final phase = _getCurrentPhase();
      for (int i = 0; i < segments.length; i++) {
        double completedRatio;
        if (i < phase.index) {
          completedRatio = 1.0;
        } else if (i == phase.index) {
          completedRatio = phase.elapsed / segments[i].duration;
        } else {
          completedRatio = 0.0;
        }
        if (completedRatio > 0.001) {
          final progressPaint = Paint()
            ..color = segments[i].color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.butt;
          canvas.drawArc(rect, segments[i].startAngle,
              segments[i].sweepAngle * completedRatio, false, progressPaint);
        }
      }
    }
  }

  ({int index, double elapsed}) _getCurrentPhase() {
    double acc = 0;
    for (int i = 0; i < mode.phases.length; i++) {
      if (cycleElapsed < acc + mode.phases[i].seconds) {
        return (index: i, elapsed: cycleElapsed - acc);
      }
      acc += mode.phases[i].seconds;
    }
    return (index: mode.phases.length - 1, elapsed: mode.phases.last.seconds.toDouble());
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.cycleElapsed != cycleElapsed ||
        oldDelegate.running != running ||
        oldDelegate.mode != mode;
  }
}

class _Segment {
  final double startAngle;
  final double sweepAngle;
  final Color color;
  final double duration;
  _Segment({
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
    required this.duration,
  });
}
