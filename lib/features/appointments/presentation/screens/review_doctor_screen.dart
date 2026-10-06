import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../services_firestore/models/review_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewDoctorScreen extends StatefulWidget {
  final String bookingId;
  final String doctorId;
  final String patientName;
  final String patientImage;

  const ReviewDoctorScreen({
    super.key,
    required this.bookingId,
    required this.doctorId,
    required this.patientName,
    required this.patientImage,
  });

  @override
  State<ReviewDoctorScreen> createState() => _ReviewDoctorScreenState();
}

class _ReviewDoctorScreenState extends State<ReviewDoctorScreen> {
  final _textController = TextEditingController();
  bool _isSubmitting = false;

  double _overallRating = 5.0;
  Map<String, double> _categoryRatings = {
    'waiting_time': 5.0,
    'communication': 5.0,
    'clinic_cleanliness': 5.0,
    'effectiveness': 5.0,
  };

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);

    try {
      final patientId = FirebaseAuth.instance.currentUser?.uid ?? '';

      final docRef = FirebaseFirestore.instance
          .collection('Doctors')
          .doc(widget.doctorId)
          .collection('reviews')
          .doc();

      final review = ReviewModel(
        id: docRef.id,
        bookingId: widget.bookingId,
        doctorId: widget.doctorId,
        patientId: patientId,
        patientName: widget.patientName,
        patientImage: widget.patientImage,
        rating: _overallRating,
        text: _textController.text.trim(),
        categoryRatings: _categoryRatings,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // 1. Fetch Doctor (GET must come before any writes)
        final doctorRef = FirebaseFirestore.instance
            .collection('Doctors')
            .doc(widget.doctorId);
        final doctorSnapshot = await transaction.get(doctorRef);

        // 2. Add review (WRITE)
        transaction.set(docRef, review.toMap());

        // 3. Update Booking (WRITE)
        final bookingRef = FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingId);
        transaction.update(bookingRef, {'reviewId': review.id});

        // 4. Update Doctor Rating Average (WRITE)
        if (doctorSnapshot.exists) {
          final data = doctorSnapshot.data()!;
          int reviewsCount = (data['reviews_count'] ?? 0) as int;
          num totalScore = (data['total_rating_score'] ?? 0) as num;

          reviewsCount += 1;
          totalScore += _overallRating;
          num newAverage = totalScore / reviewsCount;

          transaction.update(doctorRef, {
            'reviews_count': reviewsCount,
            'total_rating_score': totalScore,
            'rating_average': newAverage,
          });
        }
      });

      Get.back();
      Get.snackbar(
        AppLocalizations.of(context)!.submitReview,
        'Review submitted successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit review',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildCategoryRating(String key, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              final val = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _categoryRatings[key] = val.toDouble();
                    // Update overall rating as average of categories
                    _overallRating =
                        _categoryRatings.values.reduce((a, b) => a + b) /
                        _categoryRatings.length;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Icon(
                    val <= (_categoryRatings[key] ?? 0)
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.orangeAccent,
                    size: 28,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          l10n.rateYourExperience ?? 'Rate Experience',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Overall Rating: ${_overallRating.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildCategoryRating(
                'waiting_time',
                l10n.catWaitingTime ?? 'Waiting Time',
              ),
              _buildCategoryRating(
                'communication',
                l10n.catCommunication ?? 'Communication',
              ),
              _buildCategoryRating(
                'clinic_cleanliness',
                l10n.catClinicCleanliness ?? 'Clinic Cleanliness',
              ),
              _buildCategoryRating(
                'effectiveness',
                l10n.catEffectiveness ?? 'Effectiveness',
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _textController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: l10n.writeYourReview ?? 'Write your review...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.submitReview ?? 'Submit Review',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

