import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../chat_doctors/models/doctor_chat_model.dart';
import '../../chat_doctors/views/doctor_active_chat_screen.dart';
import '../controllers/doctor_appointments_controller.dart';
import '../controllers/doctor_navigation_controller.dart';
import '../controllers/doctor_profile_controller.dart';

class NextPatientWidget extends StatelessWidget {
  const NextPatientWidget({super.key});

  Map<String, dynamic>? _getNextPatientData(DoctorAppointmentsController ctrl) {
    final now = DateTime.now();

    Map<String, dynamic>? closest;
    DateTime? closestTime;

    for (var doc in ctrl.bookings) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) continue;

      final status =
          (data['status'] as Map<String, dynamic>?)?['current'] as String? ??
          '';
      if (status != 'upcoming' && status != 'pending' && status != 'confirmed')
        continue;

      if (data['schedule'] != null &&
          data['schedule']['date'] != null &&
          data['schedule']['time'] != null) {
        final dateStr = data['schedule']['date'] as String;
        final timeStr = data['schedule']['time'] as String;
        try {
          final date = DateTime.parse(dateStr);
          if (date.year == now.year &&
              date.month == now.month &&
              date.day == now.day) {
            // Parse time flexibly
            DateTime? parsedTime;
            String startTimeStr = timeStr;
            if (timeStr.contains('-')) {
              startTimeStr = timeStr.split('-')[0].trim();
            }
            try {
              parsedTime = DateFormat("hh:mm a").parse(startTimeStr);
            } catch (_) {
              try {
                parsedTime = DateFormat("HH:mm").parse(startTimeStr);
              } catch (_) {}
            }

            if (parsedTime != null) {
              final appointmentDateTime = DateTime(
                now.year,
                now.month,
                now.day,
                parsedTime.hour,
                parsedTime.minute,
              );
              // Pick the earliest one for today that is still pending/upcoming
              if (closestTime == null ||
                  appointmentDateTime.isBefore(closestTime)) {
                closestTime = appointmentDateTime;
                closest = data;
              }
            } else {
              // If we can't parse the time, just use it as a fallback if nothing else is found
              closest ??= data;
            }
          }
        } catch (_) {}
      }
    }
    return closest;
  }

  void _openChat(Map<String, dynamic> bookingData) {
    final profileCtrl = Get.put(DoctorProfileController());
    final doctor = profileCtrl.doctor.value;
    if (doctor == null) return;

    final customerId =
        (bookingData['user'] as Map<String, dynamic>?)?['userId'] as String? ??
        '';
    final customerName =
        (bookingData['user'] as Map<String, dynamic>?)?['name'] as String? ??
        'Patient';
    final customerImage =
        (bookingData['user'] as Map<String, dynamic>?)?['image'] as String? ??
        '';

    // Create a temporary chat room object to pass
    final ids = [customerId, doctor.id];
    ids.sort();
    final roomId = '${ids[0]}_${ids[1]}';

    final room = DoctorChatRoom(
      id: roomId,
      customerId: customerId,
      customerName: customerName,
      customerProfileImage: customerImage,
      doctorId: doctor.id,
      doctorName: doctor.nameEn,
      doctorProfileImage: doctor.image,
      lastMessage: '',
      lastMessageKind: 'text',
      lastSenderId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Get.to(() => DoctorActiveChatScreen(room: room));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = Get.put(DoctorAppointmentsController());

    return Obx(() {
      // Access length to force reactivity when the list updates
      final _ = ctrl.bookings.length;
      final nextPatient = _getNextPatientData(ctrl);
      if (nextPatient == null) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.nextPatient,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available_rounded,
                        size: 40,
                        color: AppColors.grey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noPatientsToday,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final userMap = nextPatient['user'] as Map<String, dynamic>? ?? {};
      final customerName = userMap['name'] as String? ?? 'Unknown Patient';
      final customerImage = userMap['image'] as String? ?? '';
      final userId =
          userMap['auth_uid'] as String? ?? userMap['userId'] as String? ?? '';
      final timeStr =
          (nextPatient['schedule'] as Map<String, dynamic>?)?['time']
              as String? ??
          '';
      final isOnline = (nextPatient['type'] as String?) == 'online';

      // Determine service type safely
      String serviceType = 'Consultation';
      if (nextPatient['service'] != null && nextPatient['service'] is Map) {
        final serviceMap = nextPatient['service'] as Map<String, dynamic>;
        serviceType = serviceMap['nameEn'] as String? ?? serviceType;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.nextPatient,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final navCtrl = Get.find<DoctorNavigationController>();
                    navCtrl.changeIndex(1); // Go to APPTS tab
                    final apptCtrl = Get.put(DoctorAppointmentsController());
                    apptCtrl.setSelectedTargetDate(DateTime.now());
                    apptCtrl.targetStatus.value = 'upcoming';
                  },
                  child: Row(
                    children: [
                      Text(
                        l10n.viewAll,
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.grey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (customerImage.trim().isNotEmpty)
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: NetworkImage(customerImage.trim()),
                    )
                  else if (userId.trim().isNotEmpty)
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId.trim())
                          .get(),
                      builder: (context, snapshot) {
                        String fetchedImage = '';
                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data!.exists) {
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>?;
                          if (data != null) {
                            fetchedImage = data['image'] as String? ?? '';
                          }
                        }
                        return CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          backgroundImage: fetchedImage.trim().isNotEmpty
                              ? NetworkImage(fetchedImage.trim())
                              : null,
                          child: fetchedImage.trim().isEmpty
                              ? const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                )
                              : null,
                        );
                      },
                    )
                  else
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                customerName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'UPCOMING',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeStr,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                isOnline
                                    ? 'Online - $serviceType'
                                    : 'Clinical - $serviceType',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => _openChat(nextPatient),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.openChat,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
