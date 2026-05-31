import 'package:flutter/material.dart';

class CompanyLogo extends StatelessWidget {
  const CompanyLogo({super.key, required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF0A56C2).withValues(alpha: 0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            width: 98,
            height: 98,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD7E4F8),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A56C2).withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => CustomPaint(
                  size: const Size.square(72),
                  painter: const _HeroMarkPainter(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMarkPainter extends CustomPainter {
  const _HeroMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.73;

    final gradient = const LinearGradient(
      colors: [Color(0xFF0A56C2), Color(0xFF082A63)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final outerPaint = Paint()
      ..shader = gradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.6
      ..strokeJoin = StrokeJoin.round;

    final innerPaint = Paint()
      ..color = const Color(0xFFEAF2FF)
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..shader = gradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;

    final outerHex = _hexagonPath(center, outerRadius);
    final innerHex = _hexagonPath(center, innerRadius);

    canvas.drawPath(innerHex, innerPaint);
    canvas.drawPath(outerHex, outerPaint);

    final leftX = size.width * 0.28;
    final rightX = size.width * 0.72;
    final topY = size.height * 0.24;
    final bottomY = size.height * 0.76;
    final middleY = size.height * 0.5;

    canvas.drawLine(Offset(leftX, topY), Offset(leftX, bottomY), accentPaint);
    canvas.drawLine(Offset(rightX, topY), Offset(rightX, bottomY), accentPaint);
    canvas.drawLine(
      Offset(leftX, middleY),
      Offset(rightX, middleY),
      accentPaint,
    );
  }

  Path _hexagonPath(Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = ((60 * i) - 30) * 3.141592653589793 / 180;
      final point = Offset(
        center.dx + radius * _Trig.cos(angle),
        center.dy + radius * _Trig.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Trig {
  static double sin(double value) {
    return _TaylorMath.sin(value);
  }

  static double cos(double value) {
    return _TaylorMath.cos(value);
  }
}

class _TaylorMath {
  static double sin(double value) {
    double term = value;
    double sum = value;

    for (int i = 1; i < 8; i++) {
      term *= -1 * value * value / ((2 * i) * (2 * i + 1));
      sum += term;
    }

    return sum;
  }

  static double cos(double value) {
    double term = 1;
    double sum = 1;

    for (int i = 1; i < 8; i++) {
      term *= -1 * value * value / ((2 * i - 1) * (2 * i));
      sum += term;
    }

    return sum;
  }
}
