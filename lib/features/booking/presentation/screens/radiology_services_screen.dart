import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../services/data/models/radiology_category_model.dart';
import '../controllers/radiology_services_controller.dart';
import 'radiology_profile_screen.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';

class RadiologyServicesScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const RadiologyServicesScreen({super.key, this.onBack});

  @override
  State<RadiologyServicesScreen> createState() =>
      _RadiologyServicesScreenState();
}

class _RadiologyServicesScreenState extends State<RadiologyServicesScreen>
    with AutomaticKeepAliveClientMixin {
  final RadiologyServicesController c = Get.put(
    RadiologyServicesController(),
    permanent: true,
  );

  int expandedIndex = -1;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopSection(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.radiologyServices,
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
                  AppLocalizations.of(context)!.chooseImagingService,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.75),
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

  Widget _buildContent() {
    return Obx(() {
      if (c.loading) {
        return const Center(child: CommonLoadingIndicator());
      }

      if (c.error.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.somethingWentWrong,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  c.error,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                CommonButton(
                  onPressed: () => c.load(forceRefresh: true),
                  text: AppLocalizations.of(context)!.retry,
                  type: CommonButtonType.primary,
                ),
              ],
            ),
          ),
        );
      }

      final services = c.services;
      if (services.isEmpty) {
        return Center(
          child: Text(AppLocalizations.of(context)!.noServicesFound),
        );
      }

      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildRadiologyCard(index: index, service: service);
        },
      );
    });
  }

  Widget _buildRadiologyCard({
    required int index,
    required RadiologyCategoryModel service,
  }) {
    final bool isExpanded = expandedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Get.to(
                () => RadiologyProfileScreen(service: service),
                transition: Transition.rightToLeftWithFade,
                duration: const Duration(milliseconds: 300),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _ServiceImage(
                    urlOrAsset: service.image,
                    isHighlighted: isExpanded,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.getName(Get.locale?.languageCode ?? 'en'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.availableDaysCount(
                            service.availabilityDay.length.toString(),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // The bottom cross-fade and button section is deleted as we are navigating now.
}

// ✅ Image Widget - يشتغل مع assets أو network وبـ fallback (مفيش crash)
class _ServiceImage extends StatelessWidget {
  final String urlOrAsset;
  final bool isHighlighted;

  const _ServiceImage({required this.urlOrAsset, required this.isHighlighted});

  bool get _isNetwork => urlOrAsset.trim().startsWith("http");

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (isHighlighted)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            )
          else
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
        border: Border.all(
          color: isHighlighted
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.transparent,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: _isNetwork
          ? CachedImageWidget(
              imageUrl: urlOrAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const _ImageFallback(
                icon: Icons.image_not_supported_outlined,
              ),
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const _ImageFallback(icon: Icons.hourglass_bottom_rounded),
            )
          : Image.asset(
              urlOrAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const _ImageFallback(
                icon: Icons.image_not_supported_outlined,
              ),
            ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final IconData icon;

  const _ImageFallback({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: AppColors.primary.withValues(alpha: 0.65),
        size: 28,
      ),
    );
  }
}
