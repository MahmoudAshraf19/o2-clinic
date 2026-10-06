import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: 60,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? Colors.white : AppColors.brandBlue,
            size: 22,
          ),
        ),
        title: Text(
          controller.isEditMode ? l10n.editAccount : l10n.createAccount,
          style: GoogleFonts.cairo(
            color: isDarkMode ? Colors.white : AppColors.brandBlue,
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
                    color: isDarkMode ? Colors.white70 : AppColors.brandBlue.withValues(alpha: 0.6),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                            color: isDarkMode ? Colors.green.withValues(alpha: 0.1) : const Color(0xFFEAF8F6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDarkMode ? Colors.green.withValues(alpha: 0.3) : AppColors.vibrantCyan.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: isDarkMode ? Colors.greenAccent : AppColors.vibrantCyan,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  msg,
                                  style: GoogleFonts.cairo(
                                    color: isDarkMode ? Colors.white : AppColors.brandBlue,
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
                            color: Colors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  msg,
                                  style: GoogleFonts.cairo(
                                    color: isDarkMode ? Colors.red.shade300 : Colors.red.shade700,
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
              color: Colors.black.withValues(alpha: 0.3),
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
            color: isDarkMode ? Colors.white : AppColors.brandBlue,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          controller.isEditMode
              ? l10n.updateProfileSafely
              : l10n.joinUsJourney,
          style: GoogleFonts.cairo(
            color: isDarkMode ? Colors.white60 : AppColors.brandBlue.withValues(alpha: 0.6),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _formFields(BuildContext context, AppLocalizations l10n, bool isDarkMode) {
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
            errorText: controller.emailError.value.isEmpty ? null : controller.emailError.value,
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

  Widget _editLockNote(BuildContext context, AppLocalizations l10n, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.vibrantCyan.withValues(alpha: 0.1) : AppColors.softCyan.withValues(alpha: 0.15),
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
                color: isDarkMode ? Colors.white70 : AppColors.brandBlue.withValues(alpha: 0.8),
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
              backgroundColor: isDarkMode ? const Color(0xFF1A2625) : Colors.white,
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
                  border: Border.all(color: Theme.of(Get.context!).scaffoldBackgroundColor, width: 2),
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

    if (!kIsWeb && (value.startsWith('/') || RegExp(r'^[a-zA-Z]:\\').hasMatch(value))) {
      return Image.file(
        io.File(value),
        fit: BoxFit.cover,
        errorBuilder: (_, _, ___) => _avatarFallback(isDarkMode),
      );
    }

    if (value.startsWith('http') || value.startsWith('blob:')) {
      return CachedImageWidget(
        imageUrl: value,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _avatarFallback(isDarkMode),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.vibrantCyan));
        },
      );
    }

    return _avatarFallback(isDarkMode);
  }

  Widget _avatarFallback(bool isDarkMode) {
    return Container(
      color: isDarkMode ? const Color(0xFF1A2625) : Colors.grey.shade100,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/icons/user.png',
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
        errorBuilder: (_, _, ___) {
          return Icon(Icons.person, size: 40, color: isDarkMode ? Colors.white24 : Colors.grey.shade400);
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
    final borderColor = isDarkMode ? Colors.white24 : Colors.grey.shade300;
    final fillColor = isDarkMode ? const Color(0xFF1A2625) : Colors.white;
    final iconColor = isDarkMode ? Colors.white54 : AppColors.brandBlue.withValues(alpha: 0.5);

    return TextField(
      controller: controller,
      maxLines: max,
      obscureText: obscure,
      readOnly: readOnly,
      style: GoogleFonts.cairo(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: isDarkMode ? Colors.white : AppColors.brandBlue,
      ),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: Image.asset(
            iconPath,
            width: 20,
            height: 20,
            color: iconColor,
          ),
        ),
        suffixIcon: suffix,
        hintText: hint,
        hintStyle: GoogleFonts.cairo(
          color: isDarkMode ? Colors.white38 : AppColors.brandBlue.withValues(alpha: 0.4),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: readOnly ? (isDarkMode ? Colors.white10 : Colors.grey.shade50) : fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.vibrantCyan, width: 1.5),
        ),
      ),
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
    final borderColor = isDarkMode ? Colors.white24 : Colors.grey.shade300;
    final iconColor = isDarkMode ? Colors.white54 : AppColors.brandBlue.withValues(alpha: 0.5);

    return TextField(
      controller: controller,
      readOnly: isLocked,
      enabled: !isLocked,
      style: GoogleFonts.cairo(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: isDarkMode ? Colors.white : AppColors.brandBlue,
      ),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        hintText: label,
        hintStyle: GoogleFonts.cairo(
          color: isDarkMode ? Colors.white38 : AppColors.brandBlue.withValues(alpha: 0.4),
          fontWeight: FontWeight.w500,
        ),
        errorText: errorText,
        filled: true,
        fillColor: isLocked ? (isDarkMode ? Colors.white10 : Colors.grey.shade50) : (isDarkMode ? const Color(0xFF1A2625) : Colors.white),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: 1.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDarkMode ? Colors.white12 : Colors.grey.shade200, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.vibrantCyan, width: 1.5),
        ),
      ),
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
              controller.showPassword.value ? 'assets/icons/eye.png' : 'assets/icons/hidden.png',
              width: 22,
              height: 22,
              color: isDarkMode ? Colors.white54 : AppColors.brandBlue.withValues(alpha: 0.5),
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

      final showMessage = started && controller.password.text.isNotEmpty && controller.confirmPassword.text.isNotEmpty;

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
                  controller.showConfirm.value ? 'assets/icons/eye.png' : 'assets/icons/hidden.png',
                  width: 22,
                  height: 22,
                  color: isDarkMode ? Colors.white54 : AppColors.brandBlue.withValues(alpha: 0.5),
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
                    color: match ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    match ? l10n.passwordsMatch : l10n.passwordsNotMatch,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: match ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      );
    });
  }

  Widget _phone(BuildContext context, AppLocalizations l10n, bool isDarkMode) {
    final borderColor = isDarkMode ? Colors.white24 : Colors.grey.shade300;
    final fillColor = isDarkMode ? const Color(0xFF1A2625) : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.brandBlue;

    return Obx(() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top in case textfield shows error
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
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
                  Icon(Icons.keyboard_arrow_down_rounded, color: textColor.withValues(alpha: 0.7)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _field(
              controller: controller.phone,
              hint: l10n.phone,
              iconPath: 'assets/icons/phone-call.png', // Or use normal icon since you don't have this one requested
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
    final internalValue = value.contains('ذكر') || value.toLowerCase() == 'male' ? 'Male' : 'Female';
    final isSelected = controller.gender.value == internalValue;
    
    final borderColor = isDarkMode ? Colors.white24 : Colors.grey.shade300;
    final unselectedColor = isDarkMode ? const Color(0xFF1A2625) : Colors.white;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.gender.value = internalValue,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 58,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandBlue : unselectedColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppColors.brandBlue : borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                icon,
                width: 20,
                color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : AppColors.brandBlue),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: GoogleFonts.cairo(
                  color: isSelected ? Colors.white : (isDarkMode ? Colors.white : AppColors.brandBlue),
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
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.isEditMode ? l10n.saveChanges : l10n.createAccountBtn,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!controller.isEditMode) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ]
                  ],
                ),
        ),
      );
    });
  }
}
