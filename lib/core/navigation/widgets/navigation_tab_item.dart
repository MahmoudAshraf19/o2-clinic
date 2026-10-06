import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class NavigationTabItem extends StatelessWidget {
  const NavigationTabItem({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
    this.imagePath,
  }) : assert(icon != null || imagePath != null);

  final IconData? icon;
  final String? imagePath;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white54 : AppColors.grey);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isActive ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: imagePath != null
                    ? Image.asset(
                        imagePath!,
                        width: 24,
                        height: 24,
                        color: color,
                      )
                    : Icon(
                        icon,
                        color: color,
                        size: 24,
                        weight: isActive ? 700 : 400,
                      ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                style: GoogleFonts.poppins(
                  fontSize: isActive ? 11 : 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: 1.2,
                  color: color,
                  height: 1.0,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

