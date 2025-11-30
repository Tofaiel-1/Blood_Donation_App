import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/admin.dart';
import '../models/blood_request.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== ADMIN MANAGEMENT ====================

  /// Get all organization admins (Super Admin only)
  Stream<List<AdminUser>> getAllAdmins() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'orgAdmin')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => AdminUser.fromFirestore(doc)).toList(),
        );
  }

  /// Create a new admin (Super Admin only)
  /// Uses a secondary Firebase App to avoid signing out the current user
  Future<void> createAdmin({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? organization,
    List<String> permissions = const ['manage_requests', 'view_analytics'],
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    FirebaseApp? secondaryApp;
    try {
      // Initialize a secondary app to create user without logging out current user
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      // Create Firebase Auth user
      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add to Firestore (using main app instance)
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'organization': organization,
        'role': 'orgAdmin',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser.uid,
        'permissions': permissions,
        'bloodType': 'N/A',
      });

      // Log audit
      await _logAudit(
        action: 'CREATE_ADMIN',
        targetUserId: userCredential.user!.uid,
        details: {'email': email, 'name': name},
      );
    } finally {
      await secondaryApp?.delete();
    }
  }

  /// Create a new regular user (Admin/Super Admin)
  /// Uses a secondary Firebase App to avoid signing out the current user
  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    String? phone,
    required String bloodType,
    int? age,
    String? gender,
    String? address,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    FirebaseApp? secondaryApp;
    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryAppUser',
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'user',
        'bloodType': bloodType,
        'age': age,
        'gender': gender,
        'address': address,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser.uid,
        'isDonor': true, // Default to true for manually created users?
      });

      await _logAudit(
        action: 'CREATE_USER',
        targetUserId: userCredential.user!.uid,
        details: {'email': email, 'name': name, 'bloodType': bloodType},
      );
    } finally {
      await secondaryApp?.delete();
    }
  }

  /// Update admin information
  Future<void> updateAdmin(
    String adminId, {
    String? name,
    String? phone,
    String? organization,
    List<String>? permissions,
  }) async {
    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (phone != null) updateData['phone'] = phone;
    if (organization != null) updateData['organization'] = organization;
    if (permissions != null) updateData['permissions'] = permissions;

    await _firestore.collection('users').doc(adminId).update(updateData);

    await _logAudit(
      action: 'UPDATE_ADMIN',
      targetUserId: adminId,
      details: updateData,
    );
  }

  /// Toggle admin active status
  Future<void> toggleAdminStatus(String adminId, bool isActive) async {
    await _firestore.collection('users').doc(adminId).update({
      'isActive': isActive,
    });

    await _logAudit(
      action: isActive ? 'ACTIVATE_ADMIN' : 'DEACTIVATE_ADMIN',
      targetUserId: adminId,
    );
  }

  /// Delete admin
  Future<void> deleteAdmin(String adminId) async {
    await _firestore.collection('users').doc(adminId).delete();

    await _logAudit(action: 'DELETE_ADMIN', targetUserId: adminId);
  }

  // ==================== BLOOD REQUEST MANAGEMENT ====================

  /// Get all blood requests (Super Admin)
  Stream<List<BloodRequest>> getAllBloodRequests() {
    return _firestore
        .collection('bloodRequests')
        .orderBy('requestDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BloodRequest.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get blood requests assigned to specific admin
  Stream<List<BloodRequest>> getAdminBloodRequests(String adminId) {
    return _firestore
        .collection('bloodRequests')
        .where('assignedAdminId', isEqualTo: adminId)
        .orderBy('requestDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BloodRequest.fromFirestore(doc))
              .toList(),
        );
  }

  /// Create blood request
  Future<String> createBloodRequest({
    required String bloodType,
    required String patientName,
    required String hospitalName,
    required String location,
    required String contactPhone,
    required int unitsNeeded,
    required UrgencyLevel urgency,
    String? notes,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    // Get user info
    final userDoc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final userName = userDoc.data()?['name'] ?? 'Unknown';

    final docRef = await _firestore.collection('bloodRequests').add({
      'bloodType': bloodType,
      'patientName': patientName,
      'hospitalName': hospitalName,
      'location': location,
      'contactPhone': contactPhone,
      'unitsNeeded': unitsNeeded,
      'urgency': urgency.name,
      'status': RequestStatus.pending.name,
      'requestedBy': currentUser.uid,
      'requestedByName': userName,
      'requestDate': FieldValue.serverTimestamp(),
      'assignedAdminId': currentUser.uid,
      'notes': notes,
    });

    await _logAudit(
      action: 'CREATE_BLOOD_REQUEST',
      details: {
        'requestId': docRef.id,
        'bloodType': bloodType,
        'patientName': patientName,
      },
    );

    return docRef.id;
  }

  /// Update blood request
  Future<void> updateBloodRequest(
    String requestId, {
    String? patientName,
    String? hospitalName,
    String? location,
    String? contactPhone,
    int? unitsNeeded,
    String? notes,
  }) async {
    final updateData = <String, dynamic>{};
    if (patientName != null) updateData['patientName'] = patientName;
    if (hospitalName != null) updateData['hospitalName'] = hospitalName;
    if (location != null) updateData['location'] = location;
    if (contactPhone != null) updateData['contactPhone'] = contactPhone;
    if (unitsNeeded != null) updateData['unitsNeeded'] = unitsNeeded;
    if (notes != null) updateData['notes'] = notes;

    await _firestore
        .collection('bloodRequests')
        .doc(requestId)
        .update(updateData);

    await _logAudit(
      action: 'UPDATE_BLOOD_REQUEST',
      details: {'requestId': requestId, ...updateData},
    );
  }

  /// Update blood request status
  Future<void> updateRequestStatus(
    String requestId,
    RequestStatus status,
  ) async {
    final updateData = <String, dynamic>{'status': status.name};

    if (status == RequestStatus.fulfilled) {
      updateData['fulfilledDate'] = FieldValue.serverTimestamp();
    }

    await _firestore
        .collection('bloodRequests')
        .doc(requestId)
        .update(updateData);

    await _logAudit(
      action: 'UPDATE_REQUEST_STATUS',
      details: {'requestId': requestId, 'status': status.name},
    );
  }

  /// Assign request to admin
  Future<void> assignRequestToAdmin(String requestId, String adminId) async {
    await _firestore.collection('bloodRequests').doc(requestId).update({
      'assignedAdminId': adminId,
    });

    await _logAudit(
      action: 'ASSIGN_REQUEST',
      targetUserId: adminId,
      details: {'requestId': requestId},
    );
  }

  // ==================== ANALYTICS ====================

  /// Get admin statistics
  Future<Map<String, dynamic>> getAdminStats(String adminId) async {
    final requests = await _firestore
        .collection('bloodRequests')
        .where('assignedAdminId', isEqualTo: adminId)
        .get();

    final total = requests.docs.length;
    final pending = requests.docs
        .where((d) => (d.data())['status'] == 'pending')
        .length;
    final approved = requests.docs
        .where((d) => (d.data())['status'] == 'approved')
        .length;
    final fulfilled = requests.docs
        .where((d) => (d.data())['status'] == 'fulfilled')
        .length;
    final cancelled = requests.docs
        .where((d) => (d.data())['status'] == 'cancelled')
        .length;

    return {
      'total': total,
      'pending': pending,
      'approved': approved,
      'fulfilled': fulfilled,
      'cancelled': cancelled,
      'successRate': total > 0
          ? (fulfilled / total * 100).toStringAsFixed(1)
          : '0',
    };
  }

  /// Get system-wide statistics (Super Admin)
  Future<Map<String, dynamic>> getSystemStats() async {
    final requests = await _firestore.collection('bloodRequests').get();
    final admins = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'orgAdmin')
        .get();
    final users = await _firestore.collection('users').get();

    final totalRequests = requests.docs.length;
    final pendingRequests = requests.docs
        .where((d) => (d.data())['status'] == 'pending')
        .length;
    final fulfilledRequests = requests.docs
        .where((d) => (d.data())['status'] == 'fulfilled')
        .length;

    return {
      'totalRequests': totalRequests,
      'pendingRequests': pendingRequests,
      'fulfilledRequests': fulfilledRequests,
      'totalAdmins': admins.docs.length,
      'activeAdmins': admins.docs
          .where((d) => (d.data())['isActive'] == true)
          .length,
      'totalUsers': users.docs.length,
    };
  }

  /// Get blood type distribution
  Future<Map<String, int>> getBloodTypeDistribution() async {
    final requests = await _firestore.collection('bloodRequests').get();
    final distribution = <String, int>{};

    for (var doc in requests.docs) {
      final bloodType = doc.data()['bloodType'] ?? 'Unknown';
      distribution[bloodType] = (distribution[bloodType] ?? 0) + 1;
    }

    return distribution;
  }

  // ==================== AUDIT LOGGING ====================

  Future<void> _logAudit({
    required String action,
    String? targetUserId,
    Map<String, dynamic>? details,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userDoc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final userData = userDoc.data();

    await _firestore.collection('auditLogs').add({
      'action': action,
      'performedBy': currentUser.uid,
      'email': userData?['email'] ?? currentUser.email,
      'role': userData?['role'] ?? 'user',
      'targetUserId': targetUserId,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'success',
    });
  }

  // ==================== DONOR MANAGEMENT ====================

  /// Get all registered donors
  Stream<QuerySnapshot> getAllDonors() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'user')
        .snapshots();
  }

  /// Search donors by blood type
  Stream<QuerySnapshot> searchDonorsByBloodType(String bloodType) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'user')
        .where('bloodType', isEqualTo: bloodType)
        .snapshots();
  }
}
