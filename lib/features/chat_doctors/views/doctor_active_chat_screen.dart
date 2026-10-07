import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../chat_support/widgets/support_chat_widgets.dart';
import '../../chat_doctors/models/doctor_chat_model.dart';
import '../../chat_doctors/controllers/doctor_chat_controller.dart';
import '../../chat_doctors/services/doctor_chat_service.dart';
import '../../profile/models/dashboard_profile_model.dart';
import '../../doctor_dashboard/presentation/screens/patient_profile_screen.dart';
import '../../auth/data/services/user_firestore_service.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';
import 'package:o2_clinic/common/widgets/common_empty_state.dart';

class DoctorActiveChatScreen extends StatelessWidget {
  final DoctorChatRoom room;

  const DoctorActiveChatScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    // Unique tag so if multiple chats open, controllers don't conflict
    final controller = Get.put(
      DoctorChatController(DoctorChatService(), room),
      tag: room.id,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () async {
            Get.dialog(
              const Center(child: CommonLoadingIndicator()),
              barrierDismissible: false,
            );
            try {
              final data = await UserFirestoreService.instance.getUser(
                room.customerId,
              );
              Get.back();
              if (data != null) {
                // Since we don't have doc id here directly without another fetch,
                // we can pass the uid, as fromMap uses it for uid field
                final patient = DashboardProfileModel.fromMap(
                  room.customerId,
                  data,
                );
                Get.to(() => PatientProfileScreen(patient: patient));
              }
            } catch (e) {
              Get.back();
            }
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(room.customerProfileImage),
                radius: 19,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.customerName,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Patient',
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CommonLoadingIndicator());
                }

                if (controller.messages.isEmpty &&
                    controller.uploadingItems.isEmpty) {
                  return const CommonEmptyState(title: "No messages yet.");
                }

                return ListView.builder(
                  controller: controller.scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                  reverse: true,
                  itemCount:
                      controller.messages.length +
                      1 +
                      controller.uploadingItems.length,
                  itemBuilder: (context, index) {
                    final uploadingCount = controller.uploadingItems.length;
                    final messagesCount = controller.messages.length;

                    if (index < uploadingCount) {
                      final draftMsg =
                          controller.uploadingItems[uploadingCount - 1 - index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Opacity(
                          opacity: 0.6,
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              ChatMessageBubble(
                                message: draftMsg.toChatMessage(
                                  controller.doctorId,
                                ),
                              ),
                              const Positioned(
                                right: 20,
                                bottom: 20,
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CommonLoadingIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final msgIndex = index - uploadingCount;
                    if (msgIndex < messagesCount) {
                      final msg =
                          controller.messages[messagesCount - 1 - msgIndex];
                      return Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: ChatMessageBubble(
                          message: msg.toChatMessage(controller.doctorId),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18, top: 18),
                      child: ChatDateDivider(
                        label: AppLocalizations.of(context)!.today,
                      ),
                    );
                  },
                );
              }),
            ),
            ChatComposer(controller: controller),
          ],
        ),
      ),
    );
  }
}
