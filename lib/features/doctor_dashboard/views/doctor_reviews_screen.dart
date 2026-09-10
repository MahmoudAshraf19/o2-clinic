import 'package:flutter/material.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../services_firestore/models/review_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DoctorReviewsScreen extends StatefulWidget {
  final List<ReviewModel> reviews;

  const DoctorReviewsScreen({super.key, required this.reviews});

  @override
  State<DoctorReviewsScreen> createState() => _DoctorReviewsScreenState();
}

class _DoctorReviewsScreenState extends State<DoctorReviewsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _scrolled = false;
  
  String _searchQuery = '';
  String _sortType = 'newest'; // newest, oldest, highest, lowest

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
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
    List<ReviewModel> filtered = widget.reviews.where((r) {
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

    for (var review in widget.reviews) {
      review.categoryRatings.forEach((key, val) {
        if (catScores.containsKey(key)) {
          catScores[key]!.add(val);
        }
      });
    }

    final l10n = AppLocalizations.of(context)!;
    
    String localizeCat(String key) {
      switch(key) {
        case 'waiting_time': return l10n.catWaitingTime ?? 'Waiting Time';
        case 'communication': return l10n.catCommunication ?? 'Communication';
        case 'clinic_cleanliness': return l10n.catClinicCleanliness ?? 'Clinic Cleanliness';
        case 'effectiveness': return l10n.catEffectiveness ?? 'Effectiveness';
        default: return key;
      }
    }

    List<_ReviewCategory> result = [];
    catScores.forEach((key, scores) {
      if (scores.isNotEmpty) {
        num avg = scores.reduce((a, b) => a + b) / scores.length;
        result.add(_ReviewCategory(
          title: localizeCat(key),
          value: avg.toStringAsFixed(1),
          progress: avg / 5.0,
        ));
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
    if (widget.reviews.isNotEmpty) {
      overallRating = widget.reviews.map((e) => e.rating).reduce((a, b) => a + b) / widget.reviews.length;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          reviewsTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 64),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (categories.isNotEmpty)
                _RatingSummaryCard(categories: categories, overallRating: overallRating, totalReviews: widget.reviews.length),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: AppColors.grey.withOpacity(0.2)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: const TextStyle(color: AppColors.grey),
                          prefixIcon: const Icon(Icons.search, color: AppColors.grey, size: 22),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        icon: const Icon(Icons.filter_list, color: Colors.white, size: 20),
                        dropdownColor: AppColors.primary,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        items: [
                          DropdownMenuItem(value: 'newest', child: Text(l10n.sortNewest ?? 'Newest')),
                          DropdownMenuItem(value: 'oldest', child: Text(l10n.sortOldest ?? 'Oldest')),
                          DropdownMenuItem(value: 'highest', child: Text(l10n.sortHighest ?? 'Highest')),
                          DropdownMenuItem(value: 'lowest', child: Text(l10n.sortLowest ?? 'Lowest')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _sortType = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              Column(
                children: [
                  for (int i = 0; i < displayedReviews.length; i++) ...[
                    _ReviewCardWidget(review: displayedReviews[i]),
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
  const _RatingSummaryCard({required this.categories, required this.overallRating, required this.totalReviews});

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
            color: AppColors.primary.withOpacity(0.3),
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
                              color: Colors.white.withOpacity(0.7),
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
                          return const Icon(Icons.star, size: 20, color: Colors.orangeAccent);
                        } else if (overallRating > index && overallRating < index + 1) {
                          return const Icon(Icons.star_half, size: 20, color: Colors.orangeAccent);
                        }
                        return const Icon(Icons.star_border, size: 20, color: Colors.orangeAccent);
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.totalReviewsCount(totalReviews),
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                  ],
                ),
              ),
              if (isWide) ...[
                Container(
                  width: 1,
                  height: 180,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  color: Colors.white.withOpacity(0.1),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  color: Colors.white.withOpacity(0.1),
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
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 8,
              color: Colors.white.withOpacity(0.1),
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
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
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

  const _ReviewCardWidget({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: review.patientImage.isNotEmpty ? NetworkImage(review.patientImage) : null,
                child: review.patientImage.isEmpty ? const Icon(Icons.person, color: AppColors.primary) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.patientName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                      style: const TextStyle(fontSize: 12, color: AppColors.grey),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          if (review.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.text,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
            ),
          ]
        ],
      ),
    );
  }
}
