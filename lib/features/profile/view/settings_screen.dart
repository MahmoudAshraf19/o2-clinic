import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/core/localization/locale_controller.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'change_language_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../chat_support/screens/support_chat_screen.dart';
import 'html_content_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool appointmentsEnabled = true;
  bool labAnalysisEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: AppColors.transparent,
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            _TopIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Get.back(),
            ),
            const SizedBox(width: 16),
            Text(
              AppLocalizations.of(context)?.settings ?? 'Settings',
              style: TextStyle(
                fontFamily: AppFonts.dancingScript,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            _AvatarBubble(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)?.manageYourClinicPreferences ??
                  'Manage your clinic preferences.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w400,
                color:
                    Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
                    AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            Obx(() {
              final localeController = Get.find<LocaleController>();
              final code = localeController.currentLanguageCode;
              String displayLang = 'English';
              if (code == 'ar') displayLang = 'العربية';
              if (code == 'he') displayLang = 'עברית';

              return Row(
                children: [
                  Expanded(
                    child: _QuickOptionCard(
                      icon: Icons.language_rounded,
                      title: AppLocalizations.of(context)!.language,
                      value: displayLang,
                      onTap: () => Get.to(() => const ChangeLanguageScreen()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickOptionCard(
                      icon: Icons.dark_mode_rounded,
                      title: AppLocalizations.of(context)?.theme ?? 'Theme',
                      value:
                          AppLocalizations.of(context)?.lightTheme ?? 'Light',
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Theme.of(context).cardColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (context) =>
                              const _ThemeSelectionBottomSheet(),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 16),

            _AssistanceBanner(
              onTap: () {
                Get.to(() => const SupportChatScreen());
              },
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: Text(
                AppLocalizations.of(context)?.notifications ?? 'Notifications',
                style: TextStyle(
                  fontFamily: AppFonts.dancingScript,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 12),

            _ToggleTile(
              icon: Icons.event_available_rounded,
              title:
                  AppLocalizations.of(context)?.appointments ?? 'Appointments',
              subtitle:
                  AppLocalizations.of(context)?.alertsForBookings ??
                  'Alerts for bookings',
              value: appointmentsEnabled,
              onChanged: (v) => setState(() => appointmentsEnabled = v),
            ),

            const SizedBox(height: 10),

            _ToggleTile(
              icon: Icons.science_rounded,
              title:
                  AppLocalizations.of(context)?.labAnalysis ?? 'Lab Analysis',
              subtitle:
                  AppLocalizations.of(context)?.resultNotifications ??
                  'Result notifications',
              value: labAnalysisEnabled,
              onChanged: (v) => setState(() => labAnalysisEnabled = v),
            ),

            const SizedBox(height: 16),

            const SizedBox(height: 16),

            _PrimaryActionButton(
              title:
                  AppLocalizations.of(context)?.privacyPolicy ??
                  'Privacy Policy',
              icon: Icons.privacy_tip_rounded,
              onTap: () {
                Get.to(
                  () => HtmlContentScreen(
                    title:
                        AppLocalizations.of(context)?.privacyPolicy ??
                        'Privacy Policy',
                    collection: 'app_constants',
                    docId: 'privacyPolicy',
                    fieldName: 'privacyPolicy',
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _PrimaryActionButton(
              title:
                  AppLocalizations.of(context)?.termsAndConditions ??
                  'Terms and Conditions',
              icon: Icons.gavel_rounded,
              onTap: () {
                Get.to(
                  () => HtmlContentScreen(
                    title:
                        AppLocalizations.of(context)?.termsAndConditions ??
                        'Terms and Conditions',
                    collection: 'app_constants',
                    docId: 'termsAndConditions',
                    fieldName: 'termsAndConditions',
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            Center(
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('app_constants')
                    .doc('version')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  String version = '1.0';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data != null && data['app_version'] != null) {
                      version = data['app_version'].toString();
                    }
                  }

                  return Text(
                    'Version $version',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color:
                          Theme.of(context).textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.7) ??
                          AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.white12
                  : AppColors.borderSoft,
            ),
          ),
          child: Icon(icon, size: 22, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _AvatarBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.white12
              : AppColors.borderSoft,
        ),
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 22,
        color: AppColors.primary,
      ),
    );
  }
}

class _AssistanceBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _AssistanceBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.needAssistance ??
                          'Need assistance?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)?.text247DigitalConcierge ??
                          '24/7 Digital Concierge',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.white.withValues(alpha: 0.25),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.white12
              : AppColors.borderSoft,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color:
                        Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
                        AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _SoftSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SoftSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SoftSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 50,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primary
              : (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.white24
                    : AppColors.toggleTrack),
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.white70
                  : AppColors.toggleThumb,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.white),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _QuickOptionCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.white12
                  : AppColors.borderSoft,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7) ??
                            AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                            AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeSelectionBottomSheet extends StatelessWidget {
  const _ThemeSelectionBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)?.theme ?? 'Theme',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.light_mode, color: AppColors.vibrantCyan),
            title: Text(
              AppLocalizations.of(context)?.lightTheme ?? 'Light',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.check, color: AppColors.brandBlue),
            onTap: () {
              Get.changeThemeMode(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          const Divider(height: 1, color: AppColors.borderSoft),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: AppColors.muted),
            title: Text('Dark', style: TextStyle(fontWeight: FontWeight.w500)),
            onTap: () {
              Get.changeThemeMode(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
