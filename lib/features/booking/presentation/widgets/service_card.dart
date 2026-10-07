import 'dart:ui';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

import '../../data/models/booking_service_model.dart';

class ServiceCard extends StatelessWidget {
  final BookingServiceModel model;

  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.model, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(
                child: CachedImageWidget(
                  imageUrl: model.image,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.black87,
                        AppColors.black45,
                        AppColors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 8,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            model.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontFamily: "GreatVibes",
                              height: 1.1,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      model.description.isNotEmpty
                          ? model.description
                          : AppLocalizations.of(
                              context,
                            )!.highQualityMedicalService,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.75),
                        fontSize: 10,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandBlue,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.explore,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          SizedBox(width: 4),

                          Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
