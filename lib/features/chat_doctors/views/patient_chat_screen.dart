import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../chat_support/widgets/support_chat_widgets.dart'; // Reuse composer and bubbles
import '../../doctors/models/doctor_model.dart';
import '../../all_doctors/presentation/pages/doctor_profile_page.dart';
import '../../services_firestore/models/doctor_model.dart' as fs_doctor;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/patient_chat_controller.dart';
import '../services/doctor_chat_service.dart';

class PatientChatScreen extends StatelessWidget {
  final DoctorModel doctor;

  const PatientChatScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      PatientChatController(DoctorChatService(), doctor),
      tag: doctor.id,
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
              const Center(child: CircularProgressIndicator()),
              barrierDismissible: false,
            );
            try {
              final doc = await FirebaseFirestore.instance
                  .collection('Doctors')
                  .doc(doctor.id)
                  .get();
              Get.back();
              if (doc.exists && doc.data() != null) {
                final fsDoctor = fs_doctor.DoctorModel.fromMap(
                  id: doc.id,
                  map: doc.data() as Map<String, dynamic>,
                );
                Get.to(() => DoctorProfilePage(doctor: fsDoctor));
              }
            } catch (e) {
              Get.back();
            }
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundImage: NetworkImage(doctor.image),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    doctor.title,
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
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.messages.isEmpty &&
                    controller.uploadingItems.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _getWelcomeMessage(context, doctor.name),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: controller.scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                  reverse:
                      true, // we assume messages are newest first like SupportChat
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
                                  controller.patientId,
                                ),
                                agentAvatarUrl: doctor.image,
                              ),
                              const Positioned(
                                right: 20,
                                bottom: 20,
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
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
                          message: msg.toChatMessage(controller.patientId),
                          agentAvatarUrl: doctor.image,
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

  String _getWelcomeMessage(BuildContext context, String doctorName) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'ar') {
      return "أهلاً بك، دكتور $doctorName يرحب بك. اترك رسالة وسيقوم بالرد عليك فوراً.";
    } else if (lang == 'he') {
      return "ברוך הבא, ד\"ר $doctorName מקדם אותך בברכה. השאר הודעה והוא יענה לך מיד.";
    } else {
      return "Welcome, Dr. $doctorName welcomes you. Leave a message and they will reply to you immediately.";
    }
  }
}
