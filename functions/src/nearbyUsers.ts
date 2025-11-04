// ✅ functions/index.js or index.ts
import { onValueWritten } from "firebase-functions/v2/database";
import * as admin from "firebase-admin";
import { geohashQueryBounds, distanceBetween } from "geofire-common";


interface NearbyUser {
  id: string;
  distanceInKm: number;
  status: string;
}


if (!admin.apps.length) {
  admin.initializeApp();
}

export const detectNearbyUsers = onValueWritten(
  {
    ref: "users/{userId}", // listens to your existing path
    region: "asia-southeast1", // use your Firebase region
  },
  async (event) => {
    const userId = event.params.userId;
    const after = event.data?.after?.val();
    if (!after) return;

    const { lat, lon, status } = after;
    if (!lat || !lon) {
      console.log(`❌ Missing coordinates for user ${userId}`);
      return;
    }

    const radiusInKm = 3; // configurable radius for "nearby"

    // Compute geohash bounds
    const bounds = geohashQueryBounds([lat, lon], radiusInKm * 1000);
    const db = admin.database();
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

    const snapshots = await Promise.all(promises);
    const nearby: NearbyUser[] = [];

    for (const snap of snapshots) {
      snap.forEach((child) => {
        const loc = child.val();
        if (!loc.lat || !loc.lon || child.key === userId) return;

        // ✅ Check both distance and status
        const distanceInKm = distanceBetween([lat, lon], [loc.lat, loc.lon]);
        if (distanceInKm <= radiusInKm && loc.status === "RED") {
          nearby.push({
            id: child.key,
            distanceInKm,
            status: loc.status,
          });
        }
      });
    }

    // 💾 Save result to Firestore (or RTDB) if any nearby RED users found
    const docRef = admin.firestore().collection("nearby").doc(userId);
    if (nearby.length > 0) {
      await docRef.set(
        {
          nearbyUsers: nearby,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
      console.log(
        `🚨 Found ${nearby.length} RED-status users within ${radiusInKm} km of ${userId}`
      );
    } else {
      // optional: clear or update to empty
      await docRef.set(
        {
          nearbyUsers: [],
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
      console.log(`✅ No nearby RED users found for ${userId}`);
    }
  }
);
