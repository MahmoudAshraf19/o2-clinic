class ServiceModel {
  final String id;
  final String title;
  final String titleAr;
  final String titleHe;
  final String subtitle;
  final String subtitleAr;
  final String subtitleHe;
  final String description;
  final String descriptionAr;
  final String descriptionHe;
  final String image;
  final int doctorsCount;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.title,
    this.titleAr = '',
    this.titleHe = '',
    required this.subtitle,
    this.subtitleAr = '',
    this.subtitleHe = '',
    this.description = '',
    this.descriptionAr = '',
    this.descriptionHe = '',
    required this.image,
    required this.doctorsCount,
    this.isActive = true,
  });
}
