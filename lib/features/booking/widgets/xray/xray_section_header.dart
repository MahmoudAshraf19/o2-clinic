import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';

class XRaySectionHeader extends StatelessWidget {
  const XRaySectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        fontFamily: AppFonts.dancingScript,
        height: 1,
      ),
    );
  }
}
