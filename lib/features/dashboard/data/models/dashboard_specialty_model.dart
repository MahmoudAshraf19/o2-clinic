import 'package:flutter/material.dart';

class DashboardSpecialtyModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool isAvailable;
  final String? nextSlotLabel;

  const DashboardSpecialtyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isAvailable,
    this.nextSlotLabel,
  });
}
