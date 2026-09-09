class SpecializedServiceModel {
  final String id;

  final String nameEn;
  final String nameAr;
  final String nameHe;

  final String subtitleEn;
  final String subtitleAr;
  final String subtitleHe;

  final String descriptionEn;
  final String descriptionAr;
  final String descriptionHe;

  final String image;
  
  final bool isEnabled;
  final int order;

  SpecializedServiceModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.nameHe,
    required this.subtitleEn,
    required this.subtitleAr,
    required this.subtitleHe,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.descriptionHe,
    required this.image,
    this.isEnabled = true,
    this.order = 0,
  });

  factory SpecializedServiceModel.fromMap({required Map<String, dynamic> map}) {
    return SpecializedServiceModel(
      id: map['id'] ?? '',

      nameEn: map['name_en'] ?? '',
      nameAr: map['name_ar'] ?? '',
      nameHe: map['name_he'] ?? '',

      subtitleEn: map['subtitle_en'] ?? '',
      subtitleAr: map['subtitle_ar'] ?? '',
      subtitleHe: map['subtitle_he'] ?? '',

      descriptionEn: map['description_en'] ?? '',
      descriptionAr: map['description_ar'] ?? '',
      descriptionHe: map['description_he'] ?? '',

      image: map['image'] ?? '',
      
      isEnabled: map['is_enabled'] ?? true,
      order: map['order'] ?? 0,
    );
  }

  String getLocalizedName(String langCode) {
    if (langCode == 'ar' && nameAr.isNotEmpty) return nameAr;
    if (langCode == 'he' && nameHe.isNotEmpty) return nameHe;
    return nameEn;
  }

  String getLocalizedSubtitle(String langCode) {
    if (langCode == 'ar' && subtitleAr.isNotEmpty) return subtitleAr;
    if (langCode == 'he' && subtitleHe.isNotEmpty) return subtitleHe;
    return subtitleEn;
  }

  String getLocalizedDescription(String langCode) {
    if (langCode == 'ar' && descriptionAr.isNotEmpty) return descriptionAr;
    if (langCode == 'he' && descriptionHe.isNotEmpty) return descriptionHe;
    return descriptionEn;
  }
}
