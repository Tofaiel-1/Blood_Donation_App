import 'package:cloud_firestore/cloud_firestore.dart';

class DonationCenter {
  final String id;
  final String name;
  final String address;
  final String area;
  final double latitude;
  final double longitude;
  final String phone;
  final String type; // hospital, blood_bank, mobile_unit
  final List<String> availableBloodTypes;
  final bool isActive;
  final Map<String, String> workingHours; // day: "9AM-5PM"
  final DateTime createdAt;

  DonationCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.type,
    required this.availableBloodTypes,
    this.isActive = true,
    required this.workingHours,
    required this.createdAt,
  });

  factory DonationCenter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DonationCenter(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      area: data['area'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      phone: data['phone'] ?? '',
      type: data['type'] ?? 'hospital',
      availableBloodTypes: List<String>.from(data['availableBloodTypes'] ?? []),
      isActive: data['isActive'] ?? true,
      workingHours: Map<String, String>.from(data['workingHours'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'type': type,
      'availableBloodTypes': availableBloodTypes,
      'isActive': isActive,
      'workingHours': workingHours,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Calculate distance from user's location (in kilometers)
  double distanceFrom(double userLat, double userLon) {
    const double earthRadius = 6371; // km

    final dLat = _toRadians(latitude - userLat);
    final dLon = _toRadians(longitude - userLon);

    final a =
        (dLat / 2).abs() * (dLat / 2).abs() +
        (userLat.abs() * latitude.abs() * (dLon / 2).abs() * (dLon / 2).abs());

    final c = 2 * (a < 1 ? a : 1 - a);

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * 3.14159265359 / 180;
  }
}

// Dhaka donation centers with real locations
class DhakaDonationCenters {
  static List<Map<String, dynamic>> getDefaultCenters() {
    return [
      {
        'name': 'ঢাকা মেডিকেল কলেজ হাসপাতাল',
        'address': 'বকশীবাজার, ঢাকা',
        'area': 'বকশীবাজার',
        'latitude': 23.7269,
        'longitude': 90.4078,
        'phone': '02-9668690',
        'type': 'hospital',
        'availableBloodTypes': [
          'A+',
          'A-',
          'B+',
          'B-',
          'O+',
          'O-',
          'AB+',
          'AB-',
        ],
        'workingHours': {
          'Saturday': '9:00 AM - 5:00 PM',
          'Sunday': '9:00 AM - 5:00 PM',
          'Monday': '9:00 AM - 5:00 PM',
          'Tuesday': '9:00 AM - 5:00 PM',
          'Wednesday': '9:00 AM - 5:00 PM',
          'Thursday': '9:00 AM - 5:00 PM',
          'Friday': 'Closed',
        },
      },
      {
        'name': 'শহীদ সোহরাওয়ার্দী মেডিকেল কলেজ',
        'address': 'শেরে বাংলা নগর, ঢাকা',
        'area': 'শেরে বাংলা নগর',
        'latitude': 23.7391,
        'longitude': 90.3765,
        'phone': '02-9127898',
        'type': 'hospital',
        'availableBloodTypes': [
          'A+',
          'A-',
          'B+',
          'B-',
          'O+',
          'O-',
          'AB+',
          'AB-',
        ],
        'workingHours': {
          'Saturday': '9:00 AM - 5:00 PM',
          'Sunday': '9:00 AM - 5:00 PM',
          'Monday': '9:00 AM - 5:00 PM',
          'Tuesday': '9:00 AM - 5:00 PM',
          'Wednesday': '9:00 AM - 5:00 PM',
          'Thursday': '9:00 AM - 5:00 PM',
          'Friday': 'Closed',
        },
      },
      {
        'name': 'স্যার সলিমুল্লাহ মেডিকেল কলেজ',
        'address': 'মিটফোর্ড, ঢাকা',
        'area': 'মিটফোর্ড',
        'latitude': 23.7153,
        'longitude': 90.4125,
        'phone': '02-7316341',
        'type': 'hospital',
        'availableBloodTypes': ['A+', 'B+', 'O+', 'AB+'],
        'workingHours': {
          'Saturday': '8:00 AM - 4:00 PM',
          'Sunday': '8:00 AM - 4:00 PM',
          'Monday': '8:00 AM - 4:00 PM',
          'Tuesday': '8:00 AM - 4:00 PM',
          'Wednesday': '8:00 AM - 4:00 PM',
          'Thursday': '8:00 AM - 4:00 PM',
          'Friday': 'Closed',
        },
      },
      {
        'name': 'বঙ্গবন্ধু শেখ মুজিব মেডিকেল বিশ্ববিদ্যালয়',
        'address': 'শাহবাগ, ঢাকা',
        'area': 'শাহবাগ',
        'latitude': 23.7387,
        'longitude': 90.3956,
        'phone': '02-9668690',
        'type': 'hospital',
        'availableBloodTypes': [
          'A+',
          'A-',
          'B+',
          'B-',
          'O+',
          'O-',
          'AB+',
          'AB-',
        ],
        'workingHours': {
          'Saturday': '9:00 AM - 5:00 PM',
          'Sunday': '9:00 AM - 5:00 PM',
          'Monday': '9:00 AM - 5:00 PM',
          'Tuesday': '9:00 AM - 5:00 PM',
          'Wednesday': '9:00 AM - 5:00 PM',
          'Thursday': '9:00 AM - 5:00 PM',
          'Friday': 'Emergency Only',
        },
      },
      {
        'name': 'কোয়ান্টাম ব্লাড ব্যাংক - মিরপুর',
        'address': 'মিরপুর ১০, ঢাকা',
        'area': 'মিরপুর',
        'latitude': 23.8069,
        'longitude': 90.3687,
        'phone': '01711-222222',
        'type': 'blood_bank',
        'availableBloodTypes': [
          'A+',
          'A-',
          'B+',
          'B-',
          'O+',
          'O-',
          'AB+',
          'AB-',
        ],
        'workingHours': {
          'Saturday': '9:00 AM - 9:00 PM',
          'Sunday': '9:00 AM - 9:00 PM',
          'Monday': '9:00 AM - 9:00 PM',
          'Tuesday': '9:00 AM - 9:00 PM',
          'Wednesday': '9:00 AM - 9:00 PM',
          'Thursday': '9:00 AM - 9:00 PM',
          'Friday': '9:00 AM - 9:00 PM',
        },
      },
      {
        'name': 'ঢাকা কমিউনিটি হাসপাতাল',
        'address': 'মগবাজার, ঢাকা',
        'area': 'মগবাজার',
        'latitude': 23.7459,
        'longitude': 90.4035,
        'phone': '02-8331717',
        'type': 'hospital',
        'availableBloodTypes': ['A+', 'B+', 'O+', 'AB+'],
        'workingHours': {
          'Saturday': '8:00 AM - 8:00 PM',
          'Sunday': '8:00 AM - 8:00 PM',
          'Monday': '8:00 AM - 8:00 PM',
          'Tuesday': '8:00 AM - 8:00 PM',
          'Wednesday': '8:00 AM - 8:00 PM',
          'Thursday': '8:00 AM - 8:00 PM',
          'Friday': '8:00 AM - 8:00 PM',
        },
      },
      {
        'name': 'উত্তরা ক্রিসেন্ট হাসপাতাল',
        'address': 'উত্তরা সেক্টর ৭, ঢাকা',
        'area': 'উত্তরা',
        'latitude': 23.8759,
        'longitude': 90.3795,
        'phone': '02-8963464',
        'type': 'hospital',
        'availableBloodTypes': ['A+', 'B+', 'O+', 'AB+', 'A-', 'O-'],
        'workingHours': {
          'Saturday': '9:00 AM - 6:00 PM',
          'Sunday': '9:00 AM - 6:00 PM',
          'Monday': '9:00 AM - 6:00 PM',
          'Tuesday': '9:00 AM - 6:00 PM',
          'Wednesday': '9:00 AM - 6:00 PM',
          'Thursday': '9:00 AM - 6:00 PM',
          'Friday': 'Closed',
        },
      },
      {
        'name': 'ধানমন্ডি জেনারেল হাসপাতাল',
        'address': 'ধানমন্ডি, ঢাকা',
        'area': 'ধানমন্ডি',
        'latitude': 23.7461,
        'longitude': 90.3742,
        'phone': '02-9665312',
        'type': 'hospital',
        'availableBloodTypes': ['A+', 'B+', 'O+', 'AB+'],
        'workingHours': {
          'Saturday': '9:00 AM - 5:00 PM',
          'Sunday': '9:00 AM - 5:00 PM',
          'Monday': '9:00 AM - 5:00 PM',
          'Tuesday': '9:00 AM - 5:00 PM',
          'Wednesday': '9:00 AM - 5:00 PM',
          'Thursday': '9:00 AM - 5:00 PM',
          'Friday': 'Emergency Only',
        },
      },
      {
        'name': 'গুলশান ক্লিনিক',
        'address': 'গুলশান ১, ঢাকা',
        'area': 'গুলশান',
        'latitude': 23.7808,
        'longitude': 90.4167,
        'phone': '02-9882722',
        'type': 'hospital',
        'availableBloodTypes': ['A+', 'B+', 'O+', 'AB+'],
        'workingHours': {
          'Saturday': '10:00 AM - 6:00 PM',
          'Sunday': '10:00 AM - 6:00 PM',
          'Monday': '10:00 AM - 6:00 PM',
          'Tuesday': '10:00 AM - 6:00 PM',
          'Wednesday': '10:00 AM - 6:00 PM',
          'Thursday': '10:00 AM - 6:00 PM',
          'Friday': 'Closed',
        },
      },
      {
        'name': 'মোহাম্মদপুর মেডিকেল সেন্টার',
        'address': 'মোহাম্মদপুর, ঢাকা',
        'area': 'মোহাম্মদপুর',
        'latitude': 23.7656,
        'longitude': 90.3563,
        'phone': '02-9129547',
        'type': 'hospital',
        'availableBloodTypes': ['A+', 'B+', 'O+'],
        'workingHours': {
          'Saturday': '9:00 AM - 5:00 PM',
          'Sunday': '9:00 AM - 5:00 PM',
          'Monday': '9:00 AM - 5:00 PM',
          'Tuesday': '9:00 AM - 5:00 PM',
          'Wednesday': '9:00 AM - 5:00 PM',
          'Thursday': '9:00 AM - 5:00 PM',
          'Friday': 'Closed',
        },
      },
    ];
  }
}
