import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom text styles for Blood Donation App
/// Consistent typography system throughout the app
class AppTextStyles {
  // Base font family
  static String get fontFamily => GoogleFonts.poppins().fontFamily ?? 'Poppins';
  static String get headingFont =>
      GoogleFonts.montserrat().fontFamily ?? 'Montserrat';

  // Display styles (for hero sections)
  static TextStyle displayLarge(BuildContext context) => GoogleFonts.montserrat(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle displayMedium(BuildContext context) =>
      GoogleFonts.montserrat(
        fontSize: 45,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle displaySmall(BuildContext context) => GoogleFonts.montserrat(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: Theme.of(context).colorScheme.onSurface,
  );

  // Headline styles
  static TextStyle headlineLarge(BuildContext context) =>
      GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle headlineMedium(BuildContext context) => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle headlineSmall(BuildContext context) => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: Theme.of(context).colorScheme.onSurface,
  );

  // Title styles
  static TextStyle titleLarge(BuildContext context) => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle titleMedium(BuildContext context) => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle titleSmall(BuildContext context) => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: Theme.of(context).colorScheme.onSurface,
  );

  // Body styles
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: Theme.of(context).colorScheme.onSurface,
  );

  // Label styles (for buttons and form fields)
  static TextStyle labelLarge(BuildContext context) => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle labelMedium(BuildContext context) => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle labelSmall(BuildContext context) => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Theme.of(context).colorScheme.onSurface,
  );

  // Special styles for blood donation app
  static TextStyle bloodType(BuildContext context) => GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: Theme.of(context).colorScheme.primary,
  );

  static TextStyle emergencyText(BuildContext context) => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: Theme.of(context).colorScheme.error,
  );

  static TextStyle statsNumber(BuildContext context) => GoogleFonts.montserrat(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    color: Theme.of(context).colorScheme.primary,
  );

  static TextStyle buttonText(BuildContext context) => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Theme.of(context).colorScheme.onPrimary,
  );
}
