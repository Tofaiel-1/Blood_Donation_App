import 'package:blood_bank/screens/auth/login_screen.dart';
import 'package:blood_bank/widgets/auth_wrapper.dart';
import 'package:blood_bank/screens/auth/phone_auth_screen.dart';
import 'package:blood_bank/screens/auth/verification_screen.dart';
import 'package:blood_bank/screens/admin/audit_log_screen.dart';
import 'package:blood_bank/screens/admin/super_admin_setup_screen.dart';
import 'package:blood_bank/screens/admin/demo_data_screen.dart';
import 'package:blood_bank/screens/admin/add_data_screen.dart';
import 'package:blood_bank/screens/home/user_blood_request_screen.dart';
import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/main_navigation_screen.dart';
import '../screens/home/search_screen.dart';
import '../screens/home/donate_screen.dart';
import '../screens/home/messages_screen.dart';
import '../screens/home/profile_screen.dart';
import '../screens/chat/chatbot_screen.dart';
import '../screens/theme_showcase_screen.dart';
import '../screens/admin/dashboard/super_admin_dashboard.dart';
import '../screens/admin/dashboard/admin_dashboard.dart';
import '../screens/booking/advance_booking_screen.dart';
import '../screens/booking/booking_payment_screen.dart';
import '../screens/booking/booking_success_screen.dart';
import '../screens/admin/admin_booking_dashboard.dart';

/// 🗺️ APP ROUTING - সব screen এর navigation routes
///
/// Quick Reference:
/// - Authentication: /login, /signup, /verification
/// - Main App: /home, /search, /donate, /messages, /profile
/// - Admin: /super-admin, /org-admin, /demo-data
/// - Features: /user-blood-request, /chatbot

final Map<String, WidgetBuilder> appRoutes = {
  // Entry & Welcome - AuthWrapper handles login persistence
  '/': (context) => const AuthWrapper(),
  '/welcome': (context) => const WelcomeScreen(),

  // Authentication
  '/login': (context) => LoginScreen(),
  '/phone-auth': (context) => PhoneAuthScreen(),
  '/signup': (context) => SignupScreen(),
  '/verification': (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return VerificationScreen(
      email: args?['email'] ?? '',
      phone: args?['phone'],
      userData: args?['userData'] ?? {},
    );
  },

  // Main App Screens
  '/home': (context) => MainNavigationScreen(),
  '/search': (context) => SearchScreen(),
  '/donate': (context) => DonateScreen(),
  '/messages': (context) => MessagesScreen(),
  '/profile': (context) => ProfileScreen(),

  // Admin Screens
  '/super-admin': (context) => const SuperAdminDashboard(),
  '/super-admin-setup': (context) => SuperAdminSetupScreen(),
  '/org-admin': (context) => const AdminDashboard(),
  '/audit-logs': (context) => AuditLogScreen(),
  '/demo-data': (context) => const DemoDataScreen(),
  '/add-data': (context) => const AddDataScreen(),

  // Special Features
  '/user-blood-request': (context) => const UserBloodRequestScreen(),
  '/chatbot': (context) => const ChatbotScreen(),
  '/theme-showcase': (context) => const ThemeShowcaseScreen(),

  // Advance Booking
  '/advance-booking': (context) => const AdvanceBookingScreen(),
  '/booking-payment': (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return BookingPaymentScreen(
      bookingId: args?['bookingId'] ?? '',
      totalAmount: args?['totalAmount'] ?? 0.0,
    );
  },
  '/booking-success': (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return BookingSuccessScreen(
      bookingId: args?['bookingId'] ?? '',
      transactionId: args?['transactionId'] ?? '',
    );
  },
  '/admin/booking-dashboard': (context) => const AdminBookingDashboard(),
};
