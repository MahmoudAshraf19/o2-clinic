import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:o2_clinic/common/widgets/common_button.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';
import 'package:o2_clinic/common/widgets/common_snackbar.dart';
import 'package:o2_clinic/common/widgets/common_dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../booking/data/models/fs_booking_model.dart';
import '../../../booking/data/services/fs_bookings_firestore_service.dart';
import '../../../services/data/models/radiology_category_model.dart';
import '../../../booking/presentation/pages/radiology_confirm_booking_screen.dart';

class DoctorAvatar extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final bool isHero;

  const DoctorAvatar({
    this.imageUrl,
    required this.fallbackIcon,
    this.isHero = false,
  });

  @override
  Widget build(BuildContext context) {
    final double size = isHero ? 60 : 50;
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
      child: (imageUrl != null && imageUrl!.trim().isNotEmpty)
          ? CachedImageWidget(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(
                fallbackIcon,
                color: isHero ? AppColors.white : AppColors.primary,
              ),
            )
          : Icon(
              fallbackIcon,
              color: isHero ? AppColors.white : AppColors.primary,
            ),
    );
  }
}
