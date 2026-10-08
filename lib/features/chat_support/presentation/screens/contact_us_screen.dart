import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../presentation/controllers/contact_us_controller.dart';
import '../../data/services/chat_support_service.dart';
import '../../presentation/widgets/support_chat_widgets.dart';
import 'chat_room_screen.dart';
import '../../../chat_doctors/presentation/screens/patient_chat_screen.dart';
import '../../../doctors/data/models/doctor_model.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ChatContactUsController(SupportChatService.instance),
      permanent: false,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: AppColors.transparent,
        title: Text(
          AppLocalizations.of(context)!.contactUs,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CommonLoadingIndicator());
            }

            final summary = controller.summary.value;

            return ListView.separated(
              itemCount: controller.doctorChatRooms.length + 2,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const ContactUsIntro();
                }
                if (index == 1) {
                  return SupportChatTile(
                    lastMessage:
                        summary?.lastMessage ??
                        AppLocalizations.of(context)!.tapToStartChat,
                    lastMessageTime: summary?.lastMessageAt == null
                        ? '--:--'
                        : formatTime(summary!.lastMessageAt!),
                    onTap: () {
                      Get.to(
                        () => const ChatRoomScreen(),
                        transition: Transition.rightToLeft,
                      );
                    },
                  );
                }

                final room = controller.doctorChatRooms[index - 2];
                return SupportChatTile(
                  title: room.doctorName,
                  avatar: NetworkImage(room.doctorProfileImage),
                  showOnlineIndicator: false,
                  lastMessage: room.displayLastMessage,
                  lastMessageTime: formatTime(room.updatedAt),
                  onTap: () {
                    final dummyDoctor = DoctorModel(
                      id: room.doctorId,
                      name: room.doctorName,
                      image: room.doctorProfileImage,
                      title: 'Doctor', // fallback
                      rating: 0,
                      reviews: 0,
                      availability: '',
                      booked: 0,
                      total: 0,
                    );
                    Get.to(() => PatientChatScreen(doctor: dummyDoctor));
                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
