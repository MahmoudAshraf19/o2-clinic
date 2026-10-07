class RadiologyUltrasoundModel {
  final String id;

  final String nameEn;
  final String nameAr;

  final String image;

  final String descriptionEn;
  final String descriptionAr;

  final num price;

  final bool isActive;

  RadiologyUltrasoundModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.image,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.price,
    required this.isActive,
  });

  factory RadiologyUltrasoundModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return RadiologyUltrasoundModel(
      id: id,

      nameEn: map['name_en'] ?? '',
      nameAr: map['name_ar'] ?? '',

      image: map['image'] ?? '',

      descriptionEn: map['description_en'] ?? '',
      descriptionAr: map['description_ar'] ?? '',

      price: map['price'] ?? 0,

      isActive: map['isActive'] ?? false,
    );
  }
}
