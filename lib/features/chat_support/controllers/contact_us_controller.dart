import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/chat_support_model.dart';
import '../services/chat_support_service.dart';
import '../../chat_doctors/models/doctor_chat_model.dart';
import '../../chat_doctors/services/doctor_chat_service.dart';

class ChatContactUsController extends GetxController {
  ChatContactUsController(this.service);

  final SupportChatService service;
  final DoctorChatService doctorChatService = DoctorChatService();

  final Rx<SupportConversationSummary?> summary =
      Rx<SupportConversationSummary?>(null);
  final RxList<DoctorChatRoom> doctorChatRooms = <DoctorChatRoom>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<SupportConversationSummary>? _sub;
  StreamSubscription<List<DoctorChatRoom>>? _doctorSub;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      summary.value = const SupportConversationSummary(
        uid: '',
        title: 'O2 Clinic',
        avatarPath: 'assets/images/logos/logo.png',
        lastMessage: '',
        lastMessageKind: 'text',
        lastMessageAt: null,
      );
      isLoading.value = false;
      return;
    }

    await service.ensureConversation(user.uid);

    _sub = service.watchSummary(user.uid).listen((value) {
      summary.value = value;
      isLoading.value = false;
    });

    _doctorSub = doctorChatService.watchPatientChatRooms(user.uid).listen((
      rooms,
    ) {
      doctorChatRooms.assignAll(rooms);
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    _doctorSub?.cancel();
    super.onClose();
  }
}
