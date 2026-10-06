import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/doctor_appointments_controller.dart';
import '../controllers/doctor_navigation_controller.dart';
import '../views/doctor_statistics_screen.dart';
import '../views/doctor_reviews_screen.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  int _getTodaysAppointmentsCount(DoctorAppointmentsController ctrl) {
    final now = DateTime.now();
    int count = 0;
    for (var doc in ctrl.bookings) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null && data['schedule'] != null) {
        final dateStr = data['schedule']['date'] as String?;
        if (dateStr != null && dateStr.isNotEmpty) {
          try {
            final dt = DateTime.parse(dateStr);
            if (dt.year == now.year &&
                dt.month == now.month &&
                dt.day == now.day) {
              count++;
            }
          } catch (_) {}
        }
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = Get.put(DoctorAppointmentsController());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Today's Appointments (Solid Button)
              Obx(() {
                // Access length to force reactivity
                final _ = ctrl.bookings.length;
                final count = _getTodaysAppointmentsCount(ctrl);
                String title = l10n.todaysAppointments;
                if (count > 0) {
                  title += ' ($count)';
                }
                return Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary,
                        Color(0xFF1E877B),
                      ], // Slight gradient for premium feel
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final navCtrl = Get.find<DoctorNavigationController>();
                      navCtrl.changeIndex(1); // Go to APPTS tab
                      final apptCtrl = Get.put(DoctorAppointmentsController());
                      apptCtrl.setSelectedTargetDate(DateTime.now());
                      apptCtrl.targetStatus.value = 'upcoming';
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),

              // Statistics (Outlined Button)
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Get.to(() => const DoctorStatisticsScreen());
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    l10n.statistics,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Messages (Outlined Button)
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    final navCtrl = Get.find<DoctorNavigationController>();
                    navCtrl.changeIndex(2); // Go to Messages tab
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    l10n.messages,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Reviews (Outlined Button)
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to DoctorReviewsScreen
                    Get.to(() => const DoctorReviewsScreen());
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    l10n.reviewTitle ?? 'Doctor Reviews',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
