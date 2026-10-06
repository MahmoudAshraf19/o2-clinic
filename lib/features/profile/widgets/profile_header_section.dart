import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../auth/controllers/register_controller.dart';
import '../controllers/dashboard_profile_controller.dart';
import '../models/dashboard_profile_model.dart';

class ProfileHeaderSection extends StatelessWidget {
  final DashboardProfileModel user;
  final bool isDesktop;

  const ProfileHeaderSection({
    super.key,
    required this.user,
    required this.isDesktop,
  });

  static const String _fallbackAsset = 'assets/icons/user.png';

  Future<void> _openEditProfile() async {
    if (user.uid.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'User ID is missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    debugPrint('[PROFILE] Opening edit profile screen for uid=${user.uid}');

    if (Get.isRegistered<RegisterController>()) {
      Get.delete<RegisterController>();
    }

    final result = await Get.toNamed(
      AppRoutes.register,
      arguments: {
        'mode': 'edit',
        'uid': user.uid,
        'profile': {
          'uid': user.uid,
          'id': user.uid,
          'username': user.username,
          'name': user.name,
          'email': user.email,
          'gender': user.gender,
          'bio': user.bio,
          'image': user.image,
          'phone': {
            'country_code': user.phoneCountryCode,
            'number': user.phoneNumber,
            'full_phone': user.phoneFullNumber,
          },
          'lastVisit': {
            'type': user.lastVisitType ?? '',
            'date': user.lastVisitDate ?? '',
          },
          'status': user.status,
          'isBlocked': user.isBlocked,
          'address': user.address,
          'provider': user.provider,
        },
      },
    );

    if (result == true) {
      debugPrint('[PROFILE] Edit completed, refreshing profile...');
      if (Get.isRegistered<DashboardProfileController>()) {
        await Get.find<DashboardProfileController>().refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double size = isDesktop ? 150 : 120;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Theme.of(context).brightness == Brightness.dark ? [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).scaffoldBackgroundColor] : [const Color(0xffEAF8F6), Colors.white],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  width: 3,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: ClipOval(
                  child: _ProfileAvatar(
                    imageUrl: user.image,
                    fallbackAsset: _fallbackAsset,
                  ),
                ),
              ),
            ),
            if (user.uid.isNotEmpty)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(color: Theme.of(context).cardColor, width: 2),
                  ),
                  child: Icon(
                    Icons.verified,
                    size: 14,
                    color: Theme.of(context).cardColor,
                  ),
                ),
              ),
            if (user.uid.isNotEmpty)
              Positioned(
                bottom: -5,
                right: -5,
                child: Material(
                  color: Theme.of(context).cardColor,
                  shape: const CircleBorder(),
                  elevation: 2,
                  shadowColor: Colors.black26,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _openEditProfile,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: isDesktop ? 34 : 26,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary,
                  height: 1.05,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.id,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: user.id,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final String fallbackAsset;

  const _ProfileAvatar({required this.imageUrl, required this.fallbackAsset});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();

    if (url.isEmpty) {
      return _fallback(context);
    }

    return Container(
      color: Theme.of(context).cardColor,
      child: CachedImageWidget(
        imageUrl: url,
        key: ValueKey(url),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(context),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _fallback(context);
        },
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      alignment: Alignment.center,
      child: Image.asset(
        fallbackAsset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, size: 42, color: AppColors.primary);
        },
      ),
    );
  }
}





