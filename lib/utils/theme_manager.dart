import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Comprehensive theme manager for Blood Donation App
/// Using flex_color_scheme for advanced theming capabilities
class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// Light Theme - Blood Red themed with warm accents
  ThemeData get lightTheme => FlexThemeData.light(
    // Color scheme configuration
    colors: const FlexSchemeColor(
      primary: AppColors.bloodRed,
      primaryContainer: Color(0xFFFFDAD6),
      secondary: AppColors.lifeOrange,
      secondaryContainer: Color(0xFFFFDBCF),
      tertiary: AppColors.hopeGreen,
      tertiaryContainer: Color(0xFFC8E6C9),
      appBarColor: Color(0xFFFFDAD6),
      error: AppColors.errorLight,
    ),

    // Surface and scaffold colors
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 7,

    // Sub themes configuration
    subThemesData: const FlexSubThemesData(
      // Interaction states
      interactionEffects: true,
      tintedDisabledControls: true,

      // Border radius
      defaultRadius: 12.0,

      // AppBar configuration
      appBarBackgroundSchemeColor: SchemeColor.primary,
      appBarScrolledUnderElevation: 4.0,

      // Bottom Navigation Bar
      bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
      bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
      bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
      bottomNavigationBarMutedUnselectedLabel: true,
      bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
      bottomNavigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
      bottomNavigationBarMutedUnselectedIcon: true,
      bottomNavigationBarShowSelectedLabels: true,
      bottomNavigationBarShowUnselectedLabels: true,
      bottomNavigationBarElevation: 8.0,

      // Navigation Bar (Material 3)
      navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
      navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
      navigationBarMutedUnselectedLabel: true,
      navigationBarSelectedIconSchemeColor: SchemeColor.primary,
      navigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
      navigationBarMutedUnselectedIcon: true,
      navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
      navigationBarIndicatorOpacity: 0.4,
      navigationBarHeight: 80,
      navigationBarLabelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

      // Button themes
      elevatedButtonSchemeColor: SchemeColor.primary,
      elevatedButtonSecondarySchemeColor: SchemeColor.onPrimary,
      elevatedButtonRadius: 30.0,
      elevatedButtonElevation: 2.0,

      outlinedButtonSchemeColor: SchemeColor.primary,
      outlinedButtonOutlineSchemeColor: SchemeColor.primary,
      outlinedButtonRadius: 30.0,

      textButtonSchemeColor: SchemeColor.primary,
      textButtonRadius: 30.0,

      // Input decoration
      inputDecoratorSchemeColor: SchemeColor.primary,
      inputDecoratorBackgroundAlpha: 0x15,
      inputDecoratorRadius: 12.0,
      inputDecoratorUnfocusedHasBorder: true,
      inputDecoratorFocusedHasBorder: true,
      inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,

      // FAB
      fabUseShape: true,
      fabAlwaysCircular: true,
      fabSchemeColor: SchemeColor.primary,
      fabRadius: 16.0,

      // Chip
      chipSchemeColor: SchemeColor.primary,
      chipSelectedSchemeColor: SchemeColor.primary,
      chipRadius: 16.0,

      // Card
      cardRadius: 16.0,
      cardElevation: 2.0,

      // Dialog
      dialogRadius: 20.0,
      dialogElevation: 6.0,
      dialogBackgroundSchemeColor: SchemeColor.surface,

      // Bottom Sheet
      bottomSheetRadius: 28.0,
      bottomSheetElevation: 4.0,
      bottomSheetModalBackgroundColor: SchemeColor.surface,

      // Snack Bar
      snackBarRadius: 8.0,
      snackBarElevation: 4.0,
      snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,

      // Switch, Checkbox, Radio
      switchSchemeColor: SchemeColor.primary,
      checkboxSchemeColor: SchemeColor.primary,
      radioSchemeColor: SchemeColor.primary,
      unselectedToggleIsColored: true,

      // Slider
      sliderValueTinted: true,
      sliderTrackHeight: 4.0,

      // TabBar
      tabBarIndicatorSchemeColor: SchemeColor.primary,
      tabBarIndicatorSize: TabBarIndicatorSize.tab,
      tabBarIndicatorWeight: 3.0,
      tabBarIndicatorTopRadius: 3.0,
    ),

    // Visual density
    visualDensity: FlexColorScheme.comfortablePlatformDensity,

    // Typography using Google Fonts
    fontFamily: GoogleFonts.poppins().fontFamily,

    // Use Material 3
    useMaterial3: true,

    // Custom text theme
    textTheme: _buildTextTheme(),
    primaryTextTheme: _buildTextTheme(),
  );

  /// Dark Theme - Blood Red themed dark mode
  ThemeData get darkTheme => FlexThemeData.dark(
    // Color scheme configuration
    colors: const FlexSchemeColor(
      primary: AppColors.bloodRedLight,
      primaryContainer: Color(0xFF93000A),
      secondary: Color(0xFFFFB4AB),
      secondaryContainer: Color(0xFF93000A),
      tertiary: Color(0xFF81C784),
      tertiaryContainer: Color(0xFF2E7D32),
      appBarColor: Color(0xFF93000A),
      error: AppColors.errorDark,
    ),

    // Surface and scaffold colors
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 15,

    // Sub themes configuration (same as light theme)
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      defaultRadius: 12.0,

      appBarBackgroundSchemeColor: SchemeColor.surface,
      appBarScrolledUnderElevation: 4.0,

      bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
      bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
      bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
      bottomNavigationBarMutedUnselectedLabel: true,
      bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
      bottomNavigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
      bottomNavigationBarMutedUnselectedIcon: true,
      bottomNavigationBarShowSelectedLabels: true,
      bottomNavigationBarShowUnselectedLabels: true,
      bottomNavigationBarElevation: 8.0,

      navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
      navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
      navigationBarMutedUnselectedLabel: true,
      navigationBarSelectedIconSchemeColor: SchemeColor.primary,
      navigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
      navigationBarMutedUnselectedIcon: true,
      navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
      navigationBarIndicatorOpacity: 0.4,
      navigationBarHeight: 80,
      navigationBarLabelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

      elevatedButtonSchemeColor: SchemeColor.primary,
      elevatedButtonSecondarySchemeColor: SchemeColor.onPrimary,
      elevatedButtonRadius: 30.0,
      elevatedButtonElevation: 2.0,

      outlinedButtonSchemeColor: SchemeColor.primary,
      outlinedButtonOutlineSchemeColor: SchemeColor.primary,
      outlinedButtonRadius: 30.0,

      textButtonSchemeColor: SchemeColor.primary,
      textButtonRadius: 30.0,

      inputDecoratorSchemeColor: SchemeColor.primary,
      inputDecoratorBackgroundAlpha: 0x15,
      inputDecoratorRadius: 12.0,
      inputDecoratorUnfocusedHasBorder: true,
      inputDecoratorFocusedHasBorder: true,
      inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,

      fabUseShape: true,
      fabAlwaysCircular: true,
      fabSchemeColor: SchemeColor.primary,
      fabRadius: 16.0,

      chipSchemeColor: SchemeColor.primary,
      chipSelectedSchemeColor: SchemeColor.primary,
      chipRadius: 16.0,

      cardRadius: 16.0,
      cardElevation: 2.0,

      dialogRadius: 20.0,
      dialogElevation: 6.0,
      dialogBackgroundSchemeColor: SchemeColor.surface,

      bottomSheetRadius: 28.0,
      bottomSheetElevation: 4.0,
      bottomSheetModalBackgroundColor: SchemeColor.surface,

      snackBarRadius: 8.0,
      snackBarElevation: 4.0,
      snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,

      switchSchemeColor: SchemeColor.primary,
      checkboxSchemeColor: SchemeColor.primary,
      radioSchemeColor: SchemeColor.primary,
      unselectedToggleIsColored: true,

      sliderValueTinted: true,
      sliderTrackHeight: 4.0,

      tabBarIndicatorSchemeColor: SchemeColor.primary,
      tabBarIndicatorSize: TabBarIndicatorSize.tab,
      tabBarIndicatorWeight: 3.0,
      tabBarIndicatorTopRadius: 3.0,
    ),

    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    fontFamily: GoogleFonts.poppins().fontFamily,
    useMaterial3: true,
    textTheme: _buildTextTheme(),
    primaryTextTheme: _buildTextTheme(),
  );

  /// Build custom text theme using Google Fonts
  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Display styles
      displayLarge: GoogleFonts.montserrat(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 45,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),

      // Headline styles
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),

      // Title styles
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),

      // Body styles
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),

      // Label styles
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}
