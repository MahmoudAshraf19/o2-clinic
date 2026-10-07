import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../chat_doctors/controllers/doctor_chats_list_controller.dart';
import '../../chat_doctors/services/doctor_chat_service.dart';
import '../../chat_doctors/views/doctor_active_chat_screen.dart';
import '../../chat_support/screens/chat_room_screen.dart';
import '../../chat_support/widgets/support_chat_widgets.dart';

class DoctorChatsScreen extends StatelessWidget {
  const DoctorChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorChatsListController(DoctorChatService()));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: AppColors.transparent,
        title: Text(
          AppLocalizations.of(context)!.doctorChats,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.separated(
              itemCount: controller.chatRooms.length + 2,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const ContactUsIntro();
                }
                if (index == 1) {
                  return _buildSupportChatTile(context);
                }

                final room = controller.chatRooms[index - 2];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(room.customerId)
                      .get(),
                  builder: (context, snapshot) {
                    String displayName = room.customerName.isNotEmpty
                        ? room.customerName
                        : 'Patient';
                    String displayImage = room.customerProfileImage;

                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      if (data != null) {
                        if (data['name'] != null &&
                            data['name'].toString().isNotEmpty) {
                          displayName = data['name'].toString();
                        }
                        if (data['image'] != null &&
                            data['image'].toString().isNotEmpty) {
                          displayImage = data['image'].toString();
                        }
                      }
                    }

                    return SupportChatTile(
                      title: displayName,
                      avatar: displayImage.isNotEmpty
                          ? NetworkImage(displayImage)
                          : null,
                      showOnlineIndicator: false,
                      lastMessage: room.displayLastMessage,
                      lastMessageTime: _formatTime(room.updatedAt),
                      onTap: () {
                        Get.to(() => DoctorActiveChatScreen(room: room));
                      },
                    );
                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSupportChatTile(BuildContext context) {
    return SupportChatTile(
      lastMessage: AppLocalizations.of(context)!.welcomeToSupportShort,
      lastMessageTime: _formatTime(DateTime.now()),
      showOnlineIndicator: true,
      onTap: () {
        Get.to(() => const ChatRoomScreen());
      },
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
