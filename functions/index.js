const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.sendSosNotification = functions.firestore
  .document("sosRecords/{sosId}")
  .onCreate(async (snap, context) => {
    const sosData = snap.data();
    const elderId = sosData.userId;

    if (!elderId) return console.log("No elderId found in SOS record");

    try {
      // 1. Get the Elder's profile to find their linked caregivers
      const elderDoc = await db.collection("users").doc(elderId).get();
      if (!elderDoc.exists) return console.log("Elder profile not found");

      const caregivers = elderDoc.data().caregivers || [];
      if (caregivers.length === 0) return console.log("No caregivers linked to this elder");

      // 2. Gather FCM tokens for all linked caregivers
      let tokens = [];
      for (const caregiverId of caregivers) {
        const cgDoc = await db.collection("users").doc(caregiverId).get();
        if (cgDoc.exists) {
          const cgTokens = cgDoc.data().fcmTokens || [];
          tokens = tokens.concat(cgTokens);
        }
      }

      if (tokens.length === 0) return console.log("No FCM tokens found for caregivers");

      // 3. Construct the push notification
      const payload = {
        notification: {
          title: "🚨 SOS ALERT",
          body: "Your linked elder has triggered an SOS!",
        },
        tokens: tokens, // Send to all caregivers simultaneously
      };

      // 4. Send the notification via Firebase Cloud Messaging
      const response = await admin.messaging().sendEachForMulticast(payload);
      console.log(`Successfully sent ${response.successCount} messages.`);
      
    } catch (error) {
      console.error("Error sending SOS notification:", error);
    }
  });
