import 'package:flutter/material.dart';

/// Leaf emblem matching the reference design for TaazaBazar.
class TaazaBazarEmblem extends StatelessWidget {
  final double size;

  const TaazaBazarEmblem({
    super.key,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.3,
      height: size,
      child: CustomPaint(
        painter: _ReferenceLeafPainter(),
      ),
    );
  }
}

/// Backward-compatible and alias components
typedef TaazaEmblem = TaazaBazarEmblem;
typedef FreshlyEmblem = TaazaBazarEmblem;

class TaazaBazarLogo extends StatelessWidget {
  final double size;

  const TaazaBazarLogo({
    super.key,
    this.size = 96,
  });

  @override
  Widget build(BuildContext context) {
    return TaazaBazarEmblem(size: size);
  }
}

typedef TaazaLogo = TaazaBazarLogo;
typedef FreshlyLogo = TaazaBazarLogo;

/// Custom painter for the exact dual-leaf emblem with white vein curves
class _ReferenceLeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // --- 1. Small Left Leaf (Pointing top-left) ---
    final smallLeafPath = Path();
    smallLeafPath.moveTo(w * 0.44, h * 0.88);
    smallLeafPath.cubicTo(
      w * 0.18,
      h * 0.78,
      w * 0.15,
      h * 0.42,
      w * 0.28,
      h * 0.28,
    );
    smallLeafPath.cubicTo(
      w * 0.46,
      h * 0.40,
      w * 0.48,
      h * 0.65,
      w * 0.44,
      h * 0.88,
    );
    smallLeafPath.close();

    final smallLeafPaint = Paint()
      ..color = const Color(0xFF45B93F) // Bright vibrant lime/spring leaf
      ..style = PaintingStyle.fill;

    canvas.drawPath(smallLeafPath, smallLeafPaint);

    // Left Leaf White Vein
    final smallVeinPath = Path();
    smallVeinPath.moveTo(w * 0.43, h * 0.85);
    smallVeinPath.quadraticBezierTo(
      w * 0.35,
      h * 0.58,
      w * 0.29,
      h * 0.32,
    );

    final smallVeinPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(smallVeinPath, smallVeinPaint);

    // --- 2. Large Right Leaf (Pointing top-right) ---
    final mainLeafPath = Path();
    mainLeafPath.moveTo(w * 0.40, h * 0.90);
    mainLeafPath.cubicTo(
      w * 0.35,
      h * 0.45,
      w * 0.52,
      h * 0.08,
      w * 0.84,
      h * 0.05,
    );
    mainLeafPath.cubicTo(
      w * 0.92,
      h * 0.42,
      w * 0.75,
      h * 0.85,
      w * 0.40,
      h * 0.90,
    );
    mainLeafPath.close();

    final mainLeafPaint = Paint()
      ..color = const Color(0xFF0F6832) // Deep rich dark leaf green
      ..style = PaintingStyle.fill;

    canvas.drawPath(mainLeafPath, mainLeafPaint);

    // Main Leaf White Vein
    final mainVeinPath = Path();
    mainVeinPath.moveTo(w * 0.42, h * 0.86);
    mainVeinPath.quadraticBezierTo(
      w * 0.58,
      h * 0.50,
      w * 0.80,
      h * 0.10,
    );

    final mainVeinPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.034
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(mainVeinPath, mainVeinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
