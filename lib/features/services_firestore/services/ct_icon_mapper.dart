
import 'package:flutter/material.dart';

class CtIconMapper {
  static IconData fromString(String value) {
    switch (value) {
      case 'psychology_outlined':
        return Icons.psychology_outlined;

      case 'accessible_forward_outlined':
        return Icons.accessible_forward_outlined;

      case 'air_outlined':
        return Icons.air_outlined;

      case 'dinner_dining_outlined':
        return Icons.dinner_dining_outlined;

      case 'airline_seat_legroom_extra_outlined':
        return Icons.airline_seat_legroom_extra_outlined;

      case 'accessibility_new_outlined':
        return Icons.accessibility_new_outlined;

      case 'fitness_center_outlined':
        return Icons.fitness_center_outlined;

      case 'front_hand_outlined':
        return Icons.front_hand_outlined;

      case 'directions_walk':
        return Icons.directions_walk;

      case 'face_retouching_natural':
        return Icons.face_retouching_natural;

      case 'medical_services_outlined':
        return Icons.medical_services_outlined;

      case 'science_outlined':
        return Icons.science_outlined;

      case 'monitor_heart_outlined':
        return Icons.monitor_heart_outlined;

      default:
        return Icons.medical_services_outlined;
    }
  }
}
