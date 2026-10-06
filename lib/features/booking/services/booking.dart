class BookingService {
  /// Convert day string to weekday number
  int _dayToNumber(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return DateTime.monday;
      case 'tuesday':
        return DateTime.tuesday;
      case 'wednesday':
        return DateTime.wednesday;
      case 'thursday':
        return DateTime.thursday;
      case 'friday':
        return DateTime.friday;
      case 'saturday':
        return DateTime.saturday;
      case 'sunday':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }

  /// Generate real next 7 available dates
  List<DateTime> generateNextAvailableDates(List<String> availableDays) {
    if (availableDays.isEmpty) {
      return [];
    }

    final now = DateTime.now();

    final availableNumbers = availableDays.map((e) => _dayToNumber(e)).toList();

    List<DateTime> result = [];
    int i = 0;

    while (result.length < 7) {
      final date = now.add(Duration(days: i));

      if (availableNumbers.contains(date.weekday)) {
        result.add(date);
      }

      i++;
    }

    return result;
  }

  /// Booking logic
  BookingResult book({
    required String dayKey,
    required Map<String, int> bookedPerDay,
    required int maxBookings,
  }) {
    if (maxBookings <= 0) {
      return BookingResult(
        success: false,
        message: "Booking is not available",
        updatedCount: bookedPerDay[dayKey] ?? 0,
      );
    }

    int current = bookedPerDay[dayKey] ?? 0;

    if (current >= maxBookings) {
      return BookingResult(
        success: false,
        message: "Maximum bookings reached",
        updatedCount: current,
      );
    }

    current++;
    bookedPerDay[dayKey] = current;

    return BookingResult(
      success: true,
      message: "Booking #$current confirmed",
      updatedCount: current,
    );
  }
}

class BookingResult {
  final bool success;
  final String message;
  final int updatedCount;

  BookingResult({
    required this.success,
    required this.message,
    required this.updatedCount,
  });
}
