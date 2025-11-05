// ✅ functions/index.js or index.ts
import { onValueWritten } from "firebase-functions/v2/database";
import * as admin from "firebase-admin";
import { geohashQueryBounds, distanceBetween } from "geofire-common";

interface NearbyUser {
  id: string;
  distanceInKm: number;
  status: string;
  latitude: number;
  longitude: number;
}

if (!admin.apps.length) {
  admin.initializeApp();
}

export const detectNearbyUsers = onValueWritten(
  {
    ref: "users/{userId}",
    region: "asia-southeast1",
  },
  async (event) => {
    const userId = event.params.userId;
    const after = event.data?.after?.val();
    
    console.log(`\n========== FUNCTION TRIGGERED ==========`);
    console.log(`🔔 Trigger User ID: ${userId}`);
    console.log(`📦 Data received:`, JSON.stringify(after, null, 2));
    
    if (!after) {
      console.log(`⚠️ No data after write - exiting`);
      return;
    }

    const { latitude, longitude, geohash: userGeohash, status: userStatus } = after;
    
    console.log(`\n📍 Trigger User Details:`);
    console.log(`   - Latitude: ${latitude} (type: ${typeof latitude})`);
    console.log(`   - Longitude: ${longitude} (type: ${typeof longitude})`);
    console.log(`   - Geohash: ${userGeohash}`);
    console.log(`   - Status: ${userStatus}`);
    
    if (!latitude || !longitude) {
      console.log(`❌ Missing coordinates for user ${userId}`);
      return;
    }

    const radiusInKm = 3;
    const radiusInM = radiusInKm * 1000;
    
    console.log(`\n🎯 Search Parameters:`);
    console.log(`   - Radius: ${radiusInKm} km (${radiusInM} meters)`);
    console.log(`   - Center: [${latitude}, ${longitude}]`);

    // Compute geohash bounds
    const bounds = geohashQueryBounds([latitude, longitude], radiusInM);
    
    console.log(`\n📐 Generated ${bounds.length} Geohash Query Bounds:`);
    bounds.forEach((b, idx) => {
      console.log(`   Bound ${idx}: ["${b[0]}" ... "${b[1]}"]`);
    });

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

    console.log(`\n⏳ Executing ${promises.length} queries...`);
    const snapshots = await Promise.all(promises);
    
    console.log(`\n📊 Query Results:`);
    let totalUsersFound = 0;
    snapshots.forEach((snap, idx) => {
      const count = snap.numChildren();
      totalUsersFound += count;
      console.log(`   Bound ${idx}: ${count} users returned`);
      
      // Log each user's geohash for this bound
      snap.forEach((child) => {
        console.log(`      - ${child.key}: geohash="${child.val().geohash}"`);
      });
    });
    console.log(`   📦 TOTAL users fetched: ${totalUsersFound}`);

    if (totalUsersFound === 0) {
      console.log(`\n⚠️ WARNING: No users returned from geohash queries!`);
      console.log(`   This means either:`);
      console.log(`   1. No users have geohashes in the queried bounds`);
      console.log(`   2. The geohash index is not working`);
      console.log(`   3. Users don't have geohash fields`);
    }

    const nearby: NearbyUser[] = [];
    let usersChecked = 0;
    let usersSkippedSelf = 0;
    let usersSkippedCoords = 0;
    let usersOutOfRange = 0;
    let usersWrongStatus = 0;

    console.log(`\n🔍 Starting Distance & Status Filtering:`);
    
    for (const snap of snapshots) {
      snap.forEach((child) => {
        const loc = child.val();
        usersChecked++;

        console.log(`\n   👤 User ${usersChecked}: ${child.key}`);
        console.log(`      - Geohash: ${loc.geohash}`);
        console.log(`      - Latitude: ${loc.latitude} (type: ${typeof loc.latitude})`);
        console.log(`      - Longitude: ${loc.longitude} (type: ${typeof loc.longitude})`);
        console.log(`      - Status: "${loc.status}"`);

        if (child.key === userId) {
          console.log(`      ⏭️  SKIPPED: Same as trigger user`);
          usersSkippedSelf++;
          return;
        }

        if (!loc.latitude || !loc.longitude) {
          console.log(`      ⏭️  SKIPPED: Missing coordinates`);
          usersSkippedCoords++;
          return;
        }

        // Convert to numbers explicitly
        const lat1 = Number(latitude);
        const lon1 = Number(longitude);
        const lat2 = Number(loc.latitude);
        const lon2 = Number(loc.longitude);

        console.log(`      📏 Calculating distance:`);
        console.log(`         From: [${lat1}, ${lon1}]`);
        console.log(`         To:   [${lat2}, ${lon2}]`);

        const distanceInKm = distanceBetween([lat1, lon1], [lat2, lon2]);

        console.log(`      📍 Distance: ${distanceInKm.toFixed(6)} km`);
        console.log(`      ✓ Within ${radiusInKm} km? ${distanceInKm <= radiusInKm}`);
        console.log(`      ✓ Status is "RED"? ${loc.status === "RED"}`);

        if (distanceInKm > radiusInKm) {
          console.log(`      ❌ REJECTED: Outside radius (${distanceInKm.toFixed(3)} > ${radiusInKm})`);
          usersOutOfRange++;
          return;
        }

        if (loc.status !== "RED") {
          console.log(`      ❌ REJECTED: Status is "${loc.status}", not "RED"`);
          usersWrongStatus++;
          return;
        }

        console.log(`      ✅ MATCH! Adding to nearby list`);
        nearby.push({
          id: child.key,
          distanceInKm,
          status: loc.status,
          latitude: loc.latitude,
          longitude: loc.longitude,
        });
      });
    }

    console.log(`\n📈 Filtering Summary:`);
    console.log(`   - Users checked: ${usersChecked}`);
    console.log(`   - Skipped (self): ${usersSkippedSelf}`);
    console.log(`   - Skipped (no coords): ${usersSkippedCoords}`);
    console.log(`   - Rejected (out of range): ${usersOutOfRange}`);
    console.log(`   - Rejected (wrong status): ${usersWrongStatus}`);
    console.log(`   - ✅ MATCHES FOUND: ${nearby.length}`);

    // 💾 Save result to Firestore
    const docRef = admin.firestore().collection("nearby").doc(userId);
    
    if (nearby.length > 0) {
      console.log(`\n🚨 Found ${nearby.length} RED-status users:`);
      nearby.forEach((user, idx) => {
        console.log(`   ${idx + 1}. ${user.id} - ${user.distanceInKm.toFixed(3)} km away`);
      });
      
      await docRef.set(
        {
          nearbyUsers: nearby,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
      console.log(`💾 Saved to Firestore: nearby/${userId}`);
    } else {
      await docRef.set(
        {
          nearbyUsers: [],
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
      console.log(`\n✅ No nearby RED users found for ${userId}`);
      console.log(`💾 Saved empty result to Firestore: nearby/${userId}`);
    }
    
    console.log(`\n========== FUNCTION COMPLETE ==========\n`);
  }
);
