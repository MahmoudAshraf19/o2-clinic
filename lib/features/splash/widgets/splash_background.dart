
import 'package:flutter/material.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main gradient background.
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF21897E), Color(0xFF00685F)],
            ),
          ),
        ),

        // Soft top-left glow.
        Positioned(
          top: -80,
          left: -80,
          child: _GlowCircle(color: Colors.white, size: 220, opacity: 0.07),
        ),

        // Soft bottom-right glow.
        Positioned(
          bottom: -120,
          right: -90,
          child: _GlowCircle(
            color: const Color(0xFF69D1C5),
            size: 280,
            opacity: 0.12,
          ),
        ),

        // Blur overlay for a premium look.
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.08,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Colors.white, Colors.transparent],
                    radius: 1.2,
                    center: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
    required this.color,
    required this.size,
    required this.opacity,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
