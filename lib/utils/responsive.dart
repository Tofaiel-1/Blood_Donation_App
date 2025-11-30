import 'package:flutter/material.dart';

/// Responsive utility class for consistent responsive design across the app
class Responsive {
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 1024;
  static const double _desktopBreakpoint = 1440;

  /// Check if device is mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileBreakpoint;

  /// Check if device is tablet
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= _mobileBreakpoint &&
      MediaQuery.of(context).size.width < _tabletBreakpoint;

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _desktopBreakpoint;

  /// Check if device is large screen (tablet or desktop)
  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= _mobileBreakpoint;

  /// Get responsive width
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Get responsive height
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Get responsive padding based on screen size
  static EdgeInsets responsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Get responsive horizontal padding
  static EdgeInsets responsiveHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 64.0);
    }
  }

  /// Get responsive margin
  static EdgeInsets responsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  /// Get responsive text size
  static double responsiveTextSize(
    BuildContext context, {
    double mobile = 14.0,
    double tablet = 16.0,
    double desktop = 18.0,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Get responsive icon size
  static double responsiveIconSize(BuildContext context) {
    if (isMobile(context)) return 20.0;
    if (isTablet(context)) return 24.0;
    return 28.0;
  }

  /// Get responsive card elevation
  static double responsiveElevation(BuildContext context) {
    if (isMobile(context)) return 2.0;
    if (isTablet(context)) return 4.0;
    return 6.0;
  }

  /// Get responsive border radius
  static double responsiveBorderRadius(BuildContext context) {
    if (isMobile(context)) return 8.0;
    if (isTablet(context)) return 12.0;
    return 16.0;
  }

  /// Get responsive grid column count
  static int responsiveGridCount(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }

  /// Get responsive dialog width
  static double responsiveDialogWidth(BuildContext context) {
    if (isMobile(context)) return width(context) * 0.9;
    if (isTablet(context)) return width(context) * 0.7;
    return width(context) * 0.5;
  }

  /// Get responsive container max width
  static double responsiveMaxWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 600.0;
    return 800.0;
  }

  /// Get responsive spacing
  static double responsiveSpacing(BuildContext context) {
    if (isMobile(context)) return 12.0;
    if (isTablet(context)) return 16.0;
    return 20.0;
  }

  /// Get responsive button height
  static double responsiveButtonHeight(BuildContext context) {
    if (isMobile(context)) return 48.0;
    if (isTablet(context)) return 52.0;
    return 56.0;
  }

  /// Get responsive app bar height
  static double responsiveAppBarHeight(BuildContext context) {
    if (isMobile(context)) return 56.0;
    if (isTablet(context)) return 64.0;
    return 72.0;
  }

  /// Get responsive card padding
  static EdgeInsets responsiveCardPadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(12.0);
    if (isTablet(context)) return const EdgeInsets.all(16.0);
    return const EdgeInsets.all(20.0);
  }

  /// Calculate responsive font size based on screen width
  static double scaledFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0; // Base width (iPhone 6/7/8)
    return baseSize * scaleFactor.clamp(0.8, 1.4);
  }

  /// Get responsive layout direction (vertical for mobile, horizontal for larger screens)
  static Axis responsiveAxis(BuildContext context) {
    return isMobile(context) ? Axis.vertical : Axis.horizontal;
  }

  /// Get responsive flex values for layouts
  static List<int> responsiveFlex(BuildContext context) {
    if (isMobile(context)) return [1]; // Full width
    if (isTablet(context)) return [1, 1]; // 50-50 split
    return [1, 2]; // 33-66 split
  }

  /// Get responsive cross axis count for grid views
  static int responsiveCrossAxisCount(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Get responsive aspect ratio
  static double responsiveAspectRatio(BuildContext context) {
    if (isMobile(context)) return 16 / 9;
    if (isTablet(context)) return 4 / 3;
    return 3 / 2;
  }

  /// Create responsive sized box
  static SizedBox responsiveSizedBox({
    required BuildContext context,
    double mobile = 16.0,
    double tablet = 24.0,
    double desktop = 32.0,
    bool isHeight = false,
  }) {
    final size = isMobile(context)
        ? mobile
        : isTablet(context)
        ? tablet
        : desktop;

    return isHeight ? SizedBox(height: size) : SizedBox(width: size);
  }
}
