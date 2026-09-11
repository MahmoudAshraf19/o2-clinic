const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { sendFCMPush } = require("./helpers/fcmHelper");

/**
 * Triggered when a new user is created.
 * Creates a welcome notification in the 'notifications' collection.
 */
exports.sendWelcomeNotification = onDocumentCreated(
  "Users/{userId}",
  async (event) => {
    const user = event.data.data();
    // Use the actual auth uid from the document data, not the firestore auto-id
    const authUid = user.uid;

    if (!authUid) {
      console.log("[sendWelcomeNotification] User document is missing 'uid' field.");
      return;
    }

    const notificationData = {
      userId: authUid,
      type: "account",
      title: {
        en: "Welcome to O2 Clinic 👋",
        ar: "مرحباً بك في O2 Clinic 👋",
      },
      body: {
        en: `Hi ${user.name || "there"}, welcome to O2 Clinic — where your health comes first 💙`,
        ar: `مرحباً ${user.name || ""}، في O2 Clinic — حيث صحتك تأتي أولاً 💙`,
      },
      data: {
        screen: "home",
      },
      priority: "high",
      status: {
        read: false,
        readAt: null,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      fcmSent: true, // Prevent onNotificationCreated from duplicating FCM
    };

    const docRef = await admin.firestore().collection("notifications").add(notificationData);
    
    // Send FCM immediately
    const success = await sendFCMPush(notificationData, docRef.id);
    if (success) {
      await docRef.update({
        "status.delivered": true,
        "status.deliveredAt": admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
);

/**
 * Triggered when a new document is added to the 'notifications' collection.
 * Sends a push notification to the user's FCM token.
 */
exports.onNotificationCreated = onDocumentCreated(
  "notifications/{notificationId}",
  async (event) => {
    const notification = event.data.data();
    const notificationId = event.params.notificationId;
    const userId = notification.userId;

    if (notification.fcmSent === true) {
      console.log(`[onNotificationCreated] Skipped for ${notificationId} as FCM was sent directly.`);
      return;
    }

    const stringifiedData = {};
    if (notification.data) {
      for (const [k, v] of Object.entries(notification.data)) {
        stringifiedData[k] = String(v);
      }
    }

    console.log(`[onNotificationCreated] Started for notificationId: ${notificationId}, userId: ${userId}`);

    if (!userId) {
      console.log(`[onNotificationCreated] FAILED: Missing userId in notification data`);
      return;
    }

    if (userId === "all") {
      console.log(`[onNotificationCreated] Sending notification to all users topic`);
      const message = {
        topic: "all_users",
        notification: {
          title: notification.title.en,
          body: notification.body.en,
        },
        data: {
          ...stringifiedData,
          notificationId: String(notificationId),
        },
      };

      await admin.messaging().send(message);
      console.log(`[onNotificationCreated] SUCCESS: Sent topic message to 'all_users'`);
      return;
    }

    if (userId === "selected" && Array.isArray(notification.userIds)) {
      console.log(`[onNotificationCreated] Sending notification to selected users:`, notification.userIds);
      
      const tokens = [];
      for (const uid of notification.userIds) {
        let userDoc = await admin.firestore().collection("Users").doc(uid).get();
        if (!userDoc.exists) {
          const usersSnapshot = await admin.firestore().collection("Users").where("uid", "==", uid).get();
          if (!usersSnapshot.empty) {
            userDoc = usersSnapshot.docs[0];
          }
        }

        if (userDoc && userDoc.exists) {
          const userData = userDoc.data();
          if (userData?.auth?.fcm_token) {
            tokens.push({
              token: userData.auth.fcm_token,
              lang: userData.settings?.language?.slug || userData.language?.slug || "en"
            });
          }
        }
      }

      console.log(`[onNotificationCreated] Found ${tokens.length} tokens for selected users.`);
      
      if (tokens.length === 0) {
        console.log(`[onNotificationCreated] FAILED: No tokens found for any of the selected users.`);
        return;
      }

      const promises = tokens.map(({token, lang}) => {
        const message = {
          token: token,
          notification: {
            title: notification.title[lang] || notification.title["en"],
            body: notification.body[lang] || notification.body["en"],
          },
          android: {
            priority: "high",
            ttl: 2419200000,
            notification: {
              sound: "notification",
              channelId: "custom_sound_channel_1",
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "notification.mp3",
              },
            },
          },
          data: {
            ...stringifiedData,
            notificationId: String(notificationId),
            type: String(notification.type || ""),
          },
        };
        return admin.messaging().send(message).catch(err => {
          console.log(`[onNotificationCreated] ERROR sending to token ${token}:`, err);
        });
      });

      await Promise.all(promises);
      console.log(`[onNotificationCreated] SUCCESS: Successfully sent messages to selected users.`);

      await event.data.ref.update({
        "status.delivered": true,
        "status.deliveredAt": admin.firestore.FieldValue.serverTimestamp(),
        id: notificationId,
      });

      return;
    }

    console.log(`[onNotificationCreated] Fetching user doc by ID or querying by uid for: ${userId}`);
    let userDoc = await admin.firestore().collection("Users").doc(userId).get();
    
    if (!userDoc.exists) {
      const usersSnapshot = await admin.firestore().collection("Users").where("uid", "==", userId).get();
      if (!usersSnapshot.empty) {
        userDoc = usersSnapshot.docs[0];
      }
    }

    // Fallback: Check if the user is actually a Doctor
    if (!userDoc.exists) {
      console.log(`[onNotificationCreated] Not found in Users, checking Doctors collection...`);
      userDoc = await admin.firestore().collection("Doctors").doc(userId).get();
      
      if (!userDoc.exists) {
        const doctorsSnapshot = await admin.firestore().collection("Doctors").where("auth_uid", "==", userId).get();
        if (!doctorsSnapshot.empty) {
          userDoc = doctorsSnapshot.docs[0];
        }
      }
    }

    if (!userDoc || !userDoc.exists) {
      console.log(`[onNotificationCreated] FAILED: User/Doctor document not found for ID/uid == ${userId}`);
      return;
    }

    console.log(`[onNotificationCreated] SUCCESS: Found user document with ID: ${userDoc.id}`);

    const userData = userDoc.data();
    // Doctor model has fcmToken, User model has auth.fcm_token
    const token = userData?.auth?.fcm_token || userData?.fcmToken;
    const lang = userData?.settings?.language?.slug || userData?.language?.slug || "en";

    if (!token) {
      console.log(`[onNotificationCreated] FAILED: No FCM token found for user ${userId} in their document`);
      return;
    }

    console.log(`[onNotificationCreated] Found FCM token for user. Language: ${lang}`);

    const message = {
      token: token,
      notification: {
        title: notification.title[lang] || notification.title["en"],
        body: notification.body[lang] || notification.body["en"],
      },
      android: {
        priority: "high",
        ttl: 2419200000,
        notification: {
          sound: "notification",
          channelId: "custom_sound_channel_1",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "notification.mp3",
          },
        },
      },
      data: {
        ...stringifiedData,
        notificationId: String(notificationId),
        type: String(notification.type || ""),
      },
    };

    try {
      console.log(`[onNotificationCreated] Sending FCM message to token...`);
      const response = await admin.messaging().send(message);
      console.log(`[onNotificationCreated] SUCCESS: Successfully sent message. FCM Message ID: ${response}`);

      await event.data.ref.update({
        "status.delivered": true,
        "status.deliveredAt": admin.firestore.FieldValue.serverTimestamp(),
        id: notificationId,
      });
    } catch (error) {
      console.log(`[onNotificationCreated] ERROR: Failed to send FCM message. Error details:`, error);
    }
  }
);

const { sendAppointmentReminders, onBookingCreated } = require("./booking/booking");

exports.sendAppointmentReminders = sendAppointmentReminders;
exports.onBookingCreated = onBookingCreated;

/**
 * Triggered when a new review is added to a doctor.
 * Sends a notification to the doctor.
 */
exports.onReviewCreated = onDocumentCreated(
  "Doctors/{doctorId}/reviews/{reviewId}",
  async (event) => {
    const review = event.data.data();
    const doctorId = event.params.doctorId;
    const reviewId = event.params.reviewId;

    if (!review) return;

    // Fetch the doctor document to get the correct auth_uid
    let targetUserId = doctorId;
    const doctorDoc = await admin.firestore().collection("Doctors").doc(doctorId).get();
    if (doctorDoc.exists) {
      const data = doctorDoc.data();
      if (data && data.auth_uid) {
        targetUserId = data.auth_uid;
      }
    }

    const notificationData = {
      userId: targetUserId,
      type: "review",
      title: {
        en: "New Patient Review ⭐",
        ar: "تقييم جديد من مريض ⭐",
      },
      body: {
        en: `${review.patientName || "A patient"} left a ${review.rating}-star review for you.`,
        ar: `قام ${review.patientName || "مريض"} بتقييمك بـ ${review.rating} نجوم.`,
      },
      data: {
        reviewId: reviewId,
        screen: "doctor_reviews",
      },
      priority: "high",
      status: {
        read: false,
        readAt: null,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      fcmSent: true, // Prevent onNotificationCreated from duplicating FCM
    };

    const docRef = await admin.firestore().collection("notifications").add(notificationData);
    
    // Send FCM immediately
    const success = await sendFCMPush(notificationData, docRef.id);
    if (success) {
      await docRef.update({
        "status.delivered": true,
        "status.deliveredAt": admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
);