import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxBool hasNewNotification = false.obs;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _firestore
            .collection('notifications')
            .where('adminId', isEqualTo: user.uid)
            .snapshots()
            .listen((snapshot) async {
          await ensureFieldReadExists(snapshot);
          hasNewNotification.value = snapshot.docs.any((doc) => !(doc.data() as Map<String, dynamic>)['read']);
        });
      }
    });
  }

  Future<void> addNotification({
    required String adminId,
    required String userId,
    required String tourId,
    required String message,
    required String tourImg,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final username = userDoc.exists ? userDoc.data()!['username'] ?? 'Unknown User' : 'Unknown User';

      final tourDoc = await _firestore.collection('tours').doc(tourId).get();
      final tourName = tourDoc.exists ? tourDoc.data()!['tourName'] ?? 'Unknown Tour' : 'Unknown Tour';

      await _firestore.collection('notifications').add({
        'adminId': adminId,
        'userId': userId,
        'tourId': tourId,
        'message': 'User $username has purchased your tour: $tourName',
        'tourImg': tourImg,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      print('Error adding notification: $e');
    }
  }

  Stream<QuerySnapshot> getNotificationsStream(String adminId) {
    return _firestore
        .collection('notifications')
        .where('adminId', isEqualTo: adminId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  Future<void> ensureFieldReadExists(QuerySnapshot snapshot) async {
    WriteBatch batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      if (!(doc.data() as Map<String, dynamic>).containsKey('read')) {
        batch.update(doc.reference, {'read': false});
      }
    }
    await batch.commit();
  }
}
