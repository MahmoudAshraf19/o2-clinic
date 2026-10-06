class CosmeticCategoryModel {
  final String id;

  final String titleEn;
  final String titleAr;

  final num price;

  final String image;

  final List<String> descriptionsEn;
  final List<String> descriptionsAr;

  final String buttonTextEn;
  final String buttonTextAr;

  final Map<String, String> availabilityDay;

  CosmeticCategoryModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.price,
    required this.image,
    required this.descriptionsEn,
    required this.descriptionsAr,
    required this.buttonTextEn,
    required this.buttonTextAr,
    required this.availabilityDay,
  });

  factory CosmeticCategoryModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return CosmeticCategoryModel(
      id: map['id'] ?? id,

      titleEn: map['title_en'] ?? '',
      titleAr: map['title_ar'] ?? '',

      price: map['price'] ?? 0,

      image: map['image'] ?? '',

      descriptionsEn:
          (map['descriptions_en'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      descriptionsAr:
          (map['descriptions_ar'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      buttonTextEn: map['buttonText_en'] ?? '',
      buttonTextAr: map['buttonText_ar'] ?? '',

      availabilityDay: (() {
        final dynamic rawMap = map['availability_day'];
        if (rawMap == null) return <String, String>{};
        if (rawMap is Map) {
          final parsed = rawMap.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          );
          return parsed;
        }
        return <String, String>{};
      })(),
    );
  }
}
