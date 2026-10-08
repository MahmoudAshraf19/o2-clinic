import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:o2_clinic/common/widgets/common_snackbar.dart';
import '../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../presentation/controllers/notifications_controller.dart';
import '../../data/models/notification_model.dart';
import '../../presentation/utils/notification_time_helper.dart';
import '../../../appointments/presentation/screens/my_appointments_screen.dart';
import '../../../doctor_dashboard/presentation/screens/doctor_reviews_screen.dart';
import '../../../doctor_dashboard/presentation/controllers/doctor_navigation_controller.dart';
import '../../../doctor_dashboard/presentation/controllers/doctor_appointments_controller.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/notification_router.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = _O2Colors(context);
    final textTheme = Theme.of(context).textTheme;
    final NotificationsController controller =
        Get.isRegistered<NotificationsController>()
        ? Get.find<NotificationsController>()
        : Get.put(NotificationsController(), permanent: true);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppLocalizations.of(context)!.notifications,
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          Obx(() {
            if (controller.unreadCount > 0) {
              return CommonButton(
                onPressed: () => controller.markAllAsRead(),
                text: AppLocalizations.of(context)!.markAllAsRead,
                type: CommonButtonType.text,
                foregroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                textStyle: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: colors.primary,
                ),
              );
            }
            return const SizedBox();
          }),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 768),
            child: Obx(() {
              if (controller.notifications.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context)!.noNotificationsYet,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                );
              }

              final newNotes = controller.newNotifications;
              final todayNotes = controller.todayNotifications;
              final yesterdayNotes = controller.yesterdayNotifications;
              final earlierNotes = controller.earlierNotifications;

              return ListView(
                padding: const EdgeInsets.only(bottom: 20),
                children: [
                  if (newNotes.isNotEmpty) ...[
                    _SectionTitle(
                      title: AppLocalizations.of(context)!.notifSectionNew,
                    ),
                    ...newNotes.map((n) => _buildTile(n, context)),
                  ],
                  if (todayNotes.isNotEmpty) ...[
                    _SectionTitle(
                      title: AppLocalizations.of(context)!.notifSectionToday,
                    ),
                    ...todayNotes.map((n) => _buildTile(n, context)),
                  ],
                  if (yesterdayNotes.isNotEmpty) ...[
                    _SectionTitle(
                      title: AppLocalizations.of(
                        context,
                      )!.notifSectionYesterday,
                    ),
                    ...yesterdayNotes.map((n) => _buildTile(n, context)),
                  ],
                  if (earlierNotes.isNotEmpty) ...[
                    _SectionTitle(
                      title: AppLocalizations.of(context)!.notifSectionEarlier,
                    ),
                    ...earlierNotes.map((n) => _buildTile(n, context)),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(NotificationModel n, BuildContext context) {
    final colors = _O2Colors(context);
    IconData icon;
    Color iconBg = colors.surfaceContainerHigh;
    Color iconFg = colors.onSurface;

    switch (n.type) {
      case 'booking':
      case 'booking_confirmation':
        icon = Icons.event_available;
        iconBg = colors.primaryContainer;
        iconFg = colors.onPrimaryContainer;
        break;
      case 'message':
        icon = Icons.message_rounded;
        iconBg = colors.tertiaryContainer;
        iconFg = colors.onTertiaryContainer;
        break;
      case 'payment':
        icon = Icons.receipt_long_rounded;
        iconBg = colors.secondaryContainer;
        iconFg = colors.onSecondaryContainer;
        break;
      case 'reminder':
        icon = Icons.schedule;
        iconBg = colors.errorContainer;
        iconFg = colors.onErrorContainer;
        break;
      default:
        icon = Icons.notifications;
    }

    final String langCode = Get.locale?.languageCode ?? 'en';
    final title = n.getTitle(langCode);
    final body = n.getBody(langCode);

    return _NotificationTile(
      icon: icon,
      iconBg: iconBg,
      iconFg: iconFg,
      unread: !n.isRead,
      bgColor: !n.isRead
          ? colors.surfaceContainerLow
          : colors.surfaceContainerLowest,
      message: TextSpan(
        style: const TextStyle(height: 1.25),
        children: [
          _bold('$title\n'),
          TextSpan(text: body),
        ],
      ),
      time: NotificationTimeHelper.getFullDateTime(
        n.createdAt,
        context: context,
      ),
      timeColor: !n.isRead ? colors.primary : colors.onSurfaceVariant,
      bodyOpacity: !n.isRead ? 1.0 : 0.8,
      onTap: () async {
        if (!n.isRead) {
          Get.find<NotificationsController>().markAsRead(n.id);
        }
        if (n.type == 'review' && n.data['reviewId'] != null) {
          Get.to(
            () => const DoctorReviewsScreen(),
            arguments: {'highlightReviewId': n.data['reviewId'].toString()},
          );
          return;
        }

        if (n.type == 'message' && n.data.isNotEmpty) {
          NotificationRouter.handleNotificationTap(n.data);
          return;
        }

        if (n.data.isNotEmpty &&
            n.data['bookingId'] != null &&
            n.data['bookingId'].toString().isNotEmpty) {
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
                Get.until(
                  (route) =>
                      route.settings.name == AppRoutes.doctorNavigation ||
                      route.isFirst,
                );

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
      },
    );
  }

  TextSpan _bold(String text) {
    return TextSpan(
      text: text,
      style: const TextStyle(fontWeight: FontWeight.w700),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.white70
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.unread,
    required this.bgColor,
    required this.message,
    required this.time,
    this.timeColor = AppColors.brandBlue,
    this.bodyOpacity = 1,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final bool unread;
  final Color bgColor;
  final TextSpan message;
  final String time;
  final Color timeColor;
  final double bodyOpacity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _O2Colors(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 28, color: iconFg),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: bodyOpacity,
                      child: Text.rich(
                        message,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          height: 1.25,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: timeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: unread ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.brandBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _O2Colors {
  final BuildContext context;
  const _O2Colors(this.context);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get surface => isDark
      ? Theme.of(context).scaffoldBackgroundColor
      : AppColors.colorFFF6FAF8;
  Color get surfaceContainerLow => isDark
      ? Theme.of(context).scaffoldBackgroundColor
      : AppColors.colorFFF0F4F2;
  Color get surfaceContainerLowest =>
      isDark ? Theme.of(context).cardColor : AppColors.pureWhite;
  Color get surfaceContainerHigh =>
      isDark ? AppColors.white24 : AppColors.colorFFE5E9E7;
  Color get primary => isDark ? AppColors.colorFF60A5FA : AppColors.brandBlue;
  Color get primaryContainer =>
      isDark ? AppColors.brandBlue.withValues(alpha: 0.5) : AppColors.brandBlue;
  Color get onPrimaryContainer => AppColors.pureWhite;
  Color get secondaryContainer => AppColors.softCyan;
  Color get onSecondaryContainer =>
      isDark ? AppColors.white : AppColors.brandBlue;
  Color get tertiaryContainer => isDark
      ? AppColors.vibrantCyan.withValues(alpha: 0.5)
      : AppColors.vibrantCyan;
  Color get onTertiaryContainer => AppColors.pureWhite;
  Color get errorContainer =>
      isDark ? AppColors.onErrorContainer : AppColors.colorFFFFDAD6;
  Color get onErrorContainer =>
      isDark ? AppColors.colorFFFFDAD6 : AppColors.onErrorContainer;
  Color get onSurface => isDark ? AppColors.white : AppColors.textPrimary;
  Color get onSurfaceVariant =>
      isDark ? AppColors.white70 : AppColors.textSecondary;
}
