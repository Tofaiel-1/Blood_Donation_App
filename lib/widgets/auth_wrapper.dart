import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/welcome_screen.dart';
import '../screens/home/main_navigation_screen.dart';

/// 🔐 AUTH WRAPPER - Automatically handles login persistence
///
/// এই widget check করে user logged in আছে কিনা
/// - Logged in থাকলে -> MainNavigationScreen (home)
/// - Logged out থাকলে -> WelcomeScreen
///
/// Benefits:
/// - একবার login করলে app বন্ধ করার পরেও logged in থাকবে
/// - Automatic navigation based on auth state
/// - Firebase auth state stream দিয়ে real-time update
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in -> Go to home
          return const MainNavigationScreen();
        }

        // User is not logged in -> Show welcome screen
        return const WelcomeScreen();
      },
    );
  }
}
