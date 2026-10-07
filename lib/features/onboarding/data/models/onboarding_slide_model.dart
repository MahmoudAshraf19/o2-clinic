import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingSlideModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int order;
  final bool isActive;

  const OnboardingSlideModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.order,
    required this.isActive,
  });

  // Creates a models from a Firestore document.
  factory OnboardingSlideModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    return OnboardingSlideModel(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      imageUrl: (data['imageUrl'] ?? '') as String,
      order: (data['order'] ?? 0) as int,
      isActive: (data['isActive'] ?? true) as bool,
    );
  }

  // Converts the models to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'order': order,
      'isActive': isActive,
    };
  }
}
