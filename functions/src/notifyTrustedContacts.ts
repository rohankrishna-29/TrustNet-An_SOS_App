// ✅ 1. Imports stay the same
import { onValueWritten } from "firebase-functions/v2/database";
import * as admin from "firebase-admin";

// ✅ 2. Added safe initialization check
if (!admin.apps.length) {
  admin.initializeApp();
}

export const sendAlertToTrustedContacts = onValueWritten(
  {
    ref: "/users/{userId}/status",
    region: "asia-southeast1",
  },
  async (event) => {
    const userId = event.params.userId;
    const newStatus = event.data?.after.val();

    // ✅ 3. Added debug log to confirm trigger
    console.log("Triggered for user:", userId, "New status:", newStatus);

    if (!newStatus) {
      console.log("No new status, exiting...");
      return null;
    }

    // ✅ 4. Fetch user's name from RTDB (unchanged)
    const userNameSnapshot = await admin.database().ref(`/users/${userId}/name`).once("value");
    const userName = userNameSnapshot.val() || "A user";

    // ✅ 5. Status message determination (unchanged, just cleaned)
    let notificationBody;
    switch (newStatus) {
      case "GREEN":
        notificationBody = `${userName} is sharing their location`;
        break;
      case "RED":
        notificationBody = `${userName} needs help!`;
        break;
      case "OFF":
        notificationBody = `${userName} has stopped sharing their location`;
        break;
      default:
        console.log("Unknown status value, skipping...");
        return null;
    }

    // ✅ 6. Fetch trusted contacts from Firestore (same)
    const trustedContactsSnapshot = await admin.firestore()
      .collection("users")
      .doc(userId)
      .collection("trusted_contacts")
      .get();

    if (trustedContactsSnapshot.empty) {
      console.log("No trusted contacts found for", userId);
      return null;
    }

    const tokens = [];

    for (const doc of trustedContactsSnapshot.docs) {
      const contactUid = doc.id;
      const contactDoc = await admin.firestore().collection("users").doc(contactUid).get();
      const fcmTokens = contactDoc.data()?.fcmTokens;

      // ✅ 7. Added more detailed logging for token checks
      if (Array.isArray(fcmTokens) && fcmTokens.length > 0) {
        const validTokens = fcmTokens.filter((t) => typeof t === "string" && t.length > 0);
        console.log(`Valid tokens found for contact ${contactUid}:`, validTokens);
        tokens.push(...validTokens);
      } else {
        console.log(`No FCM tokens found for contact: ${contactUid}`);
      }
    }

    if (tokens.length === 0) {
      console.log("No valid FCM tokens to send to.");
      return null;
    }

    const message = {
      notification: {
        title: "TrustNet Alert",
        body: notificationBody,
      },
      tokens,
    };

    // ✅ 8. Added error handling and logging
    try {
      const response = await admin.messaging().sendMulticast(message);
      console.log("FCM response:", response);
      return response;
    } catch (error) {
      console.error("Error sending FCM:", error);
      return null;
    }
  }
);
