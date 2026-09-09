import 'package:get/get.dart';

class RadiologyCtModel {
  final String id;

  final String titleEn;
  final String titleAr;
  final String titleHe;

  final String descriptionEn;
  final String descriptionAr;
  final String descriptionHe;

  final num price;
  final String icon;
  final String type;

  RadiologyCtModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.titleHe,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.descriptionHe,
    required this.price,
    required this.icon,
    required this.type,
  });

  String get title {
    final lang = Get.locale?.languageCode ?? 'en';
    if (lang == 'ar' && titleAr.isNotEmpty) return titleAr;
    if (lang == 'he' && titleHe.isNotEmpty) return titleHe;
    return titleEn.isNotEmpty ? titleEn : id;
  }

  String get description {
    final lang = Get.locale?.languageCode ?? 'en';
    if (lang == 'ar' && descriptionAr.isNotEmpty) return descriptionAr;
    if (lang == 'he' && descriptionHe.isNotEmpty) return descriptionHe;
    return descriptionEn;
  }

  factory RadiologyCtModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return RadiologyCtModel(
      id: id,
      titleEn: map['title_en'] ?? '',
      titleAr: map['title_ar'] ?? '',
      titleHe: map['title_he'] ?? '',
      descriptionEn: map['description_en'] ?? '',
      descriptionAr: map['description_ar'] ?? '',
      descriptionHe: map['description_he'] ?? '',
      price: map['price'] ?? 0,
      icon: map['icon'] ?? '',
      type: map['type'] ?? '',
    );
  }
}
