import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFB71C1C),
              const Color(0xFF8E0000),
              const Color(0xFFD32F2F),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmall ? 20 : 32,
                        vertical: isSmall ? 30 : 50,
                      ),
                      child: Column(
                        children: [
                          // Animated Blood Drop Logo
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: Container(
                              width: isSmall ? 100 : 140,
                              height: isSmall ? 100 : 140,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.bloodtype_rounded,
                                    size: isSmall ? 60 : 85,
                                    color: Colors.white,
                                  ),
                                  Positioned(
                                    top: 20,
                                    right: 20,
                                    child: Container(
                                      width: isSmall ? 20 : 26,
                                      height: isSmall ? 20 : 26,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.favorite,
                                        size: isSmall ? 12 : 16,
                                        color: const Color(0xFFB71C1C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: isSmall ? 30 : 50),

                          // App Name
                          Text(
                            'PSTU Bloodbank',
                            style: TextStyle(
                              fontSize: isSmall ? 32 : 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: isSmall ? 8 : 12),

                          // Tagline
                          Text(
                            'Save Lives, Donate Blood',
                            style: TextStyle(
                              fontSize: isSmall ? 16 : 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.95),
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: isSmall ? 40 : 60),

                          // Feature Cards
                          _buildFeatureCard(
                            icon: Icons.verified_user,
                            title: 'Safe & Secure',
                            isSmall: isSmall,
                          ),
                          SizedBox(height: isSmall ? 12 : 16),

                          _buildFeatureCard(
                            icon: Icons.people_outline,
                            title: 'Connect with Donors',
                            isSmall: isSmall,
                          ),
                          SizedBox(height: isSmall ? 12 : 16),

                          _buildFeatureCard(
                            icon: Icons.emergency_rounded,
                            title: 'Emergency Requests',
                            isSmall: isSmall,
                          ),

                          SizedBox(height: isSmall ? 40 : 60),

                          // Stats Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatCard('10K+', 'Donors', isSmall),
                              _buildStatCard('5K+', 'Lives Saved', isSmall),
                              _buildStatCard('24/7', 'Support', isSmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Buttons at Bottom
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 20 : 32,
                    vertical: isSmall ? 16 : 24,
                  ),
                  child: Column(
                    children: [
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: isSmall ? 54 : 60,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFB71C1C),
                            elevation: 8,
                            shadowColor: Colors.black.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: isSmall ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isSmall ? 12 : 16),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: isSmall ? 54 : 60,
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/signup'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: isSmall ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isSmall ? 12 : 16),

                      // Continue as Guest
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/home'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withValues(alpha: 0.9),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Continue as Guest',
                              style: TextStyle(
                                fontSize: isSmall ? 14 : 16,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: isSmall ? 16 : 18),
                          ],
                        ),
                      ),

                      SizedBox(height: isSmall ? 8 : 12),

                      // Version
                      Text(
                        'v1.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required bool isSmall,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 16 : 20,
        vertical: isSmall ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmall ? 8 : 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: isSmall ? 20 : 24),
          ),
          SizedBox(width: isSmall ? 12 : 16),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, bool isSmall) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isSmall ? 20 : 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 10 : 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 0.8,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
