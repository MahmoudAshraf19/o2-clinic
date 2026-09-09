class LanguageModel {
  final String image;
  final bool isActive;
  final bool isRtl;
  final String slug;
  final String title;

  const LanguageModel({
    required this.image,
    required this.isActive,
    required this.isRtl,
    required this.slug,
    required this.title,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      image: json['image'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      isRtl: json['is_rtl'] as bool? ?? false,
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'isActive': isActive,
      'is_rtl': isRtl,
      'slug': slug,
      'title': title,
    };
  }
}
