class BookingUserInfo {
  final String userId;
  final String name;
  final String countryCode;
  final String number;

  BookingUserInfo({
    required this.userId,
    required this.name,
    required this.countryCode,
    required this.number,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'countryCode': countryCode,
      'number': number,
    };
  }
}

class BookingResult {
  final bool success;
  final String message;
  final String? bookingId;
  final int? bookedCount;
  final int? maxBookings;

  BookingResult({
    required this.success,
    required this.message,
    this.bookingId,
    this.bookedCount,
    this.maxBookings,
  });
}
