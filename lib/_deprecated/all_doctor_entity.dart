class DoctorEntity {
  final String name;
  final String specialty;
  final double rating;
  final String image;
  final String time;
  final Map<String, String> availableDays;
  final Map<String, int> bookedPerDay;
  final int maxBookingsPerTime;
  final int yearsExp;
  final int patients;
  final String about;
  final List<AcademicDegreeEntity> academicDegrees;

  const DoctorEntity({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.image,
    required this.time,
    this.availableDays = const {},
    this.bookedPerDay = const {},
    this.maxBookingsPerTime = 0,
    this.yearsExp = 0,
    this.patients = 0,
    this.about = '',
    this.academicDegrees = const [],
  });
}

class AcademicDegreeEntity {
  final String name;
  final String description;

  const AcademicDegreeEntity({required this.name, required this.description});
}
