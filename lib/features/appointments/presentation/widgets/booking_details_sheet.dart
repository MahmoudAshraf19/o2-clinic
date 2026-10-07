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

class BookingDetailsSheet extends StatelessWidget {
  final BookingModel booking;
  const BookingDetailsSheet({required this.booking});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final date = booking.schedule.timestamp?.toDate();

    // Can cancel if status is not cancelled/completed/no_show
    final currentStatus = booking.status.current.toLowerCase();
    final bool canCancel =
        currentStatus != 'cancelled' &&
        currentStatus != 'completed' &&
        currentStatus != 'no_show';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
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
            children: [
              _DoctorAvatar(
                imageUrl: booking.doctor?.image,
                fallbackIcon: Icons.medical_services_rounded,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _BookingHelper.title(context, booking),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _BookingHelper.subtitle(context, booking),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(
                status: booking.status.current.toLowerCase(),
                isAr: isAr,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow(
            context,
            Icons.calendar_today_rounded,
            isAr ? 'التاريخ' : 'Date',
            date == null
                ? booking.schedule.date
                : MaterialLocalizations.of(context).formatMediumDate(date),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            Icons.access_time_rounded,
            isAr ? 'الوقت' : 'Time',
            date == null
                ? booking.schedule.time
                : MaterialLocalizations.of(
                    context,
                  ).formatTimeOfDay(TimeOfDay.fromDateTime(date)),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            Icons.location_on_rounded,
            isAr ? 'المكان' : 'Location',
            '${booking.location.clinic} - ${isAr ? 'طابق' : 'Floor'} ${booking.location.floor} - ${isAr ? 'غرفة' : 'Room'} ${booking.location.room}',
          ),
          const SizedBox(height: 32),
          if (booking.type == 'imaging' &&
              (booking.status.current == 'pending_price' ||
                  booking.status.current == 'pending')) ...[
            SizedBox(
              width: double.infinity,
              child: CommonButton(
                onPressed: () async {
                  Get.dialog(
                    const Center(
                      child: CommonLoadingIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    barrierDismissible: false,
                  );
                  try {
                    final catDoc = await FirebaseFirestore.instance
                        .collection('radiology')
                        .doc(booking.imaging!.categoryId)
                        .get();
                    Get.back(); // close loading
                    if (catDoc.exists) {
                      final service = RadiologyCategoryModel.fromMap(
                        catDoc.id,
                        catDoc.data()!,
                      );
                      Get.back(); // close bottom sheet

                      Get.to(
                        () => RadiologyConfirmBookingScreen(
                          service: service,
                          selectedDate:
                              booking.schedule.timestamp?.toDate() ??
                              DateTime.now(),
                          selectedTime: booking.schedule.time,
                          controllerTag: service.id,
                          bookingId: booking.id,
                        ),
                      );
                    } else {
                      CommonSnackbar.showError(title: 'Error', message: 'Service not found');
                    }
                  } catch (e) {
                    Get.back(); // close loading
                    CommonSnackbar.showError(title: 'Error', message: 'Failed to load details');
                  }
                },
                text: AppLocalizations.of(context)!.continueBookingOrChat,
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
            SizedBox(
              width: double.infinity,
              child: CommonButton(
                onPressed: () => Get.back(),
                text: isAr ? 'إغلاق' : 'Close',
                type: CommonButtonType.text,
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.grey600,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: CommonButton(
                onPressed: () => Get.back(),
                text: isAr ? 'إغلاق' : 'Close',
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
          ],
          if (canCancel) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CommonButton(
                onPressed: () async {
                  final confirm = await CommonDialogs.showConfirmationDialog(
                    context,
                    title: isAr ? 'إلغاء الحجز' : 'Cancel Booking',
                    message: isAr
                        ? 'هل أنت متأكد من إلغاء حجزك؟'
                        : 'Are you sure you want to cancel your booking?',
                    confirmText: isAr ? 'نعم' : 'Yes',
                    cancelText: isAr ? 'لا' : 'No',
                    isDestructive: true,
                  );

                  if (confirm == true) {
                    Get.dialog(
                      const Center(
                        child: CommonLoadingIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                      barrierDismissible: false,
                    );
                    try {
                      final service = BookingsFirestoreService();
                      await service.cancelBooking(booking);
                      Get.back(); // close loading
                      Get.back(); // close sheet
                      CommonSnackbar.showSuccess(title: isAr ? 'تم الإلغاء' : 'Cancelled', message: isAr
                            ? 'تم إلغاء حجزك بنجاح.'
                            : 'Your booking has been cancelled successfully.');
                    } catch (e) {
                      Get.back(); // close loading
                      CommonSnackbar.showError(title: 'Error', message: 'Failed to cancel booking');
                    }
                  }
                },
                type: CommonButtonType.outline,
                text: isAr ? 'إلغاء الحجز' : 'Cancel Booking',
                padding: const EdgeInsets.symmetric(vertical: 16),
                borderColor: AppColors.primary,
                borderWidth: 1.5,
                borderRadius: BorderRadius.circular(16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: AppColors.grey500),
              ),
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
      ],
    );
  }
}
