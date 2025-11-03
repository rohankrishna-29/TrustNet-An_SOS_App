// ✅ 1. Imports stay the same
import { onValueWritten } from "firebase-functions/v2/database";
import * as admin from "firebase-admin";

// ✅ 2. Safe initialization
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    databaseURL: "https://trustnet-an-sos-app-default-rtdb.asia-southeast1.firebasedatabase.app/",
  });
}

export const sendAlertToTrustedContacts = onValueWritten(
  {
    ref: "/users/{userId}/status",
    region: "asia-southeast1",
  },
  async (event) => {
    const userId = event.params.userId;
    const newStatus = event.data?.after.val();

    // ✅ 3. Debug log to confirm trigger
    console.log("Triggered for user:", userId, "New status:", newStatus);

    if (!newStatus) {
      console.log("No new status, exiting...");
      return null;
    }

    // ✅ 4. Fetch user's name
    const userNameSnapshot = await admin.database().ref(`/users/${userId}/name`).once("value");
    const userName = userNameSnapshot.val() || "A user";

    // ✅ 5. Determine notification message
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

    // ✅ 6. Fetch trusted contacts from Firestore
    const trustedContactsSnapshot = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .collection("trusted_contacts")
      .get();

    if (trustedContactsSnapshot.empty) {
      console.log("No trusted contacts found for", userId);
      return null;
    }

    const tokens: string[] = [];
    
    for (const doc of trustedContactsSnapshot.docs) {
      const contactUid = doc.id;
      const contactDoc = await admin.firestore().collection("users").doc(contactUid).get();
      const fcmTokens = contactDoc.data()?.fcmTokens;

      // ✅ 7. Validate and log tokens
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

    // ✅ 8. Prepare message payload
    const message = {
      tokens,
      notification: {
        title: "TrustNet Alert",
        body: notificationBody,
      },
      data: {
        userId: userId || "",
        type: "status_update",
      },
    };

    // ✅ 9. Send notifications using the correct method
    try {
      const response = await admin.messaging().sendEachForMulticast(message);

      console.log(
        `FCM multicast result — Success: ${response.successCount}, Failure: ${response.failureCount}`
      );

      if (response.failureCount > 0) {
        const failedTokens = response.responses
          .map((res, i) => (!res.success ? tokens[i] : null))
          .filter(Boolean);
        console.warn("Failed tokens:", failedTokens);
      }

      return response;
    } catch (error) {
      console.error("Error sending FCM:", error);
      return null;
    }
  }
);
