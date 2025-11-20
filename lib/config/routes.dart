import 'package:blood_bank/screens/auth/login_screen.dart';
import 'package:blood_bank/screens/auth/phone_auth_screen.dart';
import 'package:blood_bank/screens/admin/audit_log_screen.dart';
import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/main_navigation_screen.dart';
import '../screens/home/search_screen.dart';
import '../screens/home/donate_screen.dart';
import '../screens/home/messages_screen.dart';
import '../screens/home/profile_screen.dart';
import '../screens/admin/super_admin_screen.dart';
import '../screens/admin/org_admin_screen.dart';
import '../screens/chat/chatbot_screen.dart';
import '../screens/theme_showcase_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => WelcomeScreen(),
  '/welcome': (context) => WelcomeScreen(),
  '/login': (context) => LoginScreen(),
  '/phone-auth': (context) => PhoneAuthScreen(),
  '/signup': (context) => SignupScreen(),
  '/home': (context) => MainNavigationScreen(),
  '/search': (context) => SearchScreen(),
  '/donate': (context) => DonateScreen(),
  '/messages': (context) => MessagesScreen(),
  '/profile': (context) => ProfileScreen(),
  '/super-admin': (context) => SuperAdminScreen(),
  '/org-admin': (context) => OrgAdminScreen(),
  '/audit-logs': (context) => AuditLogScreen(),
  '/chatbot': (context) => const ChatbotScreen(),
  '/theme-showcase': (context) => const ThemeShowcaseScreen(),
};
