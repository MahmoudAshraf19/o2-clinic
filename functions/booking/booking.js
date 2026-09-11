const admin = require("firebase-admin");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { sendFCMPush } = require("../helpers/fcmHelper");

// ✅ مهم جدًا: لو الملف اتقرأ قبل initializeApp، هو هيهيئ نفسه بأمان
if (!admin.apps.length) {
  admin.initializeApp();
}


const HOURS_BEFORE = 12;
const WINDOW_HOURS = 1;

function getBookingStatus(booking) {
  if (typeof booking?.status === "string") {
    return booking.status;
  }
  return booking?.status?.current || "";
}

function getUserId(booking) {
  return booking?.user?.userId || booking?.userId || null;
}

exports.sendAppointmentReminders = onSchedule(
  {
    schedule: "every 90 minutes",
    timeZone: "Asia/Gaza",
    region: "us-central1",
  },
  async () => {
    const db = admin.firestore();
    const now = new Date();
    const batch = db.batch();
    let processed = 0;

    // --- 12-Hour Window (For Specialized / clinical) ---
    const windowStart12 = admin.firestore.Timestamp.fromDate(
      new Date(now.getTime() + 12 * 60 * 60 * 1000)
    );
    const windowEnd12 = admin.firestore.Timestamp.fromDate(
      new Date(now.getTime() + 13.5 * 60 * 60 * 1000) // 1.5 hours window
    );

    const snapshot12 = await db
      .collection("bookings")
      .where("schedule.timestamp", ">=", windowStart12)
      .where("schedule.timestamp", "<", windowEnd12)
      .get();

    for (const doc of snapshot12.docs) {
      const booking = doc.data();
      const userId = getUserId(booking);
      if (!userId) continue;

      const type = booking.type || "unknown";
      if (type !== "clinical") continue;

      const status = getBookingStatus(booking);
      if (status !== "upcoming" && status !== "confirmed") continue;

      const reminderInfo = booking?.reminders?.["12h_before"] || {};
      if (reminderInfo.sent === true) continue;

      const doctorNameEn = booking.doctor?.name_en || "the doctor";
      const doctorNameAr = booking.doctor?.name_ar || "الطبيب";

      const notificationId = `${doc.id}_reminder_12h`;
      const notificationRef = db.collection("notifications").doc(notificationId);

      batch.set(notificationRef, {
        id: notificationId,
        userId,
        type: "reminder",
        reminderType: "12h",
        title: {
          en: "Upcoming Medical Consultation",
          ar: "تذكير بموعد استشارة طبية",
        },
        body: {
          en: `This is a gentle reminder of your upcoming consultation with Dr. ${doctorNameEn} in approximately 12 hours. We look forward to welcoming you.`,
          ar: `نود تذكيركم بموعدكم القادم مع د. ${doctorNameAr} خلال 12 ساعة تقريباً. نتطلع لخدمتكم ورعايتكم.`,
        },
        data: {
          bookingId: doc.id,
          screen: "booking_details",
          reminderType: "12h",
        },
        priority: "high",
        status: { read: false, readAt: null, delivered: false, deliveredAt: null },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      batch.update(doc.ref, {
        "reminders.12h_before.sent": true,
        "reminders.12h_before.sentAt": admin.firestore.FieldValue.serverTimestamp(),
        "reminders.12h_before.notificationId": notificationId,
      });

      processed += 1;
    }

    // --- 24-Hour Window (For Radiology & Cosmetic) ---
    const windowStart24 = admin.firestore.Timestamp.fromDate(
      new Date(now.getTime() + 24 * 60 * 60 * 1000)
    );
    const windowEnd24 = admin.firestore.Timestamp.fromDate(
      new Date(now.getTime() + 25.5 * 60 * 60 * 1000) // 1.5 hours window
    );

    const snapshot24 = await db
      .collection("bookings")
      .where("schedule.timestamp", ">=", windowStart24)
      .where("schedule.timestamp", "<", windowEnd24)
      .get();

    for (const doc of snapshot24.docs) {
      const booking = doc.data();
      const userId = getUserId(booking);
      if (!userId) continue;

      const type = booking.type || "unknown";
      if (type !== "imaging" && type !== "cosmetic") continue;

      const status = getBookingStatus(booking);
      if (status !== "upcoming" && status !== "confirmed") continue;

      const reminderInfo = booking?.reminders?.["24h_before"] || {};
      if (reminderInfo.sent === true) continue;

      let serviceNameEn = "Medical Service";
      let serviceNameAr = "خدمة طبية";
      
      if (type === "cosmetic" && booking.cosmetic) {
        serviceNameEn = booking.cosmetic.name_en || "Cosmetic Service";
        serviceNameAr = booking.cosmetic.name_ar || "خدمة تجميلية";
      } else if (type === "imaging" && booking.imaging) {
        serviceNameEn = booking.imaging.name_en || "Imaging Service";
        serviceNameAr = booking.imaging.name_ar || "أشعة";
      }

      const notificationId = `${doc.id}_reminder_24h`;
      const notificationRef = db.collection("notifications").doc(notificationId);

      batch.set(notificationRef, {
        id: notificationId,
        userId,
        type: "reminder",
        reminderType: "24h",
        title: {
          en: "Upcoming Service Appointment",
          ar: "تذكير بموعد حجز",
        },
        body: {
          en: `We gently remind you of your upcoming ${serviceNameEn} appointment tomorrow. Please ensure to follow any prior instructions provided.`,
          ar: `يرجى التكرم بالعلم أن موعدكم لخدمة ${serviceNameAr} سيكون غداً. نرجو الالتزام بأي تعليمات مسبقة إن وجدت، ونتمنى لكم دوام الصحة والعافية.`,
        },
        data: {
          bookingId: doc.id,
          screen: "booking_details",
          reminderType: "24h",
        },
        priority: "high",
        status: { read: false, readAt: null, delivered: false, deliveredAt: null },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      batch.update(doc.ref, {
        "reminders.24h_before.sent": true,
        "reminders.24h_before.sentAt": admin.firestore.FieldValue.serverTimestamp(),
        "reminders.24h_before.notificationId": notificationId,
      });

      processed += 1;
    }

    // --- 30-Minute Window (For Online Consultations) ---
    // Runs every 90 minutes to catch upcoming online consultations
    const windowStart30 = admin.firestore.Timestamp.fromDate(
      new Date(now.getTime() + 15 * 60 * 1000) // 15 mins ahead
    );
    const windowEnd30 = admin.firestore.Timestamp.fromDate(
      new Date(now.getTime() + 105 * 60 * 1000) // 105 mins ahead (1.5 hours window)
    );

    const snapshot30 = await db
      .collection("bookings")
      .where("schedule.timestamp", ">=", windowStart30)
      .where("schedule.timestamp", "<", windowEnd30)
      .get();

    for (const doc of snapshot30.docs) {
      const booking = doc.data();
      const userId = getUserId(booking);
      if (!userId) continue;

      const type = booking.type || "unknown";
      if (type !== "clinical") continue;

      const status = getBookingStatus(booking);
      if (status !== "upcoming" && status !== "confirmed") continue;

      // Check if it's an online consultation
      const isOnline = booking.location?.clinic === "Online Consultation" || booking.type === "online";
      if (!isOnline) continue;

      const reminderInfo = booking?.reminders?.["30m_before"] || {};
      if (reminderInfo.sent === true) continue;

      const doctorNameEn = booking.doctor?.name_en || "the doctor";
      const doctorNameAr = booking.doctor?.name_ar || "الطبيب";
      const doctorId = booking.doctor?.id;

      // 1. Send Notification to Patient
      const patientNotifId = `${doc.id}_reminder_30m_patient`;
      batch.set(db.collection("notifications").doc(patientNotifId), {
        id: patientNotifId,
        userId: userId,
        type: "reminder",
        reminderType: "30m",
        title: {
          en: "Online Consultation Starting Soon ⏱️",
          ar: "موعد استشارة أونلاين قريب ⏱️",
        },
        body: {
          en: `Reminder: Your online consultation with Dr. ${doctorNameEn} starts in approximately 30 minutes.`,
          ar: `تذكير: موعد الكشف الأونلاين مع د. ${doctorNameAr} يبدأ خلال 30 دقيقة تقريباً.`,
        },
        data: {
          bookingId: doc.id,
          screen: "booking_details",
          reminderType: "30m",
        },
        priority: "high",
        status: { read: false, readAt: null, delivered: false, deliveredAt: null },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 2. Send Notification to Doctor (if doctorId exists)
      if (doctorId) {
        const doctorNotifId = `${doc.id}_reminder_30m_doctor`;
        batch.set(db.collection("notifications").doc(doctorNotifId), {
          id: doctorNotifId,
          userId: doctorId, // Doctor is also a user in the notifications collection
          type: "reminder",
          reminderType: "30m",
          title: {
            en: "Upcoming Online Patient ⏱️",
            ar: "موعد مريض أونلاين ⏱️",
          },
          body: {
            en: `Reminder: You have an online consultation starting in 30 minutes.`,
            ar: `تذكير: لديك كشف أونلاين يبدأ خلال 30 دقيقة تقريباً.`,
          },
          data: {
            bookingId: doc.id,
            screen: "doctor_booking_details",
            reminderType: "30m",
          },
          priority: "high",
          status: { read: false, readAt: null, delivered: false, deliveredAt: null },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      batch.update(doc.ref, {
        "reminders.30m_before.sent": true,
        "reminders.30m_before.sentAt": admin.firestore.FieldValue.serverTimestamp(),
        "reminders.30m_before.patientNotificationId": patientNotifId,
      });

      processed += (doctorId ? 2 : 1);
    }

    if (processed > 0) {
      await batch.commit();
      console.log(`[sendAppointmentReminders] Created ${processed} reminder(s).`);
    } else {
      console.log("[sendAppointmentReminders] No new reminders to create.");
    }

    return null;
  }
);

/**
 * Triggered when a new booking is created.
 * Creates a notification in the 'notifications' collection so the FCM cloud function can send it.
 */
exports.onBookingCreated = require("firebase-functions/v2/firestore").onDocumentCreated(
  "bookings/{bookingId}",
  async (event) => {
    const db = admin.firestore();
    const booking = event.data.data();
    const bookingId = event.params.bookingId;
    
    if (!booking) return;
    
    const userId = getUserId(booking);
    if (!userId) {
      console.log(`[onBookingCreated] No user ID for booking ${bookingId}`);
      return;
    }

    const type = booking.type || "unknown";
    const date = booking.schedule?.date || "";
    const time = booking.schedule?.time || "";
    let serviceNameEn = "Medical Service";
    let serviceNameAr = "خدمة طبية";

    if (type === "cosmetic" && booking.cosmetic) {
      serviceNameEn = booking.cosmetic.name_en || "Cosmetic Service";
      serviceNameAr = booking.cosmetic.name_ar || "خدمة تجميلية";
    } else if (type === "imaging" && booking.imaging) {
      serviceNameEn = booking.imaging.name_en || "Imaging Service";
      serviceNameAr = booking.imaging.name_ar || "أشعة";
    } else if (type === "clinical" && booking.doctor) {
      serviceNameEn = `Consultation with Dr. ${booking.doctor.name_en}`;
      serviceNameAr = `استشارة مع د. ${booking.doctor.name_ar}`;
    }

    const notificationId = `${bookingId}_created`;
    const notificationData = {
      id: notificationId,
      userId: userId,
      type: "booking_confirmation",
      title: {
        en: "Booking Confirmed ✅",
        ar: "تم تأكيد الحجز ✅",
      },
      body: {
        en: `Your booking for ${serviceNameEn} has been scheduled successfully on ${date} at ${time}.`,
        ar: `تم تأكيد حجزك لـ ${serviceNameAr} بنجاح بتاريخ ${date} الساعة ${time}.`,
      },
      data: {
        bookingId: bookingId,
        screen: "booking_success",
        doctorId: booking.doctor?.id || "",
        doctorNameEn: booking.doctor?.name_en || "",
        doctorNameAr: booking.doctor?.name_ar || "",
        doctorTitleEn: booking.doctor?.title_en || "",
        doctorTitleAr: booking.doctor?.title_ar || "",
        doctorImage: booking.doctor?.image || "",
        doctorSpecialty: booking.doctor?.specialty || "",
        selectedDate: date || "",
        selectedTime: time || "",
      },
      priority: "high",
      status: {
        read: false,
        readAt: null,
        delivered: false,
        deliveredAt: null,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    try {
      const docRef = db.collection("notifications").doc(notificationId);
      
      const notificationWithFlag = {
        ...notificationData,
        fcmSent: true, // Bypass onNotificationCreated to save costs
      };
      
      await docRef.set(notificationWithFlag);
      console.log(`[onBookingCreated] Notification created for booking ${bookingId}`);

      // 1.5 Send FCM push directly
      const success = await sendFCMPush(notificationWithFlag, notificationId);
      if (success) {
        await docRef.update({
          "status.delivered": true,
          "status.deliveredAt": admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      // 2. إرسال إشعار للوحة تحكم الإدارة (Admin Panel)
      // هذا هو الإشعار الذي سيظهر في الـ AppBar ويشغل الصوت
      const adminNotifData = {
        bookingId: bookingId,
        kind: "booking.created",
        title: { en: "New Booking via App", ar: "حجز جديد من التطبيق" },
        body: { 
          en: `New booking for ${serviceNameEn}`, 
          ar: `حجز جديد لـ ${serviceNameAr}` 
        },
        tone: "success",
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      await db.collection("admin_notifications").add(adminNotifData);
      console.log(`[onBookingCreated] Admin notification created for booking ${bookingId}`);

    } catch (e) {
      console.error(`[onBookingCreated] Error creating notification for booking ${bookingId}:`, e);
    }
  }
);