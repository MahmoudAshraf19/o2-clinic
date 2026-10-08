import 'package:flutter/material.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import '../../../booking/data/models/fs_booking_model.dart';

/// Pure presentation helpers shared by the card, hero card and details sheet.
class BookingHelper {
  BookingHelper._();

  static bool isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  /// Prefers the current language, falls back to the other one if empty.
  static String _pick(bool isAr, String ar, String en) {
    final primary = (isAr ? ar : en).trim();
    if (primary.isNotEmpty) return primary;
    return (isAr ? en : ar).trim();
  }

  static String title(BuildContext context, BookingModel booking) {
    final isAr = isArabic(context);

    final doctor = booking.doctor;
    if (doctor != null) {
      final name = _pick(isAr, doctor.nameAr, doctor.nameEn);
      if (name.isNotEmpty) return name;
    }
    final service = booking.service;
    if (service != null) {
      final name = _pick(isAr, service.serviceNameAr, service.serviceNameEn);
      if (name.isNotEmpty) return name;
    }
    final imaging = booking.imaging;
    if (imaging != null) {
      final name = _pick(isAr, imaging.nameAr, imaging.nameEn);
      if (name.isNotEmpty) return name;
    }
    final cosmetic = booking.cosmetic;
    if (cosmetic != null && cosmetic.serviceName.trim().isNotEmpty) {
      return cosmetic.serviceName.trim();
    }
    return AppLocalizations.of(context)!.appointmentOnly;
  }

  static String subtitle(BuildContext context, BookingModel booking) {
    final specialty = booking.doctor?.specialty.trim() ?? '';
    if (specialty.isNotEmpty) return specialty;
    final clinic = booking.location.clinic.trim();
    if (clinic.isNotEmpty) return clinic;
    return typeFriendly(context, booking.type);
  }

  static String typeFriendly(BuildContext context, String type) {
    final t = type.toLowerCase();
    final isAr = isArabic(context);
    if (t == 'clinical') return isAr ? 'كشف عيادة' : 'Clinic visit';
    if (t == 'online') return isAr ? 'استشارة عن بعد' : 'Online';
    if (t.contains('doctor')) return isAr ? 'طبيب' : 'Doctor';
    if (t.contains('service')) return isAr ? 'خدمة' : 'Service';
    if (t.contains('imaging')) return isAr ? 'أشعة' : 'Imaging';
    if (t.contains('cosmetic')) return isAr ? 'تجميل' : 'Cosmetic';
    return isAr ? 'حجز' : 'Booking';
  }

  static IconData typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'clinical':
        return Icons.local_hospital_rounded;
      case 'online':
        return Icons.videocam_rounded;
      case 'imaging':
        return Icons.image_search_rounded;
      case 'cosmetic':
        return Icons.spa_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

  // ---------------------------------------------------------------------------
  // Date / time
  // ---------------------------------------------------------------------------

  static String dateText(BuildContext context, BookingModel booking) {
    final date = booking.schedule.timestamp?.toDate();
    if (date == null) return booking.schedule.date;
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  static String timeText(BuildContext context, BookingModel booking) {
    final date = booking.schedule.timestamp?.toDate();
    if (date == null) return booking.schedule.time;
    return MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(date));
  }

  static String whenText(BuildContext context, BookingModel booking) =>
      '${dateText(context, booking)} • ${timeText(context, booking)}';

  /// "Today", "Tomorrow", "In 3 days"… or null when the date is in the past.
  static String? relativeDay(BuildContext context, DateTime? date) {
    if (date == null) return null;
    final isAr = isArabic(context);
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final target = DateTime.utc(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff < 0) return null;
    if (diff == 0) return isAr ? 'اليوم' : 'Today';
    if (diff == 1) return isAr ? 'غداً' : 'Tomorrow';
    if (isAr) {
      if (diff == 2) return 'بعد يومين';
      if (diff <= 10) return 'بعد $diff أيام';
      return 'بعد $diff يوماً';
    }
    return 'In $diff days';
  }

  // ---------------------------------------------------------------------------
  // Location
  // ---------------------------------------------------------------------------

  /// "Clinic - Floor 2 - Room 5", skipping empty parts (online / imaging).
  static String locationText(BuildContext context, BookingModel booking) {
    final isAr = isArabic(context);
    final loc = booking.location;
    final parts = <String>[];

    final clinic = loc.clinic.trim();
    if (clinic.isNotEmpty) parts.add(clinic);

    final floor = loc.floor.toString().trim();
    if (floor.isNotEmpty && floor != 'null') {
      parts.add('${isAr ? 'طابق' : 'Floor'} $floor');
    }
    final room = loc.room.toString().trim();
    if (room.isNotEmpty && room != 'null') {
      parts.add('${isAr ? 'غرفة' : 'Room'} $room');
    }
    return parts.join(' - ');
  }
}
