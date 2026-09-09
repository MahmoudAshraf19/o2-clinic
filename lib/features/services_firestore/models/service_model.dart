class ServiceModel {
  final String id;
  final String titleEn;
  final String titleAr;
  final String titleHe;
  final String descriptionEn;
  final String descriptionAr;
  final String descriptionHe;
  final String image;

  ServiceModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.titleHe,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.descriptionHe,
    required this.image,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      titleEn: map['title_en'] ?? '',
      titleAr: map['title_ar'] ?? '',
      titleHe: map['title_he'] ?? '',
      descriptionEn: map['description_en'] ?? '',
      descriptionAr: map['description_ar'] ?? '',
      descriptionHe: map['description_he'] ?? '',
      image: map['image'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title_en': titleEn,
      'title_ar': titleAr,
      'title_he': titleHe,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'description_he': descriptionHe,
      'image': image
    };
  }
}
