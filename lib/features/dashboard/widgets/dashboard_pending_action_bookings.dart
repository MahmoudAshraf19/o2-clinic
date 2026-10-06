import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../services_firestore/models/booking_model.dart';
import '../controllers/dashboard_pending_actions_controller.dart';
import '../../appointments/presentation/screens/my_appointments_screen.dart';
import '../../booking/presentation/pages/radiology_confirm_booking_screen.dart';
import '../../services/models/radiology_category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPendingActionBookings extends StatelessWidget {
  const DashboardPendingActionBookings({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardPendingActionsController());
    final isAr = Get.locale?.languageCode == 'ar';

    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox.shrink();
      }

      final bookings = controller.pendingBookings;
      if (bookings.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.requiresYourAction,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: AppFonts.dancingScript,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to appointments
                    Get.to(() => const MyAppointmentsScreen());
                  },
                  child: Text(
                    AppLocalizations.of(context)!.seeAll,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < bookings.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    _buildPendingCard(context, bookings[i], isAr),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    });
  }

  Widget _buildPendingCard(
    BuildContext context,
    BookingModel booking,
    bool isAr,
  ) {
    final dateKey = booking.schedule.timestamp != null
        ? DateFormat(
            'd MMM',
            Get.locale?.languageCode ?? 'en',
          ).format(booking.schedule.timestamp!.toDate())
        : booking.schedule.date;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  booking.imaging?.nameEn ?? booking.type,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '$dateKey • ${booking.schedule.time}',
            style: TextStyle(
              fontSize: 13,
              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey.shade600),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => _handleContinue(booking),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Theme.of(context).cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.continueBooking,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleContinue(BookingModel booking) async {
    if (booking.type != 'imaging' || booking.imaging == null) {
      Get.to(
        () => const MyAppointmentsScreen(),
        arguments: {'showBookingId': booking.id},
      );
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
      } else {
        Get.snackbar('Error', 'Service not found');
      }
    } catch (e) {
      Get.back(); // close loading
      Get.snackbar('Error', 'Failed to load details');
    }
  }
}



