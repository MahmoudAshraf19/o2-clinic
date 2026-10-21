import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/common/controllers/app_constants_controller.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import '../../data/models/medical_device_model.dart';
import '../controllers/medical_device_controller.dart';
import '../widgets/medical_device_detail_sheet.dart';

class MedicalDevicesScreen extends StatelessWidget {
  const MedicalDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MedicalDeviceController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final currentLang = Get.locale?.languageCode ?? 'ar';
    final currency = Get.isRegistered<AppConstantsController>()
        ? Get.find<AppConstantsController>().currencySymbol.value
        : 'EGP';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.medicalDevices,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.white : AppColors.colorFF081F1D,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.medicalDevicesSubtitle,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.white70 : AppColors.grey600,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.white : AppColors.colorFF081F1D,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CommonLoadingIndicator());
        }

        if (controller.devices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 64,
                  color: isDark ? AppColors.white38 : AppColors.grey400,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noMedicalDevicesFound,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.white70 : AppColors.grey600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchDevices(forceRefresh: true),
          color: AppColors.primary,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            itemCount: controller.devices.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final device = controller.devices[index];
              return _MedicalDeviceCard(
                device: device,
                currentLang: currentLang,
                currency: currency,
                isDark: isDark,
                l10n: l10n,
                onTap: () => MedicalDeviceDetailSheet.show(context, device),
              );
            },
          ),
        );
      }),
    );
  }
}

class _MedicalDeviceCard extends StatelessWidget {
  final MedicalDeviceModel device;
  final String currentLang;
  final String currency;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _MedicalDeviceCard({
    required this.device,
    required this.currentLang,
    required this.currency,
    required this.isDark,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final description = device.getLocalizedDescription(currentLang);
    final hasDiscount = device.atDiscount &&
        device.discountedPrice.isNotEmpty &&
        device.discountedPrice != device.price;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.colorFF1A2625 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.08)
              : AppColors.border.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.colorFF0F766E.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Device Image with rounded container
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: isDark
                        ? AppColors.colorFF2A3A39
                        : AppColors.colorFFF8FAFA,
                    child: CachedImageWidget(
                      imageUrl: device.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.medical_services_outlined,
                        size: 34,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Device Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              device.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.colorFF081F1D,
                              ),
                            ),
                          ),
                          if (hasDiscount)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.specialDiscount,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.white70 : AppColors.grey600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Price Tag
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (hasDiscount) ...[
                            Text(
                              '${device.discountedPrice} $currency',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '${device.price} $currency',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.lineThrough,
                                color: isDark
                                    ? AppColors.white38
                                    : AppColors.grey500,
                              ),
                            ),
                          ] else ...[
                            Text(
                              '${device.price} $currency',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
