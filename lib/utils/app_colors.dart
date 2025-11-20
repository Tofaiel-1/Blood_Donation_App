import 'package:flutter/material.dart';

/// Custom color palette for Blood Donation App
/// Colors inspired by blood, life, and medical themes
class AppColors {
  // Primary Blood Red shades
  static const bloodRed = Color(0xFFB71C1C); // Deep blood red
  static const bloodRedLight = Color(0xFFD32F2F); // Lighter blood red
  static const bloodRedDark = Color(0xFF8E0E00); // Darker blood red

  // Accent colors
  static const lifeOrange = Color(0xFFFF5722); // Warm orange - energy and life
  static const hopeGreen = Color(0xFF4CAF50); // Green for success and hope
  static const trustBlue = Color(0xFF1976D2); // Blue for trust and medical
  static const warningAmber = Color(0xFFFFA726); // Amber for warnings

  // Surface and background colors
  static const surfaceLight = Color(0xFFFFFBFE);
  static const surfaceDark = Color(0xFF1C1B1F);
  static const backgroundLight = Color(0xFFFFFBFE);
  static const backgroundDark = Color(0xFF1C1B1F);

  // Medical themed colors
  static const medicalWhite = Color(0xFFFAFAFA);
  static const medicalGrey = Color(0xFFE0E0E0);
  static const urgentRed = Color(0xFFE53935);
  static const emergencyDark = Color(0xFFC62828);

  // Blood type colors (for visualization)
  static const bloodTypePositive = Color(0xFFD32F2F);
  static const bloodTypeNegative = Color(0xFF7B1FA2);

  // Status colors
  static const statusAvailable = Color(0xFF66BB6A);
  static const statusBusy = Color(0xFFEF5350);
  static const statusPending = Color(0xFFFFCA28);

  // Gradient colors
  static const gradientStart = Color(0xFF8E0E00);
  static const gradientMiddle = Color(0xFFB71C1C);
  static const gradientEnd = Color(0xFFD32F2F);

  // Text colors
  static const textPrimaryLight = Color(0xFF1C1B1F);
  static const textSecondaryLight = Color(0xFF49454F);
  static const textPrimaryDark = Color(0xFFE6E1E5);
  static const textSecondaryDark = Color(0xFFCAC4D0);

  // Error colors
  static const errorLight = Color(0xFFBA1A1A);
  static const errorDark = Color(0xFFFFB4AB);

  // Common gradients
  static const primaryGradient = LinearGradient(
    colors: [gradientStart, gradientMiddle, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const heroGradient = LinearGradient(
    colors: [bloodRedDark, bloodRed],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const cardGradient = LinearGradient(
    colors: [bloodRedLight, lifeOrange],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
