import 'package:o2_clinic/l10n/app_localizations.dart';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/controllers/social_auth_controller.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});

  bool get _isWeb => kIsWeb;
  bool get _isAndroid => !_isWeb && Platform.isAndroid;
  bool get _isIOS => !_isWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(SocialAuthController(), permanent: true);

    final showGoogle = _isWeb || _isAndroid || _isIOS;
    final showApple = _isWeb || _isIOS;

    return Obx(() {
      final loading = c.isLoading.value;

      return Column(
        children: [
          Row(
            children: [
              Expanded(child: Container(height: 1, color: AppColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  AppLocalizations.of(context)!.orContinueWith,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.grey,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              Expanded(child: Container(height: 1, color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showGoogle)
                showApple
                    ? Expanded(
                        child: _SocialButton(
                          onTap: loading
                              ? null
                              : () => c.loginWithGoogle(isWeb: _isWeb),
                          imagePath: 'assets/icons/google.png',
                          label: loading ? "Please wait..." : 'Google',
                        ),
                      )
                    : _SocialButton(
                        onTap: loading
                            ? null
                            : () => c.loginWithGoogle(isWeb: _isWeb),
                        imagePath: 'assets/icons/google.png',
                        label: loading ? "Please wait..." : 'Google',
                      ),
              if (showGoogle && showApple) const SizedBox(width: 14),
              if (showApple)
                showGoogle
                    ? Expanded(
                        child: _SocialButton(
                          onTap: loading ? null : c.loginWithApple,
                          imagePath: 'assets/icons/apple-logo.png',
                          label: loading ? "Please wait..." : 'Apple',
                        ),
                      )
                    : _SocialButton(
                        onTap: loading ? null : c.loginWithApple,
                        imagePath: 'assets/icons/apple-logo.png',
                        label: loading ? "Please wait..." : 'Apple',
                      ),
            ],
          ),
        ],
      );
    });
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onTap,
    required this.imagePath,
    required this.label,
  });

  final VoidCallback? onTap;
  final String imagePath;
  final String label;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: disabled ? 0.6 : 1,
          child: Container(
            width: 150,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(imagePath, width: 20, height: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

