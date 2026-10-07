class RadiologyXrayModel {
  final String id;

  final String titleEn;
  final String titleAr;

  final String icon;

  RadiologyXrayModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.icon,
  });

  factory RadiologyXrayModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return RadiologyXrayModel(
      id: id,

      titleEn: map['title_en'] ?? '',
      titleAr: map['title_ar'] ?? '',

      icon: map['icon'] ?? '',
    );
  }
}
