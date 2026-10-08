import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/chat_support/presentation/screens/chat_room_screen.dart';
import '../../features/doctors/data/services/doctor_firestore_service.dart';
import 'package:o2_clinic/common/models/fs_doctor_model.dart';
import '../../features/chat_doctors/presentation/screens/patient_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/chat_doctors/data/models/doctor_chat_model.dart';
import '../../features/chat_doctors/presentation/screens/doctor_active_chat_screen.dart';
import '../../features/appointments/presentation/screens/my_appointments_screen.dart';

class NotificationRouter {
  static Future<void> handleNotificationTap(
    Map<String, dynamic> data, {
    bool fromSplash = false,
  }) async {
    debugPrint('🔔 [NotificationRouter] Handling data: $data');

    if (data.isEmpty) {
      if (!fromSplash) _navigateToFallback();
      return;
    }

    final String? screen = data['screen'];

    try {
      switch (screen) {
        case 'chat':
          debugPrint('🔔 [NotificationRouter] Navigate to chat');
          Get.to(() => const ChatRoomScreen());
          break;

        case 'doctor_chat_patient':
          final doctorId = data['doctorId'];
          final chatRoomId = data['chatRoomId'];
          if (doctorId != null && chatRoomId != null) {
            final docData = await DoctorFirestoreService.instance.getDoctor(
              doctorId,
            );
            if (docData != null) {
              final doctor = DoctorModel(
                id: doctorId,
                nameEn: docData['name_en'] ?? docData['name'] ?? '',
                nameAr: docData['name_ar'] ?? docData['name'] ?? '',
                nameHe: docData['name_he'] ?? docData['name'] ?? '',
                titleEn: docData['title_en'] ?? docData['title'] ?? '',
                titleAr: docData['title_ar'] ?? docData['title'] ?? '',
                titleHe: docData['title_he'] ?? docData['title'] ?? '',
                descriptionEn: docData['description_en'] ?? docData['description'] ?? '',
                descriptionAr: docData['description_ar'] ?? docData['description'] ?? '',
                descriptionHe: docData['description_he'] ?? docData['description'] ?? '',
                image: docData['image'] ?? '',
                ratingAverage: (docData['rating_average'] ?? 5.0).toDouble(),
                reviewsCount: docData['reviews_count'] ?? 0,
                maxBooking: docData['max_booking'] ?? 0,
                availabilityDay: {},
                isTopRateEnable: docData['is_top_rate_enable'] ?? false,
                theTop: docData['the_top'] ?? false,
                specialty: docData['specialty'] ?? '',
                yearsExperience: docData['years_experience'] ?? 0,
                price: docData['price'] ?? 0,
              );
              Get.to(() => PatientChatScreen(doctor: doctor));
            } else {
              if (!fromSplash) _navigateToFallback();
            }
          } else {
            if (!fromSplash) _navigateToFallback();
          }
          break;

        case 'doctor_chat_doctor':
          final chatRoomId = data['chatRoomId'];
          if (chatRoomId != null) {
            final doc = await FirebaseFirestore.instance
                .collection('chat_doctors')
                .doc(chatRoomId)
                .get();
            if (doc.exists && doc.data() != null) {
              final room = DoctorChatRoom.fromDoc(doc.id, doc.data()!);
              Get.to(() => DoctorActiveChatScreen(room: room));
            } else {
              if (!fromSplash) _navigateToFallback();
            }
          } else {
            if (!fromSplash) _navigateToFallback();
          }
          break;

        case 'booking_details':
        case 'receipt':
        case 'radiology_chat':
          final bookingId = data['bookingId'];
          if (bookingId != null) {
            debugPrint(
              '🔔 [NotificationRouter] Navigate to booking: $bookingId',
            );
            Get.to(
              () => MyAppointmentsScreen(),
              arguments: {'showBookingId': bookingId},
            );
          } else {
            if (!fromSplash) _navigateToFallback();
          }
          break;

        default:
          if (!fromSplash) _navigateToFallback();
      }
    } catch (e) {
      debugPrint('💥 [NotificationRouter] Error routing: $e');
      if (!fromSplash) _navigateToFallback();
    }
  }

  static void _navigateToFallback() {
    // Only navigate if we're not already on the notifications screen
    if (Get.currentRoute != '/NotificationsScreen') {
      Get.to(() => const NotificationsScreen());
    }
  }
}
