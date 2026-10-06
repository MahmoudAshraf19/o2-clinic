import 'package:flutter/material.dart';

class CosmeticCategoryModel {
  final String id;
  final String image;
  final bool isActive;
  final int order;
  final Map<String, dynamic> nameMap;
  final Map<String, dynamic> descMap;
  final Map<String, dynamic> availabilityDay;
  final String price;

  CosmeticCategoryModel({
    required this.id,
    required this.image,
    required this.isActive,
    required this.order,
    required this.nameMap,
    required this.descMap,
    required this.availabilityDay,
    required this.price,
  });

  factory CosmeticCategoryModel.fromMap(
    String docId,
    Map<String, dynamic> map,
  ) {
    return CosmeticCategoryModel(
      id: docId,
      image: map['image'] ?? '',
      isActive: map['isActive'] ?? true,
      order: map['order'] ?? 0,
      nameMap: Map<String, dynamic>.from(map['name'] ?? {}),
      descMap: Map<String, dynamic>.from(map['description'] ?? {}),
      availabilityDay: Map<String, dynamic>.from(
        map['availability_day'] ?? map['availabilityDay'] ?? {},
      ),
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
    if (title.contains('laser')) return Icons.flash_on;
    if (title.contains('skin')) return Icons.face;
    if (title.contains('nutrition')) return Icons.local_dining;
    return Icons.spa;
  }
}
