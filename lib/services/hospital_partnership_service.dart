import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hospital_partnership.dart';

class HospitalPartnershipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create partnership application
  Future<HospitalPartnership> createPartnershipApplication({
    required String userId,
    required String hospitalName,
    required String registrationNumber,
    required String contactPerson,
    required String contactPhone,
    required String contactEmail,
    required String address,
    String? division,
    String? district,
    String? upazila,
    double? latitude,
    double? longitude,
    required PartnershipPlan plan,
    List<String>? availableBloodGroups,
    bool hasBloodBank = false,
    bool hasEmergencyService = false,
    String? website,
  }) async {
    try {
      final docRef = _firestore.collection('hospital_partnerships').doc();

      final now = DateTime.now();
      final partnership = HospitalPartnership(
        id: docRef.id,
        userId: userId,
        hospitalName: hospitalName,
        registrationNumber: registrationNumber,
        contactPerson: contactPerson,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
        address: address,
        division: division,
        district: district,
        upazila: upazila,
        latitude: latitude,
        longitude: longitude,
        plan: plan,
        status: PartnershipStatus.pending,
        monthlyFee: HospitalPartnership.getPlanPrice(plan),
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        availableBloodGroups: availableBloodGroups ?? [],
        hasBloodBank: hasBloodBank,
        hasEmergencyService: hasEmergencyService,
        website: website,
        createdAt: now,
      );

      await docRef.set(partnership.toMap());
      return partnership;
    } catch (e) {
      throw Exception('Failed to create partnership application: $e');
    }
  }

  // Activate partnership after payment
  Future<void> activatePartnership(
    String partnershipId,
    String transactionId,
  ) async {
    try {
      final now = DateTime.now();
      await _firestore
          .collection('hospital_partnerships')
          .doc(partnershipId)
          .update({
            'status': PartnershipStatus.active.toString().split('.').last,
            'paymentTransactionId': transactionId,
            'startDate': Timestamp.fromDate(now),
            'endDate': Timestamp.fromDate(now.add(const Duration(days: 30))),
          });

      // Update user as hospital partner
      final doc = await _firestore
          .collection('hospital_partnerships')
          .doc(partnershipId)
          .get();

      if (doc.exists) {
        final partnership = HospitalPartnership.fromMap(doc.data()!);
        await _firestore.collection('users').doc(partnership.userId).update({
          'isHospitalPartner': true,
          'partnershipId': partnershipId,
        });
      }
    } catch (e) {
      throw Exception('Failed to activate partnership: $e');
    }
  }

  // Verify partnership
  Future<void> verifyPartnership(String partnershipId) async {
    try {
      await _firestore
          .collection('hospital_partnerships')
          .doc(partnershipId)
          .update({
            'isVerified': true,
            'verifiedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to verify partnership: $e');
    }
  }

  // Suspend partnership
  Future<void> suspendPartnership(String partnershipId) async {
    try {
      await _firestore
          .collection('hospital_partnerships')
          .doc(partnershipId)
          .update({
            'status': PartnershipStatus.suspended.toString().split('.').last,
          });
    } catch (e) {
      throw Exception('Failed to suspend partnership: $e');
    }
  }

  // Renew partnership
  Future<void> renewPartnership(
    String partnershipId,
    String transactionId,
  ) async {
    try {
      final doc = await _firestore
          .collection('hospital_partnerships')
          .doc(partnershipId)
          .get();

      if (doc.exists) {
        final partnership = HospitalPartnership.fromMap(doc.data()!);
        final newEndDate = partnership.endDate.add(const Duration(days: 30));

        await _firestore
            .collection('hospital_partnerships')
            .doc(partnershipId)
            .update({
              'endDate': Timestamp.fromDate(newEndDate),
              'status': PartnershipStatus.active.toString().split('.').last,
              'paymentTransactionId': transactionId,
            });
      }
    } catch (e) {
      throw Exception('Failed to renew partnership: $e');
    }
  }

  // Get all active partnerships
  Stream<List<HospitalPartnership>> getActivePartnerships() {
    return _firestore
        .collection('hospital_partnerships')
        .where(
          'status',
          isEqualTo: PartnershipStatus.active.toString().split('.').last,
        )
        .orderBy('isFeatured', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HospitalPartnership.fromMap(doc.data()))
              .where((p) => p.isActive)
              .toList(),
        );
  }

  // Get partnerships by location
  Stream<List<HospitalPartnership>> getPartnershipsByLocation({
    String? division,
    String? district,
    String? upazila,
  }) {
    Query query = _firestore
        .collection('hospital_partnerships')
        .where(
          'status',
          isEqualTo: PartnershipStatus.active.toString().split('.').last,
        );

    if (division != null) {
      query = query.where('division', isEqualTo: division);
    }
    if (district != null) {
      query = query.where('district', isEqualTo: district);
    }
    if (upazila != null) {
      query = query.where('upazila', isEqualTo: upazila);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) =>
                HospitalPartnership.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  // Get user's partnership
  Future<HospitalPartnership?> getUserPartnership(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('hospital_partnerships')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return HospitalPartnership.fromMap(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user partnership: $e');
    }
  }

  // Search partnerships
  Stream<List<HospitalPartnership>> searchPartnerships(String query) {
    return _firestore
        .collection('hospital_partnerships')
        .where(
          'status',
          isEqualTo: PartnershipStatus.active.toString().split('.').last,
        )
        .snapshots()
        .map((snapshot) {
          final partnerships = snapshot.docs
              .map(
                (doc) => HospitalPartnership.fromMap(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();

          // Filter by search query
          return partnerships.where((p) {
            final searchLower = query.toLowerCase();
            return p.hospitalName.toLowerCase().contains(searchLower) ||
                p.address.toLowerCase().contains(searchLower) ||
                (p.division?.toLowerCase().contains(searchLower) ?? false) ||
                (p.district?.toLowerCase().contains(searchLower) ?? false);
          }).toList();
        });
  }
}
