import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_firestore.dart';
import '../models/onboarding_slide_model.dart';

class OnboardingService {
  final FirebaseFirestore _firestore;

  OnboardingService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Watches active onboarding slides in order.
  ///
  /// NOTE: We fetch all documents and filter in memory because documents
  /// might be missing the 'isActive' field. The model defaults missing
  /// fields to 'true'.
  Stream<List<OnboardingSlideModel>> watchSlides() {
    return _firestore
        .collection(AppFirestoreCollections.onboardingSlides)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
          final slides = snapshot.docs
              .map(OnboardingSlideModel.fromDoc)
              .where((slide) => slide.isActive)
              .toList(growable: false);

          if (slides.isEmpty && snapshot.docs.isNotEmpty) {
          } else if (slides.isEmpty) {
          } else {}

          return slides;
        });
  }

  /// Direct fetch for onboarding slides.
  Future<List<OnboardingSlideModel>> getSlides() async {
    try {
      final snapshot = await _firestore
          .collection(AppFirestoreCollections.onboardingSlides)
          .orderBy('order')
          .get();

      final slides = snapshot.docs
          .map(OnboardingSlideModel.fromDoc)
          .where((slide) => slide.isActive)
          .toList(growable: false);

      return slides;
    } catch (e) {
      // Simpler fallback without order just in case index is missing
      try {
        final fallbackSnapshot = await _firestore
            .collection(AppFirestoreCollections.onboardingSlides)
            .get();

        final slides =
            fallbackSnapshot.docs
                .map(OnboardingSlideModel.fromDoc)
                .where((slide) => slide.isActive)
                .toList()
              ..sort((a, b) => a.order.compareTo(b.order));

        return slides;
      } catch (innerE) {
        return [];
      }
    }
  }
}
