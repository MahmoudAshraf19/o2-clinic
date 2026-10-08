class DashboardProfileModel {
  final String uid; // Firestore doc id
  final String username; // display id shown in UI
  final String name;
  final String email;

  /// Display-friendly phone value.
  /// Example: "+20 01150125129"
  final String phone;

  /// Raw nested values for flexible UI/details if needed.
  final String phoneCountryCode;
  final String phoneNumber;
  final String phoneFullNumber;

  final String gender;

  /// Display-friendly value.
  /// Example: "General Checkup • October 12, 2023"
  final String lastVisit;

  /// Raw nested values from the nested map.
  final String? lastVisitType;
  final String? lastVisitDate;

  final String image;
  final String status;
  final bool isBlocked;

  final String bio;
  final String address;
  final String provider;

  const DashboardProfileModel({
    this.uid = '',
    this.username = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.phoneCountryCode = '',
    this.phoneNumber = '',
    this.phoneFullNumber = '',
    this.gender = '',
    this.lastVisit = '',
    this.lastVisitType,
    this.lastVisitDate,
    this.image = '',
    this.status = 'active',
    this.isBlocked = false,
    this.bio = '',
    this.address = '',
    this.provider = '',
  });

  /// Keep old UI code working:
  /// - `user.id` now shows username, not uid.
  String get id => username.isNotEmpty ? username : uid;

  bool get hasImage => image.trim().isNotEmpty;

  bool get hasLastVisit =>
      lastVisit.trim().isNotEmpty && lastVisit != 'No recent visit';

  static DashboardProfileModel empty([String uid = '']) {
    return DashboardProfileModel(uid: uid);
  }

  static String _s(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  static String _firstNonEmpty(Iterable<String> values) {
    for (final item in values) {
      final v = item.trim();
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  factory DashboardProfileModel.fromMap(
    String uid,
    Map<String, dynamic>? data,
  ) {
    final map = data ?? const <String, dynamic>{};

    final username = _firstNonEmpty([_s(map['username']), _s(map['id'])]);

    final phoneMap = _asMap(map['phone']);
    final contactMap = _asMap(map['contact']);
    final authMap = _asMap(map['auth']);
    final lastVisitMap = _asMap(map['lastVisit']);

    final phoneCountryCode = _firstNonEmpty([
      _s(phoneMap['country_code']),
      _s(contactMap['country_code']),
    ]);

    final phoneNumber = _firstNonEmpty([
      _s(phoneMap['number']),
      _s(contactMap['number']),
    ]);

    final phoneFullNumber = _firstNonEmpty([
      _s(phoneMap['full_phone']),
      _s(contactMap['phone']),
      _s(map['phone']),
    ]);

    final phoneDisplay = _firstNonEmpty([
      phoneFullNumber,
      (phoneCountryCode.isNotEmpty && phoneNumber.isNotEmpty)
          ? '$phoneCountryCode $phoneNumber'
          : '',
      _s(map['phone']),
    ]);

    final rawLastVisitType = _s(lastVisitMap['type']);
    final rawLastVisitDate = _s(lastVisitMap['date']);

    final lastVisitDisplay = _firstNonEmpty([
      (rawLastVisitType.isNotEmpty && rawLastVisitDate.isNotEmpty)
          ? '$rawLastVisitType • $rawLastVisitDate'
          : '',
      rawLastVisitDate,
      rawLastVisitType,
      'No recent visit',
    ]);

    return DashboardProfileModel(
      uid: uid,
      username: username,
      name: _firstNonEmpty([_s(map['name'])]),
      email: _firstNonEmpty([_s(map['email']), _s(contactMap['email'])]),
      phone: phoneDisplay,
      phoneCountryCode: phoneCountryCode,
      phoneNumber: phoneNumber,
      phoneFullNumber: phoneFullNumber,
      gender: _firstNonEmpty([_s(map['gender'])]),
      lastVisit: lastVisitDisplay,
      lastVisitType: rawLastVisitType.isEmpty ? null : rawLastVisitType,
      lastVisitDate: rawLastVisitDate.isEmpty ? null : rawLastVisitDate,
      image: _firstNonEmpty([_s(map['image'])]),
      status: _firstNonEmpty([_s(map['status']), 'active']),
      isBlocked: map['isBlocked'] == true,
      bio: _firstNonEmpty([_s(map['bio'])]),
      address: _firstNonEmpty([_s(map['address']), _s(contactMap['address'])]),
      provider: _firstNonEmpty([_s(authMap['provider']), _s(map['provider'])]),
    );
  }

  DashboardProfileModel copyWith({
    String? uid,
    String? username,
    String? name,
    String? email,
    String? phone,
    String? phoneCountryCode,
    String? phoneNumber,
    String? phoneFullNumber,
    String? gender,
    String? lastVisit,
    String? lastVisitType,
    String? lastVisitDate,
    String? image,
    String? status,
    bool? isBlocked,
    String? bio,
    String? address,
    String? provider,
  }) {
    return DashboardProfileModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneCountryCode: phoneCountryCode ?? this.phoneCountryCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneFullNumber: phoneFullNumber ?? this.phoneFullNumber,
      gender: gender ?? this.gender,
      lastVisit: lastVisit ?? this.lastVisit,
      lastVisitType: lastVisitType ?? this.lastVisitType,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      image: image ?? this.image,
      status: status ?? this.status,
      isBlocked: isBlocked ?? this.isBlocked,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      provider: provider ?? this.provider,
    );
  }
}
