import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';

class PatientAppointmentCard extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const PatientAppointmentCard({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    final doctorMap = bookingData['doctor'] as Map<String, dynamic>? ?? {};
    final isAr = Get.locale?.languageCode == 'ar';
    final doctorName = isAr
        ? (doctorMap['name_ar'] as String? ?? 'Doctor')
        : (doctorMap['name_en'] as String? ?? 'Doctor');
    final doctorImage = doctorMap['image'] as String? ?? '';
    final doctorSpecialty = doctorMap['specialty'] as String? ?? '';

    final schedule = bookingData['schedule'] as Map<String, dynamic>? ?? {};
    final timeStr = schedule['time'] as String? ?? '';
    final dateStr = schedule['date'] as String? ?? '';

    // Extract start time if it's a range like "09:00 AM - 12:00 PM"
    final timeParts = timeStr.split(' - ');
    final startTime = timeParts.isNotEmpty ? timeParts[0] : timeStr;

    // Format date
    String displayDate = '';
    if (dateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(dateStr);
        final lang = Get.locale?.languageCode ?? 'en';
        displayDate = DateFormat('dd MMM yyyy', lang).format(dt);
      } catch (e) {
        displayDate = dateStr;
      }
    }
    final timeDisplay = displayDate.isNotEmpty
        ? '$displayDate • $startTime'
        : startTime;

    final type =
        bookingData['type'] as String? ?? 'clinical'; // online or clinical
    final isOnline = type == 'online';

    final service = bookingData['service'] as Map<String, dynamic>? ?? {};
    final serviceNameEn =
        service['serviceName_en'] as String? ?? doctorSpecialty;
    final serviceNameAr =
        service['serviceName_ar'] as String? ?? doctorSpecialty;
    final serviceName = isAr ? serviceNameAr : serviceNameEn;

    final statusMap = bookingData['status'] as Map<String, dynamic>? ?? {};
    final currentStatus = statusMap['current'] as String? ?? 'pending';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.grey.withValues(alpha: 0.2),
                backgroundImage: doctorImage.isNotEmpty
                    ? NetworkImage(doctorImage)
                    : null,
                child: doctorImage.isEmpty
                    ? const Icon(Icons.person, color: AppColors.grey, size: 30)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (doctorSpecialty.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        doctorSpecialty,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildStatusBadge(context, currentStatus),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.access_time_rounded, timeDisplay),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      isOnline
                          ? Icons.videocam_outlined
                          : Icons.medical_services_outlined,
                      isOnline
                          ? (isAr ? 'استشارة أونلاين' : 'Online Consultation')
                          : (isAr ? 'حضور شخصي' : 'In Person'),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.assignment_outlined,
                      serviceName.isNotEmpty ? serviceName : 'Check-up',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color bgColor;
    Color textColor;
    String text;

    final isAr = Get.locale?.languageCode == 'ar';

    switch (status) {
      case 'upcoming':
      case 'confirmed':
        bgColor = const Color(0xFF21897E).withValues(alpha: 0.12);
        textColor = const Color(0xFF21897E);
        text = isAr ? 'مؤكد' : 'Confirmed';
        break;
      case 'pending':
        bgColor = Colors.orange.withValues(alpha: 0.15);
        textColor = Colors.orange[800]!;
        text = isAr ? 'قيد الانتظار' : 'Pending';
        break;
      case 'cancelled':
        bgColor = const Color(0xFFE53E3E).withValues(alpha: 0.12);
        textColor = const Color(0xFFE53E3E);
        text = isAr ? 'ملغي' : 'Cancelled';
        break;
      case 'completed':
        bgColor = const Color(0xFF2D3737).withValues(alpha: 0.10);
        textColor = const Color(0xFF2D3737);
        text = isAr ? 'مكتمل' : 'Completed';
        break;
      default:
        bgColor = AppColors.grey.withValues(alpha: 0.15);
        textColor = AppColors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
