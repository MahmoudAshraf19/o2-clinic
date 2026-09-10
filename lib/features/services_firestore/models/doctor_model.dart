class DoctorModel {
  final String id;

  final String nameEn;
  final String nameAr;
  final String nameHe;

  final String titleEn;
  final String titleAr;
  final String titleHe;

  final String email;

  final String image;

  final String descriptionEn;
  final String descriptionAr;
  final String descriptionHe;

  final int maxBooking;

  final Map<String, String> availabilityDay;
  final Map<String, Map<String, String>> availabilityDayOnline;

  final bool isTopRateEnable;
  final bool theTop;
  final bool isOnlineConsultationAvailable;

  final String specialty;
  final int yearsExperience;
  final num price;
  final num priceForOnline;

  final String scheduleType;
  final Map<String, dynamic>? monthlySchedule;

  final int reviewsCount;
  final num totalRatingScore;
  final num ratingAverage;

  DoctorModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.nameHe,
    required this.titleEn,
    required this.titleAr,
    required this.titleHe,
    this.email = '',
    required this.image,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.descriptionHe,
    required this.maxBooking,
    required this.availabilityDay,
    this.availabilityDayOnline = const {},
    required this.isTopRateEnable,
    required this.theTop,
    this.isOnlineConsultationAvailable = false,
    required this.specialty,
    required this.yearsExperience,
    required this.price,
    this.priceForOnline = 0,
    this.scheduleType = 'weekly',
    this.monthlySchedule,
    this.reviewsCount = 0,
    this.totalRatingScore = 0,
    this.ratingAverage = 0,
  });

  factory DoctorModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    final rawAvailability = map['availability_day'];
    
    final rawOnline = map['availability_day_online'];
    Map<String, Map<String, String>> onlineMap = {};
    if (rawOnline is Map) {
      rawOnline.forEach((day, times) {
        if (times is Map) {
          onlineMap[day.toString()] = {
            'from': times['from']?.toString() ?? '',
            'to': times['to']?.toString() ?? '',
          };
        }
      });
    }

    return DoctorModel(
      id: id,
      nameEn: map['name_en'] ?? '',
      nameAr: map['name_ar'] ?? '',
      nameHe: map['name_he'] ?? '',
      titleEn: map['title_en'] ?? '',
      titleAr: map['title_ar'] ?? '',
      titleHe: map['title_he'] ?? '',
      email: map['email'] ?? '',
      image: map['image'] ?? '',
      descriptionEn: map['description_en'] ?? '',
      descriptionAr: map['description_ar'] ?? '',
      descriptionHe: map['description_he'] ?? '',
      maxBooking: (map['max_booking'] ?? 0) as int,
      availabilityDay: rawAvailability is Map
          ? rawAvailability.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : <String, String>{},
      availabilityDayOnline: onlineMap,
      isTopRateEnable: map['is_top_rate_enable'] ?? false,
      theTop: map['the_top'] ?? false,
      isOnlineConsultationAvailable: map['is_online_consultation_available'] ?? false,
      specialty: map['specialty'] ?? '',
      yearsExperience: (map['years_experience'] ?? 0) as int,
      price: (map['price'] ?? 0) as num,
      priceForOnline: (map['price_for_online'] ?? 0) as num,
      scheduleType: map['schedule_type'] ?? 'weekly',
      monthlySchedule: map['monthly_schedule'] as Map<String, dynamic>?,
      reviewsCount: (map['reviews_count'] ?? 0) as int,
      totalRatingScore: (map['total_rating_score'] ?? 0) as num,
      ratingAverage: (map['rating_average'] ?? 0) as num,
    );
  }
}
