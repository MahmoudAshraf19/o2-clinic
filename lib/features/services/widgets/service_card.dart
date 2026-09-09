import 'package:flutter/material.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../services_firestore/models/specialized_service_model.dart';
import '../models/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel department;

  const ServiceCard({super.key, required this.department});

  String _getLocalizedTitle(BuildContext context, ServiceModel dept) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'ar' && dept.titleAr.isNotEmpty) return dept.titleAr;
    if (lang == 'he' && dept.titleHe.isNotEmpty) return dept.titleHe;
    return dept.title;
  }

  String _getLocalizedSubtitle(BuildContext context, ServiceModel dept) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'ar' && dept.subtitleAr.isNotEmpty) return dept.subtitleAr;
    if (lang == 'he' && dept.subtitleHe.isNotEmpty) return dept.subtitleHe;
    return dept.subtitle;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to department doctors using the specialized model
        final specializedModel = SpecializedServiceModel(
          id: department.id,
          nameEn: department.title,
          nameAr: department.titleAr,
          nameHe: department.titleHe,
          subtitleEn: department.subtitle,
          subtitleAr: department.subtitleAr,
          subtitleHe: department.subtitleHe,
          descriptionEn: department.description,
          descriptionAr: department.descriptionAr,
          descriptionHe: department.descriptionHe,
          image: department.image,
        );
        Get.toNamed(AppRoutes.departmentDoctors, arguments: specializedModel);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedImageWidget(imageUrl: 
                department.image,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.medical_services, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLocalizedTitle(context, department),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getLocalizedSubtitle(context, department),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                      
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
