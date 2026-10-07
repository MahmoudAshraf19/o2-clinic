import 'package:get/get.dart';

class CosmeticModel {
  final String id;
  final String titleEn;
  final String titleAr;
  final String image;
  final List<String> itemsEn;
  final List<String> itemsAr;
  final String buttonTextEn;
  final String buttonTextAr;
  final double price;
  final bool isActive;
  final Map<String, String> availabilityDay;

  CosmeticModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.image,
    required this.itemsEn,
    required this.itemsAr,
    required this.buttonTextEn,
    required this.buttonTextAr,
    required this.price,
    this.isActive = true,
    this.availabilityDay = const {},
  });

  bool get _isAr => Get.locale?.languageCode == 'ar';

  String get title => _isAr ? titleAr : titleEn;
  List<String> get items => _isAr ? itemsAr : itemsEn;
  String get buttonText => _isAr ? buttonTextAr : buttonTextEn;
}
