import {onValueWritten} from "firebase-functions/v2/database";
import * as admin from "firebase-admin";

admin.initializeApp();

export const sendAlertToTrustedContacts = onValueWritten(
  {
    ref: "/users/{userId}/status", 
    region: "asia-southeast1",
  },
  async (event) => {
    const userId = event.params.userId;

    const newStatus = event.data?.after.val();
    if (!newStatus) return;

  // Get user's name from RTDB
  const userNameSnapshot = await admin.database().ref(`/users/${userId}/name`).once("value");
  const userName = userNameSnapshot.val() || "A user";

  // Determine notification body based on status
  let notificationBody: string;
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
      return;
  }

  // Get trusted contacts UIDs from Firestore
  const trustedContactsSnapshot = await admin.firestore()
    .collection("users")
    .doc(userId)
    .collection("trusted_contacts")
    .get();

  const tokens: string[] = [];

  for (const doc of trustedContactsSnapshot.docs) {
    const contactUid = doc.id;

    const contactDoc = await admin.firestore()
      .collection("users")
      .doc(contactUid)
      .get();

    const fcmTokens = contactDoc.data()?.fcmTokens;
    if (Array.isArray(fcmTokens) && fcmTokens.length > 0) {
      tokens.push(...fcmTokens.filter((token) => typeof token === "string" && token.length > 0));
    }
  }

  if (tokens.length === 0) {
    return;
  }

  const message = {
    notification: {
      title: "Trustnet Alert",
      body: notificationBody,
    },
    tokens,
  };

  await admin.messaging().sendMulticast(message);
});
