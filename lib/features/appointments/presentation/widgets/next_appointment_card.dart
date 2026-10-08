import 'package:flutter/material.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import '../../../booking/data/models/fs_booking_model.dart';
import 'action_button.dart';
import 'booking_helper.dart';
import 'doctor_avatar.dart';

/// Hero card highlighting the user's next upcoming appointment.
class NextAppointmentCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onViewDetails;

  const NextAppointmentCard({
    super.key,
    required this.booking,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = BookingHelper.isArabic(context);
    final date = booking.schedule.timestamp?.toDate();
    final countdown =
        BookingHelper.relativeDay(context, date) ?? l10n.soon;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.colorFF1E877B, AppColors.colorFF0F5A51],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorFF1E877B.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -30,
              top: -30,
              child: _circle(150, 0.05),
            ),
            PositionedDirectional(
              start: -20,
              bottom: -20,
              child: _circle(100, 0.05),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.yourNextAppointment,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      DoctorAvatar(
                        imageUrl: booking.doctor?.image,
                        fallbackIcon: BookingHelper.typeIcon(booking.type),
                        isHero: true,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              BookingHelper.title(context, booking),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              BookingHelper.subtitle(context, booking),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.white.withValues(alpha: 0.85),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          countdown,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled_rounded,
                          size: 20,
                          color: AppColors.white,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            BookingHelper.whenText(context, booking),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ActionButton(
                          text: l10n.viewDetails,
                          icon: Icons.visibility_rounded,
                          filled: true,
                          onTap: onViewDetails,
                        ),
                      ),
                      if (booking.type.toLowerCase() == 'online') ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ActionButton(
                            text: l10n.onlineConsultation,
                            icon: Icons.videocam_rounded,
                            filled: false,
                            // TODO: route to the video-consultation screen
                            // once its route/arguments are available.
                            onTap: onViewDetails,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, double alpha) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppColors.white.withValues(alpha: alpha),
      shape: BoxShape.circle,
    ),
  );
}
