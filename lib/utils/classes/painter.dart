import 'package:flutter/material.dart';

class CalculatorIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Calculator body background
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(8),
    );

    // Draw calculator outline
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill,
    );

    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Display area
    final displayRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.15,
          size.width * 0.7, size.height * 0.25),
      Radius.circular(4),
    );
    canvas.drawRRect(displayRect, paint);

    // Button grid
    final buttonSize = size.width * 0.12;
    final spacing = size.width * 0.08;
    final startX = size.width * 0.15;
    final startY = size.height * 0.5;

    // Draw buttons (simplified grid)
    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 4; col++) {
        final x = startX + col * (buttonSize + spacing * 0.5);
        final y = startY + row * (buttonSize + spacing * 0.5);

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, buttonSize, buttonSize),
            Radius.circular(3),
          ),
          paint,
        );
      }
    }

    // Draw some calculator symbols
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Plus sign
    canvas.drawLine(
      Offset(startX + buttonSize * 0.5, startY + buttonSize * 0.3),
      Offset(startX + buttonSize * 0.5, startY + buttonSize * 0.7),
      strokePaint..color = Color(0xFF667eea)..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(startX + buttonSize * 0.3, startY + buttonSize * 0.5),
      Offset(startX + buttonSize * 0.7, startY + buttonSize * 0.5),
      strokePaint..color = Color(0xFF667eea)..strokeWidth = 2,
    );

    // Minus sign
    canvas.drawLine(
      Offset(startX + buttonSize * 1.5 + spacing * 0.5 + buttonSize * 0.3,
          startY + buttonSize * 0.5),
      Offset(startX + buttonSize * 1.5 + spacing * 0.5 + buttonSize * 0.7,
          startY + buttonSize * 0.5),
      strokePaint..color = Color(0xFF667eea)..strokeWidth = 2,
    );

    // Equals sign
    final equalsY = startY + buttonSize + spacing * 0.5;
    canvas.drawLine(
      Offset(startX + buttonSize * 2.5 + spacing + buttonSize * 0.2,
          equalsY + buttonSize * 0.4),
      Offset(startX + buttonSize * 2.5 + spacing + buttonSize * 0.8,
          equalsY + buttonSize * 0.4),
      strokePaint..color = Color(0xFF667eea)..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(startX + buttonSize * 2.5 + spacing + buttonSize * 0.2,
          equalsY + buttonSize * 0.6),
      Offset(startX + buttonSize * 2.5 + spacing + buttonSize * 0.8,
          equalsY + buttonSize * 0.6),
      strokePaint..color = Color(0xFF667eea)..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}