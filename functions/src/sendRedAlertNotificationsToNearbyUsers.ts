// ✅ functions/index.js or index.ts
import { onValueWritten } from "firebase-functions/v2/database";
import * as admin from "firebase-admin";
import { geohashQueryBounds, distanceBetween } from "geofire-common";

if (!admin.apps.length) {
  admin.initializeApp();
}

export const sendRedAlertNotificationsToNearbyUsers = onValueWritten(
  {
    ref: "users/{userId}/status",  // ✅ Only trigger on status changes
    region: "asia-southeast1",
  },
  async (event) => {
    const userId = event.params.userId;
    const newStatus = event.data?.after?.val();
    const oldStatus = event.data?.before?.val();

    console.log(`\n========== RED ALERT FUNCTION TRIGGERED ==========`);
    console.log(`🔔 User ID: ${userId}`);
    console.log(`   Status change: "${oldStatus}" → "${newStatus}"`);

    // ✅ Only proceed if status changed TO RED
    if (newStatus !== "RED") {
      console.log(`⏭️ Status is "${newStatus}", not RED - exiting`);
      return;
    }

    console.log(`🚨 User went RED! Finding nearby users...`);

    // Get the RED user's location and name
    const db = admin.database();
    const userSnapshot = await db.ref(`users/${userId}`).once("value");
    const redUser = userSnapshot.val();

    if (!redUser) {
      console.log(`❌ User document not found`);
      return;
    }

    const { latitude, longitude, name: redUserName } = redUser;

    console.log(`\n📍 RED User Details:`);
    console.log(`   - User ID: ${userId}`);
    console.log(`   - Name: ${redUserName}`);
    console.log(`   - Latitude: ${latitude}`);
    console.log(`   - Longitude: ${longitude}`);

    if (!latitude || !longitude) {
      console.log(`❌ Missing coordinates for RED user ${userId}`);
      return;
    }

    const radiusInKm = 3;
    const radiusInM = radiusInKm * 1000;

    console.log(`\n🎯 Search Parameters:`);
    console.log(`   - Radius: ${radiusInKm} km`);
    console.log(`   - Center: [${latitude}, ${longitude}]`);

    // Compute geohash bounds
    const bounds = geohashQueryBounds([latitude, longitude], radiusInM);

    console.log(`\n📐 Generated ${bounds.length} Geohash Query Bounds:`);
    bounds.forEach((b, idx) => {
      console.log(`   Bound ${idx}: ["${b[0]}" ... "${b[1]}"]`);
    });

    // Query nearby users
    const promises = [];
    for (const b of bounds) {
      const query = db
        .ref("users")
        .orderByChild("geohash")
        .startAt(b[0])
        .endAt(b[1])
        .once("value");
      promises.push(query);
    }

    console.log(`\n⏳ Executing ${promises.length} geohash queries...`);
    const snapshots = await Promise.all(promises);

    const nearbyUsers: any[] = [];
    let totalUsersFound = 0;

    console.log(`\n📊 Query Results:`);
    snapshots.forEach((snap, idx) => {
      const count = snap.numChildren();
      totalUsersFound += count;
      console.log(`   Bound ${idx}: ${count} users returned`);
    });
    console.log(`   📦 TOTAL users fetched: ${totalUsersFound}`);

    // Filter for nearby users
    console.log(`\n🔍 Filtering nearby users for notifications:\n`);

    for (const snap of snapshots) {
      snap.forEach((child) => {
        const loc = child.val();

        // Skip self
        if (child.key === userId) {
          console.log(`   ⏭️ ${child.key}: Skipped (self)`);
          return;
        }

        // Check coordinates
        if (!loc.latitude || !loc.longitude) {
          console.log(`   ⏭️ ${child.key}: Skipped (missing coordinates)`);
          return;
        }

        // Calculate distance
        const lat1 = Number(latitude);
        const lon1 = Number(longitude);
        const lat2 = Number(loc.latitude);
        const lon2 = Number(loc.longitude);

        const distanceInKm = distanceBetween([lat1, lon1], [lat2, lon2]);

        // Check if within radius
        if (distanceInKm > radiusInKm) {
          console.log(
            `   ⏭️ ${child.key}: Skipped (too far: ${distanceInKm.toFixed(3)} km)`
          );
          return;
        }

        console.log(`   ✅ ${child.key}: ${distanceInKm.toFixed(3)} km away - will notify`);
        nearbyUsers.push({
          id: child.key,
          name: loc.name,
          distance: distanceInKm,
          fcmTokens: loc.fcmTokens, // Will fetch from Firestore instead
        });
      });
    }

    console.log(`\n📈 Found ${nearbyUsers.length} nearby users to notify`);

    if (nearbyUsers.length === 0) {
      console.log(`✅ No nearby users to notify`);
      console.log(`\n========== FUNCTION COMPLETE ==========\n`);
      return;
    }

    // Send FCM notifications
    console.log(`\n📲 Sending FCM notifications...\n`);
    await sendNotificationsToNearbyUsers(
      userId,
      redUserName,
      nearbyUsers
    );

    console.log(`\n========== FUNCTION COMPLETE ==========\n`);
  }
);

