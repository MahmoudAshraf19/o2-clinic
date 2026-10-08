import 'package:flutter/material.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = filled
        ? (isDark ? AppColors.primary : AppColors.white)
        : (isDark ? AppColors.black.withValues(alpha: 0.1) : AppColors.white.withValues(alpha: 0.15));
    final fg = filled 
        ? (isDark ? AppColors.white : AppColors.primary) 
        : (isDark ? AppColors.black87 : AppColors.white);

    return Semantics(
      button: true,
      label: text,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: fg, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
