class ImagingSlotModel {
  final String time;
  final int maxBookings;
  final int booked;

  const ImagingSlotModel({
    required this.time,
    required this.maxBookings,
    required this.booked,
  });

  bool get isFull => booked >= maxBookings;

  double get progress => maxBookings == 0 ? 0 : booked / maxBookings;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImagingSlotModel &&
        other.time == time &&
        other.maxBookings == maxBookings &&
        other.booked == booked;
  }

  @override
  int get hashCode => time.hashCode ^ maxBookings.hashCode ^ booked.hashCode;
}
