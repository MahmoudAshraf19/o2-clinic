import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'dart:convert';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notification_router.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  Map<String, dynamic>? pendingInitialNotification;

  // ─── Stable ID generation from bookingId ─────────────────────────────────
  // djb2-inspired hash -> positive 31-bit int.
  // 12h reminder = even, 3h reminder = odd (avoids ID collisions).
  static int _stableId(String bookingId, {bool is12h = true}) {
    int hash = 5381;
    for (final c in bookingId.codeUnits) {
      hash = ((hash << 5) + hash + c) & 0x7FFFFFFF;
    }
    return is12h ? (hash & 0x7FFFFFFE) : (hash | 1) & 0x7FFFFFFF;
  }

  /// ================= INIT =================
  Future<void> init() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();
    await _requestPermission();
    await _initLocalNotifications();
    await _listenForegroundMessages();
    _handleBackgroundTap();
    await _checkInitialMessage();
  }

  /// ================= PERMISSION =================
  Future<void> _requestPermission() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
  }

  /// ================= TOKEN =================
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null && details.payload!.isNotEmpty) {
          try {
            final data = json.decode(details.payload!);
            NotificationRouter.handleNotificationTap(data);
          } catch (e) {
            debugPrint('Failed to parse local notification payload: $e');
            NotificationRouter.handleNotificationTap({});
          }
        } else {
          NotificationRouter.handleNotificationTap({});
        }
      },
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      const mainChannel = AndroidNotificationChannel(
        'custom_sound_channel_1',
        'Main Notifications',
        description: 'Notifications with custom sounds',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification'),
      );

      const reminderChannel = AndroidNotificationChannel(
        'reminder_channel',
        'Appointment Reminders',
        description: 'Local reminders for upcoming appointments',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification'),
        enableVibration: true,
      );

      await androidPlugin?.createNotificationChannel(mainChannel);
      await androidPlugin?.createNotificationChannel(reminderChannel);
    }
  }

  // ─── Show immediate notification ─────────────────────────────────────────
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'custom_sound_channel_1',
      'Main Notifications',
      channelDescription: 'Notifications with custom sounds',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
      styleInformation: BigTextStyleInformation(body),
      icon: '@drawable/ic_notification',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification.mp3',
    );

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  // ─── Reminder notification details ───────────────────────────────────────
  static const _reminderAndroid = AndroidNotificationDetails(
    'reminder_channel',
    'Appointment Reminders',
    channelDescription: 'Local reminders for upcoming appointments',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification'),
    icon: '@drawable/ic_notification',
  );

  static const _reminderIos = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    sound: 'notification.mp3',
  );

  static const _reminderDetails = NotificationDetails(
    android: _reminderAndroid,
    iOS: _reminderIos,
  );

  // ─── Localised reminder strings ───────────────────────────────────────────
  static Map<String, String> _reminderStrings(String langCode) {
    switch (langCode) {
      case 'ar':
        return {
          'title12h':
              '\u062a\u0630\u0643\u064a\u0631 \u0628\u0627\u0644\u0645\u0648\u0639\u062f \ud83d\udcc5',
          'body12h':
              '\u0645\u0648\u0639\u062f\u0643 \u063a\u062f\u0627\u064b. \u0644\u0627 \u062a\u0646\u0633\u064e \u0627\u0644\u062d\u0636\u0648\u0631 \u0641\u064a \u0627\u0644\u0648\u0642\u062a \u0627\u0644\u0645\u062d\u062f\u062f.',
          'title3h':
              '\u0645\u0648\u0639\u062f\u0643 \u0642\u0631\u064a\u0628 \u23f0',
          'body3h':
              '\u0645\u0648\u0639\u062f\u0643 \u062e\u0644\u0627\u0644 3 \u0633\u0627\u0639\u0627\u062a. \u0628\u0631\u062c\u0627\u0621 \u0627\u0644\u0627\u0633\u062a\u0639\u062f\u0627\u062f.',
        };
      case 'he':
        return {
          'title12h':
              '\u05ea\u05d6\u05db\u05d5\u05e8\u05ea \u05ea\u05d5\u05e8 \ud83d\udcc5',
          'body12h':
              '\u05d4\u05ea\u05d5\u05e8 \u05e9\u05dc\u05da \u05de\u05d7\u05e8. \u05d0\u05dc \u05ea\u05e9\u05db\u05d7 \u05dc\u05d4\u05d2\u05d9\u05e2 \u05d1\u05d6\u05de\u05df.',
          'title3h': '\u05ea\u05d5\u05e8 \u05e7\u05e8\u05d5\u05d1 \u23f0',
          'body3h':
              '\u05d4\u05ea\u05d5\u05e8 \u05e9\u05dc\u05da \u05d1\u05e2\u05d5\u05d3 3 \u05e9\u05e2\u05d5\u05ea. \u05d0\u05e0\u05d0 \u05d4\u05ea\u05db\u05d5\u05e0\u05df.',
        };
      default: // 'en'
        return {
          'title12h': 'Appointment Reminder \ud83d\udcc5',
          'body12h':
              "Your appointment is tomorrow. Don't forget to attend on time.",
          'title3h': 'Upcoming Appointment \u23f0',
          'body3h': 'Your appointment is in 3 hours. Please be ready.',
        };
    }
  }

  /// ── Schedule both 12h and 3h reminders for a booking ─────────────────────
  ///
  /// • Works **offline** once scheduled on device.
  /// • Idempotent — same bookingId always produces same device notification IDs.
  /// • If [userId] is provided, also saves to Firestore so the reminder appears
  ///   in the notifications screen and AppBar dropdown for all 3 languages.
  Future<void> scheduleAppointmentReminders({
    required String bookingId,
    required DateTime appointmentDate,
    required String langCode,
    String? userId,
  }) async {
    if (kIsWeb) return;

    final now = DateTime.now();
    final strings = _reminderStrings(langCode);

    // 12-hour reminder
    final time12h = appointmentDate.subtract(const Duration(hours: 12));
    if (time12h.isAfter(now)) {
      try {
        await _local.zonedSchedule(
          _stableId(bookingId, is12h: true),
          strings['title12h']!,
          strings['body12h']!,
          tz.TZDateTime.from(time12h, tz.local),
          _reminderDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: json.encode({
            'bookingId': bookingId,
            'screen': 'booking_details',
          }),
        );
        debugPrint('12h reminder scheduled for $bookingId at $time12h');
      } catch (e) {
        debugPrint('Could not schedule 12h reminder: $e');
      }
    }

    // 3-hour reminder
    final time3h = appointmentDate.subtract(const Duration(hours: 3));
    if (time3h.isAfter(now)) {
      try {
        await _local.zonedSchedule(
          _stableId(bookingId, is12h: false),
          strings['title3h']!,
          strings['body3h']!,
          tz.TZDateTime.from(time3h, tz.local),
          _reminderDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: json.encode({
            'bookingId': bookingId,
            'screen': 'booking_details',
          }),
        );
        debugPrint('3h reminder scheduled for $bookingId at $time3h');
      } catch (e) {
        debugPrint('Could not schedule 3h reminder: $e');
      }
    }

    // Note: We no longer save local reminders to Firestore to prevent duplicates.
    // The Cloud Functions (sendAppointmentReminders) will generate the push
    // notifications 12h/24h before the appointment which will appear in the UI.
  }

  /// ── Schedule 30-minute reminder for Doctor (Online Consultation) ─────────────
  Future<void> scheduleDoctorOnlineReminder({
    required String bookingId,
    required DateTime appointmentDate,
    required String langCode,
  }) async {
    if (kIsWeb) return;

    final now = DateTime.now();
    final time30m = appointmentDate.subtract(const Duration(minutes: 30));

    if (time30m.isAfter(now)) {
      final title = langCode == 'ar'
          ? 'موعد استشارة أونلاين قريب ⏱️'
          : 'Upcoming Online Consultation ⏱️';
      final body = langCode == 'ar'
          ? 'تذكير: موعد الكشف الأونلاين يبدأ بعد 30 دقيقة.'
          : 'Reminder: Your online consultation starts in 30 minutes.';

      try {
        await _local.zonedSchedule(
          _stableId(bookingId, is12h: false) +
              1000, // Avoid collision with patient's 3h reminder
          title,
          body,
          tz.TZDateTime.from(time30m, tz.local),
          _reminderDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: json.encode({
            'bookingId': bookingId,
            'screen': 'booking_details',
          }),
        );
        debugPrint(
          'Doctor 30m online reminder scheduled for $bookingId at $time30m',
        );
      } catch (e) {
        debugPrint('Could not schedule doctor 30m online reminder: $e');
      }
    }
  }

  /// ── Cancel all reminders for a booking (cancelled / completed) ────────────
  Future<void> cancelAppointmentReminders(String bookingId) async {
    if (kIsWeb) return;
    try {
      await _local.cancel(_stableId(bookingId, is12h: true));
      await _local.cancel(_stableId(bookingId, is12h: false));
      debugPrint('Reminders cancelled for booking $bookingId');
    } catch (e) {
      debugPrint('Could not cancel reminders for $bookingId: $e');
    }
  }

  /// Saves a reminder document to Firestore (idempotent — one per booking).
  /// All 3 language titles/bodies are stored so the UI shows the correct text.
  Future<void> _saveReminderToFirestore({
    required String userId,
    required String bookingId,
    required DateTime appointmentDate,
  }) async {
    try {
      final docId = 'reminder_$bookingId';
      // Skip if already exists (idempotent)
      final existing = await _firestore
          .collection('notifications')
          .doc(docId)
          .get();
      if (existing.exists) return;

      await _firestore.collection('notifications').doc(docId).set({
        'id': docId,
        'userId': userId,
        'type': 'reminder',
        'title': {
          'en': 'Appointment Reminder \ud83d\udcc5',
          'ar':
              '\u062a\u0630\u0643\u064a\u0631 \u0628\u0627\u0644\u0645\u0648\u0639\u062f \ud83d\udcc5',
          'he':
              '\u05ea\u05d6\u05db\u05d5\u05e8\u05ea \u05ea\u05d5\u05e8 \ud83d\udcc5',
        },
        'body': {
          'en':
              'You have an upcoming appointment. Local reminders are set on your device.',
          'ar':
              '\u0644\u062f\u064a\u0643 \u0645\u0648\u0639\u062f \u0642\u0627\u062f\u0645. \u062a\u0645 \u062a\u0639\u064a\u064a\u0646 \u0627\u0644\u062a\u0630\u0643\u064a\u0631\u0627\u062a \u0639\u0644\u0649 \u062c\u0647\u0627\u0632\u0643.',
          'he':
              '\u05d9\u05e9 \u05dc\u05da \u05ea\u05d5\u05e8 \u05e7\u05e8\u05d5\u05d1. \u05d4\u05ea\u05d6\u05db\u05d5\u05e8\u05d5\u05ea \u05d4\u05de\u05e7\u05d5\u05de\u05d9\u05d5\u05ea \u05d4\u05d5\u05d2\u05d3\u05e8\u05d5 \u05d1\u05de\u05db\u05e9\u05d9\u05e8 \u05e9\u05dc\u05da.',
        },
        'data': {'bookingId': bookingId, 'screen': 'booking_details'},
        'priority': 'high',
        'status': {'read': false, 'readAt': null},
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Reminder saved to Firestore: $docId');
    } catch (e) {
      debugPrint('Could not save reminder to Firestore: $e');
    }
  }

  /// ── Legacy single-reminder helper (kept for backward compatibility) ───────
  Future<void> scheduleLocalReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (kIsWeb) return;

    final reminderTime = scheduledDate.subtract(const Duration(hours: 3));
    if (reminderTime.isAfter(DateTime.now())) {
      await _local.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(reminderTime, tz.local),
        _reminderDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    }
  }

  /// ================= SAVE TO FIRESTORE =================
  /// Saves the notification to Firestore (also triggers Cloud Function FCM push).
  Future<void> saveNotification({
    required String userId,
    required String type,
    required Map<String, String> title,
    required Map<String, String> body,
    Map<String, dynamic>? data,
    String priority = 'high',
    Map<String, dynamic>? schedule,
  }) async {
    try {
      final docRef = _firestore.collection('notifications').doc();

      final Map<String, dynamic> notificationData = {
        'id': docRef.id,
        'userId': userId,
        'type': type,
        'title': title,
        'body': body,
        'data': data ?? {},
        'sound': 'notification.mp3',
        'priority': priority,
        'status': {'read': false, 'readAt': null},
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (schedule != null) {
        notificationData['schedule'] = schedule;
      }

      await docRef.set(notificationData);
    } catch (e) {
      debugPrint('Error saving notification: $e');
    }
  }

  /// Helper to send booking notification (all 3 languages)
  Future<void> sendBookingNotification({
    required String userId,
    required String bookingId,
    required String screen,
    bool isReminder = false,
  }) async {
    await saveNotification(
      userId: userId,
      type: isReminder ? 'reminder' : 'booking',
      title: {
        'en': isReminder
            ? 'Upcoming Appointment \u23f0'
            : 'Booking Confirmed \u2705',
        'ar': isReminder
            ? '\u0645\u0648\u0639\u062f\u0643 \u0642\u0631\u064a\u0628 \u23f0'
            : '\u062a\u0645 \u062a\u0623\u0643\u064a\u062f \u0627\u0644\u062d\u062c\u0632 \u2705',
        'he': isReminder
            ? '\u05ea\u05d5\u05e8 \u05e7\u05e8\u05d5\u05d1 \u23f0'
            : '\u05d4\u05d6\u05de\u05e0\u05ea\u05da \u05d0\u05d5\u05e9\u05e8\u05d4 \u2705',
      },
      body: {
        'en': isReminder
            ? 'Your appointment is in 3 hours. Please be ready.'
            : 'Your appointment has been successfully booked.',
        'ar': isReminder
            ? '\u0645\u0648\u0639\u062f\u0643 \u062e\u0644\u0627\u0644 3 \u0633\u0627\u0639\u0627\u062a. \u0628\u0631\u062c\u0627\u0621 \u0627\u0644\u0627\u0633\u062a\u0639\u062f\u0627\u062f.'
            : '\u062a\u0645 \u062d\u062c\u0632 \u0645\u0648\u0639\u062f\u0643 \u0628\u0646\u062c\u0627\u062d.',
        'he': isReminder
            ? '\u05d4\u05ea\u05d5\u05e8 \u05e9\u05dc\u05da \u05d1\u05e2\u05d5\u05d3 3 \u05e9\u05e2\u05d5\u05ea. \u05d0\u05e0\u05d0 \u05d4\u05ea\u05db\u05d5\u05e0\u05df.'
            : '\u05d4\u05ea\u05d5\u05e8 \u05e9\u05dc\u05da \u05e0\u05e7\u05d1\u05e2 \u05d1\u05d4\u05e6\u05dc\u05d7\u05d4.',
      },
      data: {'bookingId': bookingId, 'screen': screen},
    );
  }

  /// Helper to send payment notification (all 3 languages)
  Future<void> sendPaymentNotification({
    required String userId,
    required String bookingId,
    required bool success,
  }) async {
    await saveNotification(
      userId: userId,
      type: 'payment',
      title: {
        'en': success
            ? 'Payment Successful \ud83d\udcb3'
            : 'Payment Failed \u274c',
        'ar': success
            ? '\u062a\u0645 \u0627\u0644\u062f\u0641\u0639 \u0628\u0646\u062c\u0627\u062d \ud83d\udcb3'
            : '\u0641\u0634\u0644 \u0627\u0644\u062f\u0641\u0639 \u274c',
        'he': success
            ? '\u05ea\u05e9\u05dc\u05d5\u05dd \u05e0\u05e7\u05dc\u05d8 \ud83d\udcb3'
            : '\u05d4\u05ea\u05e9\u05dc\u05d5\u05dd \u05e0\u05db\u05e9\u05dc \u274c',
      },
      body: {
        'en': success
            ? 'Your payment has been completed successfully.'
            : "We couldn't process your payment. Please try again.",
        'ar': success
            ? '\u062a\u0645\u062a \u0639\u0645\u0644\u064a\u0629 \u0627\u0644\u062f\u0641\u0639 \u0628\u0646\u062c\u0627\u062d.'
            : '\u0644\u0645 \u0646\u062a\u0645\u0643\u0646 \u0645\u0646 \u0645\u0639\u0627\u0644\u062c\u0629 \u0627\u0644\u062f\u0641\u0639. \u062d\u0627\u0648\u0644 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649.',
        'he': success
            ? '\u05d4\u05ea\u05e9\u05dc\u05d5\u05dd \u05d4\u05d5\u05e9\u05dc\u05dd \u05d1\u05d4\u05e6\u05dc\u05d7\u05d4.'
            : '\u05dc\u05d0 \u05d9\u05db\u05dc\u05e0\u05d5 \u05dc\u05e2\u05d1\u05d3 \u05d0\u05ea \u05d4\u05ea\u05e9\u05dc\u05d5\u05dd. \u05e0\u05d0 \u05e0\u05e1\u05d4 \u05e9\u05e0\u05d9\u05ea.',
      },
      data: {
        'bookingId': bookingId,
        'screen': success ? 'receipt' : 'payment_retry',
      },
    );
  }

  /// Helper to send chat message notification (all 3 languages)
  Future<void> sendChatMessageNotification({
    required String userId,
    required String chatRoomId,
    required String messageId,
    String? senderName,
    String? doctorId,
    String screen = 'chat',
  }) async {
    final sender = senderName ?? 'O2 Clinic';
    await saveNotification(
      userId: userId,
      type: 'message',
      title: {
        'en': 'New Message \ud83d\udcac',
        'ar':
            '\u0631\u0633\u0627\u0644\u0629 \u062c\u062f\u064a\u062f\u0629 \ud83d\udcac',
        'he':
            '\u05d4\u05d5\u05d3\u05e2\u05d4 \u05d7\u05d3\u05e9\u05d4 \ud83d\udcac',
      },
      body: {
        'en': 'You have a new message from $sender.',
        'ar':
            '\u0644\u062f\u064a\u0643 \u0631\u0633\u0627\u0644\u0629 \u062c\u062f\u064a\u062f\u0629 \u0645\u0646 $sender.',
        'he':
            '\u05d9\u05e9 \u05dc\u05da \u05d4\u05d5\u05d3\u05e2\u05d4 \u05d7\u05d3\u05e9\u05d4 \u05de\u05d0\u05ea $sender.',
      },
      data: {
        'chatRoomId': chatRoomId,
        'messageId': messageId,
        'screen': screen,
        if (doctorId != null) 'doctorId': doctorId,
      },
      priority: 'normal',
    );
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'status.read': true,
        'status.readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// ================= FOREGROUND FCM =================
  Future<void> _listenForegroundMessages() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final data = message.data;

      final langCode = Get.locale?.languageCode ?? 'en';
      String title = notification?.title ?? '';
      String body = notification?.body ?? '';

      if (data.containsKey('title_$langCode') &&
          data['title_$langCode']!.isNotEmpty) {
        title = data['title_$langCode']!;
      }
      if (data.containsKey('body_$langCode') &&
          data['body_$langCode']!.isNotEmpty) {
        body = data['body_$langCode']!;
      }

      if (title.isNotEmpty || body.isNotEmpty) {
        showNotification(title: title, body: body, payload: json.encode(data));
      }
    });
  }

  void _handleBackgroundTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      NotificationRouter.handleNotificationTap(message.data);
    });
  }

  Future<void> _checkInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      pendingInitialNotification = initialMessage.data;
    }
  }
}
