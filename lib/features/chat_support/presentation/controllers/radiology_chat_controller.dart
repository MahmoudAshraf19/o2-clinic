import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

import '../../../../core/routes/app_routes.dart';
import '../../data/models/chat_support_model.dart';
import '../../data/services/radiology_chat_service.dart';

class RadiologyPendingAttachment {
  final ChatMessageKind kind;
  final String localPath;
  final String? fileName;
  final int? durationMs;
  final Uint8List? bytes;

  const RadiologyPendingAttachment({
    required this.kind,
    required this.localPath,
    this.fileName,
    this.durationMs,
    this.bytes,
  });
}

class RadiologyChatController extends GetxController {
  RadiologyChatController(this.service, this.bookingId);

  final RadiologyChatService service;
  final String bookingId;

  final Rxn<User> authUser = Rxn<User>();
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxString currentText = ''.obs;
  final Rxn<RadiologyPendingAttachment> pendingAttachment =
      Rxn<RadiologyPendingAttachment>();
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

  @override
  void onClose() {
    _authSub?.cancel();
    _messagesSub?.cancel();
    _stopRecordTimer();
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  Future<void> _bootstrapForUser(User u) async {
    isLoading.value = true;
    await service.ensureConversation(
      u.uid,
      bookingId,
      'Radiology Pricing',
    ); // Can't easily get service name here, passing fallback

    await _messagesSub?.cancel();
    _messagesSub = service.watchMessages(bookingId).listen((data) {
      messages.assignAll(data);
      isLoading.value = false;
      _scrollToBottom(false);
    });
  }

  void _scrollToBottom([bool animated = true]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      if (animated) {
        scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(0.0);
      }
    });
  }

  Future<void> sendMessage() async {
    final u = user;
    if (u == null) {
      Get.toNamed(AppRoutes.login);
      return;
    }

    final text = textController.text.trim();
    if (text.isEmpty) return;

    try {
      isSending.value = true;
      service
          .sendUserTextMessage(uid: u.uid, bookingId: bookingId, text: text)
          .catchError((e) {
            debugPrint('Error sending message: $e');
          });
      textController.clear();
      currentText.value = '';
      _scrollToBottom();
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
      RadiologyPendingAttachment(
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
      RadiologyPendingAttachment(
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
      final tempDir = await Directory.systemTemp.createTemp(
        'o2_radiology_voice',
      );
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
      RadiologyPendingAttachment(
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

  void _startRecordTimer() {
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_recordStartedAt == null) return;
      recordingSeconds.value = DateTime.now()
          .difference(_recordStartedAt!)
          .inSeconds;
    });
  }

  void _stopRecordTimer() {
    _recordTimer?.cancel();
    _recordTimer = null;
  }

  Future<void> _sendAttachmentBackground(
    RadiologyPendingAttachment draft,
  ) async {
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
      await service.sendUserAttachmentMessage(
        uid: u.uid,
        bookingId: bookingId,
        localPath: draft.localPath,
        kind: draft.kind,
        fileName: draft.fileName,
        durationMs: draft.durationMs,
        bytes: draft.bytes,
      );
    } catch (e) {
      debugPrint('Error uploading radiology attachment: $e');
    } finally {
      uploadingItems.remove(dummyMessage);
    }
  }
}
