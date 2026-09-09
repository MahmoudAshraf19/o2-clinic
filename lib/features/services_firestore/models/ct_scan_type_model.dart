class CtScanTypeModel {
  final String id;

  final String nameEn;
  final String nameAr;

  CtScanTypeModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  factory CtScanTypeModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return CtScanTypeModel(
      id: id,

      nameEn: map['name_en'] ?? '',
      nameAr: map['name_ar'] ?? '',
    );
  }
}
