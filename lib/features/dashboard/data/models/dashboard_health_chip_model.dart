import 'package:flutter/material.dart';

class DashboardHealthChipModel {
  final String id;
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  const DashboardHealthChipModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });
}
