import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/common/controllers/app_constants_controller.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:o2_clinic/features/chat_support/data/models/chat_support_model.dart';
import 'package:o2_clinic/features/chat_support/presentation/screens/chat_room_screen.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import '../../data/models/medical_device_model.dart';

class MedicalDeviceDetailSheet extends StatefulWidget {
  final MedicalDeviceModel device;

  const MedicalDeviceDetailSheet({super.key, required this.device});

  static Future<void> show(BuildContext context, MedicalDeviceModel device) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => MedicalDeviceDetailSheet(device: device),
    );
  }

  @override
  State<MedicalDeviceDetailSheet> createState() => _MedicalDeviceDetailSheetState();
}

class _MedicalDeviceDetailSheetState extends State<MedicalDeviceDetailSheet> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final currentLang = Get.locale?.languageCode ?? 'ar';
    final currency = Get.isRegistered<AppConstantsController>()
        ? Get.find<AppConstantsController>().currencySymbol.value
        : 'EGP';

    final description = widget.device.getLocalizedDescription(currentLang);
    final hasDiscount = widget.device.atDiscount &&
        widget.device.discountedPrice.isNotEmpty &&
        widget.device.discountedPrice != widget.device.price;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.colorFF1A2625 : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle & Close Button Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center drag indicator
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.white24 : AppColors.grey300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Close button on right or left depending on direction
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.white12 : AppColors.colorFFF3F8F7,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: isDark ? AppColors.white : AppColors.colorFF081F1D,
                        ),
                      ),
                      tooltip: l10n.close,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Device Hero Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        height: 240,
                        color: isDark ? AppColors.colorFF2A3A39 : AppColors.colorFFF8FAFA,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedImageWidget(
                              imageUrl: widget.device.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => Center(
                                child: Icon(
                                  Icons.medical_services_outlined,
                                  size: 64,
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                            // Availability & Discount Tags
                            Positioned(
                              top: 14,
                              left: 14,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: (widget.device.isAvailable
                                              ? AppColors.green
                                              : AppColors.grey600)
                                          .withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          widget.device.isAvailable
                                              ? Icons.check_circle_rounded
                                              : Icons.cancel_rounded,
                                          size: 13,
                                          color: AppColors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          widget.device.isAvailable
                                              ? l10n.availableNow
                                              : l10n.currentlyUnavailable,
                                          style: const TextStyle(
                                            color: AppColors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (hasDiscount) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        l10n.specialDiscount,
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Device Name
                    Text(
                      widget.device.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.white : AppColors.colorFF081F1D,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Price Section
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        if (hasDiscount) ...[
                          Text(
                            '${widget.device.discountedPrice} $currency',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '${widget.device.price} $currency',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.lineThrough,
                              color: isDark ? AppColors.white38 : AppColors.grey500,
                            ),
                          ),
                        ] else ...[
                          Text(
                            '${widget.device.price} $currency',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 18),
                    Divider(color: isDark ? AppColors.white12 : AppColors.colorFFF2F7F6),
                    const SizedBox(height: 12),

                    // Description Section with Read More / Read Less
                    Text(
                      description,
                      maxLines: _isExpanded ? null : 3,
                      overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.65,
                        color: isDark ? AppColors.white70 : AppColors.colorFF334155,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    if (description.length > 90) ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isExpanded ? l10n.readLess : l10n.readMore,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Inquire & Purchase Action Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.colorFF1A2625 : AppColors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.white12 : AppColors.colorFFF2F7F6,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final isAr = Get.locale?.languageCode == 'ar';
                    final isHe = Get.locale?.languageCode == 'he';
                    final defaultMsg = isAr
                        ? 'اهلين\nممكن انا اسال عن الجهاز "${widget.device.name}"'
                        : isHe
                        ? 'שלום,\nאפשר בבקשה לשאול על המכשיר "${widget.device.name}"?'
                        : 'Hello,\nMay I please inquire about the device "${widget.device.name}"?';

                    Navigator.of(context).pop();
                    Get.to(
                      () => ChatRoomScreen(
                        initialText: defaultMsg,
                        initialReply: ChatReplyInfo(
                          title: widget.device.name,
                          description: hasDiscount
                              ? '${widget.device.discountedPrice} $currency'
                              : '${widget.device.price} $currency',
                          imageUrl: widget.device.imageUrl,
                        ),
                      ),
                      transition: Transition.rightToLeftWithFade,
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.white, size: 20),
                  label: Text(
                    l10n.inquireAndPurchase,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
