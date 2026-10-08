import 'package:flutter/material.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';

class DoctorAvatar extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final bool isHero;

  const DoctorAvatar({
    super.key,
    this.imageUrl,
    required this.fallbackIcon,
    this.isHero = false,
  });

  @override
  Widget build(BuildContext context) {
    final double size = isHero ? 60 : 52;
    final iconColor = isHero ? AppColors.white : AppColors.primary;
    final url = imageUrl?.trim() ?? '';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isHero
            ? AppColors.white.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: url.isNotEmpty
          ? CachedImageWidget(
              imageUrl: url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(fallbackIcon, color: iconColor),
            )
          : Icon(fallbackIcon, color: iconColor),
    );
  }
}
