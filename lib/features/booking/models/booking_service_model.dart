import 'package:get/get.dart';

class BookingServiceModel {
  final String id;
  final String titleEn;
  final String titleAr;
  final String titleHe;
  final String descriptionEn;
  final String descriptionAr;
  final String descriptionHe;
  final String category;
  final String image;
  final String price;

  BookingServiceModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.titleHe,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.descriptionHe,
    required this.category,
    required this.image,
    required this.price,
  });

  String get title {
    final lang = Get.locale?.languageCode ?? 'en';
    if (lang == 'ar' && titleAr.isNotEmpty) return titleAr;
    if (lang == 'he' && titleHe.isNotEmpty) return titleHe;
    return titleEn;
  }

  String get description {
    final lang = Get.locale?.languageCode ?? 'en';
    if (lang == 'ar' && descriptionAr.isNotEmpty) return descriptionAr;
    if (lang == 'he' && descriptionHe.isNotEmpty) return descriptionHe;
    return descriptionEn;
  }
}
