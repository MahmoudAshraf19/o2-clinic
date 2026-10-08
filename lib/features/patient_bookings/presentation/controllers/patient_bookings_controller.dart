import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class PatientBookingsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<DocumentSnapshot> bookings = <DocumentSnapshot>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription? _bookingsSub;

  @override
  void onInit() {
    super.onInit();
    _fetchBookings();
  }

  void _fetchBookings() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      isLoading.value = false;
      return;
    }

    _bookingsSub = _firestore
        .collection('bookings')
        .where('user.userId', isEqualTo: userId)
        .snapshots()
        .listen(
          (snapshot) {
            final sortedDocs = snapshot.docs.toList();
            sortedDocs.sort((a, b) {
              final dataA = a.data();
              final dataB = b.data();
              final dateA = (dataA['schedule']?['date'] as String?) ?? '';
              final dateB = (dataB['schedule']?['date'] as String?) ?? '';
              return dateA.compareTo(dateB); // Ascending order
            });

            bookings.assignAll(sortedDocs);
            isLoading.value = false;
          },
          onError: (e) {
            isLoading.value = false;
          },
        );
  }

  @override
  void onClose() {
    _bookingsSub?.cancel();
    super.onClose();
  }
}
