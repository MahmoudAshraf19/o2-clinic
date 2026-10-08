import 'package:flutter/material.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';
import '../../../booking/data/models/fs_booking_model.dart';
import 'doctor_avatar.dart';
import 'booking_helper.dart';
import 'status_badge.dart';

class AppointmentCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = BookingHelper.isArabic(context);
    final status = booking.status.current.toLowerCase();
    final date = booking.schedule.timestamp?.toDate();
    final isOpen = !{
      'completed',
      'cancelled',
      'no_show',
      'under_investigation',
    }.contains(status);
    final relative = isOpen ? BookingHelper.relativeDay(context, date) : null;
    final title = BookingHelper.title(context, booking);

    return Semantics(
      button: true,
      label: '$title, ${BookingHelper.whenText(context, booking)}',
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.white.withValues(alpha: 0.03) 
                  : AppColors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.scaffoldDark 
                : AppColors.grey100,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DoctorAvatar(
                        imageUrl: booking.doctor?.image,
                        fallbackIcon: BookingHelper.typeIcon(booking.type),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              BookingHelper.subtitle(context, booking),
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).brightness == Brightness.dark ? AppColors.white54 : AppColors.grey600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  BookingHelper.typeIcon(booking.type),
                                  size: 13,
                                  color: AppColors.grey500,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    BookingHelper.typeFriendly(
                                      context,
                                      booking.type,
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: status, isAr: isAr),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? AppColors.scaffoldDark.withValues(alpha: 0.5) 
                          : AppColors.colorFFF4F7F9,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            BookingHelper.whenText(context, booking),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black87,
                            ),
                          ),
                        ),
                        if (relative != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            relative,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.grey400,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
