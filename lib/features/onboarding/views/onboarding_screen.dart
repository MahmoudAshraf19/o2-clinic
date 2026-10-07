import 'package:flutter/material.dart';
import '../../../common/widgets/common_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingData {
  final String titlePart1;
  final String? titlePart2;
  final String description;
  final String imagePath;

  const OnboardingData({
    required this.titlePart1,
    this.titlePart2,
    required this.description,
    required this.imagePath,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  List<OnboardingData> get _pages {
    final l10n = AppLocalizations.of(context)!;
    return [
      OnboardingData(
        titlePart1: l10n.onboarding1Title,
        titlePart2: null,
        description: l10n.onboarding1Desc,
        imagePath: 'assets/images/onboarding/onboarding1.png',
      ),
      OnboardingData(
        titlePart1: l10n.onboarding2TitlePart1,
        titlePart2: l10n.onboarding2TitlePart2,
        description: l10n.onboarding2Desc,
        imagePath: 'assets/images/onboarding/onboarding2.png',
      ),
      OnboardingData(
        titlePart1: l10n.onboarding3TitlePart1,
        titlePart2: l10n.onboarding3TitlePart2,
        description: l10n.onboarding3Desc,
        imagePath: 'assets/images/onboarding/onboarding3.png',
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Get.find<OnboardingController>().finishOnboarding();
    }
  }

  void _skip() {
    Get.find<OnboardingController>().finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _pages;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top bar (Only Skip on the right/end)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    l10n.skip,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandBlue.withAlpha(160),
                    ),
                  ),
                ),
              ),
            ),

            // Dynamic Sliding Area (Image + Text)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final data = pages[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Center(
                            child: Image.asset(
                              data.imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      // Text content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            RichText(
                              textAlign: TextAlign.start,
                              text: TextSpan(
                                style: GoogleFonts.cairo(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                                children: [
                                  TextSpan(
                                    text: data.titlePart1,
                                    style: const TextStyle(
                                      color: AppColors.brandBlue,
                                    ),
                                  ),
                                  if (data.titlePart2 != null)
                                    TextSpan(
                                      text: data.titlePart2,
                                      style: const TextStyle(
                                        color: AppColors.vibrantCyan,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              data.description,
                              textAlign: TextAlign.start,
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppColors.brandBlue.withAlpha(160),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Fixed Bottom Area (Dots + Button)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (index) {
                      final isActive = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.vibrantCyan
                              : AppColors.vibrantCyan.withAlpha(80),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // Next Button
                  CommonButton(
                    text: _currentIndex == pages.length - 1
                        ? l10n.getStarted
                        : l10n.next,
                    onPressed: _nextPage,
                    icon: Icons.arrow_forward,
                    iconPosition: IconPosition.right,
                    type: CommonButtonType.primary,
                    backgroundColor: AppColors.brandBlue,
                    borderRadius: BorderRadius.circular(28),
                    width: double.infinity,
                    height: 56,
                    textStyle: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
