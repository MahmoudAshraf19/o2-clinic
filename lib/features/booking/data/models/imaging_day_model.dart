class ImagingDayModel {
  final String day;
  final DateTime date;

  const ImagingDayModel({required this.day, required this.date});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImagingDayModel && other.day == day && other.date == date;
  }

  @override
  int get hashCode => day.hashCode ^ date.hashCode;
}