/**
 * Send FCM notifications to nearby users
 */
async function sendNotificationsToNearbyUsers(
  redUserId: string,
  redUserName: string,
  nearbyUsers: any[]
) {
  const firestore = admin.firestore();
  const messaging = admin.messaging();

  let notificationsSent = 0;
  let notificationsFailed = 0;

  for (const nearbyUser of nearbyUsers) {
    try {
      console.log(`📱 Notifying ${nearbyUser.id} (${nearbyUser.name})...`);

      // Fetch FCM tokens from Firestore
      const userDoc = await firestore.collection("users").doc(nearbyUser.id).get();

      if (!userDoc.exists) {
        console.log(`   ⚠️ User document not found in Firestore`);
        notificationsFailed++;
        continue;
      }

      const userData = userDoc.data();
      const fcmTokens = userData?.fcmTokens;

      if (!fcmTokens || !Array.isArray(fcmTokens) || fcmTokens.length === 0) {
        console.log(`   ⚠️ No FCM tokens found`);
        notificationsFailed++;
        continue;
      }

      console.log(`   ✓ Found ${fcmTokens.length} FCM token(s)`);

      // Create notification message
      const distanceText =
        nearbyUser.distance < 1
          ? `${(nearbyUser.distance * 1000).toFixed(0)}m`
          : `${nearbyUser.distance.toFixed(2)}km`;

      const message = {
        notification: {
          title: "🚨 Emergency Alert",
          body: `${redUserName} (${distanceText} away) needs help!`,
        },
        data: {
          type: "red_alert",
          userId: redUserId,
          userName: redUserName,
          distance: nearbyUser.distance.toString(),
        },
      };

      // Send to all tokens
      const tokensToRemove: string[] = [];

      for (const token of fcmTokens) {
        try {
          await messaging.send({
            ...message,
            token: token,
          });
          console.log(
            `   ✅ Sent to token: ${token.substring(0, 20)}...`
          );
          notificationsSent++;
        } catch (error: any) {
          console.log(`   ❌ Failed to send to token ${token.substring(0, 20)}...`);

          // Mark invalid tokens for removal
          if (
            error.code === "messaging/invalid-registration-token" ||
            error.code === "messaging/registration-token-not-registered"
          ) {
            tokensToRemove.push(token);
            console.log(`      🗑️ Token marked for removal`);
          }
          notificationsFailed++;
        }
      }

      // Remove invalid tokens
      if (tokensToRemove.length > 0) {
        const updatedTokens = fcmTokens.filter(
          (t: string) => !tokensToRemove.includes(t)
        );
        await firestore.collection("users").doc(nearbyUser.id).update({
          fcmTokens: updatedTokens,
        });
        console.log(`   🗑️ Removed ${tokensToRemove.length} invalid token(s)`);
      }
    } catch (error: any) {
      console.log(`   ❌ Error: ${error.message}`);
      notificationsFailed++;
    }
  }

  console.log(`\n📊 Notification Summary:`);
  console.log(`   ✅ Sent: ${notificationsSent}`);
  console.log(`   ❌ Failed: ${notificationsFailed}`);
}
