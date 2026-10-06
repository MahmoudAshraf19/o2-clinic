import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String bookingId;
  final String doctorId;
  final String patientId;
  final String patientName;
  final String patientImage;
  final num rating;
  final String text;
  final Map<String, num> categoryRatings;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.patientImage,
    required this.rating,
    required this.text,
    required this.categoryRatings,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic dateVal) {
      if (dateVal == null) return DateTime.now();
      if (dateVal is Timestamp) return dateVal.toDate();
      if (dateVal is String)
        return DateTime.tryParse(dateVal) ?? DateTime.now();
      return DateTime.now();
    }

    final Map<String, num> parsedCategories = {};
    if (map['category_ratings'] is Map) {
      (map['category_ratings'] as Map).forEach((key, value) {
        if (value is num) parsedCategories[key.toString()] = value;
      });
    }

    return ReviewModel(
      id: id,
      bookingId: map['booking_id'] as String? ?? '',
      doctorId: map['doctor_id'] as String? ?? '',
      patientId: map['patient_id'] as String? ?? '',
      patientName: map['patient_name'] as String? ?? '',
      patientImage: map['patient_image'] as String? ?? '',
      rating: map['rating'] as num? ?? 0,
      text: map['text'] as String? ?? '',
      categoryRatings: parsedCategories,
      createdAt: parseDate(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'booking_id': bookingId,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_image': patientImage,
      'rating': rating,
      'text': text,
      'category_ratings': categoryRatings,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
