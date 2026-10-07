import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_firestore.dart';

class DoctorNavigationController extends GetxController {
  final currentIndex = 0.obs;
  final doctorData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    _fetchDoctorData();
  }

  void _fetchDoctorData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance
          .collection(AppFirestoreCollections.doctors)
          .where('auth_uid', isEqualTo: uid)
          .limit(1)
          .snapshots()
          .listen((snapshot) {
            if (snapshot.docs.isNotEmpty) {
              doctorData.value = snapshot.docs.first.data();
            }
          });
    }
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
