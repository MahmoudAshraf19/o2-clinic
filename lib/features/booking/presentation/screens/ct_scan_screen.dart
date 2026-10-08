import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:o2_clinic/common/widgets/common_snackbar.dart';
import '../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../services/data/models/fs_radiology_ct_model.dart';
import '../controllers/ct_scan_controller.dart';
import '../widgets/ct_scan/ct_scan_card.dart';
import '../widgets/ct_scan/ct_scan_data.dart';
import 'imaging_booking_screen.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';
import 'package:o2_clinic/common/widgets/common_empty_state.dart';

class CTScanScreen extends StatelessWidget {
  CTScanScreen({super.key});

  final CtScanController c = Get.put(CtScanController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isNarrow = size.width < 360;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Obx(() {
        if (c.loading.value) {
          return const Center(child: CommonLoadingIndicator());
        }

        final items = c.ctItems;
        if (items.isEmpty) {
          return const CommonEmptyState(title: "No CT scan data found");
        }

        final core = items
            .where((e) => e.type.toLowerCase().contains('core'))
            .toList();

        final specialized = items
            .where((e) => !e.type.toLowerCase().contains('core'))
            .toList();

        List<ScanCardData> mapToCards(List<RadiologyCtModel> list) {
          return list.map((item) {
            final iconData =
                c.icons[item.id] ?? Icons.medical_services_outlined;

            return ScanCardData(
              id: item.id,
              title: item.title,
              description: item.description,
              icon: iconData,
              bigIcon: iconData, // ✅ لازم IconData
              price: item.price.toDouble(), // ✅ لازم double
            );
          }).toList();
        }

        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
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
                            AppLocalizations.of(context)!.ctScan,
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
                            AppLocalizations.of(context)!.chooseScanAreas,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withValues(
                                alpha: .75,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                              title: AppLocalizations.of(
                                context,
                              )!.coreDiagnostics,
                            ),
                            const SizedBox(height: 12),

                            Obx(() {
                              final cards = mapToCards(core);
                              return CTScanCardColumn(
                                cards: cards,
                                selectedIds: c.selectedIds.toSet(),
                                onTap: c.toggleSelection,
                              );
                            }),

                            const SizedBox(height: 22),

                            _SectionHeader(
                              title: AppLocalizations.of(
                                context,
                              )!.specializedImaging,
                            ),
                            const SizedBox(height: 12),

                            Obx(() {
                              final cards = mapToCards(specialized);
                              return CTScanCardColumn(
                                cards: cards,
                                selectedIds: c.selectedIds.toSet(),
                                onTap: c.toggleSelection,
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),

      bottomNavigationBar: Obx(() {
        return CTScanBottomBar(
          selectedCount: c.selectedIds.length,
          onContinue: () {
            if (c.selectedIds.isEmpty) {
              CommonSnackbar.showError(title: AppLocalizations.of(context)!.selectionRequired, message: "Please select at least one scan");
              return;
            }

            final selectedIds = c.selectedIds.toList();
            final totalPrice = c.ctItems
                .where((item) => selectedIds.contains(item.id))
                .fold(0.0, (sum, item) => sum + item.price);

            Get.to(
              () => ImagingBookingScreen(
                title: AppLocalizations.of(context)!.ctScan,
              ),
              arguments: {
                "selectedCtIds": selectedIds,
                "totalPrice": totalPrice,
              },
            );
          },
        );
      }),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class CTScanBottomBar extends StatelessWidget {
  const CTScanBottomBar({
    super.key,
    required this.selectedCount,
    required this.onContinue,
  });

  final int selectedCount;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: .92),
          border: Border(
            top: BorderSide(color: AppColors.border.withValues(alpha: .5)),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: .05),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.selected,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$selectedCount Scan${selectedCount == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CommonButton(
                onPressed: onContinue,
                text: AppLocalizations.of(context)!.continueAction,
                type: CommonButtonType.primary,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                height: 56,
                elevation: 0,
                icon: Icons.arrow_forward_rounded,
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
