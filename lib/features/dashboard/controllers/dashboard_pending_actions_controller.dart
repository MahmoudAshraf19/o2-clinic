import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../booking/data/models/fs_booking_model.dart';

class DashboardPendingActionsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<BookingModel> pendingBookings = <BookingModel>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription? _inquiriesSub;

  @override
  void onInit() {
    super.onInit();
    _startListening();
  }

  void _startListening() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    _inquiriesSub = _firestore
        .collection('radiology_price_inquiries')
        .where('uid', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) async {
          final List<String> bookingIds = [];

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final lastSender = data['lastSender'] as String?;
            final determinedPrice = (data['determinedPrice'] as num?) ?? -1;
            final inquiryStatus = data['status'] as String?;

            // If the inquiry itself is marked as confirmed, skip it
            if (inquiryStatus == 'confirmed') continue;

            if (lastSender == 'agent' || determinedPrice > 0) {
              bookingIds.add(doc.id); // doc.id is the bookingId now!
            }
          }

          if (bookingIds.isEmpty) {
            pendingBookings.clear();
            isLoading.value = false;
            return;
          }

          // Fetch the actual bookings to check their status
          final List<BookingModel> loadedBookings = [];

          // Firestore 'whereIn' is limited to 10. We chunk it.
          for (var i = 0; i < bookingIds.length; i += 10) {
            final chunk = bookingIds.sublist(
              i,
              i + 10 > bookingIds.length ? bookingIds.length : i + 10,
            );

            final bookingsSnap = await _firestore
                .collection('bookings')
                .where(FieldPath.documentId, whereIn: chunk)
                .get();

            for (var bDoc in bookingsSnap.docs) {
              final bData = bDoc.data();
              final status = (bData['status']?['current'] as String?)
                  ?.toLowerCase();

              if (status == 'pending_price' || status == 'pending') {
                loadedBookings.add(
                  BookingModel.fromMap(id: bDoc.id, map: bData),
                );
              }
            }
          }

          pendingBookings.assignAll(loadedBookings);
          isLoading.value = false;
        });
  }

  @override
  void onClose() {
    _inquiriesSub?.cancel();
    super.onClose();
  }
}
