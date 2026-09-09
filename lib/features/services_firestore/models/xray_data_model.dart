import 'package:flutter/material.dart';

class XrayCategoryModel {
  final String id;
  final String titleEn;
  final String titleAr;
  final String iconKey;
  final int order;
  final int serviceCount;

  const XrayCategoryModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.iconKey,
    required this.order,
    required this.serviceCount,
  });

  factory XrayCategoryModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
    int serviceCount = 0,
  }) {
    return XrayCategoryModel(
      id: id,
      titleEn: _readString(map, const ['title_en', 'titleEn', 'name_en', 'nameEn'], fallback: id),
      titleAr: _readString(map, const ['title_ar', 'titleAr', 'name_ar', 'nameAr'], fallback: id),
      iconKey: _readString(map, const ['icon', 'icon_key', 'iconKey'], fallback: 'medical_services_outlined'),
      order: _readInt(map, const ['order', 'sort', 'priority'], fallback: 0),
      serviceCount: serviceCount,
    );
  }

  XrayCategoryModel copyWith({
    String? id,
    String? titleEn,
    String? titleAr,
    String? iconKey,
    int? order,
    int? serviceCount,
  }) {
    return XrayCategoryModel(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      iconKey: iconKey ?? this.iconKey,
      order: order ?? this.order,
      serviceCount: serviceCount ?? this.serviceCount,
    );
  }

  String titleForLanguage(String languageCode) {
    final code = languageCode.toLowerCase();
    if (code.startsWith('ar') && titleAr.trim().isNotEmpty) return titleAr;
    return titleEn;
  }

  IconData get iconData => XrayIconResolver.byKey(iconKey);
}

class XrayServiceModel {
  final String id;
  final String categoryId;
  final String nameEn;
  final String nameAr;
  final num price;
  final int order;

  const XrayServiceModel({
    required this.id,
    required this.categoryId,
    required this.nameEn,
    required this.nameAr,
    required this.price,
    required this.order,
  });

  factory XrayServiceModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return XrayServiceModel(
      id: id,
      categoryId: _readString(map, const ['categoryId', 'category_id'], fallback: ''),
      nameEn: _readString(map, const ['name_en', 'nameEn'], fallback: id),
      nameAr: _readString(map, const ['name_ar', 'nameAr'], fallback: id),
      price: _readNum(map, const ['price'], fallback: 0),
      order: _readInt(map, const ['order', 'sort', 'priority'], fallback: 0),
    );
  }

  String nameForLanguage(String languageCode) {
    final code = languageCode.toLowerCase();
    if (code.startsWith('ar') && nameAr.trim().isNotEmpty) return nameAr;
    return nameEn;
  }
}

class XrayCatalog {
  final List<XrayCategoryModel> categories;
  final List<XrayServiceModel> services;
  final Map<String, List<XrayServiceModel>> servicesByCategory;

  const XrayCatalog({
    required this.categories,
    required this.services,
    required this.servicesByCategory,
  });

  factory XrayCatalog.empty() => const XrayCatalog(
        categories: <XrayCategoryModel>[],
        services: <XrayServiceModel>[],
        servicesByCategory: <String, List<XrayServiceModel>>{},
      );
}

class XrayIconResolver {
  static IconData byKey(String key) {
    switch (key.toLowerCase()) {
      case 'thorax':
      case 'chest':
        return Icons.monitor_heart_outlined;
      case 'upper_limb':
      case 'hand':
        return Icons.front_hand_outlined;
      case 'lower_limb':
      case 'leg':
        return Icons.directions_walk;
      case 'head':
      case 'brain':
        return Icons.face_retouching_natural;
      case 'neck':
        return Icons.accessible_forward_outlined;
      case 'spine':
        return Icons.accessibility_new_outlined;
      case 'abdomen':
        return Icons.dinner_dining_outlined;
      case 'pelvis':
        return Icons.airline_seat_legroom_extra_outlined;
      case 'bones':
        return Icons.fitness_center_outlined;
      case 'dental':
        return Icons.medical_services_outlined;
      case 'special_chest':
      case 'special':
        return Icons.science_outlined;
      default:
        return Icons.medical_services_outlined;
    }
  }
}

String _readString(
  Map<String, dynamic> map,
  List<String> keys, {
  required String fallback,
}) {
  for (final key in keys) {
    final value = map[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return fallback;
}

int _readInt(
  Map<String, dynamic> map,
  List<String> keys, {
  required int fallback,
}) {
  for (final key in keys) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return fallback;
}

num _readNum(
  Map<String, dynamic> map,
  List<String> keys, {
  required num fallback,
}) {
  for (final key in keys) {
    final value = map[key];
    if (value is num) return value;
    final parsed = num.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return fallback;
}
typedef XrayDataModel = XrayServiceModel;