class DoctorModel {
  final String id;
  final String name;
  final String title;
  final String specialty;
  final double rating;
  final String image;
  final String? bio;
  final String? experience;
  final List<String>? availableDays;

  DoctorModel({
    required this.id,
    required this.name,
    required this.title,
    required this.specialty,
    required this.rating,
    required this.image,
    this.bio,
    this.experience,
    this.availableDays,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      specialty: json['specialty'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      image: json['image'] ?? '',
      bio: json['bio'],
      experience: json['experience'],
      availableDays: List<String>.from(json['availableDays'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'specialty': specialty,
      'rating': rating,
      'image': image,
      'bio': bio,
      'experience': experience,
      'availableDays': availableDays,
    };
  }
}
