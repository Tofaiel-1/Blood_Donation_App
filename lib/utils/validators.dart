class Validators {
  static String? validateEmail(String? value) {
    if (value == null || !value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  static String? validateBloodType(String? value) {
    if (value == null) {
      return 'Please select your blood type';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }

    final phone = value.trim();
    // Allow +, spaces, dashes; require 10-15 digits overall
    final digitsOnly = phone.replaceAll(RegExp(r"[^0-9]"), '');
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Enter a valid phone number (10-15 digits)';
    }
    return null;
  }
}
