import '../../../../common/widgets/common_text_field.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../common/widgets/common_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/country_picker_sheet.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: 60,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? AppColors.white : AppColors.brandBlue,
            size: 22,
          ),
        ),
        title: Text(
          controller.isEditMode ? l10n.editAccount : l10n.createAccount,
          style: GoogleFonts.cairo(
            color: isDarkMode ? AppColors.white : AppColors.brandBlue,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          if (controller.isEditMode)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  l10n.editing,
                  style: GoogleFonts.cairo(
                    color: isDarkMode
                        ? AppColors.white70
                        : AppColors.brandBlue.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 500 : double.infinity,
                  ),
                  child: Column(
                    children: [
                      _header(l10n, isDarkMode),
                      const SizedBox(height: 24),

                      Obx(() {
                        final msg = controller.successMessage.value.trim();
                        if (msg.isEmpty) return const SizedBox.shrink();

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.green.withValues(alpha: 0.1)
                                : AppColors.colorFFEAF8F6,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDarkMode
                                  ? AppColors.green.withValues(alpha: 0.3)
                                  : AppColors.vibrantCyan.withValues(
                                      alpha: 0.3,
                                    ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: isDarkMode
                                    ? AppColors.greenAccent
                                    : AppColors.vibrantCyan,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  msg,
                                  style: GoogleFonts.cairo(
                                    color: isDarkMode
                                        ? AppColors.white
                                        : AppColors.brandBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      Obx(() {
                        final msg = controller.errorMessage.value.trim();
                        if (msg.isEmpty) return const SizedBox.shrink();

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.red.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.red,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  msg,
                                  style: GoogleFonts.cairo(
                                    color: isDarkMode
                                        ? AppColors.red300
                                        : AppColors.red700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      _formFields(context, l10n, isDarkMode),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Obx(() {
            if (!controller.isLoading.value) return const SizedBox.shrink();

            return Container(
              color: AppColors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.vibrantCyan),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _header(AppLocalizations l10n, bool isDarkMode) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          controller.isEditMode ? l10n.editYourAccount : l10n.createYourAccount,
          style: GoogleFonts.cairo(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? AppColors.white : AppColors.brandBlue,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          controller.isEditMode ? l10n.updateProfileSafely : l10n.joinUsJourney,
          style: GoogleFonts.cairo(
            color: isDarkMode
                ? AppColors.white60
                : AppColors.brandBlue.withValues(alpha: 0.6),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _formFields(
    BuildContext context,
    AppLocalizations l10n,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: _avatar(isDarkMode)),
        const SizedBox(height: 32),

        if (controller.isEditMode) ...[
          _editLockNote(context, l10n, isDarkMode),
          const SizedBox(height: 16),
        ],

        // Username
        _lockedField(
          label: l10n.idUsername,
          controller: controller.username,
          icon: Icons.badge_outlined,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 12),

        // Full Name
        _field(
          controller: controller.name,
          hint: l10n.fullName,
          iconPath: 'assets/icons/user.png',
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 12),

        // Email
        Obx(
          () => _lockedField(
            label: l10n.email,
            controller: controller.email,
            icon: Icons.mail_outline_rounded,
            isLocked: controller.isEditMode,
            isDarkMode: isDarkMode,
            errorText: controller.emailError.value.isEmpty
                ? null
                : controller.emailError.value,
          ),
        ),
        const SizedBox(height: 12),

        // Phone
        _phone(context, l10n, isDarkMode),
        const SizedBox(height: 12),

        // Password & Confirm
        if (!controller.isEditMode && !controller.isSocial) ...[
          _password(l10n, isDarkMode),
          const SizedBox(height: 12),
          _confirmPasswordWithCheck(l10n, isDarkMode),
          const SizedBox(height: 12),
        ],

        // Gender
        _gender(l10n, isDarkMode),
        const SizedBox(height: 12),

        // Bio
        _field(
          controller: controller.bio,
          hint: l10n.bio,
          iconPath: 'assets/icons/user.png',
          max: 3,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 32),

        // Submit Button
        _button(l10n),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _editLockNote(
    BuildContext context,
    AppLocalizations l10n,
    bool isDarkMode,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.vibrantCyan.withValues(alpha: 0.1)
            : AppColors.softCyan.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.vibrantCyan.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_rounded, color: AppColors.vibrantCyan, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.idUsernameAndEmailAre,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? AppColors.white70
                    : AppColors.brandBlue.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(bool isDarkMode) {
    return Obx(() {
      final value = controller.imagePath.value.trim();

      return GestureDetector(
        onTap: controller.pickImage,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: isDarkMode
                  ? AppColors.colorFF1A2625
                  : AppColors.white,
              child: ClipOval(
                child: SizedBox(
                  width: 112,
                  height: 112,
                  child: _avatarContent(value, isDarkMode),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.vibrantCyan,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(Get.context!).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: Image.asset(
                  'assets/icons/pencil.png',
                  width: 14,
                  height: 14,
                  color: AppColors.brandBlue,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _avatarContent(String value, bool isDarkMode) {
    if (value.isEmpty) {
      return _avatarFallback(isDarkMode);
    }

    if (!kIsWeb &&
        (value.startsWith('/') || RegExp(r'^[a-zA-Z]:\\').hasMatch(value))) {
      return Image.file(
        io.File(value),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _avatarFallback(isDarkMode),
      );
    }

    if (value.startsWith('http') || value.startsWith('blob:')) {
      return CachedImageWidget(
        imageUrl: value,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _avatarFallback(isDarkMode),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.vibrantCyan,
            ),
          );
        },
      );
    }

    return _avatarFallback(isDarkMode);
  }

  Widget _avatarFallback(bool isDarkMode) {
    return Container(
      color: isDarkMode ? AppColors.colorFF1A2625 : AppColors.grey100,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/icons/user.png',
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        color: isDarkMode ? AppColors.white24 : AppColors.grey400,
        errorBuilder: (_, _, _) {
          return Icon(
            Icons.person,
            size: 40,
            color: isDarkMode ? AppColors.white24 : AppColors.grey400,
          );
        },
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required String iconPath,
    required bool isDarkMode,
    int max = 1,
    bool obscure = false,
    Widget? suffix,
    bool readOnly = false,
  }) {
    final iconColor = isDarkMode
        ? AppColors.white54
        : AppColors.brandBlue.withValues(alpha: 0.5);
    return CommonTextField(
      controller: controller,
      maxLines: max,
      obscureText: obscure,
      readOnly: readOnly,
      hint: hint,
      prefixWidget: Padding(
        padding: const EdgeInsets.all(14),
        child: Image.asset(iconPath, width: 20, height: 20, color: iconColor),
      ),
      suffixWidget: suffix,
    );
  }

  Widget _lockedField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDarkMode,
    bool isLocked = true,
    String? errorText,
  }) {
    final iconColor = isDarkMode
        ? AppColors.white54
        : AppColors.brandBlue.withValues(alpha: 0.5);
    return CommonTextField(
      controller: controller,
      readOnly: isLocked,
      enabled: !isLocked,
      hint: label,
      errorText: errorText,
      prefixIcon: icon,
    );
  }

  Widget _password(AppLocalizations l10n, bool isDarkMode) {
    return Obx(() {
      return _field(
        controller: controller.password,
        hint: l10n.password,
        iconPath: 'assets/icons/padlock.png',
        isDarkMode: isDarkMode,
        obscure: !controller.showPassword.value,
        suffix: GestureDetector(
          onTap: () => controller.showPassword.toggle(),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Image.asset(
              controller.showPassword.value
                  ? 'assets/icons/eye.png'
                  : 'assets/icons/hidden.png',
              width: 22,
              height: 22,
              color: isDarkMode
                  ? AppColors.white54
                  : AppColors.brandBlue.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    });
  }

  Widget _confirmPasswordWithCheck(AppLocalizations l10n, bool isDarkMode) {
    return Obx(() {
      final match = controller.passwordMatch.value;
      final started = controller.hasStartedTypingConfirm.value;

      final showMessage =
          started &&
          controller.password.text.isNotEmpty &&
          controller.confirmPassword.text.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field(
            controller: controller.confirmPassword,
            hint: l10n.confirmPassword,
            iconPath: 'assets/icons/padlock.png', // Or another appropriate icon
            isDarkMode: isDarkMode,
            obscure: !controller.showConfirm.value,
            suffix: GestureDetector(
              onTap: () => controller.showConfirm.toggle(),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Image.asset(
                  controller.showConfirm.value
                      ? 'assets/icons/eye.png'
                      : 'assets/icons/hidden.png',
                  width: 22,
                  height: 22,
                  color: isDarkMode
                      ? AppColors.white54
                      : AppColors.brandBlue.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          if (showMessage) ...[
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Icon(
                    match ? Icons.check_circle_rounded : Icons.error_rounded,
                    size: 16,
                    color: match ? AppColors.green : AppColors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    match ? l10n.passwordsMatch : l10n.passwordsNotMatch,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: match ? AppColors.green : AppColors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _phone(BuildContext context, AppLocalizations l10n, bool isDarkMode) {
    final borderColor = isDarkMode
        ? AppColors.white24
        : AppColors.grey300;
    final fillColor = isDarkMode ? AppColors.colorFF1A2625 : AppColors.white;
    final textColor = isDarkMode ? AppColors.white : AppColors.brandBlue;

    return Obx(() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment
            .start, // Align to top in case textfield shows error
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.transparent,
                builder: (_) {
                  return CountryPickerSheet(
                    onSelect: (country) {
                      controller.selectedCountry.value = country;
                      controller.countryCode.value = country.dialCode;
                    },
                  );
                },
              );
            },
            child: Container(
              height: 58, // Match textfield height
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Text(
                    controller.selectedCountry.value.flag,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.selectedCountry.value.dialCode,
                    style: GoogleFonts.cairo(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _field(
              controller: controller.phone,
              hint: l10n.phone,
              iconPath:
                  'assets/icons/phone-call.png', // Or use normal icon since you don't have this one requested
              isDarkMode: isDarkMode,
            ),
          ),
        ],
      );
    });
  }

  Widget _gender(AppLocalizations l10n, bool isDarkMode) {
    return Obx(() {
      return Row(
        children: [
          _genderBtn(l10n.male, 'assets/icons/male-gender.png', isDarkMode),
          const SizedBox(width: 12),
          _genderBtn(l10n.female, 'assets/icons/femenine.png', isDarkMode),
        ],
      );
    });
  }

  Widget _genderBtn(String value, String icon, bool isDarkMode) {
    // Note: controller.gender is comparing localized value now? Actually controller sets 'Male'/'Female'.
    // Better to check if value matches what controller sets. Controller expects English values internally or localized? Let's assume it checks english, wait, the old code used 'Male' and 'Female'.
    // Let's keep the internal value english but display localized.
    final internalValue = value.contains('ذكر') || value.toLowerCase() == 'male'
        ? 'Male'
        : 'Female';
    final isSelected = controller.gender.value == internalValue;

    final borderColor = isDarkMode
        ? AppColors.white24
        : AppColors.grey300;
    final unselectedColor = isDarkMode
        ? AppColors.colorFF1A2625
        : AppColors.white;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.gender.value = internalValue,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 58,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandBlue : unselectedColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.brandBlue : borderColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                icon,
                width: 20,
                color: isSelected
                    ? AppColors.white
                    : (isDarkMode ? AppColors.white70 : AppColors.brandBlue),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: GoogleFonts.cairo(
                  color: isSelected
                      ? AppColors.white
                      : (isDarkMode ? AppColors.white : AppColors.brandBlue),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(AppLocalizations l10n) {
    return Obx(() {
      return CommonButton(
        text: controller.isEditMode
            ? l10n.saveChanges
            : l10n.createAccountBtn,
        onPressed: controller.submitForm,
        isLoading: controller.isLoading.value,
        icon: controller.isEditMode ? null : Icons.arrow_forward,
        iconPosition: IconPosition.right,
        type: CommonButtonType.primary,
        backgroundColor: AppColors.brandBlue,
        borderRadius: BorderRadius.circular(28),
        width: double.infinity,
        height: 56,
        textStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      );
    });
  }
}
