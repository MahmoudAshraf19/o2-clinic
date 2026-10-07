class BannerModel {
  final String id;
  final String type;
  final String? url;
  final String? doctorId;
  final Map<String, String> badge;
  final Map<String, String> buttonText;
  final Map<String, String> buttonAction;
  final bool hasButton;
  final String imageUrl;
  final bool isActive;
  final int order;
  final Map<String, String> subtitle;
  final Map<String, String> title;
  final bool withBackground;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BannerModel({
    required this.id,
    required this.type,
    this.url,
    this.doctorId,
    required this.badge,
    required this.buttonText,
    required this.buttonAction,
    required this.hasButton,
    required this.imageUrl,
    required this.isActive,
    required this.order,
    required this.subtitle,
    required this.title,
    required this.withBackground,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerModel.fromMap(Map<String, dynamic> map, {required String id}) {
    return BannerModel(
      id: id,
      type: _asString(map['type']),
      url: map['url'] as String?,
      doctorId: map['doctor_id'] as String?,
      badge: _asMapString(map['badge']),
      buttonText: _asMapString(map['buttonText']),
      buttonAction: _asMapString(map['buttonAction']),
      hasButton: _asBool(map['hasButton']),
      imageUrl: _asString(map['imageUrl']),
      isActive: _asBool(map['isActive']),
      order: _asInt(map['order']),
      subtitle: _asMapString(map['subtitle']),
      title: _asMapString(map['title']),
      withBackground: _asBool(map['with_background']),
      createdAt: _asDateTime(map['createdAt']),
      updatedAt: _asDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      if (url != null) 'url': url,
      if (doctorId != null) 'doctor_id': doctorId,
      'badge': badge,
      'buttonText': buttonText,
      'buttonAction': buttonAction,
      'hasButton': hasButton,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'order': order,
      'subtitle': subtitle,
      'title': title,
      'with_background': withBackground,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  BannerModel copyWith({
    String? id,
    String? type,
    String? url,
    String? doctorId,
    Map<String, String>? badge,
    Map<String, String>? buttonText,
    Map<String, String>? buttonAction,
    bool? hasButton,
    String? imageUrl,
    bool? isActive,
    int? order,
    Map<String, String>? subtitle,
    Map<String, String>? title,
    bool? withBackground,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      type: type ?? this.type,
      url: url ?? this.url,
      doctorId: doctorId ?? this.doctorId,
      badge: badge ?? this.badge,
      buttonText: buttonText ?? this.buttonText,
      buttonAction: buttonAction ?? this.buttonAction,
      hasButton: hasButton ?? this.hasButton,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      subtitle: subtitle ?? this.subtitle,
      title: title ?? this.title,
      withBackground: withBackground ?? this.withBackground,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String getLocalizedTitle(String langCode) =>
      title[langCode] ?? title['en'] ?? '';
  String getLocalizedSubtitle(String langCode) =>
      subtitle[langCode] ?? subtitle['en'] ?? '';
  String getLocalizedBadge(String langCode) =>
      badge[langCode] ?? badge['en'] ?? '';
  String getLocalizedButtonText(String langCode) =>
      buttonText[langCode] ?? buttonText['en'] ?? '';

  static Map<String, String> _asMapString(dynamic value) {
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return {};
  }

  static String _asString(dynamic value, [String fallback = '']) {
    if (value is String) return value;
    return fallback;
  }

  static bool _asBool(dynamic value, [bool fallback = false]) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }

  static int _asInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    try {
      final dynamic timestamp = value;
      final dynamic toDate = timestamp.toDate;
      if (toDate is Function) {
        final dynamic result = toDate();
        if (result is DateTime) return result;
      }
    } catch (e) {
      /* ignore */
    }

    return null;
  }
}
