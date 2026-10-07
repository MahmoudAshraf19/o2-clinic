import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../chat_doctors/models/doctor_chat_model.dart';
import '../../chat_doctors/views/doctor_active_chat_screen.dart';
import '../views/doctor_booking_details_screen.dart';

class DoctorAppointmentCard extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const DoctorAppointmentCard({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    final userMap = bookingData['user'] as Map<String, dynamic>? ?? {};
    final userId =
        userMap['auth_uid'] as String? ?? userMap['userId'] as String? ?? '';
    final name = userMap['name'] as String? ?? 'Patient';
    final userImage =
        userMap['image'] as String? ??
        ''; // We'll try to get it from Firestore below if empty

    final bookingId = bookingData['id'] as String? ?? '';

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
    final doctorMap = bookingData['doctor'] as Map<String, dynamic>? ?? {};
    final serviceNameEn =
        service['serviceName_en'] as String? ??
        doctorMap['specialty'] as String? ??
        '';
    final serviceNameAr =
        service['serviceName_ar'] as String? ??
        doctorMap['specialty'] as String? ??
        '';
    final isAr = Get.locale?.languageCode == 'ar';
    final serviceName = isAr ? serviceNameAr : serviceNameEn;

    final statusMap = bookingData['status'] as Map<String, dynamic>? ?? {};
    final currentStatus = statusMap['current'] as String? ?? 'pending';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.1)),
        // NO SHADOWS
      ),
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get(),
        builder: (context, snapshot) {
          String? imageUrl;
          String gender = '';
          String age = '';

          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data != null) {
              imageUrl = data['image'] as String?;
              gender = data['gender'] as String? ?? '';
              age = data['age']?.toString() ?? '';
            }
          }

          String subtitle = '';
          if (age.isNotEmpty) subtitle += '$age yrs';
          if (age.isNotEmpty && gender.isNotEmpty) subtitle += ' • ';
          if (gender.isNotEmpty) subtitle += gender;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Avatar, Name & Age, Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.grey.withValues(alpha: 0.2),
                    backgroundImage:
                        (imageUrl != null && imageUrl.trim().isNotEmpty)
                        ? NetworkImage(imageUrl.trim())
                        : (userImage.trim().isNotEmpty
                              ? NetworkImage(userImage.trim())
                              : null),
                    child:
                        (imageUrl == null || imageUrl.trim().isEmpty) &&
                            userImage.trim().isEmpty
                        ? const Icon(
                            Icons.person,
                            color: AppColors.grey,
                            size: 30,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
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

              // Row 2: Icons/Info on Left, Buttons on Right
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
                              ? AppLocalizations.of(context)!.onlineConsultation
                              : (isAr ? 'حضور شخصي' : 'In Person'),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.assignment_outlined,
                          serviceName.isNotEmpty ? serviceName : 'Check-up',
                        ),
                        if (bookingId.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.tag_rounded, 'ID: $bookingId'),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        _buildActionButton(
                          text: AppLocalizations.of(context)!.viewDetails,
                          color: AppColors.primary.withValues(alpha: 0.1),
                          textColor: AppColors.primary,
                          onTap: () {
                            Get.to(
                              () => DoctorBookingDetailsScreen(
                                bookingData: bookingData,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildActionButton(
                          text: isAr ? 'بدء الاستشارة' : 'Start Consultation',
                          color: _isActionEnabled(currentStatus)
                              ? AppColors.primary
                              : AppColors.grey.withValues(alpha: 0.1),
                          textColor: _isActionEnabled(currentStatus)
                              ? AppColors.white
                              : AppColors.grey,
                          onTap: _isActionEnabled(currentStatus)
                              ? () {
                                  _startConsultation(
                                    context,
                                    userId,
                                    name,
                                    userImage,
                                    doctorMap,
                                  );
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isActionEnabled(String status) {
    return status == 'pending' || status == 'upcoming' || status == 'confirmed';
  }

  void _startConsultation(
    BuildContext context,
    String patientId,
    String patientName,
    String patientImage,
    Map<String, dynamic> doctorMap,
  ) {
    final doctorId = doctorMap['doctorId'] as String? ?? '';
    final doctorName = doctorMap['name_en'] as String? ?? '';
    final doctorImage = doctorMap['image'] as String? ?? '';

    // Sort IDs to create consistent room ID
    final ids = [patientId, doctorId];
    ids.sort();
    final roomId = ids.join('_');

    final room = DoctorChatRoom(
      id: roomId,
      customerId: patientId,
      customerName: patientName,
      customerProfileImage: patientImage,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorProfileImage: doctorImage,
      lastMessage: '',
      lastMessageKind: '',
      lastSenderId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Get.to(() => DoctorActiveChatScreen(room: room));
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case 'upcoming':
      case 'confirmed':
        bgColor = AppColors.green.withValues(alpha: 0.15);
        textColor = AppColors.green700;
        text = AppLocalizations.of(context)!.upcoming; // or confirmed
        break;
      case 'pending':
        bgColor = AppColors.orange.withValues(alpha: 0.15);
        textColor = AppColors.orange800;
        text = AppLocalizations.of(context)!.pending;
        break;
      case 'cancelled':
        bgColor = AppColors.red.withValues(alpha: 0.15);
        textColor = AppColors.red700;
        text = AppLocalizations.of(context)!.cancelled;
        break;
      case 'completed':
        bgColor = AppColors.primary.withValues(alpha: 0.15);
        textColor = AppColors.primary;
        text = AppLocalizations.of(context)!.completed;
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

  Widget _buildActionButton({
    required String text,
    required Color color,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
