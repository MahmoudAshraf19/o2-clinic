import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'dart:io' as io;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/country_picker_sheet.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  static const primary = Color(0xFF00685F);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: primary,
              ),
            ),
          ),
        ),
        title: Text(
          controller.isEditMode ? 'Edit Account' : 'Create Account',
          style: const TextStyle(
            color: Colors.black,
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
                  AppLocalizations.of(context)!.editing,
                  style: TextStyle(
                    color: Colors.grey.shade600,
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
                  horizontal: 20,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 480 : double.infinity,
                  ),
                  child: Column(
                    children: [
                      _header(),
                      const SizedBox(height: 14),

                      Obx(() {
                        final msg = controller.successMessage.value.trim();
                        if (msg.isEmpty) return const SizedBox.shrink();

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF8F6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: primary.withOpacity(0.16)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                color: primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                AppLocalizations.of(context)!.updatedSuccessfully,
                                style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  msg,
                                  style: const TextStyle(
                                    color: Color(0xFF355E59),
                                    fontWeight: FontWeight.w600,
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
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.18),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  msg,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      _formCard(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Obx(() {
            if (!controller.isLoading.value) return const SizedBox.shrink();

            return Container(
              color: Colors.black.withOpacity(0.12),
              child: const Center(child: CircularProgressIndicator()),
            );
          }),
        ],
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          controller.isEditMode ? 'Edit Your Account' : 'Create Your Account',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          controller.isEditMode
              ? 'Update your profile details safely.'
              : 'Join us and start your journey 👋',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _formCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              _avatar(),
              const SizedBox(height: 18),
              if (controller.isEditMode) ...[
                _editLockNote(context),
                const SizedBox(height: 12),
              ],
              _lockedField(
                label: AppLocalizations.of(context)!.idUsername,
                controller: controller.username,
                icon: Icons.badge_outlined,
              ),
              _field(controller.name, 'Full Name', 'assets/icons/user.png'),
              Obx(() => _lockedField(
                label: AppLocalizations.of(context)!.email,
                controller: controller.email,
                icon: Icons.mail_outline_rounded,
                isLocked: controller.isEditMode,
                errorText: controller.emailError.value.isEmpty ? null : controller.emailError.value,
              )),
              const SizedBox(height: 10),
              _phone(context),
              const SizedBox(height: 10),
              if (!controller.isEditMode && !controller.isSocial) ...[
                _password(),
                _confirmPasswordWithCheck(),
                const SizedBox(height: 10),
              ],
              _gender(),
              const SizedBox(height: 10),
              _field(controller.bio, 'Bio', 'assets/icons/user.png', max: 3),
              const SizedBox(height: 18),
              _button(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editLockNote(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_rounded, color: primary, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.idUsernameAndEmailAre,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF355E59),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    return Obx(() {
      final value = controller.imagePath.value.trim();

      return GestureDetector(
        onTap: controller.pickImage,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: _avatarContent(value),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/icons/pencil.png',
                  width: 14,
                  height: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _avatarContent(String value) {
    if (value.isEmpty) {
      return _avatarFallback();
    }

    if (!kIsWeb &&
        (value.startsWith('/') || RegExp(r'^[a-zA-Z]:\\').hasMatch(value))) {
      return Image.file(
        io.File(value),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _avatarFallback(),
      );
    }

    if (value.startsWith('http') || value.startsWith('blob:')) {
      return CachedImageWidget(imageUrl: 
        value,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('[IMAGE ERROR] Failed to load network image: $error');
          return _avatarFallback();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    }

    return _avatarFallback();
  }

  Widget _avatarFallback() {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/icons/user.png',
        width: 34,
        height: 34,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Icon(Icons.person, size: 34, color: primary);
        },
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String hint,
    String icon, {
    int max = 1,
    bool obscure = false,
    Widget? suffix,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        maxLines: max,
        obscureText: obscure,
        readOnly: readOnly,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(icon, width: 20),
          ),
          suffixIcon: suffix,
          hintText: hint,
          filled: true,
          fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _lockedField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isLocked = true,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        readOnly: isLocked,
        enabled: !isLocked,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: primary),
          ),
          hintText: label,
          errorText: errorText,
          filled: true,
          fillColor: isLocked ? Colors.grey.shade100 : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
    );
  }

  Widget _password() {
    return Obx(() {
      return _field(
        controller.password,
        'Password',
        'assets/icons/padlock.png',
        obscure: !controller.showPassword.value,
        suffix: GestureDetector(
          onTap: () => controller.showPassword.toggle(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              controller.showPassword.value
                  ? 'assets/icons/eye.png'
                  : 'assets/icons/hidden.png',
              width: 22,
            ),
          ),
        ),
      );
    });
  }

  Widget _confirmPasswordWithCheck() {
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
            controller.confirmPassword,
            'Confirm Password',
            'assets/icons/confirm_password.png',
            obscure: !controller.showConfirm.value,
            suffix: GestureDetector(
              onTap: () => controller.showConfirm.toggle(),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  controller.showConfirm.value
                      ? 'assets/icons/eye.png'
                      : 'assets/icons/hidden.png',
                  width: 22,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (showMessage)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Row(
                children: [
                  Icon(
                    match ? Icons.check_circle : Icons.error,
                    size: 16,
                    color: match
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    match
                        ? 'Passwords match perfectly 🎉'
                        : 'Passwords do not match',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: match
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _phone(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Text(
                    controller.selectedCountry.value.flag,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 6),
                  Text(controller.selectedCountry.value.dialCode),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _field(
              controller.phone,
              'Phone',
              'assets/icons/phone-call.png',
            ),
          ),
        ],
      );
    });
  }

  Widget _gender() {
    return Obx(() {
      return Row(
        children: [
          _genderBtn('Male', 'assets/icons/male-gender.png'),
          const SizedBox(width: 10),
          _genderBtn('Female', 'assets/icons/femenine.png'),
        ],
      );
    });
  }

  Widget _genderBtn(String value, String icon) {
    final selected = controller.gender.value == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.gender.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? primary : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                icon,
                width: 18,
                color: selected ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button() {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: controller.isLoading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  controller.isEditMode ? 'Save Changes' : 'Create Account →',
                ),
        ),
      );
    });
  }


}
