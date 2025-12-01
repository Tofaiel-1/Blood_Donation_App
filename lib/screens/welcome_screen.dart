import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/app_colors.dart';
import '../utils/responsive.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = Responsive.isMobile(context);
              final spacing = Responsive.responsiveSpacing(context);

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxWidth: Responsive.responsiveMaxWidth(context),
                  ),
                  child: Center(
                    child: Padding(
                      padding: Responsive.responsiveHorizontalPadding(
                        context,
                      ).copyWith(top: spacing, bottom: spacing),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // Top Section - Logo and Title
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: spacing * 2),

                                  // Hero section with animated logo
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 800),
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: child,
                                      );
                                    },
                                    child: Container(
                                      width: isMobile ? 90 : 120,
                                      height: isMobile ? 90 : 120,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.bloodtype,
                                        color: Colors.white,
                                        size: isMobile ? 60 : 80,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: spacing * 2),

                                  // App Title with custom styling
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: spacing,
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        appName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                              fontSize:
                                                  Responsive.responsiveTextSize(
                                                    context,
                                                    mobile: 32.0,
                                                    tablet: 40.0,
                                                    desktop: 48.0,
                                                  ),
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: spacing * 0.5),

                                  // Tagline with fade-in effect
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    builder: (context, value, child) {
                                      return Opacity(
                                        opacity: value,
                                        child: child,
                                      );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: spacing,
                                      ),
                                      child: Text(
                                        appTagline,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              letterSpacing: 0.5,
                                              fontSize:
                                                  Responsive.responsiveTextSize(
                                                    context,
                                                    mobile: 16.0,
                                                    tablet: 18.0,
                                                    desktop: 20.0,
                                                  ),
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: spacing * 1.5),

                                  // Feature highlights
                                  _buildFeatureRow(
                                    context,
                                    Icons.verified_user,
                                    'Safe & Secure',
                                  ),
                                  SizedBox(height: spacing * 0.6),
                                  _buildFeatureRow(
                                    context,
                                    Icons.people,
                                    'Connect with Donors',
                                  ),
                                  SizedBox(height: spacing * 0.6),
                                  _buildFeatureRow(
                                    context,
                                    Icons.emergency,
                                    'Emergency Requests',
                                  ),
                                ],
                              ),
                            ),

                            // Spacer to push buttons to bottom
                            SizedBox(height: spacing * 3),

                            // Bottom Section - Buttons
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Login Button with gradient
                                Container(
                                  width: double.infinity,
                                  height: Responsive.responsiveButtonHeight(
                                    context,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      Responsive.responsiveBorderRadius(
                                            context,
                                          ) *
                                          2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius:
                                            Responsive.responsiveElevation(
                                              context,
                                            ) *
                                            2,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        '/login',
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Responsive.responsiveBorderRadius(
                                              context,
                                            ) *
                                            2.5,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Log In',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: AppColors.bloodRed,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    Responsive.responsiveTextSize(
                                                      context,
                                                      mobile: 18.0,
                                                      tablet: 20.0,
                                                      desktop: 22.0,
                                                    ),
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: spacing),

                                // Sign Up Button with border
                                Container(
                                  width: double.infinity,
                                  height: Responsive.responsiveButtonHeight(
                                    context,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      Responsive.responsiveBorderRadius(
                                            context,
                                          ) *
                                          2.5,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        '/signup',
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Responsive.responsiveBorderRadius(
                                              context,
                                            ) *
                                            2.5,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Sign Up',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    Responsive.responsiveTextSize(
                                                      context,
                                                      mobile: 18.0,
                                                      tablet: 20.0,
                                                      desktop: 22.0,
                                                    ),
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: spacing),

                                // Guest mode
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/home'),
                                  child: Text(
                                    'Continue as Guest',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.white
                                              .withValues(alpha: 0.8),
                                          fontSize:
                                              Responsive.responsiveTextSize(
                                                context,
                                              ),
                                        ),
                                  ),
                                ),

                                // Hidden admin setup button
                                SizedBox(height: spacing * 0.3),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onLongPress: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/super-admin-setup',
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(spacing * 0.5),
                                        child: Text(
                                          'v1.0',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.white.withValues(
                                                  alpha: 0.3,
                                                ),
                                                fontSize:
                                                    Responsive.responsiveTextSize(
                                                      context,
                                                      mobile: 12.0,
                                                      tablet: 13.0,
                                                      desktop: 14.0,
                                                    ),
                                              ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: spacing),
                                    GestureDetector(
                                      onLongPress: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/demo-data',
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(spacing * 0.5),
                                        child: Icon(
                                          Icons.data_object,
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          size:
                                              Responsive.responsiveIconSize(
                                                context,
                                              ) *
                                              0.9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: Responsive.responsiveIconSize(context),
        ),
        SizedBox(width: Responsive.responsiveSpacing(context) * 0.5),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: Responsive.responsiveTextSize(context),
          ),
        ),
      ],
    );
  }
}
