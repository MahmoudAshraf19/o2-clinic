import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../models/navigation_item_model.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  // Bottom navigation items.
  final List<NavigationItemModel> items = const [
    NavigationItemModel(label: 'Home', icon: Icons.home_rounded, index: 0),
    NavigationItemModel(
      label: 'Doctors',
      icon: Icons.medical_services_rounded,
      index: 1,
    ),
    NavigationItemModel(
      label: 'Alerts',
      icon: Icons.chat_bubble_rounded,
      index: 3,
    ),
    NavigationItemModel(label: 'Profile', icon: Icons.person_rounded, index: 4),
  ];

  void changeTab(int index) {
    currentIndex.value = index;
  }

  Color get activeColor => AppColors.primary;
  Color get inactiveColor => AppColors.grey;
}
