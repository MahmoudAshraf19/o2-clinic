import 'package:cloud_firestore/cloud_firestore.dart';

import '../../booking/models/booking_status.dart';

class BookingModel {
  final String id;

  final BookingUserModel user;

  final String type;

  final BookingServiceModel? service;

  final BookingDoctorModel? doctor;

  final BookingImagingModel? imaging;

  final BookingCosmeticModel? cosmetic;

  final BookingScheduleModel schedule;

  final BookingLocationModel location;

  final BookingPaymentModel payment;

  final BookingStatusModel status;

  final BookingTimelineModel timeline;

  final BookingRemindersModel reminders;

  final BookingMetaModel meta;

  final BookingReportModel? doctorReport;

  final BookingReportModel? patientReport;

  final String? reviewId;

  BookingModel({
    required this.id,
    required this.user,
    required this.type,
    required this.service,
    required this.doctor,
    required this.imaging,
    required this.cosmetic,
    required this.schedule,
    required this.location,
    required this.payment,
    required this.status,
    required this.timeline,
    required this.reminders,
    required this.meta,
    this.doctorReport,
    this.patientReport,
    this.reviewId,
  });

  factory BookingModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return BookingModel(
      id: map['id'] ?? id,

      user: BookingUserModel.fromMap(
        map: Map<String, dynamic>.from(map['user'] ?? {}),
      ),

      type: map['type'] ?? '',

      service: map['service'] != null
          ? BookingServiceModel.fromMap(
              map: Map<String, dynamic>.from(map['service']),
            )
          : null,

      doctor: map['doctor'] != null
          ? BookingDoctorModel.fromMap(
              map: Map<String, dynamic>.from(map['doctor']),
            )
          : null,

      imaging: map['imaging'] != null
          ? BookingImagingModel.fromMap(
              map: Map<String, dynamic>.from(map['imaging']),
            )
          : null,

      cosmetic: map['cosmetic'] != null
          ? BookingCosmeticModel.fromMap(
              map: Map<String, dynamic>.from(map['cosmetic']),
            )
          : null,

      schedule: BookingScheduleModel.fromMap(
        map: Map<String, dynamic>.from(map['schedule'] ?? {}),
      ),

      location: BookingLocationModel.fromMap(
        map: Map<String, dynamic>.from(map['location'] ?? {}),
      ),

      payment: BookingPaymentModel.fromMap(
        map: Map<String, dynamic>.from(map['payment'] ?? {}),
      ),

      status: BookingStatusModel.fromMap(
        map: Map<String, dynamic>.from(map['status'] ?? {}),
      ),

      timeline: BookingTimelineModel.fromMap(
        map: Map<String, dynamic>.from(map['timeline'] ?? {}),
      ),

      reminders: BookingRemindersModel.fromMap(
        map: Map<String, dynamic>.from(map['reminders'] ?? {}),
      ),

      meta: BookingMetaModel.fromMap(
        map: Map<String, dynamic>.from(map['meta'] ?? {}),
      ),

      doctorReport: map['doctorReport'] != null
          ? BookingReportModel.fromMap(
              map: Map<String, dynamic>.from(map['doctorReport']),
            )
          : null,

      patientReport: map['patientReport'] != null
          ? BookingReportModel.fromMap(
              map: Map<String, dynamic>.from(map['patientReport']),
            )
          : null,

      reviewId: map['reviewId'] as String?,
    );
  }
}

class BookingReportModel {
  final String text;
  final String? image;
  final DateTime createdAt;

  BookingReportModel({required this.text, this.image, required this.createdAt});

