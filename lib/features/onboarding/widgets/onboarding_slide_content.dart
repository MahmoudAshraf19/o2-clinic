import 'package:flutter/material.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/onboarding_slide_model.dart';

class OnboardingSlideContent extends StatelessWidget {
  const OnboardingSlideContent({super.key, required this.slide});

  final OnboardingSlideModel slide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero image area.
            SizedBox(
              height: constraints.maxHeight * 0.48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Organic shape behind the image.
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: const Color(0xFF69D1C5).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),

                  // Main image.
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF21897E).withValues(alpha: 0.15),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: slide.imageUrl.isEmpty
                        ? Container(
                            color: const Color(0xFF21897E).withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.local_hospital,
                              size: 80,
                              color: Color(0xFF21897E),
                            ),
                          )
                        : CachedImageWidget(imageUrl: slide.imageUrl, fit: BoxFit.cover),
                  ),

                  // Top-right badge.
                  Positioned(
                    top: 18,
                    right: 24,
                    child: _GlassBadge(
                      icon: Icons.verified_user,
                      iconColor: const Color(0xFF21897E),
                    ),
                  ),

                  // Bottom-left badge.
                  Positioned(
                    bottom: 24,
                    left: 16,
                    child: _GlassBadge(
                      icon: Icons.favorite,
                      iconColor: const Color(0xFF8980F5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Text block.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF181C1D),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    slide.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF3E4947),
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.icon, required this.iconColor});

  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, size: 22, color: iconColor),
    );
  }
}
