const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Sends an FCM Push Notification to a user.
 */
async function sendFCMPush(notificationData, notificationId) {
  const userId = notificationData.userId;
  
  const stringifiedData = {};
  if (notificationData.data) {
    for (const [k, v] of Object.entries(notificationData.data)) {
      stringifiedData[k] = String(v);
    }
  }

  if (!userId) return false;

  if (userId === "all") {
    const message = {
      topic: "all_users",
      notification: {
        title: notificationData.title.en,
        body: notificationData.body.en,
      },
      data: {
        ...stringifiedData,
        notificationId: String(notificationId),
      },
    };
    await admin.messaging().send(message);
    return true;
  }

  let userDoc = await admin.firestore().collection("Users").doc(userId).get();
  
  if (!userDoc.exists) {
    const usersSnapshot = await admin.firestore().collection("Users").where("uid", "==", userId).get();
    if (!usersSnapshot.empty) {
      userDoc = usersSnapshot.docs[0];
    }
  }

  // Fallback: Check if the user is actually a Doctor
  if (!userDoc.exists) {
    userDoc = await admin.firestore().collection("Doctors").doc(userId).get();
    if (!userDoc.exists) {
      const doctorsSnapshot = await admin.firestore().collection("Doctors").where("auth_uid", "==", userId).get();
      if (!doctorsSnapshot.empty) {
        userDoc = doctorsSnapshot.docs[0];
      }
    }
  }

  if (!userDoc || !userDoc.exists) return false;

  const userData = userDoc.data();
  const token = userData?.auth?.fcm_token || userData?.fcmToken;
  const lang = userData?.settings?.language?.slug || userData?.language?.slug || "en";

  if (!token) return false;

  const message = {
    token: token,
    notification: {
      title: notificationData.title[lang] || notificationData.title["en"],
      body: notificationData.body[lang] || notificationData.body["en"],
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
      payload: { aps: { sound: "notification.mp3" } },
    },
    data: {
      ...stringifiedData,
      notificationId: String(notificationId),
      type: String(notificationData.type || ""),
    },
  };

  try {
    await admin.messaging().send(message);
    return true;
  } catch (error) {
    console.error("Failed to send FCM message", error);
    return false;
  }
}

module.exports = { sendFCMPush };
