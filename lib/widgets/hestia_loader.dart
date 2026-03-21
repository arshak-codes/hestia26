import 'package:flutter/material.dart';

class HestiaLoader extends StatefulWidget {
  const HestiaLoader({
    super.key,
    this.size = 68,
    this.label,
    this.compact = false,
  });

  final double size;
  final String? label;
  final bool compact;

  @override
  State<HestiaLoader> createState() => _HestiaLoaderState();
}

class _HestiaLoaderState extends State<HestiaLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = RotationTransition(
      turns: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.linear),
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE28B9B).withValues(alpha: 0.28),
              blurRadius: widget.compact ? 8 : 18,
              spreadRadius: widget.compact ? 1 : 3,
            ),
          ],
          gradient: const LinearGradient(
            colors: [Color(0xFFE28B9B), Color(0xFF9070E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(widget.compact ? 1.5 : 3),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFF111114),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.compact ? 2.5 : 7),
            child: ClipOval(
              child: Image.asset(
                'assets/hestia-logo-final-1.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.compact) {
      return logo;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        if (widget.label != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.label!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }
}
