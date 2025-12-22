import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/admin.dart';
import '../models/blood_request.dart';
import 'activity_log_service.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ActivityLogService _activityLog = ActivityLogService();

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

      // Log activity
      await _activityLog.logAdminAction(
        action: 'Admin Created',
        description: 'New admin "$name" ($email) was created successfully',
        targetUserId: userCredential.user!.uid,
        targetUserName: name,
        details: {'organization': organization, 'permissions': permissions},
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

      // Log activity
      await _activityLog.logUserAction(
        action: 'Donor Registered',
        description: 'New donor "$name" ($bloodType) was registered',
        targetUserId: userCredential.user!.uid,
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

  /// Promote regular user to admin (Super Admin only)
  Future<void> promoteToAdmin({
    required String userId,
    String? organization,
    List<String> permissions = const ['manage_requests', 'view_analytics'],
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    // Get user data
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw Exception('User not found');
    }

    final userData = userDoc.data()!;
    final userName = userData['name'] ?? 'Unknown';
    final userEmail = userData['email'] ?? '';

    // Update user role to admin
    await _firestore.collection('users').doc(userId).update({
      'role': 'orgAdmin',
      'organization': organization,
      'permissions': permissions,
      'promotedAt': FieldValue.serverTimestamp(),
      'promotedBy': currentUser.uid,
    });

    // Log audit
    await _logAudit(
      action: 'PROMOTE_TO_ADMIN',
      targetUserId: userId,
      details: {
        'userName': userName,
        'userEmail': userEmail,
        'organization': organization,
        'permissions': permissions,
      },
    );

    // Log activity
    await _activityLog.logAdminAction(
      action: 'User Promoted to Admin',
      description: 'User "$userName" ($userEmail) was promoted to admin',
      targetUserId: userId,
      targetUserName: userName,
      details: {'organization': organization, 'permissions': permissions},
    );
  }

  /// Demote admin to regular user (Super Admin only)
  Future<void> demoteFromAdmin({
    required String adminId,
    String? bloodType,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    // Get admin data
    final adminDoc = await _firestore.collection('users').doc(adminId).get();
    if (!adminDoc.exists) {
      throw Exception('Admin not found');
    }

    final adminData = adminDoc.data()!;
    final adminName = adminData['name'] ?? 'Unknown';
    final adminEmail = adminData['email'] ?? '';

    // Update admin role to regular user
    await _firestore.collection('users').doc(adminId).update({
      'role': 'user',
      'bloodType': bloodType ?? 'A+',
      'organization': FieldValue.delete(),
      'permissions': FieldValue.delete(),
      'demotedAt': FieldValue.serverTimestamp(),
      'demotedBy': currentUser.uid,
    });

    // Log audit
    await _logAudit(
      action: 'DEMOTE_FROM_ADMIN',
      targetUserId: adminId,
      details: {
        'adminName': adminName,
        'adminEmail': adminEmail,
        'newBloodType': bloodType,
      },
    );

    // Log activity
    await _activityLog.logAdminAction(
      action: 'Admin Demoted to User',
      description:
          'Admin "$adminName" ($adminEmail) was demoted to regular user',
      targetUserId: adminId,
      targetUserName: adminName,
      details: {'bloodType': bloodType},
    );
  }

  /// Get all regular users (for promotion to admin)
  Stream<List<Map<String, dynamic>>> getAllRegularUsers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'user')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
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
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map((doc) => BloodRequest.fromFirestore(doc))
              .toList();
          // Sort client-side to avoid composite index requirement
          requests.sort((a, b) => b.requestDate.compareTo(a.requestDate));
          return requests;
        });
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

    // Log activity
    await _activityLog.logRequest(
      action: 'Blood Request Created',
      description:
          '$bloodType needed at $hospitalName for $patientName ($unitsNeeded units)',
      status: ActivityStatus.pending,
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
  Future<Map<String, dynamic>> getSystemStats({
    DateTime? startDate,
    DateTime? endDate,
    int? daysFilter, // 7, 30, 90 days
  }) async {
    // If daysFilter is provided, calculate startDate
    if (daysFilter != null) {
      startDate = DateTime.now().subtract(Duration(days: daysFilter));
    }

    Query requestsQuery = _firestore.collection('bloodRequests');
    Query donationsQuery = _firestore.collection('donations');

    if (startDate != null) {
      requestsQuery = requestsQuery.where(
        'requestDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
      donationsQuery = donationsQuery.where(
        'donationDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      requestsQuery = requestsQuery.where(
        'requestDate',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
      donationsQuery = donationsQuery.where(
        'donationDate',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    final requests = await requestsQuery.get();
    final donations = await donationsQuery.get();
    final admins = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'orgAdmin')
        .get();
    final users = await _firestore.collection('users').get();

    final totalRequests = requests.docs.length;
    final pendingRequests = requests.docs
        .where((d) => (d.data() as Map<String, dynamic>)['status'] == 'pending')
        .length;
    final fulfilledRequests = requests.docs
        .where(
          (d) => (d.data() as Map<String, dynamic>)['status'] == 'fulfilled',
        )
        .length;

    return {
      'totalRequests': totalRequests,
      'pendingRequests': pendingRequests,
      'fulfilledRequests': fulfilledRequests,
      'totalAdmins': admins.docs.length,
      'activeAdmins': admins.docs
          .where((d) => (d.data() as Map<String, dynamic>)['isActive'] == true)
          .length,
      'totalUsers': users.docs.length,
      'totalDonations': donations.docs.length,
      'totalUnits': donations.docs.fold<int>(
        0,
        (sum, doc) => sum + ((doc.data() as Map)['units'] as int? ?? 1),
      ),
    };
  }

  /// Get blood type distribution
  Future<Map<String, int>> getBloodTypeDistribution() async {
    final requests = await _firestore.collection('bloodRequests').get();
    final distribution = <String, int>{};

    for (var doc in requests.docs) {
      final bloodType =
          (doc.data() as Map<String, dynamic>)['bloodType'] ?? 'Unknown';
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

  Future<int> getLogsCount({String collection = 'auditLogs'}) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ==================== TIME-BASED ANALYTICS ====================

  /// Get statistics for last N days (7, 30, 90)
  Future<Map<String, dynamic>> getTimeBasedStats(int days) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    return getSystemStats(startDate: startDate);
  }

  /// Get donation statistics with time filter
  Future<Map<String, dynamic>> getDonationStats({
    DateTime? startDate,
    DateTime? endDate,
    int? daysFilter,
  }) async {
    if (daysFilter != null) {
      startDate = DateTime.now().subtract(Duration(days: daysFilter));
    }

    Query query = _firestore.collection('donations');

    if (startDate != null) {
      query = query.where(
        'donationDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      query = query.where(
        'donationDate',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    final snapshot = await query.get();

    Map<String, int> donationsByBloodType = {};
    Map<String, int> donationsByLocation = {};
    int totalUnits = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final bloodType = data['bloodType'] ?? 'Unknown';
      final location = data['location'] ?? 'Unknown';
      final units = data['units'] as int? ?? 1;

      donationsByBloodType[bloodType] =
          (donationsByBloodType[bloodType] ?? 0) + 1;
      donationsByLocation[location] = (donationsByLocation[location] ?? 0) + 1;
      totalUnits += units;
    }

    return {
      'totalDonations': snapshot.docs.length,
      'totalUnits': totalUnits,
      'donationsByBloodType': donationsByBloodType,
      'donationsByLocation': donationsByLocation,
      'averageUnitsPerDonation': snapshot.docs.length > 0
          ? (totalUnits / snapshot.docs.length).toStringAsFixed(2)
          : '0',
    };
  }

  /// Get request statistics with time filter
  Future<Map<String, dynamic>> getRequestStats({
    DateTime? startDate,
    DateTime? endDate,
    int? daysFilter,
  }) async {
    if (daysFilter != null) {
      startDate = DateTime.now().subtract(Duration(days: daysFilter));
    }

    Query query = _firestore.collection('bloodRequests');

    if (startDate != null) {
      query = query.where(
        'requestDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      query = query.where(
        'requestDate',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    final snapshot = await query.get();

    int pending = 0;
    int approved = 0;
    int fulfilled = 0;
    int cancelled = 0;
    Map<String, int> requestsByBloodType = {};
    Map<String, int> requestsByUrgency = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status']?.toString() ?? 'pending';
      final bloodType = data['bloodType'] ?? 'Unknown';
      final urgency = data['urgency']?.toString() ?? 'normal';

      switch (status.toLowerCase()) {
        case 'pending':
          pending++;
          break;
        case 'approved':
          approved++;
          break;
        case 'fulfilled':
          fulfilled++;
          break;
        case 'cancelled':
          cancelled++;
          break;
      }

      requestsByBloodType[bloodType] =
          (requestsByBloodType[bloodType] ?? 0) + 1;
      requestsByUrgency[urgency] = (requestsByUrgency[urgency] ?? 0) + 1;
    }

    final total = snapshot.docs.length;

    return {
      'totalRequests': total,
      'pending': pending,
      'approved': approved,
      'fulfilled': fulfilled,
      'cancelled': cancelled,
      'fulfillmentRate': total > 0
          ? (fulfilled / total * 100).toStringAsFixed(1)
          : '0',
      'requestsByBloodType': requestsByBloodType,
      'requestsByUrgency': requestsByUrgency,
    };
  }

  /// Get user growth statistics
  Future<Map<String, dynamic>> getUserGrowthStats({
    DateTime? startDate,
    DateTime? endDate,
    int? daysFilter,
  }) async {
    if (daysFilter != null) {
      startDate = DateTime.now().subtract(Duration(days: daysFilter));
    }

    Query query = _firestore.collection('users');

    if (startDate != null) {
      query = query.where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      query = query.where(
        'createdAt',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    final snapshot = await query.get();
    final allUsers = await _firestore.collection('users').get();

    int newDonors = 0;
    int newAdmins = 0;
    Map<String, int> usersByBloodType = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final role = data['role']?.toString() ?? 'user';
      final bloodType = data['bloodType'] ?? 'Unknown';

      if (role == 'user') {
        newDonors++;
        usersByBloodType[bloodType] = (usersByBloodType[bloodType] ?? 0) + 1;
      } else if (role == 'orgAdmin') {
        newAdmins++;
      }
    }

    return {
      'newUsers': snapshot.docs.length,
      'newDonors': newDonors,
      'newAdmins': newAdmins,
      'totalUsers': allUsers.docs.length,
      'usersByBloodType': usersByBloodType,
    };
  }

  /// Get comparative statistics (compare time periods)
  Future<Map<String, dynamic>> getComparativeStats({
    required int currentPeriodDays,
    required int previousPeriodDays,
  }) async {
    final currentStart = DateTime.now().subtract(
      Duration(days: currentPeriodDays),
    );
    final previousStart = DateTime.now().subtract(
      Duration(days: previousPeriodDays),
    );
    final previousEnd = currentStart;

    final currentStats = await getSystemStats(startDate: currentStart);
    final previousStats = await getSystemStats(
      startDate: previousStart,
      endDate: previousEnd,
    );

    int calcChange(int current, int previous) {
      if (previous == 0) return current > 0 ? 100 : 0;
      return (((current - previous) / previous) * 100).round();
    }

    return {
      'current': currentStats,
      'previous': previousStats,
      'changes': {
        'requests': calcChange(
          currentStats['totalRequests'] ?? 0,
          previousStats['totalRequests'] ?? 0,
        ),
        'donations': calcChange(
          currentStats['totalDonations'] ?? 0,
          previousStats['totalDonations'] ?? 0,
        ),
        'users': calcChange(
          currentStats['totalUsers'] ?? 0,
          previousStats['totalUsers'] ?? 0,
        ),
      },
    };
  }
}
