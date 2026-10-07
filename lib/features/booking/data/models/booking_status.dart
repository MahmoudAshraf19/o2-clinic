import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';

enum BookingStatus {
  pending,
  upcoming,
  inProgress,
  completed,
  cancelled,
  noShow;

  static BookingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'upcoming':
      case 'confirmed':
        return BookingStatus.upcoming;
      case 'in_progress':
      case 'inprogress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
      case 'canceled':
        return BookingStatus.cancelled;
      case 'no_show':
      case 'noshow':
        return BookingStatus.noShow;
      default:
        return BookingStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.upcoming:
        return 'upcoming';
      case BookingStatus.inProgress:
        return 'in_progress';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.noShow:
        return 'no_show';
    }
  }

  String get labelEn {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.upcoming:
        return 'Upcoming';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.noShow:
        return 'No Show';
    }
  }

  String get labelAr {
    switch (this) {
      case BookingStatus.pending:
        return 'قيد الانتظار';
      case BookingStatus.upcoming:
        return 'مؤكد';
      case BookingStatus.inProgress:
        return 'قيد التنفيذ';
      case BookingStatus.completed:
        return 'مكتمل';
      case BookingStatus.cancelled:
        return 'ملغي';
      case BookingStatus.noShow:
        return 'لم يحضر';
    }
  }

  String get label => Get.locale?.languageCode == 'ar' ? labelAr : labelEn;

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return AppColors.orange;
      case BookingStatus.upcoming:
        return AppColors.blue;
      case BookingStatus.inProgress:
        return AppColors.purple;
      case BookingStatus.completed:
        return AppColors.green;
      case BookingStatus.cancelled:
        return AppColors.red;
      case BookingStatus.noShow:
        return AppColors.grey;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case BookingStatus.pending:
        return AppColors.orange.withValues(alpha: 0.1);
      case BookingStatus.upcoming:
        return AppColors.blue.withValues(alpha: 0.1);
      case BookingStatus.inProgress:
        return AppColors.purple.withValues(alpha: 0.1);
      case BookingStatus.completed:
        return AppColors.green.withValues(alpha: 0.1);
      case BookingStatus.cancelled:
        return AppColors.red.withValues(alpha: 0.1);
      case BookingStatus.noShow:
        return AppColors.grey.withValues(alpha: 0.1);
    }
  }

  IconData get icon {
    switch (this) {
      case BookingStatus.pending:
        return Icons.schedule_rounded;
      case BookingStatus.upcoming:
        return Icons.event_available_rounded;
      case BookingStatus.inProgress:
        return Icons.play_circle_outline_rounded;
      case BookingStatus.completed:
        return Icons.check_circle_outline_rounded;
      case BookingStatus.cancelled:
        return Icons.cancel_outlined;
      case BookingStatus.noShow:
        return Icons.person_off_outlined;
    }
  }
}
