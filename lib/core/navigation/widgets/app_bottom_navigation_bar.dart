import 'dart:ui';
import 'package:o2_clinic/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/navigation_controller.dart';
import 'navigation_book_button.dart';
import 'navigation_tab_item.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.find<NavigationController>();

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 76,
                    maxHeight: 80,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).scaffoldBackgroundColor
                        : AppColors.white.withValues(alpha: 0.90),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.white12
                          : AppColors.white.withValues(alpha: 0.50),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Obx(() {
                      final int index = controller.currentIndex.value;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: NavigationTabItem(
                              icon: Icons.home_rounded,
                              label: AppLocalizations.of(context)!.home,
                              isActive: index == 0,
                              onTap: () => controller.changeTab(0),
                            ),
                          ),
                          Expanded(
                            child: NavigationTabItem(
                              imagePath: 'assets/icons/img.png',
                              label: AppLocalizations.of(context)!.doctors,
                              isActive: index == 1,
                              onTap: () => controller.changeTab(1),
                            ),
                          ),
                          Expanded(
                            child: _BookTabLabel(
                              isActive: index == 2,
                              onTap: () => controller.changeTab(2),
                            ),
                          ),
                          Expanded(
                            child: NavigationTabItem(
                              icon: Icons.support_agent,
                              label: AppLocalizations.of(context)!.contactUs,
                              isActive: index == 3,
                              onTap: () => controller.changeTab(3),
                            ),
                          ),
                          Expanded(
                            child: NavigationTabItem(
                              icon: Icons.person_rounded,
                              label: AppLocalizations.of(context)!.profile,
                              isActive: index == 4,
                              onTap: () => controller.changeTab(4),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -20,
              left: 0,
              right: 0,
              child: Center(
                child: Obx(() {
                  final bool isActive = controller.currentIndex.value == 2;

                  return NavigationBookButton(
                    isActive: isActive,
                    onTap: () => controller.changeTab(2),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookTabLabel extends StatelessWidget {
  const _BookTabLabel({required this.isActive, required this.onTap});

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? AppColors.primary : AppColors.grey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: GoogleFonts.poppins(
                fontSize: isActive ? 11 : 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 1.2,
                color: color,
                height: 1.0,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppLocalizations.of(context)!.book.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
