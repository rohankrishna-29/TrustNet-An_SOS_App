import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectionsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Get a user's UID by their email
  /// Returns null if user not found
  Future<String?> getUserIdByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id; // document ID = user UID
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching UID by email: $e');
      return null;
    }
  }

  /// 🔹 Send a connection request using target email
  Future<void> sendConnectionRequest(String currentUid, String targetEmail) async {
    final targetUid = await getUserIdByEmail(targetEmail);
    if (targetUid == null) throw Exception('User not found for $targetEmail');

    final currentRef = _firestore
        .collection('users')
        .doc(currentUid)
        .collection('trusted_contacts')
        .doc(targetUid);

    final targetRef = _firestore
        .collection('users')
        .doc(targetUid)
        .collection('trusted_contacts')
        .doc(currentUid);

    await _firestore.runTransaction((txn) async {
      txn.set(currentRef, {
        'status': 'pending',
        'sentBy': currentUid,
        'userId': targetUid,
        'email': targetEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });

      txn.set(targetRef, {
        'status': 'pending',
        'sentBy': currentUid,
        'userId': currentUid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  /// 🔹 Accept a connection request
  Future<void> acceptConnectionRequest(String currentUid, String otherUid) async {
    final currentRef = _firestore
        .collection('users')
        .doc(currentUid)
        .collection('trusted_contacts')
        .doc(otherUid);

    final otherRef = _firestore
        .collection('users')
        .doc(otherUid)
        .collection('trusted_contacts')
        .doc(currentUid);

    await _firestore.runTransaction((txn) async {
      txn.update(currentRef, {'status': 'accepted'});
      txn.update(otherRef, {'status': 'accepted'});
    });
  }

  /// 🔹 Reject or cancel a connection request
  Future<void> rejectConnectionRequest(String currentUid, String otherUid) async {
    final currentRef = _firestore
        .collection('users')
        .doc(currentUid)
        .collection('trusted_contacts')
        .doc(otherUid);

    final otherRef = _firestore
        .collection('users')
        .doc(otherUid)
        .collection('trusted_contacts')
        .doc(currentUid);

    await _firestore.runTransaction((txn) async {
      txn.delete(currentRef);
      txn.delete(otherRef);
    });
  }

  /// 🔹 Stream of pending requests
  Stream<List<Map<String, dynamic>>> getPendingRequests(String currentUid) {
    final ref = _firestore
        .collection('users')
        .doc(currentUid)
        .collection('trusted_contacts')
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return ref.map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// 🔹 Stream of accepted connections
  Stream<List<Map<String, dynamic>>> getAcceptedConnections(String currentUid) {
    final ref = _firestore
        .collection('users')
        .doc(currentUid)
        .collection('trusted_contacts')
        .where('status', isEqualTo: 'accepted')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return ref.map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
