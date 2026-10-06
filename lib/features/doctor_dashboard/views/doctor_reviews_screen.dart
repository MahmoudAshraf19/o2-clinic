import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../controllers/doctor_profile_controller.dart';
import '../../../core/constants/app_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../services_firestore/models/review_model.dart';

class DoctorReviewsScreen extends StatefulWidget {
  const DoctorReviewsScreen({super.key});

  @override
  State<DoctorReviewsScreen> createState() => _DoctorReviewsScreenState();
}

class _DoctorReviewsScreenState extends State<DoctorReviewsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _scrolled = false;

  String _searchQuery = '';
  String _sortType = 'newest'; // newest, oldest, highest, lowest

  List<ReviewModel> _reviews = [];
  bool _isLoading = true;
  String? _highlightReviewId;
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    _highlightReviewId = Get.arguments?['highlightReviewId'];
    _scrollController.addListener(_handleScroll);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    String? doctorId;
    if (Get.isRegistered<DoctorProfileController>()) {
      doctorId = Get.find<DoctorProfileController>().doctor.value?.id;
    }

    debugPrint('================ FETCHING REVIEWS ================');
    debugPrint('Found Doctor ID: $doctorId');

    if (doctorId == null) {
      debugPrint(
        'doctorId from controller is null, fetching manually via auth_uid...',
      );
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final docSnap = await FirebaseFirestore.instance
            .collection(AppFirestoreCollections.doctors)
            .where('auth_uid', isEqualTo: uid)
            .limit(1)
            .get();
        if (docSnap.docs.isNotEmpty) {
          doctorId = docSnap.docs.first.id;
          debugPrint('Fetched manually Doctor ID: $doctorId');
        }
      }
    }

    if (doctorId == null) {
      debugPrint('ERROR: doctorId is still null! Cannot fetch reviews.');
      debugPrint('================================================');
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection(AppFirestoreCollections.doctors)
          .doc(doctorId)
          .collection('reviews')
          .get();

      debugPrint(
        'Successfully fetched ${snap.docs.length} reviews from Doctors/$doctorId/reviews',
      );
      debugPrint('================================================');

      final reviews = snap.docs
          .map((d) => ReviewModel.fromMap(d.id, d.data()))
          .toList();

      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoading = false;
        });

        if (_highlightReviewId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToReview(_highlightReviewId!);
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint('================ ERROR FETCHING REVIEWS ================');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('========================================================');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToReview(String id) {
    final key = _itemKeys[id];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.2, // Leave some space at the top
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final shouldBeScrolled = _scrollController.offset > 10;
    if (shouldBeScrolled != _scrolled) {
      setState(() => _scrolled = shouldBeScrolled);
    }
  }

  List<ReviewModel> get _filteredAndSortedReviews {
    List<ReviewModel> filtered = _reviews.where((r) {
      if (_searchQuery.isEmpty) return true;
      final textMatch = r.text.toLowerCase().contains(_searchQuery);
      final nameMatch = r.patientName.toLowerCase().contains(_searchQuery);
      return textMatch || nameMatch;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortType) {
        case 'highest':
          return b.rating.compareTo(a.rating);
        case 'lowest':
          return a.rating.compareTo(b.rating);
        case 'oldest':
          return a.createdAt.compareTo(b.createdAt);
        case 'newest':
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return filtered;
  }

  List<_ReviewCategory> _calculateCategories() {
    final Map<String, List<num>> catScores = {
      'waiting_time': [],
      'communication': [],
      'clinic_cleanliness': [],
      'effectiveness': [],
    };

    for (var review in _reviews) {
      review.categoryRatings.forEach((key, val) {
        if (catScores.containsKey(key)) {
          catScores[key]!.add(val);
        }
      });
    }

    final l10n = AppLocalizations.of(context)!;

    String localizeCat(String key) {
      switch (key) {
        case 'waiting_time':
          return l10n.catWaitingTime ?? 'Waiting Time';
        case 'communication':
          return l10n.catCommunication ?? 'Communication';
        case 'clinic_cleanliness':
          return l10n.catClinicCleanliness ?? 'Clinic Cleanliness';
        case 'effectiveness':
          return l10n.catEffectiveness ?? 'Effectiveness';
        default:
          return key;
      }
    }

    List<_ReviewCategory> result = [];
    catScores.forEach((key, scores) {
      if (scores.isNotEmpty) {
        num avg = scores.reduce((a, b) => a + b) / scores.length;
        result.add(
          _ReviewCategory(
            title: localizeCat(key),
            value: avg.toStringAsFixed(1),
            progress: avg / 5.0,
          ),
        );
      }
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final categories = _calculateCategories();
    final displayedReviews = _filteredAndSortedReviews;
    final l10n = AppLocalizations.of(context)!;
    final reviewsTitle = l10n.reviewTitle ?? 'Doctor Reviews';

    double overallRating = 5.0;
    if (_reviews.isNotEmpty) {
      overallRating =
          _reviews.map((e) => e.rating).reduce((a, b) => a + b) /
          _reviews.length;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6FAF8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181D1C)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          reviewsTitle,
          style: const TextStyle(
            color: Color(0xFF181D1C),
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 20,
                  right: 20,
                  bottom: 64,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (categories.isNotEmpty)
                      _RatingSummaryCard(
                        categories: categories,
                        overallRating: overallRating,
                        totalReviews: _reviews.length,
                      ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: AppColors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: const TextStyle(
                                  color: AppColors.grey,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: AppColors.grey,
                                  size: 22,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortType,
                              icon: const Icon(
                                Icons.filter_list,
                                color: Colors.white,
                                size: 20,
                              ),
                              dropdownColor: AppColors.primary,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'newest',
                                  child: Text(l10n.sortNewest ?? 'Newest'),
                                ),
                                DropdownMenuItem(
                                  value: 'oldest',
                                  child: Text(l10n.sortOldest ?? 'Oldest'),
                                ),
                                DropdownMenuItem(
                                  value: 'highest',
                                  child: Text(l10n.sortHighest ?? 'Highest'),
                                ),
                                DropdownMenuItem(
                                  value: 'lowest',
                                  child: Text(l10n.sortLowest ?? 'Lowest'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _sortType = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    if (displayedReviews.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No reviews found',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          for (int i = 0; i < displayedReviews.length; i++) ...[
                            Container(
                              key: _itemKeys[displayedReviews[i].id] ??=
                                  GlobalKey(),
                              child: _ReviewCardWidget(
                                review: displayedReviews[i],
                                isHighlighted:
                                    _highlightReviewId ==
                                    displayedReviews[i].id,
                              ),
                            ),
                            if (i != displayedReviews.length - 1)
                              const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}

class _RatingSummaryCard extends StatelessWidget {
  const _RatingSummaryCard({
    required this.categories,
    required this.overallRating,
    required this.totalReviews,
  });

  final List<_ReviewCategory> categories;
  final double overallRating;
  final int totalReviews;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: isWide ? 140 : double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          overallRating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '/5',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        if (overallRating >= index + 1) {
                          return const Icon(
                            Icons.star,
                            size: 20,
                            color: Colors.orangeAccent,
                          );
                        } else if (overallRating > index &&
                            overallRating < index + 1) {
                          return const Icon(
                            Icons.star_half,
                            size: 20,
                            color: Colors.orangeAccent,
                          );
                        }
                        return const Icon(
                          Icons.star_border,
                          size: 20,
                          color: Colors.orangeAccent,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.totalReviewsCount(totalReviews),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isWide) ...[
                Container(
                  width: 1,
                  height: 180,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ],
              if (isWide)
                Expanded(
                  child: Column(
                    children: [
                      for (final category in categories)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _RatingRow(category: category),
                        ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    for (final category in categories)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _RatingRow(category: category),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.category});

  final _ReviewCategory category;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            category.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 8,
              color: Colors.white.withValues(alpha: 0.1),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: category.progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 32,
          child: Text(
            category.value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCategory {
  final String title;
  final String value;
  final double progress;

  const _ReviewCategory({
    required this.title,
    required this.value,
    required this.progress,
  });
}

class _ReviewCardWidget extends StatelessWidget {
  final ReviewModel review;
  final bool isHighlighted;

  const _ReviewCardWidget({required this.review, this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.primary.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted
              ? AppColors.primary
              : AppColors.grey.withValues(alpha: 0.1),
          width: isHighlighted ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: review.patientImage.isNotEmpty
                    ? NetworkImage(review.patientImage)
                    : null,
                child: review.patientImage.isEmpty
                    ? const Icon(Icons.person, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.patientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orangeAccent, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (review.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
