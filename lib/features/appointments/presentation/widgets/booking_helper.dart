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

class BookingHelper {
  static String title(BuildContext context, BookingModel booking) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    if (booking.doctor != null) {
      return isArabic ? booking.doctor!.nameAr : booking.doctor!.nameEn;
    }
    if (booking.service != null) {
      return isArabic
          ? booking.service!.serviceNameAr
          : booking.service!.serviceNameEn;
    }
    if (booking.imaging != null) {
      return isArabic ? booking.imaging!.nameAr : booking.imaging!.nameEn;
    }
    if (booking.cosmetic != null && booking.cosmetic!.serviceName.isNotEmpty) {
      return booking.cosmetic!.serviceName;
    }
    return AppLocalizations.of(context)!.appointmentOnly;
  }

  static String subtitle(BuildContext context, BookingModel booking) {
    if (booking.doctor?.specialty.isNotEmpty == true) {
      return booking.doctor!.specialty;
    }
    if (booking.location.clinic.isNotEmpty) return booking.location.clinic;
    return typeFriendly(context, booking.type);
  }

  static String typeFriendly(BuildContext context, String type) {
    final t = type.toLowerCase();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (t.contains('doctor')) return isAr ? 'طبيب' : 'Doctor';
    if (t.contains('service')) return isAr ? 'خدمة' : 'Service';
    if (t.contains('imaging')) return isAr ? 'أشعة' : 'Imaging';
    if (t.contains('cosmetic')) return isAr ? 'تجميل' : 'Cosmetic';
    if (t == 'online') return isAr ? 'عن بعد' : 'Online';
    return isAr ? 'حجز' : 'Booking';
  }
}
