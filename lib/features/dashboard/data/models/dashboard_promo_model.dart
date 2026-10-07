import 'package:flutter/material.dart';

class DashboardPromoModel {
  final String id;
  final String title;
  final String subtitle;
  final Color startColor;
  final Color endColor;

  const DashboardPromoModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.startColor,
    required this.endColor,
  });
}
