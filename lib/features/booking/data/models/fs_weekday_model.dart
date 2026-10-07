class WeekdayModel {
  final String id;

  final String titleEn;
  final String titleAr;

  final String shortEn;

  final int order;

  final bool isActive;

  WeekdayModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.shortEn,
    required this.order,
    required this.isActive,
  });

  factory WeekdayModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return WeekdayModel(
      id: id,

      titleEn: map['title_en'] ?? '',

      titleAr: map['title_ar'] ?? '',

      shortEn: map['short_en'] ?? '',

      order: map['order'] ?? 0,

      isActive: map['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'title_en': titleEn,

      'title_ar': titleAr,

      'short_en': shortEn,

      'order': order,

      'isActive': isActive,
    };
  }
}
