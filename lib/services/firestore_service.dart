import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> setUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  Future<void> addAuditLog(Map<String, dynamic> log) async {
    await _db.collection('auditLogs').add(log);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchEmergencyRequests() {
    return _db
        .collection('emergencyRequests')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> createEmergencyRequest(Map<String, dynamic> data) async {
    await _db.collection('emergencyRequests').add(data);
  }
}
