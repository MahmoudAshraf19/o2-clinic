import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/booking_helper.dart';
import '../../all_doctors/presentation/pages/doctor_profile_page.dart';
import '../../services/controllers/cosmetic_controller.dart';
import '../../services/controllers/radiology_controller.dart';
import '../../services/controllers/services_controller.dart';
import '../../services/models/cosmetic_model.dart';
import '../../services/models/department_model.dart';
import '../../services/models/radiology_category_model.dart';
import '../../services_firestore/models/doctor_model.dart';
import '../../services_firestore/models/specialized_service_model.dart';
import '../../services_firestore/services/doctors_cache_service.dart';
import '../../services_firestore/services/specialized_cache.dart';

import '../views/ct_scan_screen.dart';

class DepartmentDoctorScreen extends StatefulWidget {
  final DepartmentModel department;
  final String serviceType;

  const DepartmentDoctorScreen({
    super.key,
    required this.department,
    required this.serviceType,
  });

  @override
  State<DepartmentDoctorScreen> createState() => _DepartmentDoctorScreenState();
}

class _DepartmentDoctorScreenState extends State<DepartmentDoctorScreen> {
  int expandedIndex = -1;

  late ServicesController servicesController;
  late RadiologyController radiologyController;
  late CosmeticController cosmeticController;

  List<DoctorModel> allDoctors = [];
  bool doctorsLoading = true;

  List<SpecializedServiceModel> specializedServices = [];
  bool specializedLoading = true;

  @override
  void initState() {
    super.initState();

    servicesController = Get.put(ServicesController());
    radiologyController = Get.put(RadiologyController());
    cosmeticController = Get.put(CosmeticController());

    _loadDoctors();
    _loadSpecialized();
  }

