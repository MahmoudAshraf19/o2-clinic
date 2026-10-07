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

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isAr;

  const StatusBadge({required this.status, required this.isAr});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    if (status == 'completed') {
      bg = AppColors.green50;
      fg = AppColors.green700;
      label = isAr ? 'مكتمل' : 'Completed';
    } else if (status == 'cancelled') {
      bg = AppColors.red50;
      fg = AppColors.red700;
      label = isAr ? 'ملغي' : 'Cancelled';
    } else if (status == 'pending' || status == 'pending_price') {
      bg = AppColors.orange50;
      fg = AppColors.orange700;
      label = isAr ? 'معلق' : 'Pending';
    } else {
      bg = AppColors.primary.withValues(alpha: 0.1);
      fg = AppColors.primary;
      label = isAr ? 'قادم' : 'Upcoming';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
