import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class DoctorAppointmentsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<DocumentSnapshot> bookings = <DocumentSnapshot>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<DateTime?> selectedTargetDate = Rx<DateTime?>(null);
  final Rx<String?> targetStatus = Rx<String?>(null);

  StreamSubscription? _bookingsSub;

  @override
  void onInit() {
    super.onInit();
    _fetchBookings();
  }

  void _fetchBookings() async {
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (authUid == null) {
      isLoading.value = false;
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Doctors') // or AppFirestoreCollections.doctors
          .where('auth_uid', isEqualTo: authUid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doctorId = snapshot.docs.first.id;
        _listenToBookings(doctorId);
      } else {
        print(
          '[DoctorAppointmentsController] No doctor profile found for auth_uid: $authUid',
        );
        isLoading.value = false;
      }
    } catch (e) {
      print('[DoctorAppointmentsController] Error resolving doctorId: $e');
      isLoading.value = false;
    }
  }

  void _listenToBookings(String doctorId) {
    print(
      '[DoctorAppointmentsController] Fetching bookings for doctor: $doctorId',
    );
    _bookingsSub = _firestore
        .collection('bookings')
        .where('doctor.doctorId', isEqualTo: doctorId)
        .snapshots()
        .listen(
          (snapshot) {
            print(
              '[DoctorAppointmentsController] Received ${snapshot.docs.length} bookings',
            );

            final sortedDocs = snapshot.docs.toList();
            sortedDocs.sort((a, b) {
              final dataA = a.data() as Map<String, dynamic>;
              final dataB = b.data() as Map<String, dynamic>;
              final dateA = (dataA['schedule']?['date'] as String?) ?? '';
              final dateB = (dataB['schedule']?['date'] as String?) ?? '';
              return dateA.compareTo(dateB);
            });

            bookings.assignAll(sortedDocs);
            isLoading.value = false;
          },
          onError: (e) {
            print('[DoctorAppointmentsController] ERROR fetching bookings: $e');
            isLoading.value = false;
          },
        );
  }

  @override
  void onClose() {
    _bookingsSub?.cancel();
    super.onClose();
  }

  void setSelectedTargetDate(DateTime? date) {
    selectedTargetDate.value = date;
  }
}