  Future<void> _loadSpecialized() async {
    try {
      final data = await SpecializedCache.getData();

      final filtered = data.where((e) => e.isEnabled).toList();
      filtered.sort((a, b) => a.order.compareTo(b.order));

      if (mounted) {
        setState(() {
          specializedServices = filtered;
          specializedLoading = false;
        });
      }
    } catch (e) {
      debugPrint("💥 LOAD SPECIALIZED ERROR: $e");
      if (mounted) {
        setState(() => specializedLoading = false);
      }
    }
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await DoctorsCacheService.getDoctors();

      // ✅ ترتيب اختياري: Top Rated الأول
      doctors.sort((a, b) {
        final av = a.isTopRateEnable ? 1 : 0;
        final bv = b.isTopRateEnable ? 1 : 0;
        return bv.compareTo(av);
      });

      setState(() {
        allDoctors = doctors;
        doctorsLoading = false;
      });

      debugPrint("✅ Doctors Loaded: ${allDoctors.length}");
    } catch (e) {
      debugPrint("💥 LOAD DOCTORS ERROR: $e");
      setState(() => doctorsLoading = false);
    }
  }

  String _key(String v) => v.trim().toLowerCase();

  /// ✅ فلترة صح 100% باستخدام service.id
  List<DoctorModel> _getDoctorsForSpecializedService({
    required SpecializedServiceModel service,
  }) {
    final serviceKey = _key(
      service.id.isNotEmpty ? service.id : service.nameEn,
    );

    final result = allDoctors.where((doctor) {
      final doctorKey = _key(doctor.specialty);
      return doctorKey == serviceKey;
    }).toList();

    debugPrint("🩺 MATCH '${service.id}' => ${result.length} doctors");
    return result;
  }

  // ===========================================================================
  // ✅ AUTH GUARD (Book Button)
  // ===========================================================================

  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;

  Future<void> _ensureLoggedInThen(VoidCallback onAuthed) async {
    if (_isLoggedIn) {
      onAuthed();
      return;
    }

    await Get.dialog(barrierDismissible: true, _loginRequiredDialog());
  }

  Widget _loginRequiredDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.10),
              ),
              child: Icon(
                Icons.lock_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.loginRequired,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.youMustLogInFirst,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.85),
                height: 1.35,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                      side: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.9),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.notNow,
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // close dialog
                      Get.toNamed(AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.login,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // UI
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopSection(),
            Expanded(child: _buildServiceContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    final title = _getTitleForServiceType();
    final subtitle = _getSubtitleForServiceType();

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
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: AppFonts.dancingScript,
                    height: 1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTitleForServiceType() {
    switch (widget.serviceType) {
      case 'radiology':
        return AppLocalizations.of(context)!.radiologyServices;
      case 'cosmetic':
        return AppLocalizations.of(context)!.cosmeticTreatments;
      case 'specialized':
      default:
        return AppLocalizations.of(context)!.specializedClinics;
    }
  }

  String _getSubtitleForServiceType() {
    switch (widget.serviceType) {
      case 'radiology':
        return AppLocalizations.of(context)!.chooseImagingService;
      case 'cosmetic':
        return AppLocalizations.of(context)!.exploreCosmeticTreatments;
      case 'specialized':
      default:
        return AppLocalizations.of(context)!.chooseSpecialtyToSeeDoctors;
    }
  }

  Widget _buildServiceContent() {
    switch (widget.serviceType) {
      case 'radiology':
        return _buildRadiologyContent();
      case 'cosmetic':
        return _buildCosmeticContent();
      case 'specialized':
      default:
        return _buildSpecializedContent();
    }
  }

  // ================= Specialized =================

  Widget _buildSpecializedContent() {
    if (specializedLoading || doctorsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (specializedServices.isEmpty) {
      return const Center(child: Text("No specialized services found"));
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      itemCount: specializedServices.length,
      itemBuilder: (context, index) {
        final specializedService = specializedServices[index];

        return _buildSpecializedTile(index: index, service: specializedService);
      },
    );
  }

  Widget _buildSpecializedTile({
    required int index,
    required SpecializedServiceModel service,
  }) {
    final isOpen = expandedIndex == index;
    final doctors = _getDoctorsForSpecializedService(service: service);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOpen
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => expandedIndex = isOpen ? -1 : index),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: ClipOval(
                child: CachedImageWidget(
                  imageUrl: service.image,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, ___) {
                    return Image.asset(
                      'assets/images/common/Doctor_avatar.jpg',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            title: Text(
              service.getLocalizedName(Get.locale?.languageCode ?? 'en'),
              style: TextStyle(
                fontWeight: FontWeight.w700,

                color: isOpen ? AppColors.primary : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: Text(
              service.getLocalizedSubtitle(Get.locale?.languageCode ?? 'en'),
              style: TextStyle(fontSize: 12),
            ),
            trailing: Icon(
              isOpen ? Icons.expand_less : Icons.expand_more,
              color: AppColors.primary,
            ),
          ),
          if (isOpen && doctors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: doctors.map(_doctorCard).toList()),
            ),
          if (isOpen && doctors.isEmpty)
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                AppLocalizations.of(context)!.noDoctorsAvailableForThis,
                style: TextStyle(fontSize: 12, color: AppColors.grey),
              ),
            ),
        ],
      ),
    );
  }

  // ================= Radiology =================

  Widget _buildRadiologyContent() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      itemCount: radiologyController.services.length,
      itemBuilder: (context, index) {
        final service = radiologyController.services[index];
        return _buildRadiologyService(index: index, service: service);
      },
    );
  }

  Widget _buildRadiologyService({
    required int index,
    required RadiologyCategoryModel service,
  }) {
    final isOpen = expandedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOpen
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => expandedIndex = isOpen ? -1 : index),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: ClipOval(
                child: CachedImageWidget(
                  imageUrl: service.image,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, ___) {
                    return Image.asset(
                      'assets/images/common/Doctor_avatar.jpg',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            title: Text(service.getName('en')),
            subtitle: Text(
              "Available ${service.availabilityDay.length} days a week",
            ),
            trailing: Icon(
              isOpen ? Icons.expand_less : Icons.expand_more,
              color: AppColors.primary,
            ),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.getDesc('en')),
                  SizedBox(height: 12),
                  if (service.id == "ct_scan")
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => CTScanScreen()),
                        child: Text("Book CT Scan"),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ================= Cosmetic =================

  Widget _buildCosmeticContent() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      itemCount: cosmeticController.cosmetics.length,
      itemBuilder: (context, index) {
        final cosmetic = cosmeticController.cosmetics[index];
        return _buildCosmeticService(index: index, cosmetic: cosmetic);
      },
    );
  }

  Widget _buildCosmeticService({
    required int index,
    required CosmeticModel cosmetic,
  }) {
    final isOpen = expandedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: () => setState(() => expandedIndex = isOpen ? -1 : index),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: ClipOval(
            child: CachedImageWidget(
              imageUrl: cosmetic.image,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, _, ___) {
                return Image.asset(
                  'assets/images/common/Doctor_avatar.jpg',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
        title: Text(cosmetic.title),
        subtitle: Text("${cosmetic.items.length} treatments available"),
        trailing: Icon(
          isOpen ? Icons.expand_less : Icons.expand_more,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ================= Doctor Card =================

  Widget _doctorCard(DoctorModel doctor) {
    final lang = Get.locale?.languageCode ?? 'en';
    String doctorName = doctor.nameEn;
    if (lang == 'ar' && doctor.nameAr.isNotEmpty) doctorName = doctor.nameAr;
    if (lang == 'he' && doctor.nameHe.isNotEmpty) doctorName = doctor.nameHe;

    String doctorTitle = doctor.titleEn;
    if (lang == 'ar' && doctor.titleAr.isNotEmpty) doctorTitle = doctor.titleAr;
    if (lang == 'he' && doctor.titleHe.isNotEmpty) doctorTitle = doctor.titleHe;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipOval(
                child: CachedImageWidget(
                  imageUrl: doctor.image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, ___) {
                    return Image.asset(
                      'assets/images/common/Doctor_avatar.jpg',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2),
                    Text(
                      doctorTitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Get.to(() => DoctorProfilePage(doctor: doctor)),
                  child: Text(AppLocalizations.of(context)!.viewProfile),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await _ensureLoggedInThen(() {
                      BookingHelper.onBookNowClicked(context, doctor);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(AppLocalizations.of(context)!.book.toUpperCase()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}




