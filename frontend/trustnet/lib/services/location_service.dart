import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';


class LocationService {
  final FirebaseDatabase _rtdb = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://trustnet-an-sos-app-default-rtdb.asia-southeast1.firebasedatabase.app",

  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final StreamController<Map<String, dynamic>> _controller = StreamController.broadcast();

  Stream<Map<String, dynamic>> get contactUpdatesStream => _controller.stream;

  Future<void> subscribeToTrustedContacts(String currentUserId) async {
    try {
      final contactsSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('trusted_contacts')
          .get();
          

      if (contactsSnapshot.docs.isEmpty) {
        print('No trusted contacts found.');
        return;
      }

      for (final doc in contactsSnapshot.docs) {
        final contactUserId = doc.id;
        final userRef = _rtdb.ref('users/$contactUserId');

        userRef.onValue.listen((DatabaseEvent event) {
          print("listening to $contactUserId");
          if (event.snapshot.value != null) {
            print("Got data for $contactUserId: ${event.snapshot.value}");
            final data = Map<String, dynamic>.from(event.snapshot.value as Map);

            final update = {
              'userId': contactUserId,
              'name' : data['name'],
              'latitude': data['latitude'],
              'longitude': data['longitude'],
              'status': data['status'],
            };

            _controller.add(update);
            print('📍 Update from $contactUserId: $update');
          }
        });
      }
    } catch (e) {
      print('Error subscribing to trusted contacts: $e');
    }
  }

  void dispose() {
    _controller.close();
  }
}
