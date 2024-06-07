import 'package:flutter/material.dart';

class RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double innerRadius;

  RingPainter({required this.color, required this.strokeWidth, required this.innerRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    double outerRadius = (size.shortestSide - strokeWidth) / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, outerRadius, paint);

    // 绘制内部圆
    if (innerRadius > 0) {
      double innerCircleRadius = outerRadius - innerRadius;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(center, innerCircleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class RingWidget extends StatelessWidget {
  final Color color;
  final double strokeWidth;
  final double innerRadius;

  const RingWidget({super.key, required this.color, required this.strokeWidth, required this.innerRadius});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(100),
      painter: RingPainter(color: color, strokeWidth: strokeWidth, innerRadius: innerRadius),
    );
  }
}