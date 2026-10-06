import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DiscountCodeModel {
  final String id;
  final String code;
  final String discountTypeId;
  final Map<String, String> title;
  final Map<String, String> description;
  final num value;
  final String currency;
  final String? bookingId;
  final num minimumBookingPrice;
  final num? maximumDiscountAmount;
  final String status;
  final bool isSingleUse;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final int usageLimit;
  final int usedCount;

  DiscountCodeModel({
    required this.id,
    required this.code,
    required this.discountTypeId,
    required this.title,
    required this.description,
    required this.value,
    required this.currency,
    this.bookingId,
    required this.minimumBookingPrice,
    this.maximumDiscountAmount,
    required this.status,
    required this.isSingleUse,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.usageLimit = 10,
    this.usedCount = 0,
  });

  String get localizedTitle {
    final langCode = Get.locale?.languageCode ?? 'ar';
    return title[langCode] ?? title['ar'] ?? '';
  }

  String get localizedDescription {
    final langCode = Get.locale?.languageCode ?? 'ar';
    return description[langCode] ?? description['ar'] ?? '';
  }

  bool get isInfiniteUse => usageLimit == -1;

  factory DiscountCodeModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return DiscountCodeModel(
      id: documentId,
      code: data['code'] ?? '',
      discountTypeId: data['discount_type_id'] ?? '',
      title: Map<String, String>.from(data['title'] ?? {}),
      description: Map<String, String>.from(data['description'] ?? {}),
      value: data['value'] ?? 0,
      currency: data['currency'] ?? 'ILS',
      bookingId: data['booking_id'],
      minimumBookingPrice: data['minimum_booking_price'] ?? 0,
      maximumDiscountAmount: data['maximum_discount_amount'],
      status: data['status'] ?? 'active',
      isSingleUse: data['is_single_use'] ?? false,
      startDate: _parseDate(data['start_date']),
      endDate: _parseDate(data['end_date']),
      createdAt: _parseDate(data['created_at']),
      usageLimit: data['usage_limit'] ?? 10,
      usedCount: data['used_count'] ?? 0,
    );
  }

  factory DiscountCodeModel.fromSnapshot(DocumentSnapshot snapshot) {
    return DiscountCodeModel.fromMap(
      snapshot.data() as Map<String, dynamic>,
      snapshot.id,
    );
  }

  static DateTime? _parseDate(dynamic dateData) {
    if (dateData == null) return null;
    if (dateData is String) {
      return DateTime.tryParse(dateData);
    } else if (dateData is Timestamp) {
      return dateData.toDate();
    }
    return null;
  }
}