  factory BookingReportModel.fromMap({required Map<String, dynamic> map}) {
    DateTime parseDate(dynamic dateVal) {
      if (dateVal == null) return DateTime.now();
      if (dateVal is Timestamp) return dateVal.toDate();
      if (dateVal is String) {
        return DateTime.tryParse(dateVal) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return BookingReportModel(
      text: map['text'] ?? '',
      image: map['image'],
      createdAt: parseDate(map['createdAt']),
    );
  }
}

class BookingUserModel {
  final String userId;

  final String name;

  final BookingPhoneModel phone;

  BookingUserModel({
    required this.userId,
    required this.name,
    required this.phone,
  });

  factory BookingUserModel.fromMap({required Map<String, dynamic> map}) {
    return BookingUserModel(
      userId: map['userId'] ?? '',

      name: map['name'] ?? '',

      phone: BookingPhoneModel.fromMap(
        map: Map<String, dynamic>.from(map['phone'] ?? {}),
      ),
    );
  }
}

class BookingPhoneModel {
  final String countryCode;

  final String number;

  final String full;

  BookingPhoneModel({
    required this.countryCode,
    required this.number,
    required this.full,
  });

  factory BookingPhoneModel.fromMap({required Map<String, dynamic> map}) {
    return BookingPhoneModel(
      countryCode: map['countryCode'] ?? '',

      number: map['number'] ?? '',

      full: map['full'] ?? '',
    );
  }
}

class BookingServiceModel {
  final String serviceId;

  final String serviceNameEn;

  final String serviceNameAr;

  BookingServiceModel({
    required this.serviceId,
    required this.serviceNameEn,
    required this.serviceNameAr,
  });

  factory BookingServiceModel.fromMap({required Map<String, dynamic> map}) {
    return BookingServiceModel(
      serviceId: map['serviceId'] ?? '',

      serviceNameEn: map['serviceName_en'] ?? '',

      serviceNameAr: map['serviceName_ar'] ?? '',
    );
  }
}

class BookingDoctorModel {
  final String doctorId;

  final String nameEn;

  final String nameAr;

  final String specialty;

  final String image;

  BookingDoctorModel({
    required this.doctorId,
    required this.nameEn,
    required this.nameAr,
    required this.specialty,
    required this.image,
  });

  factory BookingDoctorModel.fromMap({required Map<String, dynamic> map}) {
    return BookingDoctorModel(
      doctorId: map['doctorId'] ?? '',

      nameEn: map['name_en'] ?? '',

      nameAr: map['name_ar'] ?? '',

      specialty: map['specialty'] ?? '',

      image: map['image'] ?? '',
    );
  }
}

class BookingImagingModel {
  final String categoryId;

  final String subcategoryId;

  final String nameEn;

  final String nameAr;

  BookingImagingModel({
    required this.categoryId,
    required this.subcategoryId,
    required this.nameEn,
    required this.nameAr,
  });

  factory BookingImagingModel.fromMap({required Map<String, dynamic> map}) {
    return BookingImagingModel(
      categoryId: map['categoryId'] ?? '',

      subcategoryId: map['subcategoryId'] ?? '',

      nameEn: map['name_en'] ?? '',

      nameAr: map['name_ar'] ?? '',
    );
  }
}

class BookingCosmeticModel {
  final String categoryId;

  final String serviceName;

  BookingCosmeticModel({required this.categoryId, required this.serviceName});

  factory BookingCosmeticModel.fromMap({required Map<String, dynamic> map}) {
    return BookingCosmeticModel(
      categoryId: map['categoryId'] ?? '',

      serviceName: map['serviceName'] ?? '',
    );
  }
}

class BookingScheduleModel {
  final String date;

  final String time;

  final Timestamp? timestamp;

  final int durationMinutes;

  BookingScheduleModel({
    required this.date,
    required this.time,
    required this.timestamp,
    required this.durationMinutes,
  });

  factory BookingScheduleModel.fromMap({required Map<String, dynamic> map}) {
    return BookingScheduleModel(
      date: map['date'] ?? '',

      time: map['time'] ?? '',

      timestamp: map['timestamp'],

      durationMinutes: map['duration_minutes'] ?? 0,
    );
  }
}

class BookingLocationModel {
  final String clinic;

  final String floor;

  final String room;

  BookingLocationModel({
    required this.clinic,
    required this.floor,
    required this.room,
  });

  factory BookingLocationModel.fromMap({required Map<String, dynamic> map}) {
    return BookingLocationModel(
      clinic: map['clinic'] ?? '',

      floor: map['floor'] ?? '',

      room: map['room'] ?? '',
    );
  }
}

class BookingPaymentModel {
  final String status;

  final String method;

  final num amount;

  final String currency;

  BookingPaymentModel({
    required this.status,
    required this.method,
    required this.amount,
    required this.currency,
  });

  factory BookingPaymentModel.fromMap({required Map<String, dynamic> map}) {
    return BookingPaymentModel(
      status: map['status'] ?? '',

      method: map['method'] ?? '',

      amount: map['amount'] ?? 0,

      currency: map['currency'] ?? '',
    );
  }
}

class BookingStatusModel {
  final String current;
  final String label;

  BookingStatusModel({required this.current, required this.label});

  factory BookingStatusModel.fromMap({required Map<String, dynamic> map}) {
    return BookingStatusModel(
      current: map['current'] ?? '',
      label: map['label'] ?? '',
    );
  }

  BookingStatus get statusEnum => BookingStatus.fromString(current);
}

class BookingTimelineModel {
  final Timestamp? createdAt;

  final Timestamp? confirmedAt;

  final Timestamp? cancelledAt;

  final Timestamp? completedAt;

  BookingTimelineModel({
    required this.createdAt,
    required this.confirmedAt,
    required this.cancelledAt,
    required this.completedAt,
  });

  factory BookingTimelineModel.fromMap({required Map<String, dynamic> map}) {
    return BookingTimelineModel(
      createdAt: map['createdAt'],

      confirmedAt: map['confirmedAt'],

      cancelledAt: map['cancelledAt'],

      completedAt: map['completedAt'],
    );
  }
}

class BookingReminderItemModel {
  final bool sent;

  final Timestamp? sentAt;

  BookingReminderItemModel({required this.sent, required this.sentAt});

  factory BookingReminderItemModel.fromMap({
    required Map<String, dynamic> map,
  }) {
    return BookingReminderItemModel(
      sent: map['sent'] ?? false,

      sentAt: map['sentAt'],
    );
  }
}

class BookingMetaModel {
  final String source;

  final String version;

  BookingMetaModel({required this.source, required this.version});

  factory BookingMetaModel.fromMap({required Map<String, dynamic> map}) {
    return BookingMetaModel(
      source: map['source'] ?? '',

      version: map['version'] ?? '',
    );
  }
}

class BookingRemindersModel {
  final BookingReminderItemModel? twelveHoursBefore;
  final BookingReminderItemModel? threeHoursBefore;

  BookingRemindersModel({
    required this.twelveHoursBefore,
    required this.threeHoursBefore,
  });

  factory BookingRemindersModel.fromMap({required Map<String, dynamic> map}) {
    return BookingRemindersModel(
      twelveHoursBefore: map['12h_before'] != null
          ? BookingReminderItemModel.fromMap(
              map: Map<String, dynamic>.from(map['12h_before']),
            )
          : null,
      threeHoursBefore: map['3h_before'] != null
          ? BookingReminderItemModel.fromMap(
              map: Map<String, dynamic>.from(map['3h_before']),
            )
          : null,
    );
  }
}
