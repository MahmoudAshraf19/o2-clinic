import 'package:flutter/material.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../common/models/fs_doctor_model.dart';
import '../../data/models/fs_specialized_service_model.dart';
import '../../../doctors/data/services/doctors_cache_service.dart';
import '../../data/services/fs_specialized_cache.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';

class DepartmentDoctorScreen extends StatefulWidget {
  final SpecializedServiceModel department;

  const DepartmentDoctorScreen({super.key, required this.department});

  @override
  State<DepartmentDoctorScreen> createState() => _DepartmentDoctorScreenState();
}

class _DepartmentDoctorScreenState extends State<DepartmentDoctorScreen> {
  int expandedIndex = -1;

  List<SpecializedServiceModel> allDepartments = [];
  List<DoctorModel> allDoctors = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final departmentsFuture = SpecializedCache.getData();

      final doctorsFuture = DoctorsCacheService.getDoctors();

      final results = await Future.wait([departmentsFuture, doctorsFuture]);

      setState(() {
        allDepartments = results[0] as List<SpecializedServiceModel>;

        allDoctors = results[1] as List<DoctorModel>;

        expandedIndex = allDepartments.indexWhere(
          (d) => d.id == widget.department.id,
        );

        if (expandedIndex == -1 && allDepartments.isNotEmpty) {
          expandedIndex = 0;
        }

        isLoading = false;
      });
    } catch (e) {
      debugPrint("💥 DepartmentDoctorScreen ERROR: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  List<DoctorModel> _getDoctors(String specialty) {
    final normalized = specialty.trim().toLowerCase();

    return allDoctors.where((doctor) {
      return doctor.specialty.trim().toLowerCase() == normalized;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "O2 Clinics",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CommonLoadingIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProgress(),

                const SizedBox(height: 20),

                _buildTitle(),

                const SizedBox(height: 16),

                ...allDepartments.asMap().entries.map((entry) {
                  final index = entry.key;

                  final department = entry.value;

                  return _buildDepartment(index: index, department: department);
                }),
              ],
            ),
    );
  }

  Widget _buildProgress() {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: 0.6,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Our Specialties",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,

            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Select a department to explore our medical services.",
          style: TextStyle(fontSize: 14, color: AppColors.grey),
        ),
      ],
    );
  }

  Widget _buildDepartment({
    required int index,
    required SpecializedServiceModel department,
  }) {
    final isOpen = expandedIndex == index;

    final doctors = _getDoctors(department.nameEn);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
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
            onTap: () {
              setState(() {
                expandedIndex = isOpen ? -1 : index;
              });
            },

            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedImageWidget(
                imageUrl: department.image,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
              ),
            ),

            title: Text(
              department.getLocalizedName(
                Localizations.localeOf(context).languageCode,
              ),
              style: TextStyle(
                fontWeight: FontWeight.w700,

                color: isOpen ? AppColors.primary : AppColors.textPrimary,
              ),
            ),

            subtitle: Text(
              department.getLocalizedSubtitle(
                Localizations.localeOf(context).languageCode,
              ),
              style: const TextStyle(fontSize: 12),
            ),

            trailing: Icon(
              isOpen ? Icons.expand_less : Icons.expand_more,
              color: AppColors.primary,
            ),
          ),

          if (isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  Text(
                    department.getLocalizedDescription(
                      Localizations.localeOf(context).languageCode,
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.grey,
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (doctors.isEmpty)
                    const Text(
                      "No doctors available in this specialty",
                      style: TextStyle(color: AppColors.grey),
                    )
                  else
                    Column(
                      children: doctors
                          .map(
                            (doctor) =>
                                _doctorCard(context, doctor, department),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _doctorCard(
    BuildContext context,
    DoctorModel doctor,
    SpecializedServiceModel department,
  ) {
    final lang = Localizations.localeOf(context).languageCode;
    String doctorName = doctor.nameEn;
    if (lang == 'ar' && doctor.nameAr.isNotEmpty) doctorName = doctor.nameAr;
    if (lang == 'he' && doctor.nameHe.isNotEmpty) doctorName = doctor.nameHe;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipOval(
            child: CachedImageWidget(
              imageUrl: doctor.image,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),

                Text(
                  department.getLocalizedName(
                    Localizations.localeOf(context).languageCode,
                  ),
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
