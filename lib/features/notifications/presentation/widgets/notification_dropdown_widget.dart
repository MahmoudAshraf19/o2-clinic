import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:o2_clinic/common/widgets/common_snackbar.dart';
import '../../../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../presentation/controllers/notifications_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/notification_model.dart';
import '../../presentation/utils/notification_time_helper.dart';
import '../../../appointments/presentation/screens/my_appointments_screen.dart';
import '../../presentation/screens/notifications_screen.dart';
import '../../../doctor_dashboard/presentation/controllers/doctor_navigation_controller.dart';
import '../../../doctor_dashboard/presentation/controllers/doctor_appointments_controller.dart';
import '../../../doctor_dashboard/presentation/screens/doctor_reviews_screen.dart';
import '../../../../core/services/notification_router.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';

class NotificationDropdownWidget extends StatelessWidget {
  const NotificationDropdownWidget({super.key});

  Color _surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).cardColor
      : AppColors.pureWhite;
  Color _surfaceVariant(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.white12
      : AppColors.colorFFDFE3E1;
  Color _outlineVariant(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.white24
      : AppColors.outlineVariant;
  Color _primary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.colorFF60A5FA
      : AppColors.brandBlue;
  Color _tertiaryContainer(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.vibrantCyan.withValues(alpha: 0.5)
      : AppColors.vibrantCyan;
  Color _onSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.white
      : AppColors.textPrimary;
  Color _onTertiaryContainer(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.white
      : AppColors.colorFFF4FFFC;

  @override
  Widget build(BuildContext context) {
    final NotificationsController controller =
        Get.isRegistered<NotificationsController>()
        ? Get.find<NotificationsController>()
        : Get.put(NotificationsController(), permanent: true);

    return Material(
      color: AppColors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(color: AppColors.black.withValues(alpha: 0.02)),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 380),
                margin: const EdgeInsets.only(top: 72, right: 16, left: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _outlineVariant(context).withValues(alpha: 0.30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.colorFF006A61.withValues(alpha: 0.08),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _header(context, controller),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 420),
                      child: Obx(() {
                        final latest = controller.latestFive;
                        if (latest.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.noNewNotifications,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  color: _outlineVariant(context),
                                ),
                              ),
                            ),
                          );
                        }
                        return Scrollbar(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: latest.length,
                            itemBuilder: (context, index) {
                              return _buildNotificationItem(
                                latest[index],
                                showTopDivider: index > 0,
                                controller: controller,
                                context: context,
                              );
                            },
                          ),
                        );
                      }),
                    ),
                    _footer(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, NotificationsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _surfaceVariant(context).withValues(alpha: 0.50),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.notifications,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: _onSurface(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() {
                  final unread = controller.unreadCount;
                  if (unread == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _tertiaryContainer(context),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.notifUnreadCount(unread),
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        height: 1.33,
                        color: _onTertiaryContainer(context),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Obx(() {
            if (controller.unreadCount == 0) return const SizedBox.shrink();
            return CommonButton(
              onPressed: () => controller.markAllAsRead(),
              text: AppLocalizations.of(context)!.markAllRead,
              type: CommonButtonType.text,
              padding: EdgeInsets.zero,
              width: 0,
              height: 0,
              foregroundColor: _primary(context),
              textStyle: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: _primary(context),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _surface(context).withValues(alpha: 0.50),
        border: Border(
          top: BorderSide(
            color: _surfaceVariant(context).withValues(alpha: 0.50),
          ),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: CommonButton(
          onPressed: () {
            Get.back();
            Get.to(() => const NotificationsScreen());
          },
          text: AppLocalizations.of(context)!.viewAllNotifications,
          type: CommonButtonType.text,
          foregroundColor: _primary(context),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          icon: Icons.arrow_forward_rounded,
          iconPosition: IconPosition.right,
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: _primary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    NotificationModel n, {
    required bool showTopDivider,
    required NotificationsController controller,
    required BuildContext context,
  }) {
    IconData icon;
    Color iconBg = AppColors.colorFFE5E9E7; // surfaceContainerHigh
    Color iconFg = AppColors.outline; // outline

    switch (n.type) {
      case 'booking':
      case 'booking_confirmation':
        icon = Icons.event_available;
        iconBg = AppColors.colorFF158278; // primaryContainer
        iconFg = AppColors.colorFFF4FFFC; // onPrimaryContainer
        break;
      case 'message':
        icon = Icons.message_rounded;
        iconBg = AppColors.colorFF008379; // tertiaryContainer
        iconFg = AppColors.colorFFF4FFFC; // onTertiaryContainer
        break;
      case 'payment':
        icon = Icons.receipt_long_rounded;
        iconBg = AppColors.tertiaryFixed; // secondaryContainer
        iconFg = AppColors.colorFF007167; // onSecondaryContainer
        break;
      case 'reminder':
        icon = Icons.schedule;
        iconBg = AppColors.colorFFFFDAD6; // errorContainer
        iconFg = AppColors.onErrorContainer; // onErrorContainer
        break;
      default:
        icon = Icons.notifications;
    }

    final String langCode = Get.locale?.languageCode ?? 'en';
    final title = n.getTitle(langCode);
    final body = n.getBody(langCode);
    final time = NotificationTimeHelper.getRelativeTime(
      n.createdAt,
      context: context,
    );

    void handleTap() async {
      if (!n.isRead) {
        controller.markAsRead(n.id);
      }
      if (n.type == 'review' && n.data['reviewId'] != null) {
        Get.back(); // close dropdown
        Get.to(
          () => const DoctorReviewsScreen(),
          arguments: {'highlightReviewId': n.data['reviewId'].toString()},
        );
        return;
      }

      if (n.type == 'message' && n.data.isNotEmpty) {
        Get.back(); // close dropdown
        NotificationRouter.handleNotificationTap(n.data);
        return;
      }

      if (n.data.isNotEmpty &&
          n.data['bookingId'] != null &&
          n.data['bookingId'].toString().isNotEmpty) {
        Get.back(); // close dropdown

        Get.dialog(
          const Center(
            child: CommonLoadingIndicator(color: AppColors.brandBlue),
          ),
          barrierDismissible: false,
          barrierColor: AppColors.black12,
        );

        try {
          final doc = await FirebaseFirestore.instance
              .collection('bookings')
              .doc(n.data['bookingId'].toString())
              .get();
          Get.back(); // close loading

          if (doc.exists) {
            if (Get.isRegistered<DoctorNavigationController>()) {
              final navCtrl = Get.find<DoctorNavigationController>();
              navCtrl.changeIndex(1); // Appts tab

              if (Get.isRegistered<DoctorAppointmentsController>()) {
                final apptsCtrl = Get.find<DoctorAppointmentsController>();
                final bookingData = doc.data();
                if (bookingData != null && bookingData['schedule'] != null) {
                  final dateStr = bookingData['schedule']['date'] as String?;
                  if (dateStr != null && dateStr.isNotEmpty) {
                    try {
                      final parsedDate = DateTime.parse(dateStr);
                      apptsCtrl.setSelectedTargetDate(parsedDate);
                    } catch (e) {
                      debugPrint('Could not parse booking date: $e');
                    }
                  }
                }
              }
            } else {
              Get.to(
                () => const MyAppointmentsScreen(),
                arguments: {'showBookingId': doc.id},
              );
            }
          } else {
            CommonSnackbar.showError(title: 'Error', message: 'Booking not found');
          }
        } catch (e) {
          Get.back(); // close loading
          CommonSnackbar.showError(title: 'Error', message: 'Could not load booking details');
        }
      }
    }

    if (!n.isRead) {
      return InkWell(
        onTap: handleTap,
        child: _UnreadNotificationItem(
          icon: icon,
          iconBg: iconBg,
          iconFg: iconFg,
          title: title,
          time: time,
          body: body,
          showTopDivider: showTopDivider,
          showUnreadDot: true,
        ),
      );
    } else {
      return InkWell(
        onTap: handleTap,
        child: _ReadNotificationItem(
          icon: icon,
          iconBg: iconBg,
          iconFg: iconFg,
          title: title,
          time: time,
          body: body,
          showTopDivider: showTopDivider,
        ),
      );
    }
  }
}

class _UnreadNotificationItem extends StatelessWidget {
  const _UnreadNotificationItem({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.time,
    required this.body,
    required this.showTopDivider,
    required this.showUnreadDot,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String time;
  final String body;
  final bool showTopDivider;
  final bool showUnreadDot;

  Color _primary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.colorFF60A5FA
      : AppColors.brandBlue;
  Color _onSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.white
      : AppColors.textPrimary;
  Color _onSurfaceVariant(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.white70
      : AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: _primary(context), width: 4),
          top: BorderSide(
            color: showTopDivider
                ? AppColors.outlineVariant.withValues(alpha: 0.30)
                : AppColors.transparent,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          if (showUnreadDot)
            const Positioned(top: 0, right: 0, child: _UnreadDot()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconFg),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                                color: _onSurface(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 1.33,
                              letterSpacing: 0.6,
                              color: _onSurfaceVariant(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          color: _onSurfaceVariant(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadNotificationItem extends StatelessWidget {
  const _ReadNotificationItem({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.time,
    required this.body,
    required this.showTopDivider,
  }) : avatarUrl = null;

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String time;
  final String body;
  final bool showTopDivider;
  final String? avatarUrl;

  Color _surfaceVariant(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.white12
      : AppColors.colorFFDFE3E1;
  Color _outline(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.white54
      : AppColors.outline;
  Color _onSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.white
      : AppColors.textPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.transparent, width: 4),
          top: BorderSide(
            color: showTopDivider
                ? _surfaceVariant(context).withValues(alpha: 0.30)
                : AppColors.transparent,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: avatarUrl != null
                ? CachedImageWidget(
                    imageUrl: avatarUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 20, color: iconFg),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color: _onSurface(context).withValues(alpha: 0.80),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.33,
                          letterSpacing: 0.6,
                          color: _outline(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: _outline(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 8,
      height: 8,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.brandBlue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.02),
              blurRadius: 0,
            ),
          ],
        ),
      ),
    );
  }
}
