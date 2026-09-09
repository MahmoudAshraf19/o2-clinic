import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/booking/presentation/pages/online_consultation_booking_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingHelper {
  /// Navigates to the booking page or shows a bottom sheet for online consultation choice.
  /// The [doctor] parameter can be of type from either doctor model implementations.
  static Future<void> onBookNowClicked(BuildContext context, dynamic doctor) async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    
    bool isOnline = false;
    try {
      final doc = await FirebaseFirestore.instance.collection('Doctors').doc(doctor.id).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        isOnline = data['is_online_consultation_available'] == true || 
                   data['isOnlineConsultationAvailable'] == true;
      } else {
        isOnline = doctor.isOnlineConsultationAvailable == true;
      }
    } catch (e) {
      try {
        isOnline = doctor.isOnlineConsultationAvailable == true;
      } catch (_) {}
    }
    
    Get.back(); // Close loading dialog

    if (isOnline) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildBookingOptionsSheet(context, doctor),
      );
    } else {
      Get.to(() => BookingPage(doctor: doctor));
    }
  }

  static Widget _buildBookingOptionsSheet(BuildContext context, dynamic doctor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          Text(
            'Choose Consultation Type', // Need to localize later if needed
            style: AppTextStyles.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'How would you like to consult with the doctor?',
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Option 1: In O2 Clinic
          _buildOptionButton(
            context: context,
            title: 'In O2 Clinic',
            icon: Icons.local_hospital_outlined,
            onTap: () {
              Navigator.pop(context); // Close bottom sheet
              Get.to(() => BookingPage(doctor: doctor)); // Go to normal booking
            },
          ),
          const SizedBox(height: 16),
          
          // Option 2: Online Consultation
          _buildOptionButton(
            context: context,
            title: 'Online Consultation', // Or use translation if possible
            icon: Icons.video_camera_front_outlined,
            onTap: () {
              Navigator.pop(context); // Close bottom sheet
              Get.to(() => OnlineConsultationBookingPage(doctor: doctor));
            },
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _buildOptionButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.primary.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
