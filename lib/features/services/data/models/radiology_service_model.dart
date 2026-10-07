import 'package:flutter/material.dart';

class RadiologyServiceModel {
  final String title;
  final String desc;
  final String image;
  final String specialists;
  final String buttonText;
  final String badge;
  final bool isSecondary;
  final IconData badgeIcon;
  final double? price;

  RadiologyServiceModel({
    required this.title,
    required this.desc,
    required this.image,
    required this.specialists,
    required this.buttonText,
    required this.badge,
    required this.badgeIcon,
    this.isSecondary = false,
    this.price,
  });
}
