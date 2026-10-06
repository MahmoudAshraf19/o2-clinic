import 'dart:ui';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../booking/views/cosmetic_booking_page.dart';

import '../../../common/widgets/common_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../doctors/views/doctors_screen.dart';
import '../controllers/cosmetic_controller.dart';
import '../models/cosmetic_model.dart';
import '../models/cosmetic_category_model.dart';

class CosmeticCards extends StatelessWidget {
  const CosmeticCards({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CosmeticController(),
      child: const CosmeticCardsView(),
    );
  }
}

class CosmeticCardsView extends StatelessWidget {
  const CosmeticCardsView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount = 1;
    if (width > 1000) {
      crossAxisCount = 3;
    } else if (width > 650) {
      crossAxisCount = 2;
    }

    return RefreshIndicator(
      onRefresh: Provider.of<CosmeticController>(
        context,
        listen: false,
      ).refreshCosmetics,
      child: Consumer<CosmeticController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontFamily: 'NunitoSans',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CommonButton(
                    text: 'Retry',
                    onPressed: controller.refreshCosmetics,
                    type: CommonButtonType.primary,
                    size: CommonButtonSize.medium,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: controller.cosmetics.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: width < 600 ? 0.78 : 0.70,
            ),
            itemBuilder: (context, index) {
              return CosmeticCard(model: controller.cosmetics[index]);
            },
          );
        },
      ),
    );
  }
}

class CosmeticCard extends StatefulWidget {
  final CosmeticModel model;

  const CosmeticCard({super.key, required this.model});

  @override
  State<CosmeticCard> createState() => _CosmeticCardState();
}

class _CosmeticCardState extends State<CosmeticCard> {
  bool hovered = false;

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: CachedImageWidget(
                  imageUrl: widget.model.image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.model.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.model.items.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 3),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                e,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'NunitoSans',
                                  color: AppColors.black,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                    CommonButton(
                      text: "Book Now",
                      onPressed: () {
                        Navigator.pop(context);
                        Get.to(
                          () => CosmeticBookingPage(
                            model: CosmeticCategoryModel(
                              id: widget.model.id,
                              image: widget.model.image,
                              isActive: widget.model.isActive,
                              order: 0,
                              nameMap: {
                                'en': widget.model.titleEn,
                                'ar': widget.model.titleAr,
                              },
                              descMap: {},
                              availabilityDay: widget.model.availabilityDay,
                              price: widget.model.price.toString(),
                            ),
                          ),
                        );
                      },
                      type: CommonButtonType.primary,
                      size: CommonButtonSize.large,
                      icon: Icons.arrow_forward,
                      iconPosition: IconPosition.right,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.model;

    return GestureDetector(
      onTap: () => _showDetails(context),
      child: MouseRegion(
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: hovered ? 0.18 : 0.08,
                ),
                blurRadius: hovered ? 24 : 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 400),
                    scale: hovered ? 1.06 : 1.0,
                    child: CachedImageWidget(
                      imageUrl: m.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xAA000000),
                          Color(0xCC000000),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          m.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


