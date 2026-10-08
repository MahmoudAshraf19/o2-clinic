import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../patient_bookings/presentation/screens/patient_bookings_screen.dart' as o2;
import '../../../profile/presentation/controllers/dashboard_profile_controller.dart';
import '../../../profile/data/models/dashboard_profile_model.dart';
import '../../../profile/presentation/widgets/profile_detail_card.dart';
import '../../../profile/presentation/widgets/profile_header_section.dart';
import '../../../profile/presentation/widgets/profile_settings_card.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';

class DashboardProfileScreen extends StatelessWidget {
  const DashboardProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardProfileController controller =
        Get.find<DashboardProfileController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          final user = controller.currentUser;
          final size = MediaQuery.sizeOf(context);
          final isDesktop = size.width >= 900;

          return Column(
            children: [
              if (isDesktop) _buildDesktopTopBar(context, user),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 24 : 16,
                            vertical: isDesktop ? 48 : 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (controller.errorMessage.value.isNotEmpty)
                                _ErrorBanner(
                                  text: controller.errorMessage.value,
                                ),
                              if (controller.errorMessage.value.isNotEmpty)
                                const SizedBox(height: 16),
                              if (controller.isLoading.value &&
                                  user.uid.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 80),
                                  child: Center(
                                    child: CommonLoadingIndicator(),
                                  ),
                                )
                              else ...[
                                ProfileHeaderSection(
                                  user: user,
                                  isDesktop: isDesktop,
                                ),
                                const SizedBox(height: 32),
                                GridView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: isDesktop ? 2 : 1,
                                        crossAxisSpacing: isDesktop ? 24 : 16,
                                        mainAxisSpacing: isDesktop ? 24 : 16,
                                        mainAxisExtent: isDesktop ? 92 : 78,
                                      ),
                                  children: [
                                    ProfileDetailCard(
                                      icon: Icons.call_outlined,
                                      title: AppLocalizations.of(
                                        context,
                                      )!.phoneNumber,
                                      value: user.phone,
                                    ),
                                    ProfileDetailCard(
                                      icon: Icons.mail_outline,
                                      title: AppLocalizations.of(
                                        context,
                                      )!.email,
                                      value: user.email,
                                    ),
                                    ProfileDetailCard(
                                      icon: Icons.person_outline,
                                      title: AppLocalizations.of(
                                        context,
                                      )!.gender,
                                      value: user.gender,
                                    ),
                                    ProfileDetailCard(
                                      icon: Icons.event_outlined,
                                      title: AppLocalizations.of(
                                        context,
                                      )!.lastVisit,
                                      value: user.lastVisit,
                                      subtitle: user.lastVisitType,
                                    ),
                                  ],
                                ),
                                SizedBox(height: isDesktop ? 24 : 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: isDesktop ? 250 : 210,
                                  child: ProfileSettingsCard(
                                    onTap: controller.openSettings,
                                  ),
                                ),
                                SizedBox(height: isDesktop ? 48 : 32),
                                Align(
                                  alignment: isDesktop
                                      ? Alignment.centerLeft
                                      : Alignment.center,
                                  child: CommonButton(
                                      onPressed: controller.logout,
                                      type: CommonButtonType.primary,
                                      elevation: 0,
                                      backgroundColor:
                                          (controller.isGuest
                                                  ? AppColors.primary
                                                  : AppColors.error)
                                              .withValues(alpha: 0.08),
                                      foregroundColor: controller.isGuest
                                          ? AppColors.primary
                                          : AppColors.error,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 12,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      icon: controller.isGuest
                                          ? Icons.login
                                          : Icons.logout,
                                      text: controller.isGuest
                                          ? AppLocalizations.of(context)!.login
                                          : AppLocalizations.of(context)!.signOut,
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ),
                                SizedBox(height: isDesktop ? 8 : 18),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDesktopTopBar(BuildContext context, DashboardProfileModel user) {
    return Container(
      height: 80,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withValues(alpha: 0.80),
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.30),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorFF21897E.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.o2Vitality,
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryContainer,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              _navItem('Hub'),
              _navItem('Doctors'),
              _navItem('Bookings'),
              _navItem('Records'),
              const SizedBox(width: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  AppLocalizations.of(context)!.profile,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _TopAvatar(imageUrl: user.image),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          if (title == 'Bookings') {
            Get.to(() => const o2.PatientBookingsScreen());
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _TopAvatar extends StatelessWidget {
  final String imageUrl;

  const _TopAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surfaceLowest, width: 2),
        color: AppColors.white,
      ),
      child: ClipOval(
        child: url.isEmpty
            ? Container(
                color: AppColors.white,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 24,
                ),
              )
            : CachedImageWidget(
                imageUrl: url,
                key: ValueKey(url),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.white,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String text;

  const _ErrorBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
