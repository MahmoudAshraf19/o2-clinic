import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_firestore.dart';
import '../models/doctor_chat_model.dart';
import '../services/doctor_chat_service.dart';

class DoctorChatsListController extends GetxController {
  final DoctorChatService service;
  
  DoctorChatsListController(this.service);

  final RxList<DoctorChatRoom> chatRooms = <DoctorChatRoom>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<List<DoctorChatRoom>>? _roomsSub;
  StreamSubscription<User?>? _authSub;

  @override
  void onInit() {
    super.onInit();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _resolveDoctorIdAndBootstrap(user.uid);
      } else {
        _roomsSub?.cancel();
        chatRooms.clear();
        isLoading.value = false;
      }
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _resolveDoctorIdAndBootstrap(currentUser.uid);
    } else {
      isLoading.value = false;
    }
  }

  Future<void> _resolveDoctorIdAndBootstrap(String authUid) async {
    isLoading.value = true;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(AppFirestoreCollections.doctors)
          .where('auth_uid', isEqualTo: authUid)
          .limit(1)
          .get();
          
      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        _bootstrap(docId);
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
    }
  }

  void _bootstrap(String doctorId) {
    isLoading.value = true;
    _roomsSub?.cancel();
    _roomsSub = service.watchDoctorChatRooms(doctorId).listen((rooms) {
      chatRooms.assignAll(rooms);
      isLoading.value = false;
    });
  }

  @override
  void onClose() {
    _roomsSub?.cancel();
    _authSub?.cancel();
    super.onClose();
  }
}
