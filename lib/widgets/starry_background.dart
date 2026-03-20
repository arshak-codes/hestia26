import 'dart:math';
import 'package:flutter/material.dart';

class StarryBackground extends StatefulWidget {
  final Widget? child;
  const StarryBackground({super.key, this.child});

  @override
  State<StarryBackground> createState() => _StarryBackgroundState();
}

class _StarryBackgroundState extends State<StarryBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int numberOfStars = 150;
  final List<Star> stars = [];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < numberOfStars; i++) {
      stars.add(Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2.0 + 0.5,
        twinkleSpeed: random.nextDouble() * 0.5 + 0.5,
        phase: random.nextDouble() * pi * 2,
      ));
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0C0C0E),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: StarPainter(stars, _controller.value),
                size: Size.infinite,
              );
            },
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double twinkleSpeed;
  final double phase;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleSpeed,
    required this.phase,
  });
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var star in stars) {
      final currentPhase = star.phase + (animationValue * pi * 2) * star.twinkleSpeed * 5;
      final opacity = (sin(currentPhase) + 1) / 2; // 0.0 to 1.0
      
      final baseOpacity = (opacity * 0.7 + 0.1).clamp(0.0, 1.0);
      
      if (star.size > 2.0) {
         paint.color = const Color(0xFFE28B9B).withValues(alpha: baseOpacity);
      } else if (star.size > 1.5) {
         paint.color = const Color(0xFF9070E0).withValues(alpha: baseOpacity);
      } else {
         paint.color = Colors.white.withValues(alpha: baseOpacity);
      }
      
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) => true;
}
