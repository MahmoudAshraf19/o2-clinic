import 'package:flutter/material.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';

class CTScanBackground extends StatelessWidget {
  const CTScanBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.colorFFF9FBFF, AppColors.colorFFF4F7FC],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
