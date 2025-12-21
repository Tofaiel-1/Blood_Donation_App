import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Donor Health Tracker Service
/// Track health metrics before donation for safety
class DonorHealthTrackerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final DonorHealthTrackerService _instance =
      DonorHealthTrackerService._internal();
  factory DonorHealthTrackerService() => _instance;
  DonorHealthTrackerService._internal();

  /// Health metrics model
  static const Map<String, dynamic> healthMetrics = {
    'hemoglobin': {'min': 12.5, 'max': 18.0, 'unit': 'g/dL'},
    'bloodPressure': {'systolic': 120, 'diastolic': 80},
    'weight': {'min': 50.0, 'unit': 'kg'},
    'temperature': {'min': 36.0, 'max': 37.5, 'unit': '°C'},
    'pulse': {'min': 60, 'max': 100, 'unit': 'bpm'},
  };

  /// Save health record
  Future<void> saveHealthRecord({
    required String userId,
    required double hemoglobinLevel,
    required String bloodPressure, // "120/80"
    required double weight,
    required double temperature,
    required int pulse,
    required int sleepHours,
    required String hydrationLevel, // good/moderate/low
    required DateTime lastMealTime,
    List<String>? medications,
    String? notes,
  }) async {
    final eligibilityScore = _calculateEligibilityScore(
      hemoglobinLevel: hemoglobinLevel,
      bloodPressure: bloodPressure,
      weight: weight,
      temperature: temperature,
      pulse: pulse,
      sleepHours: sleepHours,
      hydrationLevel: hydrationLevel,
      medications: medications,
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('healthRecords')
        .add({
          'hemoglobinLevel': hemoglobinLevel,
          'bloodPressure': bloodPressure,
          'weight': weight,
          'temperature': temperature,
          'pulse': pulse,
          'sleepHours': sleepHours,
          'hydrationLevel': hydrationLevel,
          'lastMealTime': Timestamp.fromDate(lastMealTime),
          'medications': medications ?? [],
          'notes': notes,
          'eligibilityScore': eligibilityScore,
          'isEligible': eligibilityScore >= 70,
          'timestamp': FieldValue.serverTimestamp(),
        });

    // Update user's latest health record
    await _firestore.collection('users').doc(userId).update({
      'latestHealthRecord': {
        'hemoglobinLevel': hemoglobinLevel,
        'bloodPressure': bloodPressure,
        'weight': weight,
        'eligibilityScore': eligibilityScore,
        'lastUpdated': FieldValue.serverTimestamp(),
      },
    });
  }

  /// Calculate eligibility score (0-100)
  int _calculateEligibilityScore({
    required double hemoglobinLevel,
    required String bloodPressure,
    required double weight,
    required double temperature,
    required int pulse,
    required int sleepHours,
    required String hydrationLevel,
    List<String>? medications,
  }) {
    int score = 100;

    // Hemoglobin check (20 points)
    if (hemoglobinLevel < 12.5) {
      score -= 20;
    } else if (hemoglobinLevel < 13.0) {
      score -= 10;
    }

    // Blood pressure check (20 points)
    final bpParts = bloodPressure.split('/');
    if (bpParts.length == 2) {
      final systolic = int.tryParse(bpParts[0]) ?? 120;
      final diastolic = int.tryParse(bpParts[1]) ?? 80;
      if (systolic > 140 || systolic < 90 || diastolic > 90 || diastolic < 60) {
        score -= 20;
      } else if (systolic > 130 || diastolic > 85) {
        score -= 10;
      }
    }

    // Weight check (15 points)
    if (weight < 50.0) {
      score -= 15;
    } else if (weight < 52.0) {
      score -= 8;
    }

    // Temperature check (15 points)
    if (temperature > 37.5 || temperature < 36.0) {
      score -= 15;
    }

    // Pulse check (10 points)
    if (pulse > 100 || pulse < 60) {
      score -= 10;
    }

    // Sleep check (10 points)
    if (sleepHours < 6) {
      score -= 10;
    } else if (sleepHours < 7) {
      score -= 5;
    }

    // Hydration check (5 points)
    if (hydrationLevel == 'low') {
      score -= 5;
    } else if (hydrationLevel == 'moderate') {
      score -= 2;
    }

    // Medication check (5 points)
    if (medications != null && medications.isNotEmpty) {
      score -= 5;
    }

    return score < 0 ? 0 : score;
  }

  /// Get latest health record
  Future<Map<String, dynamic>?> getLatestHealthRecord(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('healthRecords')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  /// Get health history
  Future<List<Map<String, dynamic>>> getHealthHistory(
    String userId, {
    int limit = 10,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('healthRecords')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Get health recommendations
  List<String> getHealthRecommendations(Map<String, dynamic> healthRecord) {
    final recommendations = <String>[];
    final score = healthRecord['eligibilityScore'] ?? 0;

    if (score < 70) {
      recommendations.add('⚠️ Not eligible for donation currently');
    }

    // Hemoglobin recommendations
    final hb = healthRecord['hemoglobinLevel'] ?? 0.0;
    if (hb < 12.5) {
      recommendations.add('🍎 Eat iron-rich foods (spinach, red meat, beans)');
      recommendations.add('🍊 Take vitamin C to improve iron absorption');
    }

    // Blood pressure recommendations
    final bp = healthRecord['bloodPressure'] ?? '120/80';
    final bpParts = bp.split('/');
    if (bpParts.length == 2) {
      final systolic = int.tryParse(bpParts[0]) ?? 120;
      if (systolic > 130) {
        recommendations.add('🧘 Practice stress reduction techniques');
        recommendations.add('🏃 Regular exercise helps lower blood pressure');
      }
    }

    // Weight recommendations
    final weight = healthRecord['weight'] ?? 50.0;
    if (weight < 50.0) {
      recommendations.add('🍽️ Gain weight to meet minimum requirement (50kg)');
    }

    // Sleep recommendations
    final sleep = healthRecord['sleepHours'] ?? 8;
    if (sleep < 7) {
      recommendations.add('😴 Get at least 7-8 hours of sleep before donation');
    }

    // Hydration recommendations
    final hydration = healthRecord['hydrationLevel'] ?? 'good';
    if (hydration != 'good') {
      recommendations.add('💧 Drink 2-3 liters of water before donation');
    }

    // General recommendations
    if (score >= 70) {
      recommendations.add('✅ You are eligible to donate blood!');
      recommendations.add('🍌 Eat a healthy meal 2-3 hours before donation');
      recommendations.add('☕ Avoid alcohol and caffeine before donation');
    }

    return recommendations;
  }

  /// Pre-donation checklist
  static const List<Map<String, dynamic>> preDonationChecklist = [
    {
      'item': 'Had at least 7 hours of sleep',
      'icon': '😴',
      'importance': 'high',
    },
    {
      'item': 'Ate a healthy meal 2-3 hours ago',
      'icon': '🍽️',
      'importance': 'high',
    },
    {
      'item': 'Drank plenty of water (2-3 liters)',
      'icon': '💧',
      'importance': 'high',
    },
    {
      'item': 'No alcohol in last 24 hours',
      'icon': '🚫',
      'importance': 'critical',
    },
    {
      'item': 'No antibiotics in last 7 days',
      'icon': '💊',
      'importance': 'critical',
    },
    {
      'item': 'Feeling healthy and energetic',
      'icon': '💪',
      'importance': 'high',
    },
    {'item': 'Brought ID proof', 'icon': '🪪', 'importance': 'medium'},
    {'item': 'Wore comfortable clothing', 'icon': '👕', 'importance': 'medium'},
  ];

  /// Post-donation care tips
  static const List<Map<String, dynamic>> postDonationCare = [
    {
      'tip': 'Rest for 10-15 minutes after donation',
      'icon': '🛋️',
      'duration': '15 min',
    },
    {
      'tip': 'Drink extra fluids for next 24 hours',
      'icon': '💧',
      'duration': '24 hours',
    },
    {
      'tip': 'Avoid heavy lifting or exercise',
      'icon': '🏋️',
      'duration': '24 hours',
    },
    {
      'tip': 'Keep the bandage on for 4-5 hours',
      'icon': '🩹',
      'duration': '5 hours',
    },
    {'tip': 'Eat iron-rich foods', 'icon': '🍎', 'duration': '1 week'},
    {
      'tip': 'If dizzy, lie down and elevate legs',
      'icon': '🤕',
      'duration': 'if needed',
    },
  ];

  /// Calculate health trend
  Future<Map<String, dynamic>> getHealthTrend(String userId) async {
    final history = await getHealthHistory(userId, limit: 5);
    if (history.isEmpty) {
      return {'trend': 'no_data', 'message': 'No health records yet'};
    }

    if (history.length < 2) {
      return {
        'trend': 'insufficient_data',
        'message': 'Need more records to show trend',
      };
    }

    // Compare latest with previous
    final latest = history[0]['eligibilityScore'] ?? 0;
    final previous = history[1]['eligibilityScore'] ?? 0;
    final diff = latest - previous;

    String trend;
    String message;

    if (diff > 5) {
      trend = 'improving';
      message = 'Your health is improving! Keep it up! 📈';
    } else if (diff < -5) {
      trend = 'declining';
      message = 'Health declining. Please consult doctor. 📉';
    } else {
      trend = 'stable';
      message = 'Your health is stable. Maintain it! ➡️';
    }

    return {
      'trend': trend,
      'message': message,
      'latest': latest,
      'previous': previous,
      'change': diff,
    };
  }
}
