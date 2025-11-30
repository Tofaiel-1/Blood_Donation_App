import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class BangladeshDemoDataService {
  static final BangladeshDemoDataService _instance =
      BangladeshDemoDataService._internal();
  factory BangladeshDemoDataService() => _instance;
  BangladeshDemoDataService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _random = Random();

  // Bangladeshi names
  final List<Map<String, String>> _bangladeshiUsers = [
    {'name': 'মো. রহিম উদ্দিন', 'email': 'rahim.uddin@gmail.com'},
    {'name': 'আবুল কালাম আজাদ', 'email': 'abul.kalam@gmail.com'},
    {'name': 'সালমা বেগম', 'email': 'salma.begum@gmail.com'},
    {'name': 'ফাতেমা খাতুন', 'email': 'fatema.khatun@gmail.com'},
    {'name': 'মো. করিম মিয়া', 'email': 'karim.mia@gmail.com'},
    {'name': 'জাহাঙ্গীর আলম', 'email': 'jahangir.alam@gmail.com'},
    {'name': 'নাসরিন সুলতানা', 'email': 'nasrin.sultana@gmail.com'},
    {'name': 'মো. আলী হোসেন', 'email': 'ali.hosen@gmail.com'},
    {'name': 'রোকেয়া বেগম', 'email': 'rokeya.begum@gmail.com'},
    {'name': 'শফিকুল ইসলাম', 'email': 'shafiqul.islam@gmail.com'},
    {'name': 'আমিনা খাতুন', 'email': 'amina.khatun@gmail.com'},
    {'name': 'জামাল উদ্দিন', 'email': 'jamal.uddin@gmail.com'},
    {'name': 'হাসনা বেগম', 'email': 'hasna.begum@gmail.com'},
    {'name': 'কামরুল হাসান', 'email': 'kamrul.hasan@gmail.com'},
    {'name': 'নার্গিস আক্তার', 'email': 'nargis.akter@gmail.com'},
    {'name': 'আলতাফ হোসেন', 'email': 'altaf.hosen@gmail.com'},
    {'name': 'রুমানা আক্তার', 'email': 'rumana.akter@gmail.com'},
    {'name': 'শাহজাহান মিয়া', 'email': 'shahjahan.mia@gmail.com'},
    {'name': 'সুমাইয়া খাতুন', 'email': 'sumaiya.khatun@gmail.com'},
    {'name': 'রফিকুল ইসলাম', 'email': 'rafiqul.islam@gmail.com'},
  ];

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  // Dhaka areas with coordinates
  final List<Map<String, dynamic>> _dhakaLocations = [
    {'area': 'মিরপুর ১০', 'lat': 23.8069, 'lon': 90.3687, 'district': 'ঢাকা'},
    {'area': 'ধানমন্ডি', 'lat': 23.7461, 'lon': 90.3742, 'district': 'ঢাকা'},
    {'area': 'মোহাম্মদপুর', 'lat': 23.7656, 'lon': 90.3563, 'district': 'ঢাকা'},
    {
      'area': 'উত্তরা সেক্টর ৭',
      'lat': 23.8759,
      'lon': 90.3795,
      'district': 'ঢাকা',
    },
    {'area': 'গুলশান ১', 'lat': 23.7808, 'lon': 90.4167, 'district': 'ঢাকা'},
    {'area': 'বনানী', 'lat': 23.7939, 'lon': 90.4067, 'district': 'ঢাকা'},
    {'area': 'শাহবাগ', 'lat': 23.7387, 'lon': 90.3956, 'district': 'ঢাকা'},
    {'area': 'মগবাজার', 'lat': 23.7459, 'lon': 90.4035, 'district': 'ঢাকা'},
    {'area': 'বকশীবাজার', 'lat': 23.7269, 'lon': 90.4078, 'district': 'ঢাকা'},
    {'area': 'মিটফোর্ড', 'lat': 23.7153, 'lon': 90.4125, 'district': 'ঢাকা'},
  ];

  final List<String> _hospitals = [
    'ঢাকা মেডিকেল কলেজ হাসপাতাল',
    'শহীদ সোহরাওয়ার্দী মেডিকেল কলেজ',
    'স্যার সলিমুল্লাহ মেডিকেল কলেজ',
    'বঙ্গবন্ধু শেখ মুজিব মেডিকেল বিশ্ববিদ্যালয়',
    'ঢাকা কমিউনিটি হাসপাতাল',
    'উত্তরা ক্রিসেন্ট হাসপাতাল',
    'ধানমন্ডি জেনারেল হাসপাতাল',
    'গুলশান ক্লিনিক',
  ];

  // Organizations
  final List<Map<String, String>> _organizations = [
    {'name': 'সন্ধানী', 'email': 'sandhani@gmail.com'},
    {'name': 'রেড ক্রিসেন্ট', 'email': 'redcrescent@gmail.com'},
    {'name': 'বাঁধন', 'email': 'badhon@gmail.com'},
    {'name': 'কোয়ান্টাম', 'email': 'quantum@gmail.com'},
    {'name': 'পুলিশ ব্লাড ব্যাংক', 'email': 'police.blood@gmail.com'},
  ];

  // Generate Bangladeshi phone number
  String _generateBDPhone() {
    final operators = ['013', '014', '015', '016', '017', '018', '019'];
    final operator = operators[_random.nextInt(operators.length)];
    final restDigits = List.generate(8, (_) => _random.nextInt(10)).join();
    return '$operator$restDigits';
  }

  // Create comprehensive demo data with clear donation tracking
  Future<void> createBangladeshDemoData() async {
    try {
      debugPrint('🇧🇩 Creating Bangladesh Demo Data...');

      // Step 1: Create Users
      final userIds = await _createBangladeshiUsers();
      debugPrint('✅ Created ${userIds.length} users');

      // Step 2: Create Admins & Organizations
      await _createAdmins();
      debugPrint('✅ Created admins and organizations');

      // Step 3: Create Blood Requests
      await _createBloodRequests(userIds);
      debugPrint('✅ Created blood requests');

      // Step 4: Create Donations with clear tracking
      await _createDonationsWithTracking(userIds);
      debugPrint('✅ Created donations with tracking');

      debugPrint('🎉 Bangladesh Demo Data Created Successfully!');
    } catch (e) {
      debugPrint('❌ Error creating demo data: $e');
      rethrow;
    }
  }

  Future<List<String>> _createBangladeshiUsers() async {
    final List<String> userIds = [];

    for (int i = 0; i < _bangladeshiUsers.length; i++) {
      final user = _bangladeshiUsers[i];
      final location = _dhakaLocations[i % _dhakaLocations.length];
      final bloodType = _bloodTypes[_random.nextInt(_bloodTypes.length)];
      final phone = _generateBDPhone();

      // Create user document with ID
      final docRef = _firestore.collection('users').doc();
      await docRef.set({
        'name': user['name'],
        'email': user['email'],
        'bloodType': bloodType,
        'phone': phone,
        'role': 'user',
        'isActive': true,
        'availableForDonation': _random.nextBool(),
        'totalDonations': _random.nextInt(5),
        'location': location['area'],
        'district': location['district'],
        'latitude': location['lat'],
        'longitude': location['lon'],
        'lastDonationDate': _randomPastDate(120),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      userIds.add(docRef.id);
    }

    return userIds;
  }

  Future<void> _createAdmins() async {
    for (var org in _organizations) {
      final phone = _generateBDPhone();

      // Create admin user
      await _firestore.collection('users').add({
        'name': '${org['name']} এডমিন',
        'email': org['email'],
        'phone': phone,
        'role': 'orgAdmin',
        'organization': org['name'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _createBloodRequests(List<String> userIds) async {
    final statuses = ['pending', 'approved', 'fulfilled', 'cancelled'];
    final urgencies = ['critical', 'urgent', 'normal'];

    for (int i = 0; i < 15; i++) {
      final requester =
          _bangladeshiUsers[_random.nextInt(_bangladeshiUsers.length)];
      final location = _dhakaLocations[_random.nextInt(_dhakaLocations.length)];
      final bloodType = _bloodTypes[_random.nextInt(_bloodTypes.length)];
      final hospital = _hospitals[_random.nextInt(_hospitals.length)];
      final phone = _generateBDPhone();

      await _firestore.collection('bloodRequests').add({
        'patientName': requester['name'],
        'bloodType': bloodType,
        'unitsNeeded': _random.nextInt(3) + 1,
        'hospitalName': hospital,
        'location': location['area'],
        'district': location['district'],
        'latitude': location['lat'],
        'longitude': location['lon'],
        'contactPhone': phone,
        'urgency': urgencies[_random.nextInt(urgencies.length)],
        'status': statuses[_random.nextInt(statuses.length)],
        'requestDate': _randomPastDate(30),
        'requestedBy': userIds[_random.nextInt(userIds.length)],
        'requestedByName': requester['name'],
        'notes': 'জরুরি রক্তের প্রয়োজন। দয়া করে সাহায্য করুন।',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _createDonationsWithTracking(List<String> userIds) async {
    // Create matched donations - clear tracking of who gave and who received
    for (int i = 0; i < 20; i++) {
      final donorIndex = _random.nextInt(userIds.length);
      final recipientIndex =
          (donorIndex + _random.nextInt(userIds.length - 1) + 1) %
          userIds.length;

      final donor = _bangladeshiUsers[donorIndex];
      final recipient = _bangladeshiUsers[recipientIndex];
      final location = _dhakaLocations[_random.nextInt(_dhakaLocations.length)];
      final bloodType = _bloodTypes[_random.nextInt(_bloodTypes.length)];
      final hospital = _hospitals[_random.nextInt(_hospitals.length)];
      final donationDate = _randomPastDate(90);

      // Create donation record with clear donor and recipient
      await _firestore.collection('donations').add({
        // Donor information
        'donorId': userIds[donorIndex],
        'donorName': donor['name'],
        'donorPhone': _generateBDPhone(),
        'donorBloodType': bloodType,

        // Recipient information
        'recipientId': userIds[recipientIndex],
        'recipientName': recipient['name'],
        'recipientPhone': _generateBDPhone(),

        // Donation details
        'bloodType': bloodType,
        'unitsCollected': 1,
        'donationDate': donationDate,
        'status': 'completed',

        // Location details
        'location': location['area'],
        'district': location['district'],
        'latitude': location['lat'],
        'longitude': location['lon'],
        'center': hospital,

        // Additional info
        'notes': 'সফলভাবে রক্তদান সম্পন্ন হয়েছে',
        'testResults': 'Negative',
        'bloodPressure': '120/80',
        'hemoglobin': '${13 + _random.nextInt(4)}.${_random.nextInt(10)}',

        // Tracking
        'matchedByLocation': true,
        'distanceKm': _random.nextDouble() * 5, // Within 5 km
        'matchedAt': donationDate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update donor's total donations
      await _firestore.collection('users').doc(userIds[donorIndex]).update({
        'totalDonations': FieldValue.increment(1),
        'lastDonationDate': donationDate,
      });
    }
  }

  Timestamp _randomPastDate(int maxDaysAgo) {
    final now = DateTime.now();
    final daysAgo = _random.nextInt(maxDaysAgo);
    final pastDate = now.subtract(Duration(days: daysAgo));
    return Timestamp.fromDate(pastDate);
  }

  // Get statistics
  Future<Map<String, dynamic>> getDemoStats() async {
    try {
      final users = await _firestore.collection('users').get();
      final requests = await _firestore.collection('bloodRequests').get();
      final donations = await _firestore.collection('donations').get();

      // Count location-based matches
      int locationMatches = 0;
      for (var doc in donations.docs) {
        if (doc.data()['matchedByLocation'] == true) {
          locationMatches++;
        }
      }

      return {
        'totalUsers': users.docs.length,
        'totalRequests': requests.docs.length,
        'totalDonations': donations.docs.length,
        'locationBasedMatches': locationMatches,
        'matchPercentage': donations.docs.isEmpty
            ? 0
            : (locationMatches / donations.docs.length * 100).toStringAsFixed(
                1,
              ),
      };
    } catch (e) {
      debugPrint('Error getting stats: $e');
      return {
        'totalUsers': 0,
        'totalRequests': 0,
        'totalDonations': 0,
        'locationBasedMatches': 0,
        'matchPercentage': '0',
      };
    }
  }

  // Clear all demo data
  Future<void> clearDemoData() async {
    try {
      // Delete users
      final users = await _firestore.collection('users').get();
      for (var doc in users.docs) {
        await doc.reference.delete();
      }

      // Delete blood requests
      final requests = await _firestore.collection('bloodRequests').get();
      for (var doc in requests.docs) {
        await doc.reference.delete();
      }

      // Delete donations
      final donations = await _firestore.collection('donations').get();
      for (var doc in donations.docs) {
        await doc.reference.delete();
      }

      debugPrint('✅ All demo data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
      rethrow;
    }
  }
}

// Go to Firebase Console → Authentication
// Enable "Phone" sign-in method
// Add test phone numbers for testing
// Add SHA-1 fingerprint to Firebase project
// Run: cd android && ./gradlew signingReport
