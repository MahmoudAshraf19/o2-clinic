import '../../../auth/data/services/user_firestore_service.dart';
import '../models/dashboard_profile_model.dart';

class DashboardProfileService {
  DashboardProfileService({UserFirestoreService? userFirestoreService})
    : _userFirestoreService =
          userFirestoreService ?? UserFirestoreService.instance;

  final UserFirestoreService _userFirestoreService;

  DashboardProfileModel? _cachedProfile;
  Map<String, dynamic>? _cachedRawProfile;
  String? _cachedUid;
  DateTime? _cachedAt;

  Future<DashboardProfileModel?> getProfile({
    required String uid,
    bool forceRefresh = false,
    Duration ttl = const Duration(minutes: 10),
  }) async {
    final now = DateTime.now();
    final cacheValid =
        _cachedProfile != null &&
        _cachedUid == uid &&
        _cachedAt != null &&
        now.difference(_cachedAt!) < ttl;

    if (!forceRefresh && cacheValid) {
      return _cachedProfile;
    }

    try {
      final data = await _userFirestoreService.getUser(
        uid,
        forceRefresh: forceRefresh,
      );

      if (data == null) {
        _cacheNull(uid, now);
        return DashboardProfileModel.empty(uid);
      }

      _cachedRawProfile = Map<String, dynamic>.from(data);
      _cachedProfile = DashboardProfileModel.fromMap(uid, _cachedRawProfile);
      _cachedUid = uid;
      _cachedAt = now;
      return _cachedProfile;
    } catch (_) {
      // If Firestore fails, return last valid cache when available.
      if (_cachedProfile != null && _cachedUid == uid) {
        return _cachedProfile;
      }

      _cacheNull(uid, now);
      return DashboardProfileModel.empty(uid);
    }
  }

  Stream<DashboardProfileModel?> watchProfile(String uid) {
    return _userFirestoreService.streamUser(uid).map((data) {
      if (data == null) return null;

      final profile = DashboardProfileModel.fromMap(uid, data);
      _cachedRawProfile = Map<String, dynamic>.from(data);
      _cachedProfile = profile;
      _cachedUid = uid;
      _cachedAt = DateTime.now();
      return profile;
    });
  }

  Future<void> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _userFirestoreService.updateUser(uid: uid, data: data);

    final merged = <String, dynamic>{};
    if (_cachedRawProfile != null) {
      merged.addAll(_cachedRawProfile!);
    }
    merged.addAll(data);

    _cachedRawProfile = merged;
    _cachedProfile = DashboardProfileModel.fromMap(uid, merged);
    _cachedUid = uid;
    _cachedAt = DateTime.now();
  }

  void clearCache() {
    _cachedProfile = null;
    _cachedRawProfile = null;
    _cachedUid = null;
    _cachedAt = null;
  }

  void _cacheNull(String uid, DateTime now) {
    _cachedProfile = DashboardProfileModel.empty(uid);
    _cachedRawProfile = null;
    _cachedUid = uid;
    _cachedAt = now;
  }
}
