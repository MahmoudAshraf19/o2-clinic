import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Model Imports
import '../../features/chat_support/models/chat_support_model.dart';
import '../../features/dashboard/models/dashboard_appointment_model.dart';
import '../../features/doctors/models/doctor_model.dart';
import '../../features/onboarding/models/onboarding_slide_model.dart';
import '../../features/profile/models/dashboard_profile_model.dart';
import '../../features/services/models/category_model.dart';
import '../../features/services/models/cosmetic_model.dart';
import '../../features/services/models/radiology_service_model.dart';
import '../../features/services/models/service_model.dart';
import '../constants/app_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Singleton instance
  static final FirestoreService instance = FirestoreService._internal();
  FirestoreService._internal();
  factory FirestoreService() => instance;

  /// Saves or updates the user profile data.
  Future<void> saveUserProfile(DashboardProfileModel user) async {
    await _db.collection(AppFirestoreCollections.users).doc(user.id).set({
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'gender': user.gender,
      'lastVisit': user.lastVisit,
      'lastVisitType': user.lastVisitType,
      'image': user.image,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Streams the user profile for real-time updates.
  Stream<DashboardProfileModel?> watchUserProfile(String uid) {
    return _db
        .collection(AppFirestoreCollections.users)
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          final data = doc.data()!;
          return DashboardProfileModel.fromMap(doc.id, data);
        });
  }

  /// Updates specific fields in the user document.
  Future<void> updateUserFields(String uid, Map<String, dynamic> data) async {
    await _db.collection(AppFirestoreCollections.users).doc(uid).update(data);
  }

  /// Streams the list of all doctors.
  Stream<List<DoctorModel>> watchDoctors() {
    return _db
        .collection(AppFirestoreCollections.doctors)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _mapDoctor(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Retrieves doctors marked as top-rated.
  Future<List<DoctorModel>> getTopRatedDoctors() async {
    final query = await _db
        .collection(AppFirestoreCollections.doctors)
        .where('isTopRated', isEqualTo: true)
        .limit(10)
        .get();
    return query.docs.map((doc) => _mapDoctor(doc.data(), doc.id)).toList();
  }

  DoctorModel _mapDoctor(Map<String, dynamic> data, String id) {
    return DoctorModel(
      name: data['name'] ?? '',
      title: data['title'] ?? '',
      image: data['image'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviews: data['reviews'] ?? 0,
      availability: data['availability'] ?? '',
      booked: data['booked'] ?? 0,
      total: data['total'] ?? 0,
      isTopRated: data['isTopRated'] ?? false,
      isMostBooked: data['isMostBooked'] ?? false,
      location: data['location'],
      about: data['about'],
      experience: data['experience'],
      specializations: (data['specializations'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      credentials: (data['credentials'] as List?)?.map((e) {
        final iconName = e['icon_name'] ?? 'school';
        IconData iconData;
        switch (iconName) {
          case 'school':
            iconData = Icons.school;
            break;
          case 'verified':
            iconData = Icons.verified;
            break;
          default:
            iconData = Icons.school;
        }
        return Credential(
          title: e['title'] ?? '',
          institution: e['institution'] ?? '',
          icon: iconData,
        );
      }).toList(),
    );
  }

  Stream<List<ServiceModel>> watchServices() {
    return _db
        .collection(AppFirestoreCollections.services)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _mapService(doc.data(), doc.id))
              .toList(),
        );
  }

  ServiceModel _mapService(Map<String, dynamic> data, String id) {
    return ServiceModel(
      id: id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      image: data['image'] ?? '',
      doctorsCount: data['doctorsCount'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Stream<List<RadiologyServiceModel>> watchRadiologyServices() {
    const collectionName = "radiology_category";

    print("📡 [Firestore] Listening to: /$collectionName");

    return _db.collection(collectionName).snapshots().map((snapshot) {
      print("📦 [Firestore] Radiology docs received: ${snapshot.docs.length}");

      final List<RadiologyServiceModel> items = snapshot.docs.map((doc) {
        final id = doc.id; // ct / x_ray / ultrasound
        final data = doc.data();

        final count = _safeMapCount(data);

        final title = _prettyRadiologyTitle(id);
        final desc = "Choose from $count available options in $title.";
        final specialists = _prettyRadiologySubtitle(id, count);
        final badge = "Available • $count options";
        final badgeIcon = _radiologyBadgeIcon(id);

        final image = _radiologyDefaultImage(id);

        return RadiologyServiceModel(
          title: title,
          desc: desc,
          image: image,
          specialists: specialists,
          buttonText: "Book Now",
          badge: badge,
          badgeIcon: badgeIcon,
          isSecondary: false,
          price: 0.0,
        );
      }).toList();

      items.sort(
        (a, b) => _radiologyOrder(a.title).compareTo(_radiologyOrder(b.title)),
      );

      print("✅ [Firestore] Radiology services mapped: ${items.length}");
      return items;
    });
  }

  int _safeMapCount(Map<String, dynamic>? data) {
    if (data == null) return 0;
    return data.keys.length;
  }

  String _prettyRadiologyTitle(String id) {
    switch (id) {
      case 'ct':
        return 'CT Scan';
      case 'x_ray':
        return 'X-Ray';
      case 'ultrasound':
        return 'Ultrasound';
      default:
        return id;
    }
  }

  String _prettyRadiologySubtitle(String id, int count) {
    switch (id) {
      case 'ct':
        return "$count scan areas & categories";
      case 'x_ray':
        return "$count imaging categories";
      case 'ultrasound':
        return "$count ultrasound types";
      default:
        return "$count items";
    }
  }

  IconData _radiologyBadgeIcon(String id) {
    switch (id) {
      case 'ct':
        return Icons.biotech;
      case 'x_ray':
        return Icons.medical_services;
      case 'ultrasound':
        return Icons.health_and_safety;
      default:
        return Icons.medical_services;
    }
  }

  int _radiologyOrder(String title) {
    if (title.toLowerCase().contains('ct')) return 0;
    if (title.toLowerCase().contains('x-ray')) return 1;
    if (title.toLowerCase().contains('ultrasound')) return 2;
    return 99;
  }

  String _radiologyDefaultImage(String id) {
    switch (id) {
      case 'ct':
        return "https://images.unsplash.com/photo-1581595219315-a187dd40c322?auto=format&fit=crop&w=800&q=60";
      case 'x_ray':
        return "https://images.unsplash.com/photo-1582719478185-2bbd3a2a3aa0?auto=format&fit=crop&w=800&q=60";
      case 'ultrasound':
        return "https://images.unsplash.com/photo-1580281657527-47f249e8f3b1?auto=format&fit=crop&w=800&q=60";
      default:
        return "https://images.unsplash.com/photo-1580281657527-47f249e8f3b1?auto=format&fit=crop&w=800&q=60";
    }
  }


  IconData _mapBadgeIcon(String? iconName) {
    switch (iconName) {
      case 'biotech':
        return Icons.biotech;
      case 'health_and_safety':
        return Icons.health_and_safety;
      default:
        return Icons.medical_services;
    }
  }

  /// Streams cosmetic services.
  Stream<List<CosmeticModel>> watchCosmeticServices() {
    return _db
        .collection(AppFirestoreCollections.cosmeticServices)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _mapCosmeticService(doc.data(), doc.id))
              .toList(),
        );
  }

  CosmeticModel _mapCosmeticService(Map<String, dynamic> data, String id) {
    return CosmeticModel(
      id: id,
      titleEn: data['title_en'] ?? data['title'] ?? '',
      titleAr: data['title_ar'] ?? data['title'] ?? '',
      image: data['image'] ?? '',
      itemsEn:
          (data['descriptions_en'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          (data['items'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      itemsAr:
          (data['descriptions_ar'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          (data['items'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      buttonTextEn:
          data['buttonText_en'] ?? data['buttonText'] ?? 'View Services',
      buttonTextAr:
          data['buttonText_ar'] ?? data['buttonText'] ?? 'عرض الخدمات',
      price: (data['price'] ?? 0.0).toDouble(),
      isActive: data['isActive'] ?? true,
    );
  }

  /// Streams categories.
  Stream<List<CategoryModel>> watchCategories() {
    return _db
        .collection(AppFirestoreCollections.categories)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _mapCategory(doc.data(), doc.id))
              .toList(),
        );
  }

  CategoryModel _mapCategory(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      color: data['color'] ?? 'FF000000',
      serviceCount: data['serviceCount'] ?? 0,
    );
  }

  Future<String> bookAppointment(
    DashboardAppointmentModel appointment,
    String userId,
  ) async {
    final docRef = _db.collection(AppFirestoreCollections.bookings).doc();
    final data = {
      'id': docRef.id,
      'userId': userId,
      'doctorName': appointment.doctorName,
      'doctorSpecialty': appointment.doctorSpecialty,
      'doctorImageUrl': appointment.doctorImageUrl,
      'label': appointment.label,
      'time': appointment.time,
      'location': appointment.location,
      'status': 'upcoming',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await Future.wait([
      docRef.set(data),
      _db
          .collection(AppFirestoreCollections.users)
          .doc(userId)
          .collection(AppFirestoreCollections.bookings)
          .doc(docRef.id)
          .set(data),
    ]);

    return docRef.id;
  }

  Future<void> bookImagingService({
    required String userId,
    required String imagingType,
    required DateTime date,
    required String time,
    required String bookingId,
  }) async {
    final data = {
      'id': bookingId,
      'userId': userId,
      'type': 'imaging',
      'imagingType': imagingType,
      'appointmentDate': Timestamp.fromDate(date),
      'appointmentTime': time,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await Future.wait([
      _db.collection(AppFirestoreCollections.bookings).doc(bookingId).set(data),
      _db
          .collection(AppFirestoreCollections.users)
          .doc(userId)
          .collection(AppFirestoreCollections.bookings)
          .doc(bookingId)
          .set(data),
    ]);
  }

  Stream<List<DashboardAppointmentModel>> watchUserAppointments(String userId) {
    return _db
        .collection(AppFirestoreCollections.users)
        .doc(userId)
        .collection(AppFirestoreCollections.bookings)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return DashboardAppointmentModel(
              id: doc.id,
              doctorName:
                  data['doctorName'] ??
                  (data['imagingType'] ?? 'Medical Service'),
              doctorSpecialty: data['doctorSpecialty'] ?? 'Specialist',
              doctorImageUrl: data['doctorImageUrl'] ?? '',
              label: data['label'] ?? 'Confirmed',
              time: data['time'] ?? data['appointmentTime']?.toString() ?? '',
              location: data['location'] ?? 'O2 Clinic',
              date: data['date'],
              amount: (data['amount'] ?? 0.0).toDouble(),
              paymentStatus: data['paymentStatus'],
              type: data['type'],
            );
          }).toList();
        });
  }

  /// ✅ ROOT notifications collection
  /// Reads notifications from: /notifications
  /// Filters by userId so the app sees reminders created by Cloud Functions.
  Stream<List<Map<String, dynamic>>> watchNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  /// ✅ Mark root notification as read
  Future<void> markNotificationRead(
    String userId,
    String notificationId,
  ) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'status.read': true,
        'status.readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Stream<List<ChatMessage>> watchChatMessages(String userId) {
    return _db
        .collection(AppFirestoreCollections.chatRooms)
        .doc(userId)
        .collection(AppFirestoreCollections.messages)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return ChatMessage(
              id: doc.id,
              sender: data['sender'] == 'user'
                  ? ChatSender.user
                  : ChatSender.agent,
              kind: _mapMessageKind(data['kind']),
              text: data['text'] ?? '',
              createdAt:
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList();
        });
  }

  ChatMessageKind _mapMessageKind(String? kind) {
    switch (kind) {
      case 'options':
        return ChatMessageKind.options;
      case 'typing':
        return ChatMessageKind.typing;
      default:
        return ChatMessageKind.text;
    }
  }

  Future<void> sendChatMessage(String userId, String text) async {
    final batch = _db.batch();

    final messageRef = _db
        .collection(AppFirestoreCollections.chatRooms)
        .doc(userId)
        .collection(AppFirestoreCollections.messages)
        .doc();

    batch.set(messageRef, {
      'text': text,
      'sender': 'user',
      'kind': 'text',
      'createdAt': FieldValue.serverTimestamp(),
    });

    final roomRef = _db
        .collection(AppFirestoreCollections.chatRooms)
        .doc(userId);
    batch.set(roomRef, {
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'userId': userId,
    }, SetOptions(merge: true));

    await batch.commit();
  }

  Future<List<DoctorModel>> getDoctorsBySpecialty(String specialty) async {
    final query = await _db
        .collection(AppFirestoreCollections.doctors)
        .where('specializations', arrayContains: specialty)
        .get();
    return query.docs.map((doc) => _mapDoctor(doc.data(), doc.id)).toList();
  }

  Stream<List<Map<String, dynamic>>> watchBanners() {
    return _db
        .collection(AppFirestoreCollections.banners)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<OnboardingSlideModel>> watchOnboardingSlides() {
    return _db
        .collection(AppFirestoreCollections.onboardingSlides)
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OnboardingSlideModel.fromDoc(doc))
              .toList(),
        );
  }

  List<RadiologyServiceModel>? _radiologyCache;
  DateTime? _radiologyCacheAt;

  Future<List<RadiologyServiceModel>> fetchRadiologyServices({
    bool forceRefresh = false,
    Duration ttl = const Duration(minutes: 10),
  }) async {
    const collectionName = "radiology_category";

    final now = DateTime.now();
    final cacheValid =
        _radiologyCache != null &&
        _radiologyCacheAt != null &&
        now.difference(_radiologyCacheAt!) < ttl;

    if (!forceRefresh && cacheValid) {
      debugPrint(
        "⚡ [Firestore] Radiology CACHE HIT (${_radiologyCache!.length})",
      );
      return _radiologyCache!;
    }

    debugPrint("🌐 [Firestore] Radiology FETCH (cheap one-time read)");

    final docs = await Future.wait([
      _db
          .collection(collectionName)
          .doc('ct')
          .get(const GetOptions(source: Source.serverAndCache)),
      _db
          .collection(collectionName)
          .doc('x_ray')
          .get(const GetOptions(source: Source.serverAndCache)),
      _db
          .collection(collectionName)
          .doc('ultrasound')
          .get(const GetOptions(source: Source.serverAndCache)),
    ]);

    RadiologyServiceModel mapDoc(String id, Map<String, dynamic>? data) {
      final count = (data?.keys.length ?? 0);

      final title = _prettyRadiologyTitle(id);
      final desc = "Choose from $count available options in $title.";
      final specialists = _prettyRadiologySubtitle(id, count);
      final badge = "Available • $count options";
      final badgeIcon = _radiologyBadgeIcon(id);

      final image = _radiologyDefaultImage(id);

      return RadiologyServiceModel(
        title: title,
        desc: desc,
        image: image,
        specialists: specialists,
        buttonText: "Book Now",
        badge: badge,
        badgeIcon: badgeIcon,
        isSecondary: false,
        price: 0.0,
      );
    }

    final result = <RadiologyServiceModel>[];

    for (final d in docs) {
      final id = d.id;
      final data = d.data();
      result.add(mapDoc(id, data));
    }

    result.sort(
      (a, b) => _radiologyOrder(a.title).compareTo(_radiologyOrder(b.title)),
    );

    _radiologyCache = result;
    _radiologyCacheAt = now;

    debugPrint("✅ [Firestore] Radiology FETCH DONE (${result.length})");
    return result;
  }

  void clearRadiologyCache() {
    _radiologyCache = null;
    _radiologyCacheAt = null;
    debugPrint("🧹 [Firestore] Radiology cache cleared");
  }

  List<CosmeticModel>? _cosmeticCache;
  DateTime? _cosmeticCacheAt;

  Future<List<CosmeticModel>> fetchCosmeticTreatments({
    bool forceRefresh = false,
    Duration ttl = const Duration(minutes: 10),
  }) async {
    const collectionName = "cosmetic";

    final now = DateTime.now();
    final cacheValid =
        _cosmeticCache != null &&
        _cosmeticCacheAt != null &&
        now.difference(_cosmeticCacheAt!) < ttl;

    if (!forceRefresh && cacheValid) {
      debugPrint(
        "⚡ [Firestore] Cosmetic CACHE HIT (${_cosmeticCache!.length})",
      );
      return _cosmeticCache!;
    }

    debugPrint("🌐 [Firestore] Cosmetic FETCH");

    final query = await _db
        .collection(collectionName)
        .get(const GetOptions(source: Source.serverAndCache));

    final result = query.docs.map((doc) {
      final data = doc.data();
      return CosmeticModel(
        id: doc.id,
        titleEn: data['title_en'] ?? data['title'] ?? '',
        titleAr: data['title_ar'] ?? data['title'] ?? '',
        image: data['image'] ?? '',
        itemsEn:
            (data['descriptions_en'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            (data['items'] as List?)?.map((e) => e.toString()).toList() ??
            [],
        itemsAr:
            (data['descriptions_ar'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            (data['items'] as List?)?.map((e) => e.toString()).toList() ??
            [],
        buttonTextEn:
            data['buttonText_en'] ?? data['buttonText'] ?? 'View Services',
        buttonTextAr:
            data['buttonText_ar'] ?? data['buttonText'] ?? 'عرض الخدمات',
        price: (data['price'] ?? 0.0).toDouble(),
        isActive: data['isActive'] ?? true,
        availabilityDay: (() {
          final dynamic rawMap = data['availability_day'];
          if (rawMap == null) return <String, String>{};
          if (rawMap is Map) {
            return rawMap.map<String, String>(
              (key, value) => MapEntry(key.toString(), value.toString()),
            );
          }
          return <String, String>{};
        })(),
      );
    }).toList();

    _cosmeticCache = result;
    _cosmeticCacheAt = now;

    debugPrint("✅ [Firestore] Cosmetic FETCH DONE (${result.length})");
    return result;
  }
}
