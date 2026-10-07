class RadiologyItemModel {
  final String id;
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;
  final num price;
  final String icon;
  final String type;
  final String category;

  RadiologyItemModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.price,
    required this.icon,
    required this.type,
    required this.category,
  });

  factory RadiologyItemModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
    required String category,
  }) {
    return RadiologyItemModel(
      id: id,
      titleEn: map['title_en'] ?? '',
      titleAr: map['title_ar'] ?? '',
      descriptionEn: map['description_en'] ?? '',
      descriptionAr: map['description_ar'] ?? '',
      price: map['price'] ?? 0,
      icon: map['icon'] ?? '',
      type: map['type'] ?? '',
      category: category,
    );
  }
}
