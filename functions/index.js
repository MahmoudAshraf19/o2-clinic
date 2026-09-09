const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

const { onDocumentCreated } = require("firebase-functions/v2/firestore");

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
    };

    await admin.firestore().collection("notifications").add(notificationData);
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

    if (!userDoc || !userDoc.exists) {
      console.log(`[onNotificationCreated] FAILED: User document not found for ID/uid == ${userId}`);
      return;
    }

    console.log(`[onNotificationCreated] SUCCESS: Found user document with ID: ${userDoc.id}`);

    const userData = userDoc.data();
    const token = userData?.auth?.fcm_token;
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