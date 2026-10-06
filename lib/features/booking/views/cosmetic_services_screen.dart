import 'package:flutter/material.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../services/models/cosmetic_category_model.dart';
import '../controllers/cosmetic_services_controller.dart';
import 'cosmetic_booking_page.dart';

class CosmeticServicesScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const CosmeticServicesScreen({super.key, this.onBack});

  @override
  State<CosmeticServicesScreen> createState() => _CosmeticServicesScreenState();
}

class _CosmeticServicesScreenState extends State<CosmeticServicesScreen>
    with AutomaticKeepAliveClientMixin {
  final CosmeticServicesController c = Get.put(
    CosmeticServicesController(),
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
    final isAr = Get.locale?.languageCode == 'ar';
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
                  isAr ? "العلاجات التجميلية" : "Cosmetic Treatments",
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
                  isAr
                      ? "اختر الخدمة التجميلية المناسبة لك"
                      : "Choose your aesthetic service",
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
        return const Center(child: CircularProgressIndicator());
      }

      if (c.error.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Get.locale?.languageCode == 'ar'
                      ? "حدث خطأ ما"
                      : "Something went wrong",
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
                ElevatedButton(
                  onPressed: () => c.load(forceRefresh: true),
                  child: Text(
                    Get.locale?.languageCode == 'ar'
                        ? "إعادة المحاولة"
                        : "Try again",
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final services = c.services;
      if (services.isEmpty) {
        return Center(
          child: Text(
            Get.locale?.languageCode == 'ar'
                ? "لم يتم العثور على خدمات"
                : "No cosmetic services found",
          ),
        );
      }

      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildCosmeticCard(index: index, service: service);
        },
      );
    });
  }

  Widget _buildCosmeticCard({
    required int index,
    required CosmeticCategoryModel service,
  }) {
    final bool isExpanded = expandedIndex == index;
    final isAr = Get.locale?.languageCode == 'ar';
    final langCode = Get.locale?.languageCode ?? 'en';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isExpanded
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border.withValues(alpha: 0.6),
          width: isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.shadowLight.withValues(alpha: 0.04),
            blurRadius: isExpanded ? 20 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: () {
              setState(() => expandedIndex = isExpanded ? -1 : index);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _ServiceImage(
                    urlOrAsset: service.image,
                    isHighlighted: isExpanded,
                    fallbackIcon: service.getBadgeIcon(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isExpanded
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                          child: Text(service.getName(langCode)),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                service.getBadgeIcon(),
                                size: 15,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  isAr ? "تجميلية" : "Aesthetic",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: AppColors.border.withValues(alpha: 0.6),
                    height: 20,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    service.getDesc(langCode),
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textPrimary.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _PrimaryButton(
                    text: isAr ? 'احجز الآن' : 'Book Now',
                    onPressed: () =>
                        Get.to(() => CosmeticBookingPage(model: service)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceImage extends StatelessWidget {
  final String urlOrAsset;
  final bool isHighlighted;
  final IconData fallbackIcon;

  const _ServiceImage({
    required this.urlOrAsset,
    required this.isHighlighted,
    required this.fallbackIcon,
  });

  bool get _isNetwork => urlOrAsset.trim().startsWith("http");

  @override
  Widget build(BuildContext context) {
    if (urlOrAsset.isEmpty) {
      return Container(
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
        child: Icon(fallbackIcon, color: AppColors.primary, size: 32),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isHighlighted
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: _isNetwork
          ? CachedImageWidget(
              imageUrl: urlOrAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _ImageFallback(icon: fallbackIcon),
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const _ImageFallback(icon: Icons.hourglass_bottom_rounded),
            )
          : Image.asset(
              urlOrAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _ImageFallback(icon: fallbackIcon),
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

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month_rounded, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

