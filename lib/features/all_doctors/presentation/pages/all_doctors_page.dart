import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../services_firestore/models/doctor_model.dart';
import '../../../services_firestore/models/specialized_service_model.dart';
import '../../../services_firestore/services/doctors_cache_service.dart';
import '../../../services_firestore/services/specialized_cache.dart';
import '../pages/doctor_profile_page.dart';
import '../widgets/category_chips.dart';
import '../widgets/doctor_card.dart';
import '../widgets/search_bar.dart';

class AllDoctorsPage extends StatefulWidget {
  const AllDoctorsPage({super.key, this.onBack, this.showBackButton = true});

  final VoidCallback? onBack;
  final bool showBackButton;

  @override
  State<AllDoctorsPage> createState() => _AllDoctorsPageState();
}

class _AllDoctorsPageState extends State<AllDoctorsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<DoctorModel> _allDoctors = [];
  List<DoctorModel> _filteredDoctors = [];
  Map<String, String> _categories = {'All': 'All'};
  Map<String, String> _categoryMap = {};
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String? _errorMessage;

  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final results = await Future.wait([
        DoctorsCacheService.getDoctors(),
        SpecializedCache.getData(),
      ]);

      final doctors = results[0] as List<DoctorModel>;
      final specialized = results[1] as List<SpecializedServiceModel>;

      final Map<String, String> categoryMap = {};
      final locale = Localizations.localeOf(context).languageCode;

      for (final item in specialized) {
        final englishLabel = item.nameEn;
        String localized = englishLabel;
        
        if (locale == 'ar' && item.nameAr.isNotEmpty) {
          localized = item.nameAr;
        } else if (locale == 'he' && item.nameHe.isNotEmpty) {
          localized = item.nameHe;
        }

        if (englishLabel.isNotEmpty) {
           final key = _normalizeCategory(englishLabel);
           categoryMap[key] = localized;
        }
        
        if (item.id.isNotEmpty) {
           final idKey = _normalizeCategory(item.id);
           categoryMap[idKey] = localized;
        }
      }

      for (final doctor in doctors) {
        final key = _normalizeCategory(doctor.specialty);
        if (key.isNotEmpty) {
          categoryMap.putIfAbsent(key, () => _beautifyCategory(doctor.specialty));
        }
      }

      final Map<String, String> uniqueCategories = {'All': 'All'};
      final Set<String> seenValues = {};

      for (final val in categoryMap.values) {
        if (!seenValues.contains(val)) {
          seenValues.add(val);
          uniqueCategories[val] = val;
        }
      }

      if (!mounted) return;

      setState(() {
        _allDoctors = doctors;
        _categoryMap = categoryMap;
        _categories = uniqueCategories;
        if (!_categories.containsKey(_selectedCategory)) {
          _selectedCategory = 'All';
        }
        _filteredDoctors = _buildFilteredDoctors();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('💥 LOAD DOCTORS SCREEN ERROR: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load doctors';
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    DoctorsCacheService.clearCache();
    SpecializedCache.clear();
    await _loadData();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value.trim().toLowerCase();
      _filteredDoctors = _buildFilteredDoctors();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _filteredDoctors = _buildFilteredDoctors();
    });
  }

  List<DoctorModel> _buildFilteredDoctors() {
    final query = _query;

    return _allDoctors.where((doctor) {
      final matchesSearch =
          query.isEmpty ||
          doctor.nameEn.toLowerCase().contains(query) ||
          doctor.nameAr.toLowerCase().contains(query) ||
          doctor.nameHe.toLowerCase().contains(query) ||
          doctor.specialty.toLowerCase().contains(query) ||
          doctor.titleEn.toLowerCase().contains(query) ||
          doctor.titleAr.toLowerCase().contains(query) ||
          doctor.titleHe.toLowerCase().contains(query);

      final localizedSpecialty = _categoryMap[_normalizeCategory(doctor.specialty)] ?? _beautifyCategory(doctor.specialty);
      final matchesCategory =
          _selectedCategory == 'All' ||
          localizedSpecialty == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _addCategory(Map<String, String> categoryMap, String? rawValue) {
    final value = rawValue?.trim() ?? '';
    if (value.isEmpty) return;

    final key = _normalizeCategory(value);
    if (key.isEmpty) return;

    categoryMap.putIfAbsent(key, () => _beautifyCategory(value));
  }

  String _normalizeCategory(String value) {
    return value
        .replaceAll(RegExp(r'[^a-zA-Z0-9\u0600-\u06FF\u0590-\u05FF\s]'), ' ') // support arabic/hebrew if needed, but mainly for english special chars
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  String _readSpecialtyLabel(dynamic item) {
    try {
      final nameEn = item.nameEn;
      if (nameEn is String && nameEn.trim().isNotEmpty) return nameEn.trim();
    } catch (_) {}
    try {
      final titleEn = item.titleEn;
      if (titleEn is String && titleEn.trim().isNotEmpty) return titleEn.trim();
    } catch (_) {}
    try {
      final name = item.name;
      if (name is String && name.trim().isNotEmpty) return name.trim();
    } catch (_) {}
    try {
      final title = item.title;
      if (title is String && title.trim().isNotEmpty) return title.trim();
    } catch (_) {}
    try {
      final specialty = item.specialty;
      if (specialty is String && specialty.trim().isNotEmpty) {
        return specialty.trim();
      }
    } catch (_) {}
    try {
      final id = item.id;
      if (id is String && id.trim().isNotEmpty) {
        return _beautifyId(id);
      }
    } catch (_) {}
    return '';
  }

  String _beautifyCategory(String value) {
    final raw = value.replaceAll('-', ' ').replaceAll('_', ' ').trim();
    if (raw.isEmpty) return value;

    return raw
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
        .join(' ');
  }

  String _beautifyId(String value) {
    final raw = value.replaceAll('-', ' ').replaceAll('_', ' ').trim();
    if (raw.isEmpty) return value;
    return raw
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
        .join(' ');
  }

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Row(
        children: [
          if (widget.showBackButton) ...[
            GestureDetector(
              onTap: widget.onBack ?? () => Navigator.of(context).pop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.allDoctors,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: AppFonts.dancingScript,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.chooseYourSpecialist,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.75),
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFonts.inter,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildTopSection()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchBarWidget(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                      ),
                      const SizedBox(height: 18),
                      CategoryChips(
                        categories: _categories,
                        selectedCategory: _selectedCategory,
                        onSelected: _onCategorySelected,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      _errorMessage == 'Failed to load doctors' ? AppLocalizations.of(context)!.failedToLoadDoctors : _errorMessage!,
                      style: const TextStyle(
                        fontFamily: AppFonts.inter,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else if (_filteredDoctors.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/no_doctors_found.png',
                          width: 250,
                          height: 250,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.noDoctorsFound,
                          style: TextStyle(
                            fontFamily: AppFonts.inter,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final doctor = _filteredDoctors[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DoctorCard(
                          doctor: doctor,
                          localizedSpecialty: _categories[_normalizeCategory(doctor.specialty)],
                          onViewProfile: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DoctorProfilePage(
                                      doctor: doctor,
                                      localizedSpecialty: _categories[_normalizeCategory(doctor.specialty)],
                                    ),
                              ),
                            );
                          },
                          onBook: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DoctorProfilePage(
                                      doctor: doctor,
                                      localizedSpecialty: _categories[_normalizeCategory(doctor.specialty)],
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    }, childCount: _filteredDoctors.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

