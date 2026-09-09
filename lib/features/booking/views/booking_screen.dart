import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../chat_support/widgets/support_chat_widgets.dart';
import '../controllers/booking_controller.dart';
import '../widgets/service_card.dart';

class BookingScreen extends StatelessWidget {
  BookingScreen({super.key, this.onBack, this.showBackButton = false});

  final VoidCallback? onBack;
  final bool showBackButton;

  final BookingController controller = Get.put(BookingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildServicesView(context),
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 14, 2, 10),
      child: Row(
        children: [
          if (showBackButton) ...[
            GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).pop(),
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
                  AppLocalizations.of(context)!.services,
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
                  AppLocalizations.of(context)!.chooseTheMedicalServiceYou,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.75),
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

  Widget _buildServicesView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopSection(context),
        const SizedBox(height: 8),
        Expanded(
          child: Builder(builder: (context) {
            final isAuth = FirebaseAuth.instance.currentUser != null;
            if (!isAuth) {
              return const Center(
                child: SingleChildScrollView(
                  child: SupportAuthPrompt(),
                ),
              );
            }

            return Obx(() {
              if (controller.isLoading.value && controller.services.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.services.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.loadServices,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 140),
                      Icon(
                        Icons.medical_services_outlined,
                        size: 64,
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          AppLocalizations.of(context)!.noServicesFound,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadServices,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(bottom: 20, top: 6),
                  itemCount: controller.services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) {
                    return SizedBox(
                      height: 200,
                      child: ServiceCard(
                        model: controller.services[i],
                        onTap: () => controller.selectService(i),
                      ),
                    );
                  },
                ),
              );
            });
          }),
        ),
      ],
    );
  }
}

