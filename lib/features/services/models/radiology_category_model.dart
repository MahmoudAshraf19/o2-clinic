import 'package:flutter/material.dart';

class RadiologyCategoryModel {
  final String id;
  final String image;
  final bool isActive;
  final int order;
  final Map<String, dynamic> nameMap;
  final Map<String, dynamic> descMap;
  final Map<String, dynamic> availabilityDay;
  final String price;

  RadiologyCategoryModel({
    required this.id,
    required this.image,
    required this.isActive,
    required this.order,
    required this.nameMap,
    required this.descMap,
    required this.availabilityDay,
    required this.price,
  });

  factory RadiologyCategoryModel.fromMap(String docId, Map<String, dynamic> map) {
    return RadiologyCategoryModel(
      id: docId,
      image: map['image'] ?? '',
      isActive: map['isActive'] ?? true,
      order: map['order'] ?? 0,
      nameMap: Map<String, dynamic>.from(map['name'] ?? {}),
      descMap: Map<String, dynamic>.from(map['description'] ?? {}),
      availabilityDay: Map<String, dynamic>.from(map['availability_day'] ?? {}),
      price: map['price']?.toString() ?? '0',
    );
  }

  String getName(String langCode) {
    return nameMap[langCode] ?? nameMap['en'] ?? id;
  }

  String getDesc(String langCode) {
    return descMap[langCode] ?? descMap['en'] ?? '';
  }

  IconData getBadgeIcon() {
    final title = id.toLowerCase();
    if (title.contains('ct')) return Icons.science;
    if (title.contains('ultrasound')) return Icons.visibility;
    return Icons.local_hospital;
  }
}
