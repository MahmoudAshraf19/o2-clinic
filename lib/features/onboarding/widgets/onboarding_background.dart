import 'dart:ui';

import 'package:flutter/material.dart';

class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background.
        Container(color: const Color(0xFFF7FAFA)),

        // Soft top-right glow.
        Positioned(
          top: -80,
          right: -60,
          child: _BlurGlow(color: const Color(0xFF69D1C5), size: 260),
        ),

        // Soft bottom-left glow.
        Positioned(
          bottom: -90,
          left: -70,
          child: _BlurGlow(color: const Color(0xFF21897E), size: 240),
        ),

        // Center mesh feel.
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.08,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0xFF69D1C5), Colors.transparent],
                    radius: 1.1,
                    center: Alignment.topLeft,
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

class _BlurGlow extends StatelessWidget {
  const _BlurGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
