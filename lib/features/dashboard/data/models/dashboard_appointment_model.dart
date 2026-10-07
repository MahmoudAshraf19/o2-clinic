class DashboardAppointmentModel {
  final String id;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorImageUrl;
  final String label;
  final String time;
  final String location;
  final String? date;
  final double? amount;
  final String? paymentStatus;
  final String? type;

  const DashboardAppointmentModel({
    required this.id,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorImageUrl,
    required this.label,
    required this.time,
    required this.location,
    this.date,
    this.amount,
    this.paymentStatus,
    this.type,
  });
}
