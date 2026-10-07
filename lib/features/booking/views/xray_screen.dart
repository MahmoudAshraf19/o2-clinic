import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../widgets/xray/xray_background.dart';
import '../widgets/xray/xray_bottom_action_bar.dart';
import '../widgets/xray/xray_card.dart';
import '../widgets/xray/xray_data.dart';
import '../../services_firestore/models/xray_data_model.dart';
import 'imaging_booking_page.dart';

class XRayScreen extends StatefulWidget {
  const XRayScreen({super.key});

  @override
  State<XRayScreen> createState() => _XRayScreenState();
}

class _XRayScreenState extends State<XRayScreen> {
  String? selectedCategoryId;
  final Set<String> selectedServiceIds = {};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await XRayData.loadCategories(forceRefresh: forceRefresh);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  XrayCategoryModel? get _selectedCategory {
    if (selectedCategoryId == null) return null;
    return XRayData.categoryById(selectedCategoryId!);
  }

  List<XrayServiceModel> get _currentServices {
    if (selectedCategoryId == null) return const <XrayServiceModel>[];
    return XRayData.servicesForCategory(selectedCategoryId!);
  }

  Future<void> _continue() async {
    if (selectedCategoryId == null) {
      Get.snackbar(
        'Select category',
        'Please choose an X-Ray category first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedServiceIds.isEmpty) {
      Get.snackbar(
        'Select service',
        'Please choose at least one service.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final selectedList = selectedServiceIds.toList();
    final totalPrice = XRayData.services
        .where((service) => selectedList.contains(service.id))
        .fold(0.0, (sum, service) => sum + service.price);

    await Get.to(
      () => const ImagingBookingPage(title: 'X-Ray Imaging'),
      arguments: {"selectedServiceIds": selectedList, "totalPrice": totalPrice},
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isNarrow = size.width < 360;

    final headerTitle = selectedCategoryId == null
        ? 'X-Ray'
        : (_selectedCategory?.titleForLanguage(
                Get.locale?.languageCode ?? 'en',
              ) ??
              'X-Ray');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          const XRayBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(isNarrow, headerTitle),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isLoading
                        ? const Center(
                            key: ValueKey('loading'),
                            child: CircularProgressIndicator(),
                          )
                        : _errorMessage != null
                        ? _buildErrorState()
                        : (selectedCategoryId == null
                              ? _buildCategories()
                              : _buildServices()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: XRayBottomActionBar(
        selectedCount: selectedServiceIds.length,
        onContinue: _continue,
      ),
    );
  }

  Widget _buildHeader(bool isNarrow, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (selectedCategoryId != null) {
                setState(() {
                  selectedCategoryId = null;
                });
              } else {
                Navigator.pop(context);
              }
            },
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isNarrow ? 23 : 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: AppFonts.dancingScript,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  selectedCategoryId == null
                      ? 'Choose imaging areas'
                      : 'Select services',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: .75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    if (XRayData.categories.isEmpty) {
      return _buildEmptyState(
        title: AppLocalizations.of(context)!.noXrayCategoriesFound,
        subtitle: AppLocalizations.of(context)!.pleaseCheckTheFirestoreDocument,
        icon: Icons.medical_information_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: XRayData.categories.length,
        itemBuilder: (context, index) {
          final cat = XRayData.categories[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: XRayCard(
              category: cat,
              selected: selectedCategoryId == cat.id,
              onTap: () {
                setState(() {
                  selectedCategoryId = cat.id;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildServices() {
    final services = _currentServices;

    if (services.isEmpty) {
      return _buildEmptyState(
        title: AppLocalizations.of(context)!.noServicesFound,
        subtitle: AppLocalizations.of(context)!.thisCategoryDoesNotHave,
        icon: Icons.article_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          final selected = selectedServiceIds.contains(service.id);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (selected) {
                  selectedServiceIds.remove(service.id);
                } else {
                  selectedServiceIds.add(service.id);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: .08)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.border,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      service.nameEn,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.failedToLoadXrayData,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            CommonButton(
              onPressed: () => _loadData(forceRefresh: true),
              text: 'Try again',
              type: CommonButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: AppColors.primary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
