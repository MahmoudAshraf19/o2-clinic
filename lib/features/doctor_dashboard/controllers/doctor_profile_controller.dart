import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_firestore.dart';
import '../../services_firestore/models/doctor_model.dart';

class DoctorProfileController extends GetxController {
  final isLoading = true.obs;
  final Rx<DoctorModel?> doctor = Rx<DoctorModel?>(null);
  String? _docId;

  @override
  void onInit() {
    super.onInit();
    fetchDoctorData();
  }

  Future<void> fetchDoctorData() async {
    try {
      isLoading.value = true;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        isLoading.value = false;
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection(AppFirestoreCollections.doctors)
          .where('auth_uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        _docId = doc.id;
        doctor.value = DoctorModel.fromMap(id: _docId!, map: doc.data());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      if (_docId == null) return false;

      isLoading.value = true;
      await FirebaseFirestore.instance
          .collection(AppFirestoreCollections.doctors)
          .doc(_docId)
          .update(data);

      await fetchDoctorData();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
