import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/onboarding_slide_model.dart';

class OnboardingSlideContent extends StatelessWidget {
  const OnboardingSlideContent({super.key, required this.slide});

  final OnboardingSlideModel slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hero image area
        Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: slide.imageUrl.isEmpty
                ? const Icon(
                    Icons.local_hospital,
                    size: 80,
                    color: AppColors.brandBlue,
                  )
                : Image.asset(slide.imageUrl, fit: BoxFit.contain),
          ),
        ),

        const SizedBox(height: 32),

        // Title
        Text(
          slide.title,
          textAlign: TextAlign.start,
          style: GoogleFonts.cairo(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.brandBlue,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 16),

        // Subtitle
        Text(
          slide.description,
          textAlign: TextAlign.start,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.brandBlue.withAlpha(160),
            height: 1.4,
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
