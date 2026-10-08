import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../presentation/controllers/chat_contact_us_controller.dart';
import '../../data/services/chat_support_service.dart';
import '../../presentation/widgets/support_chat_widgets.dart';
import 'chat_room_screen.dart';
import '../../../chat_doctors/presentation/screens/patient_chat_screen.dart';
import 'package:o2_clinic/common/models/fs_doctor_model.dart';
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
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.contactUs,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.colorFF60A5FA
                    : AppColors.primary,
                fontFamily: AppFonts.dancingScript,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.needHelpWithInquiriesComplaints ?? 'We are here to help',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.grey400
                    : AppColors.grey600,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.pureWhite
              : AppColors.primary,
        ),
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
                      nameEn: room.doctorName,
                      nameAr: room.doctorName,
                      nameHe: room.doctorName,
                      image: room.doctorProfileImage,
                      titleEn: 'Doctor',
                      titleAr: 'دكتور',
                      titleHe: 'Doctor',
                      descriptionEn: '',
                      descriptionAr: '',
                      descriptionHe: '',
                      maxBooking: 0,
                      availabilityDay: {},
                      isTopRateEnable: false,
                      theTop: false,
                      specialty: '',
                      yearsExperience: 0,
                      price: 0,
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
