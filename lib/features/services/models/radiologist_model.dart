class RadiologistModel {
  final String id;
  final Map<String, dynamic> nameMap;
  final Map<String, dynamic> titleMap;
  final Map<String, dynamic> descMap;
  final String image;
  final int price;
  final bool isActive;

  RadiologistModel({
    required this.id,
    required this.nameMap,
    required this.titleMap,
    required this.descMap,
    required this.image,
    required this.price,
    required this.isActive,
  });

  factory RadiologistModel.fromMap(String docId, Map<String, dynamic> map) {
    return RadiologistModel(
      id: docId,
      nameMap: Map<String, dynamic>.from(map['name'] ?? {}),
      titleMap: Map<String, dynamic>.from(map['title'] ?? {}),
      descMap: Map<String, dynamic>.from(map['description'] ?? {}),
      image: map['image'] ?? '',
      price: map['price']?.toInt() ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  String getName(String langCode) {
    return nameMap[langCode] ?? nameMap['en'] ?? '';
  }

  String getTitle(String langCode) {
    return titleMap[langCode] ?? titleMap['en'] ?? '';
  }

  String getDesc(String langCode) {
    return descMap[langCode] ?? descMap['en'] ?? '';
  }
}
