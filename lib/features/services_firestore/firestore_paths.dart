class FirestorePaths {
  FirestorePaths._();

  // Main Collections
  static const String doctors = "Doctors";
  static const String bookings = "bookings";
  static const String users = "Users";
  static const String specialized = "specialized";
  static const String weekdays = "weekdays";
  static const String radiologyCategory = "radiology_category";
  static const String notifications = "notifications";
  static const String banners = "banners";
  static const String settings = "settings";
  static const String servicesCollection = "services";
  static const String appConstants = "app_constants";
  // Sub Collections
  static String doctorReviews(String doctorId) => "$doctors/$doctorId/reviews";

  static String doctorBookings(String doctorId) =>
      "$doctors/$doctorId/bookings";

  static String userBookings(String userId) => "$users/$userId/bookings";
}
