import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/models/radiology_category_model.dart';
import '../../services/models/radiologist_model.dart';
import 'radiologist_profile_screen.dart';
import '../presentation/pages/radiology_booking_page.dart';

class RadiologyProfileScreen extends StatefulWidget {
  final RadiologyCategoryModel service;

  const RadiologyProfileScreen({super.key, required this.service});

  @override
  State<RadiologyProfileScreen> createState() => _RadiologyProfileScreenState();
}

class _RadiologyProfileScreenState extends State<RadiologyProfileScreen> {
  bool _aboutExpanded = false;
  RadiologistModel? _radiologist;
  bool _isLoadingDoctor = true;

  @override
  void initState() {
    super.initState();
    _fetchRadiologist();
  }

  Future<void> _fetchRadiologist() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Radiologist')
          .doc('Radiologist')
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _radiologist = RadiologistModel.fromMap(doc.id, doc.data()!);
          _isLoadingDoctor = false;
        });
      } else {
        setState(() => _isLoadingDoctor = false);
      }
    } catch (e) {
      setState(() => _isLoadingDoctor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
                child: Column(
                  children: [
                    _buildProfileHeaderCard(),
                    const SizedBox(height: 14),
                    _buildDoctorCard(),
                    const SizedBox(height: 14),
                    _buildAboutCard(),
                    const SizedBox(height: 14),
                    _buildAvailabilityCard(),
                    const SizedBox(height: 88),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ===================== TOP BAR (Dynamic, Modern) =====================

  Widget _buildTopBar(BuildContext context) {
    final service = widget.service;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.getName(Get.locale?.languageCode ?? 'en'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontFamily: AppFonts.dancingScript,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  AppLocalizations.of(context)!.radiologyDepartment,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildTopRightBadge(),
        ],
      ),
    );
  }

  Widget _buildTopRightBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context)!.available,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== HEADER CARD =====================

  Widget _buildProfileHeaderCard() {
    final service = widget.service;

    return Container(
      decoration: _cardDecoration(),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'service_${service.id}',
                  child: Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: DecorationImage(
                        image: service.image.isNotEmpty
                            ? CachedNetworkImageProvider(service.image)
                            : const AssetImage(
                                    'assets/images/common/placeholder.jpg',
                                  )
                                  as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.radiology,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        service.getName(Get.locale?.languageCode ?? 'en'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.advancedDiagnosticImaging,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
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
      ),
    );
  }

  // ===================== DOCTOR CARD =====================

  Widget _buildDoctorCard() {
    if (_isLoadingDoctor) {
      return Container(
        height: 80,
        decoration: _cardDecoration(),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_radiologist == null || !_radiologist!.isActive) {
      return const SizedBox.shrink();
    }

    final doctor = _radiologist!;
    final langCode = Get.locale?.languageCode ?? 'en';
    final name = doctor.getName(langCode);
    final title = doctor.getTitle(langCode);

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
                width: 1.5,
              ),
              image: DecorationImage(
                image: doctor.image.isNotEmpty
                    ? CachedNetworkImageProvider(doctor.image)
                    : const AssetImage('assets/images/common/Doctor_avatar.jpg')
                          as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,

                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,

                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          CommonButton(
            onPressed: () {
              Get.to(() => RadiologistProfileScreen(radiologist: doctor));
            },
            text: langCode == 'ar' ? "التفاصيل" : "View Profile",
            type: CommonButtonType.text,
            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            borderRadius: BorderRadius.circular(8),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== ABOUT =====================

  Widget _buildAboutCard() {
    final service = widget.service;
    final langCode = Get.locale?.languageCode ?? 'en';
    final about = service.getDesc(langCode).trim();

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.info_rounded,
            title: AppLocalizations.of(context)!.aboutThisService,
          ),
          const SizedBox(height: 10),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _aboutExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              about.isEmpty
                  ? AppLocalizations.of(context)!.noDescriptionAvailable
                  : about,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: _bodyStyle(),
            ),
            secondChild: Text(
              about.isEmpty
                  ? AppLocalizations.of(context)!.noDescriptionAvailable
                  : about,
              style: _bodyStyle(),
            ),
          ),

          if (about.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: CommonButton(
                onPressed: () =>
                    setState(() => _aboutExpanded = !_aboutExpanded),
                text: _aboutExpanded
                    ? AppLocalizations.of(context)!.showLess
                    : AppLocalizations.of(context)!.readMore,
                type: CommonButtonType.text,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.only(top: 8, left: 0, right: 0),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===================== AVAILABILITY =====================

  String _translateDay(String day, String langCode) {
    day = day.toLowerCase().trim();
    if (langCode == 'ar') {
      switch (day) {
        case 'monday':
          return 'الإثنين';
        case 'tuesday':
          return 'الثلاثاء';
        case 'wednesday':
          return 'الأربعاء';
        case 'thursday':
          return 'الخميس';
        case 'friday':
          return 'الجمعة';
        case 'saturday':
          return 'السبت';
        case 'sunday':
          return 'الأحد';
      }
    } else if (langCode == 'he') {
      switch (day) {
        case 'monday':
          return 'שני';
        case 'tuesday':
          return 'שלישי';
        case 'wednesday':
          return 'רביעי';
        case 'thursday':
          return 'חמישי';
        case 'friday':
          return 'שישי';
        case 'saturday':
          return 'שבת';
        case 'sunday':
          return 'ראשון';
      }
    }
    return day;
  }

  String _formatTimeRange(String range, BuildContext context) {
    try {
      final parts = range.split('-');
      if (parts.length != 2) return range;

      String formatTime(String time24) {
        final tParts = time24.split(':');
        int h = int.parse(tParts[0]);
        int m = int.parse(tParts[1]);
        String amPm = "AM";
        if (h >= 12) {
          amPm = "PM";
          if (h > 12) h -= 12;
        }
        if (h == 0) h = 12;
        String localizedAmPm = amPm == "AM"
            ? AppLocalizations.of(context)!.am
            : AppLocalizations.of(context)!.pm;
        return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $localizedAmPm";
      }

      return "${formatTime(parts[0].trim())} - ${formatTime(parts[1].trim())}";
    } catch (e) {
      return range;
    }
  }

  Widget _buildAvailabilityCard() {
    final service = widget.service;

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.schedule_rounded,
            title: AppLocalizations.of(context)!.availableDays,
          ),
          const SizedBox(height: 12),

          if (service.availabilityDay.isEmpty)
            Text(
              AppLocalizations.of(context)!.noAvailabilityProvided,
              style: _bodyStyle(),
            )
          else
            Column(
              children: service.availabilityDay.entries.map((e) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _translateDay(
                            e.key,
                            Get.locale?.languageCode ?? 'en',
                          ).toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimeRange(e.value.toString(), context),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ===================== BOTTOM BAR =====================

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        height: 52,
        child: CommonButton(
          onPressed: () {
            Get.to(
              () => RadiologyBookingPage(service: widget.service),
              transition: Transition.rightToLeftWithFade,
              duration: const Duration(milliseconds: 300),
            );
          },
          text: AppLocalizations.of(context)!.bookAppointment,
          type: CommonButtonType.primary,
          icon: Icons.calendar_month_rounded,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          elevation: 0,
          textStyle: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  // ===================== STYLES =====================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.05),
          blurRadius: 26,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  TextStyle _bodyStyle() => TextStyle(
    fontSize: 13,
    height: 1.8,
    color: AppColors.textSecondary.withValues(alpha: 0.88),
    fontWeight: FontWeight.w600,
  );
}
