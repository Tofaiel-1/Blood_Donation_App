class PhoneValidator {
  // Bangladeshi phone number validation
  // GP: 017, Robi: 018, Banglalink: 019, Airtel: 016, Teletalk: 015

  static final RegExp _bangladeshiPhoneRegex = RegExp(
    r'^(01[3-9]\d{8})$', // 01 + (3-9) + 8 digits = 11 digits total
  );

  static bool isValidBangladeshiPhone(String phone) {
    // Remove spaces, dashes, and other characters
    final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Check if it matches Bangladeshi format
    return _bangladeshiPhoneRegex.hasMatch(cleanedPhone);
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'ফোন নম্বর দিন';
    }

    final cleanedPhone = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanedPhone.length != 11) {
      return 'ফোন নম্বর ১১ ডিজিটের হতে হবে';
    }

    if (!cleanedPhone.startsWith('01')) {
      return 'ফোন নম্বর 01 দিয়ে শুরু হতে হবে';
    }

    final thirdDigit = int.parse(cleanedPhone[2]);
    if (thirdDigit < 3 || thirdDigit > 9) {
      return 'সঠিক ফোন নম্বর দিন (GP, Robi, Banglalink, Airtel)';
    }

    return null;
  }

  static String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length == 11) {
      // Format: 01711-123456
      return '${cleaned.substring(0, 5)}-${cleaned.substring(5)}';
    }
    return phone;
  }

  static String getOperatorName(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length < 3) return 'Unknown';

    switch (cleaned.substring(0, 3)) {
      case '013':
      case '017':
        return 'GP (Grameenphone)';
      case '018':
        return 'Robi';
      case '019':
        return 'Banglalink';
      case '016':
        return 'Airtel';
      case '015':
        return 'Teletalk';
      case '014':
        return 'Banglalink';
      default:
        return 'Unknown';
    }
  }
}
