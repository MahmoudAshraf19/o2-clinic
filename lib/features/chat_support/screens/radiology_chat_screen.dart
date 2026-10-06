import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/radiology_chat_controller.dart';
import '../services/radiology_chat_service.dart';
import '../widgets/support_chat_widgets.dart';
import '../models/chat_support_model.dart';

class RadiologyChatScreen extends StatefulWidget {
  final String bookingId;
  final String serviceName;

  const RadiologyChatScreen({
    super.key,
    required this.bookingId,
    required this.serviceName,
  });

  @override
  State<RadiologyChatScreen> createState() => _RadiologyChatScreenState();
}

class _RadiologyChatScreenState extends State<RadiologyChatScreen> {
  late RadiologyChatController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      RadiologyChatController(RadiologyChatService.instance, widget.bookingId),
      tag: widget.bookingId,
    );
  }

  @override
  void dispose() {
    Get.delete<RadiologyChatController>(tag: widget.bookingId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 19,
              backgroundImage: AssetImage('assets/images/logos/logo.png'),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.serviceName.isNotEmpty
                      ? widget.serviceName
                      : 'Radiology Pricing',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Obx(() {
                  final online = controller.isAuthenticated;

                  return Text(
                    online
                        ? AppLocalizations.of(context)!.onlineSupport
                        : AppLocalizations.of(context)!.loginRequired,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Obx(() {
              if (controller.isAuthenticated) {
                return const SizedBox.shrink();
              }
              return const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: SupportAuthPrompt(),
              );
            }),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!controller.isAuthenticated) {
                  return const SizedBox.shrink();
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
                  itemBuilder: (_, index) {
                    final uploadingCount = controller.uploadingItems.length;
                    final messagesCount = controller.messages.length;

                    if (index < uploadingCount) {
                      final message =
                          controller.uploadingItems[uploadingCount - 1 - index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Opacity(
                          opacity: 0.6,
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              ChatMessageBubble(message: message),
                              const Positioned(
                                right: 20,
                                bottom: 20,
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
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
                      final message =
                          controller.messages[messagesCount - 1 - msgIndex];

                      return Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: ChatMessageBubble(message: message),
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
            Obx(() {
              if (!controller.isAuthenticated) {
                return const SizedBox.shrink();
              }
              // We need to use the generic ChatComposer for our radiology chat.
              // We'll need a slight tweak if ChatComposer strongly expects SupportChatController.
              // Let's create a copy or pass it a generic interface if it breaks.
              // Since dart is statically typed, passing RadiologyChatController to ChatComposer will throw an error if it strictly expects SupportChatController.
              return ChatComposer(controller: controller);
            }),
          ],
        ),
      ),
    );
  }
}
