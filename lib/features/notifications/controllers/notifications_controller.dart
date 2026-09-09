import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../common/controllers/global_auth_controller.dart';
import '../models/notification_model.dart';
import '../services/notifications_firestore_service.dart';

class NotificationsController extends GetxController {
  final NotificationsFirestoreService _service = NotificationsFirestoreService();
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<GlobalAuthController>();
    ever(auth.currentUserData, (_) {
      _listenToNotifications(FirebaseAuth.instance.currentUser?.uid);
    });
    _listenToNotifications(FirebaseAuth.instance.currentUser?.uid);
  }

  void _listenToNotifications(String? uid) {
    _sub?.cancel();
    if (uid != null && uid.isNotEmpty) {
      _sub = _service.watchUserNotifications(uid).listen((data) {
        final seenBookingIds = <String>{};
        final deduplicated = <NotificationModel>[];
        
        for (final n in data) {
          if (n.type == 'booking' || n.type == 'booking_confirmation') {
            final bookingId = n.data['bookingId']?.toString();
            if (bookingId != null && bookingId.isNotEmpty) {
              if (seenBookingIds.contains(bookingId)) {
                continue; // Skip duplicate
              }
              seenBookingIds.add(bookingId);
            }
          }
          deduplicated.add(n);
        }
        
        notifications.value = deduplicated;
      });
    } else {
      notifications.clear();
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get latestFive => notifications.take(5).toList();

  void markAsRead(String id) {
    _service.markAsRead(id);
  }

  void markAllAsRead() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _service.markAllAsRead(uid);
    }
  }

  // Helper for UI grouping
  List<NotificationModel> get newNotifications =>
      notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get todayNotifications {
    final now = DateTime.now();
    return notifications.where((n) {
      if (!n.isRead) return false;
      return n.createdAt.year == now.year &&
          n.createdAt.month == now.month &&
          n.createdAt.day == now.day;
    }).toList();
  }

  List<NotificationModel> get yesterdayNotifications {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return notifications.where((n) {
      if (!n.isRead) return false;
      return n.createdAt.year == yesterday.year &&
          n.createdAt.month == yesterday.month &&
          n.createdAt.day == yesterday.day;
    }).toList();
  }

  List<NotificationModel> get earlierNotifications {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final startOfYesterday =
        DateTime(yesterday.year, yesterday.month, yesterday.day);
    return notifications.where((n) {
      if (!n.isRead) return false;
      return n.createdAt.isBefore(startOfYesterday);
    }).toList();
  }
}
