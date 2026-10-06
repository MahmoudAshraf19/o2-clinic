import 'package:o2_clinic/core/widgets/cached_image_widget.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';
import '../controllers/doctor_navigation_controller.dart';
import '../../../features/notifications/controllers/notifications_controller.dart';
import '../../../features/notifications/widgets/notification_dropdown_widget.dart';
import '../../../l10n/app_localizations.dart';

class DoctorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DoctorAppBar({super.key, this.onNotificationTap});

  final VoidCallback? onNotificationTap;

  

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00685F);
    const primaryContainer = Color(0xFF158278);
    const surfaceContainerLow = Color(0xFFF1F4F3);

    final doctorNav = Get.find<DoctorNavigationController>();

    return Obx(() {
      final user = doctorNav.doctorData.value;

      final locale = Get.locale?.languageCode ?? 'en';
      final drName = locale == 'ar'
          ? (user?['name_ar'] ?? 'طبيب')
          : (locale == 'he'
                ? (user?['name_he'] ?? 'רוֹפֵא')
                : (user?['name_en'] ?? 'Doctor'));

      final image = user?['image'];


      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: const Border(
            bottom: BorderSide(color: Color(0x33BDC9C6), width: 1),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: primaryContainer.withValues(alpha: 0.20),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primary.withValues(alpha: 0.10),
                              width: 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child:
                              
                                  image == null ||
                                  image.toString().trim().isEmpty
                              ? const Icon(Icons.person, color: primary)
                              : CachedImageWidget(
                                  imageUrl: image.toString(),
                                  key: ValueKey(image.toString()),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/icons/user.png',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.hiName(drName),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF134E4A),
                                        height: 1.1,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  
                                ],
                              ),
                              const SizedBox(height: 2),
                                Text(
                                  DateFormat(
                                    'd MMMM, yyyy',
                                  ).format(DateTime.now()),
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF64748B),
                                  letterSpacing: 1.1,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    if (onNotificationTap != null) {
                      onNotificationTap!();
                    } else {
                      Get.dialog(
                        const NotificationDropdownWidget(),
                        barrierColor: Colors.transparent,
                      );
                    }
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: surfaceContainerLow,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.notifications_none,
                          size: 20,
                          color: primary,
                        ),
                      ),
                      Obx(() {
                        final notificationsController =
                            Get.isRegistered<NotificationsController>()
                            ? Get.find<NotificationsController>()
                            : Get.put(
                                NotificationsController(),
                                permanent: true,
                              );
                        final unreadCount = notificationsController
                            .notifications
                            .where((n) => !n.isRead)
                            .length;
                        if (unreadCount == 0) {
                          return const SizedBox.shrink();
                        }

                        final displayCount = unreadCount > 99
                            ? '99+'
                            : unreadCount.toString();

                        return Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4B4B),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              displayCount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

