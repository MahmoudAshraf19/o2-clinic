import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/doctor_appointments_controller.dart';
import '../../services_firestore/services/bookings_firestore_service.dart';
import '../../appointments/presentation/screens/report_issue_screen.dart';

class PastAppointmentsWidget extends StatelessWidget {
  const PastAppointmentsWidget({super.key});

  List<Map<String, dynamic>> _getPastAppointments(
    DoctorAppointmentsController ctrl,
  ) {
    final now = DateTime.now();
    List<Map<String, dynamic>> pastList = [];

    for (var doc in ctrl.bookings) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) continue;

      final status =
          (data['status'] as Map<String, dynamic>?)?['current'] as String? ??
          '';
      // We only care about pending, upcoming, or confirmed that have PASSED their time.
      if (status != 'upcoming' &&
          status != 'pending' &&
          status != 'confirmed') {
        continue;
      }

      final type = data['type'] as String? ?? '';
      if (type != 'online') continue;

      if (data['schedule'] != null &&
          data['schedule']['date'] != null &&
          data['schedule']['time'] != null) {
        final dateStr = data['schedule']['date'] as String;
        final timeStr = data['schedule']['time'] as String;
        try {
          final date = DateTime.parse(dateStr);

          DateTime? parsedTime;
          String endTimeStr = timeStr;
          if (timeStr.contains('-')) {
            endTimeStr = timeStr.split('-')[1].trim(); // End time
          }
          try {
            parsedTime = DateFormat("hh:mm a").parse(endTimeStr);
          } catch (_) {
            try {
              parsedTime = DateFormat("HH:mm").parse(endTimeStr);
            } catch (e) {
              /* ignore */
            }
          }

          if (parsedTime != null) {
            final appointmentEndDateTime = DateTime(
              date.year,
              date.month,
              date.day,
              parsedTime.hour,
              parsedTime.minute,
            );

            // If the appointment ended in the past, add to the list
            if (appointmentEndDateTime.isBefore(now)) {
              pastList.add(data);
            }
          }
        } catch (e) {
          /* ignore */
        }
      }
    }

    // Sort from newest past to oldest past
    pastList.sort((a, b) {
      // Basic sorting logic could be added here based on date/time.
      return 0;
    });

    return pastList;
  }

  void _markAsCompleted(BuildContext context, String bookingId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await BookingsFirestoreService().updateBookingStatus(
        bookingId,
        'completed',
      );
      Get.snackbar('Success', l10n.markAsCompleted);
    } catch (e) {
      Get.snackbar('Error', l10n.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final apptCtrl = Get.find<DoctorAppointmentsController>();

    return Obx(() {
      final pastAppointments = _getPastAppointments(apptCtrl);
      if (pastAppointments.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                l10n.pastAppointments,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: pastAppointments.length,
                itemBuilder: (context, index) {
                  final data = pastAppointments[index];
                  return _buildPastCard(context, data, l10n);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPastCard(
    BuildContext context,
    Map<String, dynamic> bookingData,
    AppLocalizations l10n,
  ) {
    final customerName =
        (bookingData['user'] as Map<String, dynamic>?)?['name'] as String? ??
        'Patient';
    final customerImage =
        (bookingData['user'] as Map<String, dynamic>?)?['image'] as String? ??
        '';
    final userId =
        (bookingData['user'] as Map<String, dynamic>?)?['auth_uid']
            as String? ??
        (bookingData['user'] as Map<String, dynamic>?)?['userId'] as String? ??
        '';
    final timeStr =
        (bookingData['schedule'] as Map<String, dynamic>?)?['time']
            as String? ??
        '';
    final dateStr =
        (bookingData['schedule'] as Map<String, dynamic>?)?['date']
            as String? ??
        '';
    final bookingId = bookingData['id'] as String? ?? '';

    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (customerImage.trim().isNotEmpty)
                CircleAvatar(
                  radius: 20,
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
                      radius: 20,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: fetchedImage.trim().isNotEmpty
                          ? NetworkImage(fetchedImage.trim())
                          : null,
                      child: fetchedImage.trim().isEmpty
                          ? const Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 20,
                            )
                          : null,
                    );
                  },
                )
              else
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$dateStr $timeStr',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: CommonButton(
                  onPressed: () {
                    Get.to(
                      () => ReportIssueScreen(
                        bookingId: bookingId,
                        isPatient: false,
                      ),
                    );
                  },
                  text: l10n.reportIssue,
                  type: CommonButtonType.outline,
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CommonButton(
                  onPressed: () => _markAsCompleted(context, bookingId),
                  text: l10n.markAsCompleted,
                  type: CommonButtonType.primary,
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 0,
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
