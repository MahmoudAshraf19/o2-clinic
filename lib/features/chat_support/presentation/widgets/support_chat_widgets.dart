import '../../../../../../common/widgets/common_text_field.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/common_avatar.dart';
import '../../../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../presentation/controllers/support_chat_controller.dart';
import '../../data/models/chat_support_model.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';

class ContactUsIntro extends StatelessWidget {
  const ContactUsIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.brandBlue.withValues(alpha: 0.1) 
            : AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
              ? AppColors.brandBlue.withValues(alpha: 0.2) 
              : AppColors.outlineVariant.withValues(alpha: .25),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.needHelpWithInquiriesComplaints,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.pureWhite 
                    : AppColors.grey800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text('📩', style: TextStyle(fontSize: 28)),
        ],
      ),
    );
  }
}

class SupportChatTile extends StatelessWidget {
  const SupportChatTile({
    super.key,
    this.title,
    this.avatar,
    this.showOnlineIndicator = true,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.onTap,
  });

  final String? title;
  final ImageProvider? avatar;
  final bool showOnlineIndicator;
  final String lastMessage;
  final String lastMessageTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.brandBlue.withValues(alpha: 0.05) 
                : AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.brandBlue.withValues(alpha: 0.15) 
                  : AppColors.outlineVariant.withValues(alpha: .25),
            ),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CommonAvatar(
                    size: 56,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    imageProvider: avatar ?? const AssetImage('assets/images/logos/logo.png'),
                  ),
                  if (showOnlineIndicator)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.green,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? AppLocalizations.of(context)!.o2Clinic,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppColors.pureWhite 
                            : AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage == '__WELCOME_MESSAGE_SHORT__'
                          ? AppLocalizations.of(context)!.welcomeToSupportShort
                          : lastMessage == '__WELCOME_MESSAGE_FULL__'
                          ? AppLocalizations.of(context)!.welcomeToSupportFull
                          : lastMessage == '__ATTACHMENT_PHOTO__'
                          ? AppLocalizations.of(context)!.photo
                          : lastMessage == '__ATTACHMENT_VIDEO__'
                          ? AppLocalizations.of(context)!.video
                          : lastMessage == '__ATTACHMENT_VOICE__'
                          ? AppLocalizations.of(context)!.voiceNote
                          : lastMessage == '__ATTACHMENT_MESSAGE__'
                          ? AppLocalizations.of(context)!.chatMessage
                          : lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppColors.pureWhite.withValues(alpha: 0.7) 
                            : AppColors.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    lastMessageTime,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? AppColors.pureWhite.withValues(alpha: 0.5) 
                          : AppColors.grey600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.grey500,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupportAuthPrompt extends StatelessWidget {
  const SupportAuthPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: .25),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.of(context)!.signInToContinue,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.pleaseLoginOrCreateAn,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: CommonButton(
                  onPressed: () => Get.toNamed(AppRoutes.login),
                  text: AppLocalizations.of(context)!.login,
                  type: CommonButtonType.outline,
                  borderColor: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  height: 50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CommonButton(
                  onPressed: () => Get.toNamed(AppRoutes.register),
                  text: AppLocalizations.of(context)!.createAccount,
                  type: CommonButtonType.primary,
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  height: 50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatComposer extends StatelessWidget {
  final dynamic controller;

  const ChatComposer({super.key, required this.controller});

  void _showAttachmentSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 16),
              _AttachmentAction(
                icon: Icons.image_rounded,
                title: AppLocalizations.of(context)!.photo,
                subtitle: AppLocalizations.of(context)!.sendAnImageFromGallery,
                onTap: () {
                  Get.back();
                  controller.pickImage();
                },
              ),
              const SizedBox(height: 10),
              _AttachmentAction(
                icon: Icons.video_collection_rounded,
                title: AppLocalizations.of(context)!.video,
                subtitle: AppLocalizations.of(context)!.sendAVideoFromGallery,
                onTap: () {
                  Get.back();
                  controller.pickVideo();
                },
              ),
              const SizedBox(height: 10),
              _AttachmentAction(
                icon: Icons.mic_rounded,
                title: AppLocalizations.of(context)!.voiceNote,
                subtitle: AppLocalizations.of(context)!.recordAndSendVoice,
                onTap: () {
                  Get.back();
                  controller.startOrStopVoiceRecording();
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.isAuthenticated) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
        child: Obx(() {
          final draft = controller.pendingAttachment.value;
          final recording = controller.isRecording.value;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.isCompressing.value)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: .2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CommonLoadingIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.compressingMedia,
                        style: TextStyle(
                          color: AppColors.grey700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              if (recording)
                _RecordingBar(
                  duration: controller.formatRecordingTime(),
                  onStop: controller.startOrStopVoiceRecording,
                  onCancel: controller.cancelPendingAttachment,
                ),
              if (draft != null) ...[
                const SizedBox(height: 10),
                _AttachmentPreview(
                  attachment: draft,
                  onRemove: controller.cancelPendingAttachment,
                ),
              ],
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CommonTextField(
                              controller: controller.textController,
                              focusNode: controller.focusNode,
                              minLines: 1,
                              maxLines: 5,
                              textInputAction: TextInputAction.newline,
                              hint: AppLocalizations.of(context)!.typeAMessage,
                              type: CommonTextFieldType.multiline,
                              showBorder: false,
                              filled: false,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.attach_file_rounded,
                              color: AppColors.colorFF64748B,
                              size: 24,
                            ),
                            onPressed: () => _showAttachmentSheet(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() {
                    final hasText = controller.currentText.value
                        .trim()
                        .isNotEmpty;
                    final hasDraft = controller.pendingAttachment.value != null;
                    final busy = controller.isSending.value;

                    final isTyping = hasText || hasDraft;

                    return GestureDetector(
                      onTap: () {
                        if (busy) return;
                        if (isTyping) {
                          controller.sendMessage();
                        } else {
                          controller.startOrStopVoiceRecording();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: busy
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: CommonLoadingIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.white,
                                ),
                              )
                            : Icon(
                                isTyping
                                    ? Icons.send_rounded
                                    : (recording
                                          ? Icons.stop_rounded
                                          : Icons.mic_rounded),
                                color: AppColors.white,
                                size: 22,
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String? agentAvatarUrl;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.agentAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (message.kind == ChatMessageKind.options) {
      return const SizedBox.shrink();
    }

    if (message.kind == ChatMessageKind.image ||
        message.kind == ChatMessageKind.video ||
        message.kind == ChatMessageKind.voice) {
      return message.isUser
          ? _UserMediaBubble(message: message)
          : _AgentMediaBubble(message: message, avatarUrl: agentAvatarUrl);
    }

    return message.isUser
        ? _UserBubble(message: message)
        : _AgentBubble(message: message, avatarUrl: agentAvatarUrl);
  }
}

class _AgentBubble extends StatelessWidget {
  final ChatMessage message;
  final String? avatarUrl;

  const _AgentBubble({required this.message, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
              ? NetworkImage(avatarUrl!) as ImageProvider
              : const AssetImage('assets/images/logos/logo.png'),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Text(
                  message.text == '__WELCOME_MESSAGE_FULL__'
                      ? AppLocalizations.of(context)!.welcomeToSupportFull
                      : message.text == '__WELCOME_MESSAGE_SHORT__'
                      ? AppLocalizations.of(context)!.welcomeToSupportShort
                      : message.text,
                  style: TextStyle(
                    height: 1.5,
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.colorFF1E293B,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.grey600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserBubble extends StatelessWidget {
  final ChatMessage message;

  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 310),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.chatUserBubble,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: AppColors.pureWhite,
                  height: 1.5,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.done_all_rounded,
                  size: 14,
                  color: AppColors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AgentMediaBubble extends StatelessWidget {
  final ChatMessage message;
  final String? avatarUrl;

  const _AgentMediaBubble({required this.message, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
              ? NetworkImage(avatarUrl!) as ImageProvider
              : const AssetImage('assets/images/logos/logo.png'),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _MediaCard(
            message: message,
            backgroundColor: AppColors.surfaceContainerHigh,
            textColor: AppColors.black87,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            isUser: false,
          ),
        ),
      ],
    );
  }
}

class _UserMediaBubble extends StatelessWidget {
  final ChatMessage message;

  const _UserMediaBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: _MediaCard(
          message: message,
          backgroundColor: AppColors.primary,
          textColor: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          isUser: true,
        ),
      ),
    );
  }
}

class _MediaCard extends StatelessWidget {
  final ChatMessage message;
  final Color backgroundColor;
  final Color textColor;
  final BorderRadius borderRadius;
  final bool isUser;

  const _MediaCard({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.borderRadius,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final attachment = message.attachment;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (message.kind == ChatMessageKind.image && attachment != null)
            _ImagePreview(url: attachment.url),
          if (message.kind == ChatMessageKind.video && attachment != null)
            _VideoPreview(url: attachment.url),
          if (message.kind == ChatMessageKind.voice && attachment != null)
            _VoicePreview(url: attachment.url),
          if (message.text.isNotEmpty) ...[
            if (attachment != null) const SizedBox(height: 10),
            Text(
              message.text,
              style: TextStyle(
                color: textColor,
                height: 1.45,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatTime(message.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: isUser ? AppColors.white70 : AppColors.grey600,
                ),
              ),
              const SizedBox(width: 4),
              if (isUser)
                const Icon(
                  Icons.done_all_rounded,
                  size: 14,
                  color: AppColors.green,
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String url;

  const _ImagePreview({required this.url});

  bool get _isNetwork => url.startsWith('http') || url.startsWith('blob:');

  @override
  Widget build(BuildContext context) {
    Widget buildImage(BoxFit fit) {
      if (_isNetwork) {
        return CachedImageWidget(
          imageUrl: url,
          fit: fit,
          errorBuilder: (_, _, _) {
            return Container(
              color: AppColors.black12,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_rounded),
            );
          },
        );
      } else {
        if (kIsWeb) {
          // Fallback if somehow it's web but not blob
          return Container(
            color: AppColors.black12,
            alignment: Alignment.center,
            child: CommonLoadingIndicator(),
          );
        }
        return Image.file(
          File(url),
          fit: fit,
          errorBuilder: (_, _, _) {
            return Container(
              color: AppColors.black12,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_rounded),
            );
          },
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 1.2,
        child: GestureDetector(
          onTap: () => Get.dialog(
            Dialog(
              insetPadding: const EdgeInsets.all(16),
              child: InteractiveViewer(child: buildImage(BoxFit.contain)),
            ),
          ),
          child: buildImage(BoxFit.cover),
        ),
      ),
    );
  }
}

class _VideoPreview extends StatelessWidget {
  final String url;

  const _VideoPreview({required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.dialog(
        Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: _VideoViewer(url: url),
        ),
      ),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.black12,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                size: 60,
                color: AppColors.white,
              ),
            ),
            Positioned(
              bottom: 10,
              left: 12,
              right: 12,
              child: Text(
                AppLocalizations.of(context)!.video,
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: .9),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoViewer extends StatefulWidget {
  final String url;

  const _VideoViewer({required this.url});

  @override
  State<_VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<_VideoViewer> {
  VideoPlayerController? _controller;
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    final bool isNetwork =
        widget.url.startsWith('http') || widget.url.startsWith('blob:');
    _controller = isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(widget.url))
        : VideoPlayerController.file(File(widget.url));
    _initFuture = _controller!.initialize().then((_) {
      _controller!.setLooping(true);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 240,
            child: Center(child: CommonLoadingIndicator()),
          );
        }

        return AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller!),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                    } else {
                      _controller!.play();
                    }
                  });
                },
                icon: Icon(
                  _controller!.value.isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  size: 64,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VoicePreview extends StatelessWidget {
  final String url;

  const _VoicePreview({required this.url});

  @override
  Widget build(BuildContext context) {
    return _VoicePlayer(url: url);
  }
}

class _VoicePlayer extends StatefulWidget {
  final String url;

  const _VoicePlayer({required this.url});

  @override
  State<_VoicePlayer> createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<_VoicePlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      final bool isNetwork =
          widget.url.startsWith('http') || widget.url.startsWith('blob:');
      if (isNetwork) {
        await _player.setUrl(widget.url);
      } else {
        await _player.setFilePath(widget.url);
      }
    } catch (e) {
      debugPrint('Voice preview error: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        bool playing = false;
        try {
          playing = (snapshot.data as dynamic)?.playing ?? false;
        } catch (e) {
          /* ignore */
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _loading
                    ? null
                    : () async {
                        if (playing) {
                          await _player.pause();
                        } else {
                          await _player.play();
                        }
                      },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white24,
                  ),
                  child: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(11),
                          child: CommonLoadingIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.white,
                          size: 28,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.voiceNote,
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AttachmentAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AttachmentAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: .2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  final PendingAttachment attachment;
  final VoidCallback onRemove;

  const _AttachmentPreview({required this.attachment, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final bool exists = !kIsWeb && File(attachment.localPath).existsSync();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: .2),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 64,
              height: 64,
              color: AppColors.surfaceContainerHigh,
              child: switch (attachment.kind) {
                ChatMessageKind.image when kIsWeb => CachedImageWidget(
                  imageUrl: attachment.localPath,
                  fit: BoxFit.cover,
                ),
                ChatMessageKind.image when exists => Image.file(
                  File(attachment.localPath),
                  fit: BoxFit.cover,
                ),
                ChatMessageKind.video => const Icon(
                  Icons.videocam_rounded,
                  size: 30,
                ),
                ChatMessageKind.voice => const Icon(
                  Icons.mic_rounded,
                  size: 30,
                ),
                _ => const Icon(Icons.insert_drive_file_rounded),
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(switch (attachment.kind) {
                  ChatMessageKind.image => 'Photo',
                  ChatMessageKind.video => 'Video',
                  ChatMessageKind.voice => 'Voice note',
                  _ => 'Attachment',
                }, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  attachment.fileName ??
                      attachment.localPath.split(Platform.pathSeparator).last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 12.5,
                  ),
                ),
                if (attachment.durationMs != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${(attachment.durationMs! / 1000).ceil()} sec',
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _RecordingBar extends StatelessWidget {
  final String duration;
  final VoidCallback onStop;
  final VoidCallback onCancel;

  const _RecordingBar({
    required this.duration,
    required this.onStop,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.red.withValues(alpha: .2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.fiber_manual_record_rounded,
            color: AppColors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.recording,
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 10),
          Text(duration, style: TextStyle(color: AppColors.grey700)),
          const Spacer(),
          CommonButton(
            onPressed: onCancel,
            text: 'Cancel',
            type: CommonButtonType.text,
          ),
          const SizedBox(width: 6),
          CommonButton(
            onPressed: onStop,
            text: 'Stop',
            type: CommonButtonType.primary,
            backgroundColor: AppColors.red,
            foregroundColor: AppColors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ],
      ),
    );
  }
}

class ChatTypingIndicator extends StatelessWidget {
  const ChatTypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundImage: AssetImage('assets/images/logos/logo.png'),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            children: [
              _Dot(),
              SizedBox(width: 4),
              _Dot(),
              SizedBox(width: 4),
              _Dot(),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.grey500,
      ),
    );
  }
}

class ChatDateDivider extends StatelessWidget {
  final String label;

  const ChatDateDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.white.withValues(alpha: 0.1) : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.white70 : AppColors.grey700,
          ),
        ),
      ),
    );
  }
}

String formatTime(DateTime time) {
  final hour = time.hour > 12
      ? time.hour - 12
      : (time.hour == 0 ? 12 : time.hour);
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}
