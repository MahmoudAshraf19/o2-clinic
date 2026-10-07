// lib/features/booking/widgets/Ultrasound/ultrasound_background.dart

import 'package:flutter/material.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';

class UltrasoundBackground extends StatelessWidget {
  const UltrasoundBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.colorFFF6FAF8, AppColors.colorFFF4F7FC],
          ),
        ),
      ),
    );
  }
}
