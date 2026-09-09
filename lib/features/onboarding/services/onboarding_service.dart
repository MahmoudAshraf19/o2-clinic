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
    print('🔥 FIRESTORE: Creating stream for onboarding_slides collection...');

    return _firestore
        .collection(AppFirestoreCollections.onboardingSlides)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
          print(
            '🔥 FIRESTORE: Stream snapshot received with ${snapshot.docs.length} documents',
          );

          final slides = snapshot.docs
              .map(OnboardingSlideModel.fromDoc)
              .where((slide) => slide.isActive)
              .toList(growable: false);

          if (slides.isEmpty && snapshot.docs.isNotEmpty) {
            print('⚠️ FIRESTORE: Found documents but none are "active"');
          } else if (slides.isEmpty) {
            print('⚠️ FIRESTORE: No documents found in collection');
          } else {
            print(
              '✅ FIRESTORE: Successfully processed ${slides.length} active slides',
            );
          }

          return slides;
        });
  }

  /// Direct fetch for onboarding slides.
  Future<List<OnboardingSlideModel>> getSlides() async {
    print('🔥 FIRESTORE: Direct fetch from onboarding_slides collection...');

    try {
      final snapshot = await _firestore
          .collection(AppFirestoreCollections.onboardingSlides)
          .orderBy('order')
          .get();

      print('📊 FIRESTORE: Found ${snapshot.docs.length} documents in total');

      final slides = snapshot.docs
          .map(OnboardingSlideModel.fromDoc)
          .where((slide) => slide.isActive)
          .toList(growable: false);

      print('✅ FIRESTORE: Found ${slides.length} active slides');

      return slides;
    } catch (e) {
      print('❌ FIRESTORE: Direct fetch error - $e');

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
        print('❌ FIRESTORE: Fallback fetch also failed - $innerE');
        return [];
      }
    }
  }
}
