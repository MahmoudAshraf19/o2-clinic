import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../booking/views/booking_screen.dart';
import 'package:o2_clinic/features/booking/controllers/booking_controller.dart';

class DashboardBookScreen extends StatelessWidget {
  const DashboardBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the booking controller if not already registered
    if (!Get.isRegistered<BookingController>()) {
      Get.put(BookingController());
    }

    return BookingScreen();
  }
}
