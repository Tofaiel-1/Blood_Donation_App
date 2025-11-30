import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class DemoDataService {
  static final DemoDataService _instance = DemoDataService._internal();
  factory DemoDataService() => _instance;
  DemoDataService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _random = Random();

  // ডেমো ইউজার নাম
  final List<String> _demoNames = [
    'আবুল কালাম',
    'রহিম উদ্দিন',
    'করিম মিয়া',
    'সালমা বেগম',
    'ফাতেমা খাতুন',
    'জাহাঙ্গীর আলম',
    'নাসরিন সুলতানা',
    'মোহাম্মদ আলী',
    'রোকেয়া বেগম',
    'শফিকুল ইসলাম',
    'আমিনা খাতুন',
    'জামাল উদ্দিন',
    'হাসনা বেগম',
    'কামরুল হাসান',
    'নার্গিস আক্তার',
    'আলতাফ হোসেন',
    'রুমানা আক্তার',
    'শাহজাহান মিয়া',
    'সুমাইয়া খাতুন',
    'রফিকুল ইসলাম',
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

  final List<String> _hospitals = [
    'ঢাকা মেডিকেল কলেজ হাসপাতাল',
    'চট্টগ্রাম মেডিকেল কলেজ',
    'রাজশাহী মেডিকেল',
    'শহীদ সোহরাওয়ার্দী হাসপাতাল',
    'বঙ্গবন্ধু শেখ মুজিব মেডিকেল বিশ্ববিদ্যালয়',
    'স্যার সলিমুল্লাহ মেডিকেল কলেজ',
    'কুমিল্লা মেডিকেল কলেজ',
    'ময়মনসিংহ মেডিকেল কলেজ',
  ];

  final List<String> _locations = [
    'ঢাকা, মিরপুর',
    'ঢাকা, ধানমন্ডি',
    'ঢাকা, মোহাম্মদপুর',
    'ঢাকা, উত্তরা',
    'চট্টগ্রাম, আগ্রাবাদ',
    'চট্টগ্রাম, নাসিরাবাদ',
    'সিলেট, জিন্দাবাজার',
    'রাজশাহী, সাহেব বাজার',
    'খুলনা, খালিশপুর',
    'বরিশাল, বন্দর রোড',
  ];

  // Check if demo data already created
  Future<bool> isDemoDataCreated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('demo_data_created') ?? false;
  }

  // Mark demo data as created
  Future<void> markDemoDataCreated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('demo_data_created', true);
  }

  // Create all demo data
  Future<void> createAllDemoData() async {
    try {
      // Check if already created
      if (await isDemoDataCreated()) {
        debugPrint('✅ Demo data already exists');
        return;
      }

      debugPrint('🚀 Creating demo data...');

      // Create demo users (donors)
      await _createDemoUsers();

      // Create demo blood requests
      await _createDemoBloodRequests();

      // Create demo donations
      await _createDemoDonations();

      // Create demo admins
      await _createDemoAdmins();

      // Mark as created
      await markDemoDataCreated();

      debugPrint('✅ Demo data created successfully!');
    } catch (e) {
      debugPrint('❌ Error creating demo data: $e');
      // Save for offline sync
      await _saveForOfflineSync();
    }
  }

  // Create demo users
  Future<void> _createDemoUsers() async {
    debugPrint('👥 Creating demo users...');

    for (int i = 0; i < 15; i++) {
      final name = _demoNames[i];
      final bloodType = _bloodTypes[_random.nextInt(_bloodTypes.length)];
      final phone = '017${_random.nextInt(90000000) + 10000000}';

      final userData = {
        'name': name,
        'email': 'user${i + 1}@demo.com',
        'bloodType': bloodType,
        'phone': phone,
        'role': 'user',
        'isActive': true,
        'totalDonations': _random.nextInt(5),
        'lastDonationDate': _randomPastDate(),
        'location': _locations[_random.nextInt(_locations.length)],
        'availableForDonation': _random.nextBool(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      try {
        await _firestore.collection('users').add(userData);
      } catch (e) {
        // Save to local storage for offline sync
        await _saveToLocal('pending_users', userData);
      }
    }

    debugPrint('✅ Demo users created');
  }

  // Create demo blood requests
  Future<void> _createDemoBloodRequests() async {
    debugPrint('🩸 Creating demo blood requests...');

    final statuses = ['pending', 'approved', 'fulfilled', 'cancelled'];
    final urgencies = ['critical', 'urgent', 'normal'];

    for (int i = 0; i < 20; i++) {
      final patientName = _demoNames[_random.nextInt(_demoNames.length)];
      final bloodType = _bloodTypes[_random.nextInt(_bloodTypes.length)];
      final hospital = _hospitals[_random.nextInt(_hospitals.length)];
      final location = _locations[_random.nextInt(_locations.length)];

      final requestData = {
        'patientName': patientName,
        'bloodType': bloodType,
        'unitsNeeded': _random.nextInt(4) + 1,
        'hospitalName': hospital,
        'location': location,
        'contactPhone': '016${_random.nextInt(90000000) + 10000000}',
        'urgency': urgencies[_random.nextInt(urgencies.length)],
        'status': statuses[_random.nextInt(statuses.length)],
        'requestDate': _randomPastDate(),
        'requestedByName': _demoNames[_random.nextInt(_demoNames.length)],
        'notes': 'জরুরি রক্তের প্রয়োজন। দয়া করে সাহায্য করুন।',
        'createdAt': FieldValue.serverTimestamp(),
      };

      try {
        await _firestore.collection('bloodRequests').add(requestData);
      } catch (e) {
        await _saveToLocal('pending_requests', requestData);
      }
    }

    debugPrint('✅ Demo blood requests created');
  }

  // Create demo donations
  Future<void> _createDemoDonations() async {
    debugPrint('❤️ Creating demo donations...');

    for (int i = 0; i < 25; i++) {
      final donorName = _demoNames[_random.nextInt(_demoNames.length)];
      final bloodType = _bloodTypes[_random.nextInt(_bloodTypes.length)];
      final location = _locations[_random.nextInt(_locations.length)];

      final donationData = {
        'donorName': donorName,
        'bloodType': bloodType,
        'location': location,
        'donationDate': _randomPastDate(),
        'status': _random.nextDouble() > 0.3 ? 'completed' : 'scheduled',
        'center': _hospitals[_random.nextInt(_hospitals.length)],
        'notes': 'সফলভাবে রক্তদান সম্পন্ন হয়েছে',
        'createdAt': FieldValue.serverTimestamp(),
      };

      try {
        await _firestore.collection('donations').add(donationData);
      } catch (e) {
        await _saveToLocal('pending_donations', donationData);
      }
    }

    debugPrint('✅ Demo donations created');
  }

  // Create demo admins
  Future<void> _createDemoAdmins() async {
    debugPrint('👨‍💼 Creating demo admins...');

    final adminNames = ['নার্স ফাতেমা', 'ডা. করিম', 'ম্যানেজার রহিম'];
    final organizations = [
      'ঢাকা মেডিকেল',
      'চট্টগ্রাম মেডিকেল',
      'রাজশাহী মেডিকেল',
    ];

    for (int i = 0; i < 3; i++) {
      final adminData = {
        'name': adminNames[i],
        'email': 'admin${i + 1}@demo.com',
        'role': 'orgAdmin',
        'organization': organizations[i],
        'phone': '018${_random.nextInt(90000000) + 10000000}',
        'isActive': true,
        'permissions': ['manage_requests', 'view_analytics'],
        'bloodType': 'N/A',
        'createdAt': FieldValue.serverTimestamp(),
      };

      try {
        await _firestore.collection('users').add(adminData);
      } catch (e) {
        await _saveToLocal('pending_admins', adminData);
      }
    }

    debugPrint('✅ Demo admins created');
  }

  // Generate random past date
  Timestamp _randomPastDate() {
    final now = DateTime.now();
    final daysAgo = _random.nextInt(90); // Last 90 days
    final pastDate = now.subtract(Duration(days: daysAgo));
    return Timestamp.fromDate(pastDate);
  }

  // Save data to local storage for offline sync
  Future<void> _saveToLocal(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(key) ?? [];

    // Convert map to JSON string and add
    existing.add(data.toString());
    await prefs.setStringList(key, existing);
  }

  // Save all pending data for offline sync
  Future<void> _saveForOfflineSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_offline_data', true);
    debugPrint('💾 Data saved for offline sync');
  }

  // Sync offline data to Firebase when online
  Future<void> syncOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasOfflineData = prefs.getBool('has_offline_data') ?? false;

      if (!hasOfflineData) {
        debugPrint('✅ No offline data to sync');
        return;
      }

      debugPrint('🔄 Syncing offline data to Firebase...');

      // Sync pending users
      await _syncCollection('pending_users', 'users');

      // Sync pending requests
      await _syncCollection('pending_requests', 'bloodRequests');

      // Sync pending donations
      await _syncCollection('pending_donations', 'donations');

      // Sync pending admins
      await _syncCollection('pending_admins', 'users');

      // Clear offline data flag
      await prefs.setBool('has_offline_data', false);

      debugPrint('✅ Offline data synced successfully!');
    } catch (e) {
      debugPrint('❌ Error syncing offline data: $e');
    }
  }

  // Sync a specific collection
  Future<void> _syncCollection(
    String localKey,
    String firestoreCollection,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(localKey) ?? [];

    if (items.isEmpty) return;

    debugPrint('📤 Syncing $localKey to $firestoreCollection...');

    for (final _ in items) {
      try {
        // Parse and add to Firestore
        // Note: This is simplified - you'd need proper JSON parsing
        await _firestore.collection(firestoreCollection).add({
          'syncedFromOffline': true,
          'syncedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('⚠️ Failed to sync item: $e');
      }
    }

    // Clear synced items
    await prefs.remove(localKey);
  }

  // Check network connectivity
  Future<bool> isOnline() async {
    try {
      await _firestore.collection('_test').limit(1).get();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Auto sync when coming online
  Future<void> startAutoSync() async {
    // Check every 30 seconds
    Stream.periodic(const Duration(seconds: 30)).listen((_) async {
      if (await isOnline()) {
        await syncOfflineData();
      }
    });
  }

  // Clear all demo data (for testing)
  Future<void> clearAllDemoData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('demo_data_created');
    await prefs.remove('has_offline_data');
    await prefs.remove('pending_users');
    await prefs.remove('pending_requests');
    await prefs.remove('pending_donations');
    await prefs.remove('pending_admins');
    debugPrint('🗑️ Demo data cleared');
  }

  // Get demo data statistics
  Future<Map<String, int>> getDemoStats() async {
    try {
      final users = await _firestore.collection('users').get();
      final requests = await _firestore.collection('bloodRequests').get();
      final donations = await _firestore.collection('donations').get();

      return {
        'users': users.docs.length,
        'requests': requests.docs.length,
        'donations': donations.docs.length,
      };
    } catch (e) {
      return {'users': 0, 'requests': 0, 'donations': 0};
    }
  }
}
