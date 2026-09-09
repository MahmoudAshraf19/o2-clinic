import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/notifications_controller.dart';
import '../models/notification_model.dart';
import '../utils/notification_time_helper.dart';
import '../../services_firestore/models/doctor_model.dart';
import '../../booking/presentation/pages/booking_success_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _colors = _O2Colors();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final NotificationsController controller = Get.put(NotificationsController());

    return Scaffold(
      backgroundColor: _colors.surface,
      appBar: AppBar(
        backgroundColor: _colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181D1C)),
          onPressed: () => Get.back(),
        ),
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
                      color: _colors.onSurfaceVariant,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.notifications,
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: _colors.onSurface,
                            letterSpacing: -0.4,
                          ),
                        ),
                        if (controller.unreadCount > 0)
                          TextButton(
                            onPressed: () => controller.markAllAsRead(),
                            style: TextButton.styleFrom(
                              foregroundColor: _colors.primary,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.markAllAsRead,
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: _colors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (newNotes.isNotEmpty) ...[
                  _SectionTitle(title: AppLocalizations.of(context)!.notifSectionNew),
                  ...newNotes.map((n) => _buildTile(n, context)),
                ],
                if (todayNotes.isNotEmpty) ...[
                  _SectionTitle(title: AppLocalizations.of(context)!.notifSectionToday),
                  ...todayNotes.map((n) => _buildTile(n, context)),
                ],
                if (yesterdayNotes.isNotEmpty) ...[
                  _SectionTitle(title: AppLocalizations.of(context)!.notifSectionYesterday),
                  ...yesterdayNotes.map((n) => _buildTile(n, context)),
                ],
                if (earlierNotes.isNotEmpty) ...[
                  _SectionTitle(title: AppLocalizations.of(context)!.notifSectionEarlier),
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
    IconData icon;
    Color iconBg = _colors.surfaceContainerHigh;
    Color iconFg = _colors.onSurface;

    switch (n.type) {
      case 'booking':
      case 'booking_confirmation':
        icon = Icons.event_available;
        iconBg = _colors.primaryContainer;
        iconFg = _colors.onPrimaryContainer;
        break;
      case 'message':
        icon = Icons.message_rounded;
        iconBg = _colors.tertiaryContainer;
        iconFg = _colors.onTertiaryContainer;
        break;
      case 'payment':
        icon = Icons.receipt_long_rounded;
        iconBg = _colors.secondaryContainer;
        iconFg = _colors.onSecondaryContainer;
        break;
      case 'reminder':
        icon = Icons.schedule;
        iconBg = _colors.errorContainer;
        iconFg = _colors.onErrorContainer;
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
      bgColor: !n.isRead ? _colors.surfaceContainerLow : _colors.surfaceContainerLowest,
      message: TextSpan(
        style: const TextStyle(height: 1.25),
        children: [
          _bold('$title\n'),
          TextSpan(text: body),
        ],
      ),
      time: NotificationTimeHelper.getFullDateTime(n.createdAt, context: context),
      timeColor: !n.isRead ? _colors.primary : _colors.onSurfaceVariant,
      bodyOpacity: !n.isRead ? 1.0 : 0.8,
      onTap: () async {
        if (!n.isRead) {
          Get.find<NotificationsController>().markAsRead(n.id);
        }
        if ((n.type == 'booking' || n.type == 'booking_confirmation') && n.data['bookingId'] != null && n.data['bookingId'].toString().isNotEmpty) {
          Get.dialog(const Center(child: CircularProgressIndicator(color: Color(0xFF00685F))), barrierDismissible: false, barrierColor: Colors.black12);
          
          try {
            final doc = await FirebaseFirestore.instance.collection('bookings').doc(n.data['bookingId'].toString()).get();
            Get.back(); // close loading
            
            if (doc.exists) {
              final data = doc.data()!;
              final doctorMap = data['doctor'] as Map<String, dynamic>? ?? {};
              final doctor = DoctorModel.fromMap(
                id: doctorMap['id']?.toString() ?? '',
                map: doctorMap,
              );
              
              final schedule = data['schedule'] as Map<String, dynamic>? ?? {};
              final dateStr = schedule['date']?.toString();
              final date = dateStr != null ? DateTime.tryParse(dateStr) : DateTime.now();
              final time = schedule['time']?.toString() ?? '';
              
              Get.to(() => BookingSuccessScreen(
                doctor: doctor,
                selectedDate: date ?? DateTime.now(),
                selectedTime: time,
                bookingId: doc.id,
              ));
            } else {
              Get.snackbar('Error', 'Booking not found');
            }
          } catch (e) {
            Get.back(); // close loading
            Get.snackbar('Error', 'Could not load booking details');
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
          color: const Color(0xFF3E4947),
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
    this.timeColor = const Color(0xFF00685F),
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
    const colors = _O2Colors();

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
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: iconFg,
              ),
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
                  color: Color(0xFF00685F),
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
  const _O2Colors();

  Color get surface => const Color(0xFFF6FAF8);
  Color get surfaceContainerLow => const Color(0xFFF0F4F2);
  Color get surfaceContainerLowest => const Color(0xFFFFFFFF);
  Color get surfaceContainerHigh => const Color(0xFFE5E9E7);
  Color get primary => const Color(0xFF00685F);
  Color get primaryContainer => const Color(0xFF158278);
  Color get onPrimaryContainer => const Color(0xFFF4FFFC);
  Color get secondaryContainer => const Color(0xFF8CF5E6);
  Color get onSecondaryContainer => const Color(0xFF007167);
  Color get tertiaryContainer => const Color(0xFF008379);
  Color get onTertiaryContainer => const Color(0xFFF4FFFC);
  Color get errorContainer => const Color(0xFFFFDAD6);
  Color get onErrorContainer => const Color(0xFF93000A);
  Color get onSurface => const Color(0xFF181D1C);
  Color get onSurfaceVariant => const Color(0xFF3E4947);
}

