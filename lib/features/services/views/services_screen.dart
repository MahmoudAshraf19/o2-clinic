import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/services_controller.dart';
import '../widgets/cosmetic_cards.dart';
import '../widgets/radiology_cards.dart';
import '../widgets/service_card.dart' as service_widget;
import '../widgets/service_tab.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GetBuilder<ServicesController>(
      init: ServicesController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                /// HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Services",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                /// TABS
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.tabs.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return ServiceTab(
                        title: controller.tabs[index],
                        isSelected: controller.selectedTab.value == index,
                        onTap: () => controller.changeTab(index),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                /// CONTENT
                Expanded(
                  child: Obx(() {
                    /// Radiology
                    if (controller.selectedTab.value == 1) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: RadiologyCards(),
                      );
                    }

                    /// Cosmetic
                    if (controller.selectedTab.value == 2) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const CosmeticCards(),
                      );
                    }

                    /// Loading
                    if (controller.isLoading.value &&
                        controller.services.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    /// Empty
                    if (controller.services.isEmpty) {
                      return const Center(child: Text("No services found"));
                    }

                    /// Services List
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.services.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return service_widget.ServiceCard(
                          department: controller.services[index],
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

