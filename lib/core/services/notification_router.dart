import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/notifications/views/notifications_screen.dart';
import '../../features/chat_support/screens/chat_room_screen.dart';
// TODO: import booking details if available

class NotificationRouter {
  static void handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('🔔 [NotificationRouter] Handling data: $data');

    if (data.isEmpty) {
      _navigateToFallback();
      return;
    }

    final String? screen = data['screen'];

    try {
      switch (screen) {
        case 'chat':
          // The ChatRoomScreen automatically gets the current user's uid in its controller
          debugPrint('🔔 [NotificationRouter] Navigate to chat');
          Get.to(() => const ChatRoomScreen());
          break;

        case 'doctor_chat_patient':
          final doctorId = data['doctorId'];
          final chatRoomId = data['chatRoomId'];
          if (chatRoomId != null) {
            // Patient taps notification from doctor -> opens chat with doctor
            // The PatientChatScreen will need the doctor ID and details, but typically we can navigate by chatRoomId or pass it.
            // Wait, we need to create the PatientChatScreen first. 
            // We'll navigate to a route that handles it or pass parameters.
            Get.toNamed('/patient_chat', parameters: {'chatRoomId': chatRoomId, 'doctorId': doctorId ?? ''});
          } else {
            _navigateToFallback();
          }
          break;

        case 'doctor_chat_doctor':
          final chatRoomId = data['chatRoomId'];
          if (chatRoomId != null) {
            // Doctor taps notification from patient -> opens chat with patient
            Get.toNamed('/doctor_active_chat', parameters: {'chatRoomId': chatRoomId});
          } else {
            _navigateToFallback();
          }
          break;

        case 'booking_details':
        case 'receipt':
          final bookingId = data['bookingId'];
          if (bookingId != null) {
            // Get.to(() => BookingDetailsScreen(bookingId: bookingId));
            debugPrint('🔔 [NotificationRouter] Navigate to booking: $bookingId');
            // _navigateToFallback();
          } else {
            _navigateToFallback();
          }
          break;

        default:
          _navigateToFallback();
      }
    } catch (e) {
      debugPrint('💥 [NotificationRouter] Error routing: $e');
      _navigateToFallback();
    }
  }

  static void _navigateToFallback() {
    // Only navigate if we're not already on the notifications screen
    if (Get.currentRoute != '/NotificationsScreen') {
      Get.to(() => const NotificationsScreen());
    }
  }
}
