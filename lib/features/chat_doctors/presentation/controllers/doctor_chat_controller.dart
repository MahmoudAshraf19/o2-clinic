import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

import '../../../../core/utils/media_compressor.dart';
import '../../../chat_support/controllers/support_chat_controller.dart'
    show PendingAttachment;
import '../../../chat_support/models/chat_support_model.dart';
import '../../data/models/doctor_chat_model.dart';
import '../../data/services/doctor_chat_service.dart';

class DoctorChatController extends GetxController {
  final DoctorChatService service;
  final DoctorChatRoom room;

  DoctorChatController(this.service, this.room);

  final RxList<DoctorChatMessage> messages = <DoctorChatMessage>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxString currentText = ''.obs;
  final Rxn<PendingAttachment> pendingAttachment = Rxn<PendingAttachment>();
  final RxList<DoctorChatMessage> uploadingItems = <DoctorChatMessage>[].obs;
  final RxBool isCompressing = false.obs;
  final RxBool isRecording = false.obs;
  final RxInt recordingSeconds = 0.obs;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();

  StreamSubscription<List<DoctorChatMessage>>? _messagesSub;
  Timer? _recordTimer;
  DateTime? _recordStartedAt;
  bool get isAuthenticated => true;

  String get doctorId => room.doctorId;
  String get roomId => room.id;
  String get patientId => room.customerId;

  @override
  void onInit() {
    super.onInit();
    textController.addListener(() {
      currentText.value = textController.text;
    });
    _bootstrap();
  }

  void _bootstrap() {
    isLoading.value = true;
    _messagesSub = service.watchMessages(roomId).listen((data) {
      messages.assignAll(data);
      isLoading.value = false;
      _scrollToBottom(false);
    });
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    final draft = pendingAttachment.value;

    if (text.isEmpty && draft == null) return;

    try {
      isSending.value = true;

      final patientName = room.customerName;
      final patientProfileImage = room.customerProfileImage;
      final doctorName = room.doctorName;
      final doctorProfileImage = room.doctorProfileImage;

      // No pending attachment logic, media sends automatically in background
      if (text.isNotEmpty) {
        service
            .sendTextMessage(
              patientId: patientId,
              patientName: patientName,
              patientProfileImage: patientProfileImage,
              doctorId: doctorId,
              doctorName: doctorName,
              doctorProfileImage: doctorProfileImage,
              senderId: doctorId,
              receiverId: patientId,
              text: text,
              senderNameForNotification: doctorName,
              screenForNotification: 'doctor_chat_patient',
            )
            .catchError((e) {
              debugPrint('Error sending message: $e');
            });
        textController.clear();
        currentText.value = '';
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
      final tempDir = await Directory.systemTemp.createTemp('o2_doctor_voice');
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
    final patientName = room.customerName;
    final patientProfileImage = room.customerProfileImage;
    final doctorName = room.doctorName;
    final doctorProfileImage = room.doctorProfileImage;

    final dummyMessage = DoctorChatMessage(
      id: 'uploading_${DateTime.now().microsecondsSinceEpoch}',
      message: '',
      kind: draft.kind,
      receiverId: patientId,
      senderId: doctorId,
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

      await service.sendAttachmentMessage(
        patientId: patientId,
        patientName: patientName,
        patientProfileImage: patientProfileImage,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorProfileImage: doctorProfileImage,
        senderId: doctorId,
        receiverId: patientId,
        localPath: finalPath,
        kind: draft.kind,
        fileName: draft.fileName,
        caption: null,
        durationMs: draft.durationMs,
        bytes: draft.bytes,
        senderNameForNotification: doctorName,
        screenForNotification: 'doctor_chat_patient',
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
    _messagesSub?.cancel();
    _stopRecordTimer();
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    _recorder.dispose();
    super.onClose();
  }
}
