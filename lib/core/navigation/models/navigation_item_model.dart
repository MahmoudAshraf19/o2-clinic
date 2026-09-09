import 'package:flutter/material.dart';

class NavigationItemModel {
  const NavigationItemModel({
    required this.label,
    required this.icon,
    required this.index,
  });

  final String label;
  final IconData icon;
  final int index;
}