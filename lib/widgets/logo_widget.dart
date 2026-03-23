import 'package:flutter/material.dart';
import '../core/theme.dart';

class LogoPainter extends CustomPainter {
  final double size;

  LogoPainter({this.size = 100});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final scale = canvasSize.width / 100;

    // Shield shape
    final shieldPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final shieldPath = Path();
    shieldPath.moveTo(center.dx, center.dy - 40 * scale);
    shieldPath.quadraticBezierTo(
      center.dx + 38 * scale, center.dy - 30 * scale,
      center.dx + 35 * scale, center.dy - 5 * scale,
    );
    shieldPath.quadraticBezierTo(
      center.dx + 30 * scale, center.dy + 25 * scale,
      center.dx, center.dy + 42 * scale,
    );
    shieldPath.quadraticBezierTo(
      center.dx - 30 * scale, center.dy + 25 * scale,
      center.dx - 35 * scale, center.dy - 5 * scale,
    );
    shieldPath.quadraticBezierTo(
      center.dx - 38 * scale, center.dy - 30 * scale,
      center.dx, center.dy - 40 * scale,
    );
    shieldPath.close();
    canvas.drawPath(shieldPath, shieldPaint);

    // Shield border
    final borderPaint = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale;
    canvas.drawPath(shieldPath, borderPaint);

    // Sprout stem
    final stemPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scale
      ..strokeCap = StrokeCap.round;

    final stemPath = Path();
    stemPath.moveTo(center.dx, center.dy + 20 * scale);
    stemPath.quadraticBezierTo(
      center.dx, center.dy,
      center.dx, center.dy - 5 * scale,
    );
    canvas.drawPath(stemPath, stemPaint);

    // Left leaf
    final leafPaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..style = PaintingStyle.fill;

    final leftLeaf = Path();
    leftLeaf.moveTo(center.dx, center.dy - 2 * scale);
    leftLeaf.quadraticBezierTo(
      center.dx - 20 * scale, center.dy - 25 * scale,
      center.dx - 8 * scale, center.dy - 28 * scale,
    );
    leftLeaf.quadraticBezierTo(
      center.dx - 2 * scale, center.dy - 18 * scale,
      center.dx, center.dy - 2 * scale,
    );
    canvas.drawPath(leftLeaf, leafPaint);

    // Right leaf
    final rightLeaf = Path();
    rightLeaf.moveTo(center.dx, center.dy - 5 * scale);
    rightLeaf.quadraticBezierTo(
      center.dx + 20 * scale, center.dy - 28 * scale,
      center.dx + 8 * scale, center.dy - 30 * scale,
    );
    rightLeaf.quadraticBezierTo(
      center.dx + 2 * scale, center.dy - 20 * scale,
      center.dx, center.dy - 5 * scale,
    );
    canvas.drawPath(rightLeaf, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LogoWidget extends StatelessWidget {
  final double size;

  const LogoWidget({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: LogoPainter(size: size),
      ),
    );
  }
}
