import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/media_compressor.dart';
import '../models/chat_support_model.dart';
import '../services/chat_support_service.dart';

class PendingAttachment {
  final ChatMessageKind kind;
  final String localPath;
  final String? fileName;
  final int? durationMs;
  final Uint8List? bytes;

  const PendingAttachment({
    required this.kind,
    required this.localPath,
    this.fileName,
    this.durationMs,
    this.bytes,
  });
}

class SupportChatController extends GetxController {
  SupportChatController(this.service);

  final SupportChatService service;

  final Rxn<User> authUser = Rxn<User>();
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxString currentText = ''.obs;
  final Rxn<PendingAttachment> pendingAttachment = Rxn<PendingAttachment>();
  final RxList<ChatMessage> uploadingItems = <ChatMessage>[].obs;
  final RxBool isCompressing = false.obs;
  final RxBool isRecording = false.obs;
  final RxInt recordingSeconds = 0.obs;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();

  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<ChatMessage>>? _messagesSub;
  Timer? _recordTimer;
  DateTime? _recordStartedAt;

  User? get user => authUser.value;
  bool get isAuthenticated => authUser.value != null;

  @override
  void onInit() {
    super.onInit();

    textController.addListener(() {
      currentText.value = textController.text;
    });

    authUser.value = FirebaseAuth.instance.currentUser;

    _authSub = FirebaseAuth.instance.authStateChanges().listen((u) async {
      authUser.value = u;

      if (u == null) {
        await _messagesSub?.cancel();
        _messagesSub = null;
        messages.clear();
        isLoading.value = false;
        pendingAttachment.value = null;
        isRecording.value = false;
        recordingSeconds.value = 0;
        _stopRecordTimer();
        return;
      }

      await _bootstrapForUser(u);
    });

    if (authUser.value != null) {
      _bootstrapForUser(authUser.value!);
    } else {
      isLoading.value = false;
    }
  }

  Future<void> _bootstrapForUser(User u) async {
    isLoading.value = true;

    await service.ensureConversation(u.uid);

    await _messagesSub?.cancel();
    _messagesSub = service.watchMessages(u.uid).listen((data) {
      messages.assignAll(data);
      isLoading.value = false;
      _scrollToBottom(false);
    });
  }

  Future<void> sendMessage() async {
    final u = user;

    if (u == null) {
      Get.toNamed(AppRoutes.login);
      return;
    }

    final text = textController.text.trim();
    final draft = pendingAttachment.value;

    if (text.isEmpty && draft == null) return;

    try {
      isSending.value = true;

      // No pending attachment logic, media sends automatically in background
      if (text.isNotEmpty) {
        service.sendUserTextMessage(uid: u.uid, text: text).catchError((e) {
          debugPrint('Error sending message: $e');
        });
        textController.clear();
        this.currentText.value = '';
        _scrollToBottom();
      }
    } finally {
      isSending.value = false;
    }
  }

  Future<void> pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null) return;
    final bytes = kIsWeb ? await file.readAsBytes() : null;

    _sendAttachmentBackground(
      PendingAttachment(
        kind: ChatMessageKind.image,
        localPath: file.path,
        fileName: file.name,
        bytes: bytes,
      ),
    );
  }

  Future<void> pickVideo() async {
    final file = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 2),
    );

    if (file == null) return;
    final bytes = kIsWeb ? await file.readAsBytes() : null;

    _sendAttachmentBackground(
      PendingAttachment(
        kind: ChatMessageKind.video,
        localPath: file.path,
        fileName: file.name,
        bytes: bytes,
      ),
    );
  }

  Future<void> startOrStopVoiceRecording() async {
    if (isRecording.value) {
      await stopVoiceRecording();
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;

    String filePath = '';
    if (!kIsWeb) {
      final tempDir = await Directory.systemTemp.createTemp('o2_support_voice');
      filePath =
          '${tempDir.path}${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}.m4a';
    }

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000),
      path: filePath,
    );

    _recordStartedAt = DateTime.now();
    isRecording.value = true;
    recordingSeconds.value = 0;
    _startRecordTimer();
  }

  Future<void> stopVoiceRecording() async {
    final path = await _recorder.stop();

    _stopRecordTimer();
    isRecording.value = false;

    if (path == null || path.isEmpty) {
      recordingSeconds.value = 0;
      return;
    }

    Uint8List? bytes;
    if (kIsWeb) {
      final xFile = XFile(path);
      bytes = await xFile.readAsBytes();
    }

    _sendAttachmentBackground(
      PendingAttachment(
        kind: ChatMessageKind.voice,
        localPath: path,
        fileName: 'voice_note.m4a',
        durationMs: recordingSeconds.value * 1000,
        bytes: bytes,
      ),
    );

    recordingSeconds.value = 0;
    _recordStartedAt = null;
  }

  Future<void> _sendAttachmentBackground(PendingAttachment draft) async {
    final u = user;
    if (u == null) return;

    final dummyMessage = ChatMessage(
      id: 'uploading_${DateTime.now().microsecondsSinceEpoch}',
      sender: ChatSender.user,
      kind: draft.kind,
      text: '',
      createdAt: DateTime.now(),
      attachment: ChatAttachment(
        url: draft.localPath,
        fileName: draft.fileName,
        durationMs: draft.durationMs,
      ),
    );

    uploadingItems.add(dummyMessage);
    _scrollToBottom();

    try {
      String finalPath = draft.localPath;
      if (draft.kind == ChatMessageKind.image) {
        finalPath =
            await MediaCompressor.compressImage(draft.localPath) ??
            draft.localPath;
      } else if (draft.kind == ChatMessageKind.video) {
        finalPath =
            await MediaCompressor.compressVideo(draft.localPath) ??
            draft.localPath;
      }

      await service.sendUserAttachmentMessage(
        uid: u.uid,
        localPath: finalPath,
        kind: draft.kind,
        fileName: draft.fileName,
        caption: null,
        durationMs: draft.durationMs,
        bytes: draft.bytes,
      );
    } catch (e) {
      debugPrint('Error sending attachment: $e');
    } finally {
      uploadingItems.remove(dummyMessage);
    }
  }

  Future<void> cancelPendingAttachment() async {
    pendingAttachment.value = null;
  }

  void _startRecordTimer() {
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_recordStartedAt == null) return;
      recordingSeconds.value = DateTime.now()
          .difference(_recordStartedAt!)
          .inSeconds
          .clamp(0, 3599);
    });
  }

  void _stopRecordTimer() {
    _recordTimer?.cancel();
    _recordTimer = null;
  }

  String formatRecordingTime() {
    final total = recordingSeconds.value;
    final minutes = (total ~/ 60).toString().padLeft(2, '0');
    final seconds = (total % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _scrollToBottom([bool animated = true]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!scrollController.hasClients) return;

        final position = 0.0;

        if (animated) {
          scrollController.animateTo(
            position,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        } else {
          scrollController.jumpTo(position);
        }
      });
    });
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _messagesSub?.cancel();
    _stopRecordTimer();
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    _recorder.dispose();
    super.onClose();
  }
}
