/// Blood Compatibility Service
/// Handles blood type compatibility for donations
class BloodCompatibilityService {
  /// Check if donor can donate to recipient
  static bool canDonate(String donorBloodType, String recipientBloodType) {
    // O- is universal donor
    if (donorBloodType == 'O-') return true;

    // AB+ is universal recipient
    if (recipientBloodType == 'AB+') return true;

    // Exact match is always compatible
    if (donorBloodType == recipientBloodType) return true;

    // Compatibility matrix
    final compatibilityMap = {
      'O+': ['O+', 'A+', 'B+', 'AB+'],
      'O-': ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'],
      'A+': ['A+', 'AB+'],
      'A-': ['A+', 'A-', 'AB+', 'AB-'],
      'B+': ['B+', 'AB+'],
      'B-': ['B+', 'B-', 'AB+', 'AB-'],
      'AB+': ['AB+'],
      'AB-': ['AB+', 'AB-'],
    };

    return compatibilityMap[donorBloodType]?.contains(recipientBloodType) ??
        false;
  }

  /// Get all compatible blood types for a recipient
  static List<String> getCompatibleDonors(String recipientBloodType) {
    final compatibilityMap = {
      'O+': ['O+', 'O-'],
      'O-': ['O-'],
      'A+': ['A+', 'A-', 'O+', 'O-'],
      'A-': ['A-', 'O-'],
      'B+': ['B+', 'B-', 'O+', 'O-'],
      'B-': ['B-', 'O-'],
      'AB+': ['AB+', 'AB-', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-'],
      'AB-': ['AB-', 'A-', 'B-', 'O-'],
    };

    return compatibilityMap[recipientBloodType] ?? [];
  }

  /// Get all compatible recipients for a donor
  static List<String> getCompatibleRecipients(String donorBloodType) {
    final compatibilityMap = {
      'O+': ['O+', 'A+', 'B+', 'AB+'],
      'O-': ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'],
      'A+': ['A+', 'AB+'],
      'A-': ['A+', 'A-', 'AB+', 'AB-'],
      'B+': ['B+', 'AB+'],
      'B-': ['B+', 'B-', 'AB+', 'AB-'],
      'AB+': ['AB+'],
      'AB-': ['AB+', 'AB-'],
    };

    return compatibilityMap[donorBloodType] ?? [];
  }

  /// Get blood type rarity score (1-5, higher = rarer)
  static int getRarityScore(String bloodType) {
    final rarityMap = {
      'O+': 2, // Common
      'A+': 2, // Common
      'B+': 3, // Moderate
      'O-': 5, // Very rare (universal donor)
      'AB+': 4, // Rare (universal recipient)
      'A-': 4, // Rare
      'B-': 4, // Rare
      'AB-': 5, // Very rare
    };

    return rarityMap[bloodType] ?? 3;
  }

  /// Get priority score for matching (considers compatibility and rarity)
  static int getPriorityScore({
    required String donorBloodType,
    required String recipientBloodType,
  }) {
    int score = 0;

    // Exact match gets highest priority
    if (donorBloodType == recipientBloodType) {
      score += 100;
    }

    // Universal donor/recipient
    if (donorBloodType == 'O-') {
      score += 80;
    }
    if (recipientBloodType == 'AB+') {
      score += 70;
    }

    // Rare blood types get higher priority
    score += getRarityScore(donorBloodType) * 10;

    // Check compatibility
    if (canDonate(donorBloodType, recipientBloodType)) {
      score += 50;
    }

    return score;
  }

  /// Get blood type description
  static String getBloodTypeDescription(String bloodType) {
    final descriptions = {
      'O-': '🌟 Universal Donor - Can donate to all blood types',
      'O+': '💪 Most common blood type - Can donate to O+, A+, B+, AB+',
      'A+': '🔴 Can donate to A+ and AB+',
      'A-': '🔴 Can donate to A+, A-, AB+, AB-',
      'B+': '🔵 Can donate to B+ and AB+',
      'B-': '🔵 Can donate to B+, B-, AB+, AB-',
      'AB+': '🎯 Universal Recipient - Can receive from all blood types',
      'AB-': '⭐ Rare blood type - Can donate to AB+, AB-',
    };

    return descriptions[bloodType] ?? 'Unknown blood type';
  }
}
