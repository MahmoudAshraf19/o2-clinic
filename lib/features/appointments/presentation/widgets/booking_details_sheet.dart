import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:o2_clinic/core/theme/app_colors.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/common/widgets/common_button.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';
import 'package:o2_clinic/common/widgets/common_snackbar.dart';
import 'package:o2_clinic/common/widgets/common_dialogs.dart';

import '../../../booking/data/models/fs_booking_model.dart';
import '../../../booking/data/services/fs_bookings_firestore_service.dart';
import '../../../booking/presentation/screens/radiology_confirm_booking_screen.dart';
import '../../../services/data/models/radiology_category_model.dart';
import '../screens/report_issue_screen.dart';

import 'booking_helper.dart';
import 'doctor_avatar.dart';
import 'status_badge.dart';

class BookingDetailsSheet extends StatelessWidget {
  final BookingModel booking;
  const BookingDetailsSheet({super.key, required this.booking});

  static Future<void> show(BuildContext context, BookingModel booking) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => BookingDetailsSheet(booking: booking),
    );
  }

  static const Set<String> _nonCancellable = {
    'cancelled',
    'completed',
    'no_show',
    'under_investigation',
  };

  @override
  Widget build(BuildContext context) {
    final isAr = BookingHelper.isArabic(context);
    final l10n = AppLocalizations.of(context)!;
    final status = booking.status.current.toLowerCase();

    final canCancel = !_nonCancellable.contains(status);
    final canReport = status == 'completed';
    final canContinueImaging =
        booking.type.toLowerCase() == 'imaging' &&
        booking.imaging != null &&
        (status == 'pending_price' || status == 'pending');

    final location = BookingHelper.locationText(context, booking);
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DoctorAvatar(
                    imageUrl: booking.doctor?.image,
                    fallbackIcon: BookingHelper.typeIcon(booking.type),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          BookingHelper.title(context, booking),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          BookingHelper.subtitle(context, booking),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).brightness == Brightness.dark ? AppColors.white54 : AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: status, isAr: isAr),
                ],
              ),
              if (status == 'under_investigation') ...[
                const SizedBox(height: 16),
                _InfoBanner(
                  text: isAr
                      ? 'تم استلام بلاغك وهو قيد المراجعة من فريقنا.'
                      : 'Your report was received and is being reviewed by our team.',
                ),
              ],
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? AppColors.scaffoldDark.withValues(alpha: 0.5) 
                      : AppColors.colorFFF4F7F9,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: isAr ? 'التاريخ' : 'Date',
                      value: BookingHelper.dateText(context, booking),
                    ),
                    _divider(),
                    _DetailRow(
                      icon: Icons.access_time_rounded,
                      label: isAr ? 'الوقت' : 'Time',
                      value: BookingHelper.timeText(context, booking),
                    ),
                    if (location.isNotEmpty) ...[
                      _divider(),
                      _DetailRow(
                        icon: Icons.location_on_rounded,
                        label: isAr ? 'المكان' : 'Location',
                        value: location,
                      ),
                    ],
                    _divider(),
                    _DetailRow(
                      icon: Icons.confirmation_number_rounded,
                      label: isAr ? 'رقم الحجز' : 'Booking ref',
                      value: _shortRef(booking.id),
                      trailing: Icon(
                        Icons.copy_rounded,
                        size: 18,
                        color: AppColors.grey500,
                      ),
                      onTap: () => _copyRef(isAr),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (canContinueImaging) ...[
                SizedBox(
                  width: double.infinity,
                  child: CommonButton(
                    onPressed: () => _continueImagingBooking(isAr),
                    text: l10n.continueBookingOrChat,
                    type: CommonButtonType.primary,
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    borderRadius: BorderRadius.circular(16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (canReport) ...[
                SizedBox(
                  width: double.infinity,
                  child: CommonButton(
                    onPressed: () {
                      Get.back(); // close sheet
                      Get.to(
                        () => ReportIssueScreen(
                          bookingId: booking.id,
                          isPatient: true,
                        ),
                      );
                    },
                    icon: Icons.flag_outlined,
                    text: l10n.reportIssue,
                    type: CommonButtonType.outline,
                    borderColor: AppColors.error,
                    borderWidth: 1.5,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    borderRadius: BorderRadius.circular(16),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (canCancel) ...[
                SizedBox(
                  width: double.infinity,
                  child: CommonButton(
                    onPressed: () => _cancelBooking(context, isAr),
                    type: CommonButtonType.outline,
                    text: isAr ? 'إلغاء الحجز' : 'Cancel booking',
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    borderColor: AppColors.error,
                    borderWidth: 1.5,
                    borderRadius: BorderRadius.circular(16),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: CommonButton(
                  onPressed: () => Get.back(),
                  text: isAr ? 'إغلاق' : 'Close',
                  type: canContinueImaging
                      ? CommonButtonType.text
                      : CommonButtonType.primary,
                  backgroundColor: canContinueImaging
                      ? null
                      : (Theme.of(context).brightness == Brightness.dark ? AppColors.scaffoldDark : AppColors.primary),
                  foregroundColor: canContinueImaging
                      ? (Theme.of(context).brightness == Brightness.dark ? AppColors.white54 : AppColors.grey600)
                      : AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  borderRadius: BorderRadius.circular(16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  static String _shortRef(String id) {
    final clean = id.trim();
    if (clean.length <= 8) return clean.toUpperCase();
    return clean.substring(clean.length - 8).toUpperCase();
  }

  Future<void> _copyRef(bool isAr) async {
    await Clipboard.setData(ClipboardData(text: booking.id));
    CommonSnackbar.showSuccess(
      title: isAr ? 'تم النسخ' : 'Copied',
      message: isAr
          ? 'تم نسخ رقم الحجز.'
          : 'Booking reference copied to clipboard.',
    );
  }

  void _showLoading() {
    Get.dialog(
      const Center(child: CommonLoadingIndicator(color: AppColors.primary)),
      barrierDismissible: false,
    );
  }

  Future<void> _continueImagingBooking(bool isAr) async {
    final imaging = booking.imaging;
    if (imaging == null) return;

    var loadingOpen = true;
    void closeLoading() {
      if (loadingOpen) {
        loadingOpen = false;
        Get.back();
      }
    }

    _showLoading();
    try {
      final catDoc = await FirebaseFirestore.instance
          .collection('radiology')
          .doc(imaging.categoryId)
          .get();
      closeLoading();

      final data = catDoc.data();
      if (!catDoc.exists || data == null) {
        CommonSnackbar.showError(
          title: isAr ? 'خطأ' : 'Error',
          message: isAr ? 'الخدمة غير متاحة حالياً.' : 'Service not found.',
        );
        return;
      }

      final service = RadiologyCategoryModel.fromMap(catDoc.id, data);
      Get.back(); // close bottom sheet
      Get.to(
        () => RadiologyConfirmBookingScreen(
          service: service,
          selectedDate:
              booking.schedule.timestamp?.toDate() ?? DateTime.now(),
          selectedTime: booking.schedule.time,
          controllerTag: service.id,
          bookingId: booking.id,
        ),
      );
    } catch (_) {
      closeLoading();
      CommonSnackbar.showError(
        title: isAr ? 'خطأ' : 'Error',
        message: isAr ? 'تعذّر تحميل التفاصيل.' : 'Failed to load details.',
      );
    }
  }

  Future<void> _cancelBooking(BuildContext context, bool isAr) async {
    final confirm = await CommonDialogs.showConfirmationDialog(
      context,
      title: isAr ? 'إلغاء الحجز' : 'Cancel booking',
      message: isAr
          ? 'هل أنت متأكد من إلغاء حجزك؟'
          : 'Are you sure you want to cancel your booking?',
      confirmText: isAr ? 'نعم، إلغاء' : 'Yes, cancel',
      cancelText: isAr ? 'تراجع' : 'Keep it',
      isDestructive: true,
    );
    if (confirm != true) return;

    var loadingOpen = true;
    void closeLoading() {
      if (loadingOpen) {
        loadingOpen = false;
        Get.back();
      }
    }

    _showLoading();
    try {
      await BookingsFirestoreService().cancelBooking(booking);
      closeLoading();
      Get.back(); // close sheet
      CommonSnackbar.showSuccess(
        title: isAr ? 'تم الإلغاء' : 'Cancelled',
        message: isAr
            ? 'تم إلغاء حجزك بنجاح.'
            : 'Your booking has been cancelled successfully.',
      );
    } catch (_) {
      closeLoading();
      CommonSnackbar.showError(
        title: isAr ? 'خطأ' : 'Error',
        message: isAr ? 'تعذّر إلغاء الحجز.' : 'Failed to cancel booking.',
      );
    }
  }

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Divider(height: 1, color: AppColors.grey200),
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppColors.grey500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black87,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );

    if (onTap == null) return row;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: row,
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.orange50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: AppColors.orange700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppColors.orange700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
