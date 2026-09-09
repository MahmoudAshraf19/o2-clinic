import '../../domain/entities/doctor_entity.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.name,
    required super.specialty,
    required super.rating,
    required super.image,
    required super.time,
    super.availableDays,
    super.bookedPerDay,
    super.maxBookingsPerTime,
    super.yearsExp,
    super.patients,
    super.about,
    super.academicDegrees,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    try {
      final degreesJson = json['academicDegrees'];
      final availableDaysJson = json['availableDays'];
      final bookedPerDayJson = json['bookedPerDay'];
      Map<String, String> availableDaysMap = {};
      if (availableDaysJson is Map) {
        availableDaysJson.forEach((key, value) {
          availableDaysMap[key.toString()] = value.toString();
        });
      }

      Map<String, int> bookedPerDayMap = {};
      if (bookedPerDayJson is Map) {
        bookedPerDayJson.forEach((key, value) {
          final day = key.toString();
          final v = value;
          if (v is num) {
            bookedPerDayMap[day] = v.toInt();
          } else {
            final parsed = int.tryParse(v.toString());
            if (parsed != null) {
              bookedPerDayMap[day] = parsed;
            }
          }
        });
      }

      return DoctorModel(
        name: json['name'] ?? 'Unknown',
        specialty: json['specialty'] ?? 'General',
        rating: (json['rating'] ?? 0).toDouble(),
        image: json['image'] ?? '',
        time: json['time'] ?? 'Not Available',
        availableDays: availableDaysMap,
        bookedPerDay: bookedPerDayMap,
        maxBookingsPerTime: (json['maxBookingsPerTime'] is num)
            ? (json['maxBookingsPerTime'] as num).toInt()
            : 0,
        yearsExp:
            (json['yearsExp'] is num) ? (json['yearsExp'] as num).toInt() : 0,
        patients:
            (json['patients'] is num) ? (json['patients'] as num).toInt() : 0,
        about: (json['about'] ?? '') as String,
        academicDegrees: (degreesJson is List)
            ? degreesJson
                .map(
                  (d) {
                    if (d is Map) {
                      final map = Map<String, dynamic>.from(d);
                      return AcademicDegreeEntity(
                        name: (map['name'] ?? '') as String,
                        description: (map['description'] ?? '') as String,
                      );
                    }

                    return const AcademicDegreeEntity(name: '', description: '');
                  },
                )
                .where(
                  (d) => d.name.isNotEmpty || d.description.isNotEmpty,
                )
                .toList()
            : const [],
      );
    } catch (e) {
      throw Exception("DoctorModel Parsing Error: $e");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'image': image,
      'time': time,
      'availableDays': availableDays,
      'bookedPerDay': bookedPerDay,
      'maxBookingsPerTime': maxBookingsPerTime,
      'yearsExp': yearsExp,
      'patients': patients,
      'about': about,
      'academicDegrees': academicDegrees
          .map(
            (d) => {
              'name': d.name,
              'description': d.description,
            },
          )
          .toList(),
    };
  }
}