class MedicalDeviceModel {
  final String id;
  final String name;
  final String descriptionAr;
  final String descriptionEn;
  final String imageUrl;
  final String price;
  final String discountedPrice;
  final bool atDiscount;
  final bool isAvailable;
  final int index;

  MedicalDeviceModel({
    required this.id,
    required this.name,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.imageUrl,
    required this.price,
    required this.discountedPrice,
    required this.atDiscount,
    required this.isAvailable,
    required this.index,
  });

  factory MedicalDeviceModel.fromMap(Map<String, dynamic> map, String docId) {
    return MedicalDeviceModel(
      id: map['id'] ?? docId,
      name: map['name'] ?? '',
      descriptionAr: map['description_ar'] ?? '',
      descriptionEn: map['description_en'] ?? '',
      imageUrl: map['image_url'] ?? map['image'] ?? '',
      price: map['price']?.toString() ?? '0',
      discountedPrice: map['discounted_price']?.toString() ?? '',
      atDiscount: map['at_discount'] ?? false,
      isAvailable: map['is_available'] ?? true,
      index: (map['index'] ?? 0) as int,
    );
  }

  String getLocalizedDescription(String langCode) {
    if (langCode == 'ar' && descriptionAr.isNotEmpty) {
      return descriptionAr;
    }
    return descriptionEn.isNotEmpty ? descriptionEn : descriptionAr;
  }
}
