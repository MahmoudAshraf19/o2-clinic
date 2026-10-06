import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glass logo circle.
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
              const Icon(Icons.air, color: Colors.white, size: 56),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // App title.
        Text(
          'O2 Clinic',
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 64,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.0,
            fontStyle: FontStyle.italic,
          ),
        ),

        const SizedBox(height: 6),

        // Tagline.
        Text(
          'HEALTHCARE SIMPLIFIED',
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.70),
            letterSpacing: 3.0,
          ),
        ),
      ],
    );
  }
}
