import 'package:o2_clinic/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import '../../../../common/widgets/common_avatar.dart';
import '../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/booking_helper.dart';
import '../../../chat_doctors/presentation/screens/patient_chat_screen.dart'; // NEW
import '../../../../features/doctors/data/models/doctor_model.dart';
import '../../data/models/doctor_model.dart' as ui_model; // NEW
import '../../../services/data/services/fs_specialized_cache.dart';

class DoctorProfilePage extends StatefulWidget {
  final DoctorModel doctor;
  final String? localizedSpecialty;

  const DoctorProfilePage({
    super.key,
    required this.doctor,
    this.localizedSpecialty,
  });

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  bool _aboutExpanded = false;
  String? _resolvedSpecialty;

  @override
  void initState() {
    super.initState();
    if (widget.localizedSpecialty == null) {
      _fetchSpecialty();
    } else {
      _resolvedSpecialty = widget.localizedSpecialty;
    }
  }

  Future<void> _fetchSpecialty() async {
    final specializedList = await SpecializedCache.getData();
    if (!mounted) return;

    final locale = Localizations.localeOf(context).languageCode;
    final String targetId = widget.doctor.specialty.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );

    for (final item in specializedList) {
      final itemId = item.id.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (itemId == targetId) {
        String localized = item.nameEn;
        if (locale == 'ar' && item.nameAr.isNotEmpty) localized = item.nameAr;
        if (locale == 'he' && item.nameHe.isNotEmpty) localized = item.nameHe;
        if (mounted) {
          setState(() {
            _resolvedSpecialty = localized;
          });
        }
        return;
      }
    }
  }

  String _getLocalizedDay(BuildContext context, String dayKey) {
    final key = dayKey.trim().toLowerCase();
    switch (key) {
      case 'monday':
        return AppLocalizations.of(context)!.monday;
      case 'tuesday':
        return AppLocalizations.of(context)!.tuesday;
      case 'wednesday':
        return AppLocalizations.of(context)!.wednesday;
      case 'thursday':
        return AppLocalizations.of(context)!.thursday;
      case 'friday':
        return AppLocalizations.of(context)!.friday;
      case 'saturday':
        return AppLocalizations.of(context)!.saturday;
      case 'sunday':
        return AppLocalizations.of(context)!.sunday;
      default:
        return dayKey;
    }
  }

  String _getDoctorName(BuildContext context) {
    final doctor = widget.doctor;
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'ar' && doctor.nameAr.isNotEmpty) return doctor.nameAr;
    if (lang == 'he' && doctor.nameHe.isNotEmpty) return doctor.nameHe;
    return doctor.nameEn;
  }

  String _getDoctorTitle(BuildContext context) {
    final doctor = widget.doctor;
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'ar' && doctor.titleAr.isNotEmpty) return doctor.titleAr;
    if (lang == 'he' && doctor.titleHe.isNotEmpty) return doctor.titleHe;
    return doctor.titleEn;
  }

  String _getDoctorDescription(BuildContext context) {
    final doctor = widget.doctor;
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'ar' && doctor.descriptionAr.isNotEmpty) {
      return doctor.descriptionAr;
    }
    if (lang == 'he' && doctor.descriptionHe.isNotEmpty) {
      return doctor.descriptionHe;
    }
    return doctor.descriptionEn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: (Theme.of(context).brightness == Brightness.dark
                ? AppColors.colorFF60A5FA
                : AppColors.primary),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.doctorProfile,
          style: TextStyle(
            color: (Theme.of(context).brightness == Brightness.dark
                ? AppColors.colorFF60A5FA
                : AppColors.primary),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 32),
              _buildAboutSection(),
              const SizedBox(height: 24),
              const Divider(color: AppColors.colorFFE8F0EC, thickness: 1.5),
              const SizedBox(height: 24),
              _buildAvailabilitySection(),
              const SizedBox(height: 32),
              _buildBottomBar(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== HEADER (Centered Avatar) =====================

  Widget _buildProfileHeader() {
    final doctor = widget.doctor;

    return Column(
      children: [
        // Avatar with halo and verified tick
        Stack(
          alignment: Alignment.center,
          children: [
            // Halo
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
            // Avatar
            CommonAvatar(
              size: 110,
              imageUrl: doctor.image,
              assetPath: 'assets/images/common/Doctor_avatar.jpg',
            ),
            // Verified Tick
            if (doctor.isTopRateEnable)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.colorFF60A5FA
                        : AppColors.primary),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: AppColors.white, size: 16),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Doctor Name
        Text(
          _getDoctorName(context),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: (Theme.of(context).brightness == Brightness.dark
                ? AppColors.colorFF60A5FA
                : AppColors.primary),
          ),
        ),
        const SizedBox(height: 6),

        // Specialty
        Text(
          _getDoctorTitle(context).isNotEmpty
              ? _getDoctorTitle(context)
              : (_resolvedSpecialty ?? widget.doctor.specialty),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: (Theme.of(context).brightness == Brightness.dark
                ? AppColors.white70
                : AppColors.textSecondary.withValues(alpha: 0.8)),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Experience
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              color: (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.colorFF60A5FA
                  : AppColors.primary),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              '${doctor.yearsExperience} ${AppLocalizations.of(context)!.yearsExp}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.colorFF60A5FA
                    : AppColors.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===================== ABOUT =====================

  Widget _buildAboutSection() {
    final about = _getDoctorDescription(context).trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                color: (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.colorFF60A5FA
                    : AppColors.primary),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.about,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.colorFF60A5FA
                    : AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: AnimatedCrossFade(
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
        ),
        if (about.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: CommonButton(
              onPressed: () => setState(() => _aboutExpanded = !_aboutExpanded),
              text: _aboutExpanded
                  ? AppLocalizations.of(context)!.showLess
                  : AppLocalizations.of(context)!.readMore,
              type: CommonButtonType.text,
              padding: const EdgeInsets.only(top: 4, left: 4, right: 0),
              foregroundColor:
                  (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.colorFF60A5FA
                  : AppColors.primary),
              textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              width: 0,
              height: 0,
            ),
          ),
      ],
    );
  }

  // ===================== AVAILABILITY =====================

  Widget _buildAvailabilitySection() {
    final doctor = widget.doctor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                color: (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.colorFF60A5FA
                    : AppColors.primary),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.availableDays,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.colorFF60A5FA
                    : AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (doctor.availabilityDay.isEmpty)
          Text(
            AppLocalizations.of(context)!.noAvailabilityProvided,
            style: _bodyStyle(),
          )
        else
          Column(
            children: doctor.availabilityDay.entries.map((e) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.04,
                  ), // Very light tint
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.colorFF60A5FA
                          : AppColors.primary),
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getLocalizedDay(context, e.key),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color:
                                  (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.colorFF60A5FA
                                  : AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            e.value.toString(),
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.white60
                                  : AppColors.textSecondary.withValues(
                                      alpha: 0.7,
                                    )),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.white54
                          : AppColors.textSecondary.withValues(alpha: 0.5)),
                      size: 16,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ===================== BUTTONS (Two Buttons) =====================

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary Button: Book Appointment
          SizedBox(
            width: double.infinity,
            height: 54,
            child: CommonButton(
              onPressed: () {
                BookingHelper.onBookNowClicked(context, widget.doctor);
              },
              icon: Icons.calendar_today_outlined,
              iconSize: 18,
              text: AppLocalizations.of(context)!.bookAppointment,
              textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              type: CommonButtonType.primary,
              backgroundColor:
                  (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.colorFF60A5FA
                  : AppColors.primary),
              foregroundColor: AppColors.white,
              borderRadius: BorderRadius.circular(999), // Fully rounded
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          // Secondary Button: Message Doctor
          SizedBox(
            width: double.infinity,
            height: 54,
            child: CommonButton(
              onPressed: () {
                final uiDoctor = ui_model.DoctorModel(
                  id: widget.doctor.id,
                  name: _getDoctorName(context),
                  title: _getDoctorTitle(context),
                  image: widget.doctor.image,
                  rating: 5.0,
                  reviews: 0,
                  availability: 'Available',
                  booked: 0,
                  total: widget.doctor.maxBooking,
                );
                Get.to(() => PatientChatScreen(doctor: uiDoctor));
              },
              icon: Icons.chat_bubble_outline,
              iconSize: 18,
              text: AppLocalizations.of(context)!.chatMessage,
              textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              type: CommonButtonType.outline,
              foregroundColor:
                  (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.colorFF60A5FA
                  : AppColors.primary),
              borderRadius: BorderRadius.circular(999), // Fully rounded
            ),
          ),
        ],
      ),
    );
  }

  // ===================== STYLES =====================

  TextStyle _bodyStyle() => TextStyle(
    fontSize: 14,
    height: 1.6,
    color: (Theme.of(context).brightness == Brightness.dark
        ? AppColors.white70
        : AppColors.textSecondary.withValues(alpha: 0.9)),
    fontWeight: FontWeight.w500,
  );
}
