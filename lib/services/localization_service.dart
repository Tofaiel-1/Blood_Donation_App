import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported languages
enum AppLanguage { english, bangla }

/// Localization Service for managing app language
class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  AppLanguage _currentLanguage = AppLanguage.bangla; // Default to Bangla
  static const String _storageKey = 'app_language';

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isBangla => _currentLanguage == AppLanguage.bangla;
  bool get isEnglish => _currentLanguage == AppLanguage.english;

  /// Initialize language from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_storageKey);

    if (languageCode == 'en') {
      _currentLanguage = AppLanguage.english;
    } else {
      _currentLanguage = AppLanguage.bangla;
    }
    notifyListeners();
  }

  /// Change language
  Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      language == AppLanguage.english ? 'en' : 'bn',
    );
    notifyListeners();
  }

  /// Get translation for a key
  String translate(String key) {
    return _translations[key]?[_currentLanguage] ?? key;
  }

  /// Quick access methods
  String get(String key) => translate(key);
}

/// Translation strings
final Map<String, Map<AppLanguage, String>> _translations = {
  // ============= COMMON =============
  'app_name': {
    AppLanguage.english: 'Blood Donation',
    AppLanguage.bangla: 'রক্তদান',
  },
  'ok': {AppLanguage.english: 'OK', AppLanguage.bangla: 'ঠিক আছে'},
  'cancel': {AppLanguage.english: 'Cancel', AppLanguage.bangla: 'বাতিল'},
  'save': {AppLanguage.english: 'Save', AppLanguage.bangla: 'সংরক্ষণ'},
  'delete': {AppLanguage.english: 'Delete', AppLanguage.bangla: 'মুছুন'},
  'edit': {AppLanguage.english: 'Edit', AppLanguage.bangla: 'সম্পাদনা'},
  'search': {AppLanguage.english: 'Search', AppLanguage.bangla: 'খুঁজুন'},
  'loading': {
    AppLanguage.english: 'Loading...',
    AppLanguage.bangla: 'লোড হচ্ছে...',
  },
  'error': {AppLanguage.english: 'Error', AppLanguage.bangla: 'ত্রুটি'},
  'success': {AppLanguage.english: 'Success', AppLanguage.bangla: 'সফল'},
  'warning': {AppLanguage.english: 'Warning', AppLanguage.bangla: 'সতর্কতা'},
  'refresh': {AppLanguage.english: 'Refresh', AppLanguage.bangla: 'রিফ্রেশ'},
  'close': {AppLanguage.english: 'Close', AppLanguage.bangla: 'বন্ধ করুন'},
  'submit': {AppLanguage.english: 'Submit', AppLanguage.bangla: 'জমা দিন'},
  'back': {AppLanguage.english: 'Back', AppLanguage.bangla: 'ফিরুন'},
  'next': {AppLanguage.english: 'Next', AppLanguage.bangla: 'পরবর্তী'},
  'previous': {
    AppLanguage.english: 'Previous',
    AppLanguage.bangla: 'পূর্ববর্তী',
  },
  'yes': {AppLanguage.english: 'Yes', AppLanguage.bangla: 'হ্যাঁ'},
  'no': {AppLanguage.english: 'No', AppLanguage.bangla: 'না'},

  // ============= AUTH =============
  'login': {AppLanguage.english: 'Login', AppLanguage.bangla: 'লগইন'},
  'signup': {AppLanguage.english: 'Sign Up', AppLanguage.bangla: 'নিবন্ধন'},
  'email': {AppLanguage.english: 'Email', AppLanguage.bangla: 'ইমেইল'},
  'password': {
    AppLanguage.english: 'Password',
    AppLanguage.bangla: 'পাসওয়ার্ড',
  },
  'forgot_password': {
    AppLanguage.english: 'Forgot Password?',
    AppLanguage.bangla: 'পাসওয়ার্ড ভুলে গেছেন?',
  },
  'login_with_google': {
    AppLanguage.english: 'Login with Google',
    AppLanguage.bangla: 'গুগল দিয়ে লগইন',
  },
  'phone_verification': {
    AppLanguage.english: 'Phone Verification',
    AppLanguage.bangla: 'ফোন যাচাইকরণ',
  },

  // ============= HOME =============
  'home': {AppLanguage.english: 'Home', AppLanguage.bangla: 'হোম'},
  'donate': {AppLanguage.english: 'Donate', AppLanguage.bangla: 'রক্তদান'},
  'requests': {AppLanguage.english: 'Requests', AppLanguage.bangla: 'অনুরোধ'},
  'profile': {AppLanguage.english: 'Profile', AppLanguage.bangla: 'প্রোফাইল'},
  'welcome': {AppLanguage.english: 'Welcome', AppLanguage.bangla: 'স্বাগতম'},
  'find_donors': {
    AppLanguage.english: 'Find Donors',
    AppLanguage.bangla: 'ডোনার খুঁজুন',
  },
  'blood_request': {
    AppLanguage.english: 'Blood Request',
    AppLanguage.bangla: 'রক্তের অনুরোধ',
  },
  'emergency': {AppLanguage.english: 'Emergency', AppLanguage.bangla: 'জরুরি'},

  // ============= DASHBOARD =============
  'total_donations': {
    AppLanguage.english: 'Total Donations',
    AppLanguage.bangla: 'মোট রক্তদান',
  },
  'lives_saved': {
    AppLanguage.english: 'Lives Saved',
    AppLanguage.bangla: 'জীবন রক্ষা',
  },
  'next_donation': {
    AppLanguage.english: 'Next Donation',
    AppLanguage.bangla: 'পরবর্তী রক্তদান',
  },
  'days_until_eligible': {
    AppLanguage.english: 'Days Until Eligible',
    AppLanguage.bangla: 'যোগ্য হতে আর',
  },
  'ready_to_donate': {
    AppLanguage.english: 'Ready to Donate',
    AppLanguage.bangla: 'রক্তদান করতে প্রস্তুত',
  },
  'notifications': {
    AppLanguage.english: 'Notifications',
    AppLanguage.bangla: 'বিজ্ঞপ্তি',
  },

  // ============= ADMIN =============
  'admin_dashboard': {
    AppLanguage.english: 'Admin Dashboard',
    AppLanguage.bangla: 'অ্যাডমিন ড্যাশবোর্ড',
  },
  'super_admin': {
    AppLanguage.english: 'Super Admin',
    AppLanguage.bangla: 'সুপার অ্যাডমিন',
  },
  'total_users': {
    AppLanguage.english: 'Total Users',
    AppLanguage.bangla: 'মোট ব্যবহারকারী',
  },
  'total_admins': {
    AppLanguage.english: 'Total Admins',
    AppLanguage.bangla: 'মোট অ্যাডমিন',
  },
  'active_admins': {
    AppLanguage.english: 'Active Admins',
    AppLanguage.bangla: 'সক্রিয় অ্যাডমিন',
  },
  'total_requests': {
    AppLanguage.english: 'Total Requests',
    AppLanguage.bangla: 'মোট অনুরোধ',
  },
  'pending_requests': {
    AppLanguage.english: 'Pending Requests',
    AppLanguage.bangla: 'অপেক্ষমাণ অনুরোধ',
  },
  'fulfilled_requests': {
    AppLanguage.english: 'Fulfilled Requests',
    AppLanguage.bangla: 'সম্পন্ন অনুরোধ',
  },
  'activity_logs': {
    AppLanguage.english: 'Activity Logs',
    AppLanguage.bangla: 'কার্যকলাপ লগ',
  },
  'view_logs': {
    AppLanguage.english: 'View Logs',
    AppLanguage.bangla: 'লগ দেখুন',
  },
  'revenue': {AppLanguage.english: 'Revenue', AppLanguage.bangla: 'আয়'},
  'bookings': {AppLanguage.english: 'Bookings', AppLanguage.bangla: 'বুকিং'},

  // ============= TIME FILTERS =============
  'all_time': {AppLanguage.english: 'All Time', AppLanguage.bangla: 'সব সময়'},
  'last_7_days': {
    AppLanguage.english: 'Last 7 Days',
    AppLanguage.bangla: 'গত ৭ দিন',
  },
  'last_30_days': {
    AppLanguage.english: 'Last 30 Days',
    AppLanguage.bangla: 'গত ৩০ দিন',
  },
  'last_90_days': {
    AppLanguage.english: 'Last 90 Days',
    AppLanguage.bangla: 'গত ৯০ দিন',
  },
  'today': {AppLanguage.english: 'Today', AppLanguage.bangla: 'আজ'},
  'this_week': {
    AppLanguage.english: 'This Week',
    AppLanguage.bangla: 'এই সপ্তাহ',
  },
  'this_month': {
    AppLanguage.english: 'This Month',
    AppLanguage.bangla: 'এই মাস',
  },

  // ============= BLOOD TYPES =============
  'blood_type': {
    AppLanguage.english: 'Blood Type',
    AppLanguage.bangla: 'রক্তের গ্রুপ',
  },
  'blood_group': {
    AppLanguage.english: 'Blood Group',
    AppLanguage.bangla: 'রক্তের গ্রুপ',
  },

  // ============= SETTINGS =============
  'settings': {AppLanguage.english: 'Settings', AppLanguage.bangla: 'সেটিংস'},
  'language': {AppLanguage.english: 'Language', AppLanguage.bangla: 'ভাষা'},
  'select_language': {
    AppLanguage.english: 'Select Language',
    AppLanguage.bangla: 'ভাষা নির্বাচন করুন',
  },
  'english': {AppLanguage.english: 'English', AppLanguage.bangla: 'ইংরেজি'},
  'bangla': {AppLanguage.english: 'Bangla', AppLanguage.bangla: 'বাংলা'},
  'theme': {AppLanguage.english: 'Theme', AppLanguage.bangla: 'থিম'},
  'dark_mode': {
    AppLanguage.english: 'Dark Mode',
    AppLanguage.bangla: 'ডার্ক মোড',
  },
  'light_mode': {
    AppLanguage.english: 'Light Mode',
    AppLanguage.bangla: 'লাইট মোড',
  },

  // ============= STATUS =============
  'available': {AppLanguage.english: 'Available', AppLanguage.bangla: 'উপলব্ধ'},
  'unavailable': {
    AppLanguage.english: 'Unavailable',
    AppLanguage.bangla: 'অনুপলব্ধ',
  },
  'busy': {AppLanguage.english: 'Busy', AppLanguage.bangla: 'ব্যস্ত'},
  'active': {AppLanguage.english: 'Active', AppLanguage.bangla: 'সক্রিয়'},
  'inactive': {
    AppLanguage.english: 'Inactive',
    AppLanguage.bangla: 'নিষ্ক্রিয়',
  },
  'pending': {AppLanguage.english: 'Pending', AppLanguage.bangla: 'অপেক্ষমাণ'},
  'completed': {
    AppLanguage.english: 'Completed',
    AppLanguage.bangla: 'সম্পন্ন',
  },
  'cancelled': {
    AppLanguage.english: 'Cancelled',
    AppLanguage.bangla: 'বাতিলকৃত',
  },

  // ============= MESSAGES =============
  'no_data': {
    AppLanguage.english: 'No data available',
    AppLanguage.bangla: 'কোন তথ্য নেই',
  },
  'no_results': {
    AppLanguage.english: 'No results found',
    AppLanguage.bangla: 'কোন ফলাফল পাওয়া যায়নি',
  },
  'loading_error': {
    AppLanguage.english: 'Failed to load data',
    AppLanguage.bangla: 'তথ্য লোড করতে ব্যর্থ',
  },
  'network_error': {
    AppLanguage.english: 'Network error',
    AppLanguage.bangla: 'নেটওয়ার্ক ত্রুটি',
  },
  'try_again': {
    AppLanguage.english: 'Try Again',
    AppLanguage.bangla: 'আবার চেষ্টা করুন',
  },
  'logout': {AppLanguage.english: 'Logout', AppLanguage.bangla: 'লগআউট'},
  'logout_confirm': {
    AppLanguage.english: 'Are you sure you want to logout?',
    AppLanguage.bangla: 'আপনি কি লগআউট করতে চান?',
  },

  // ============= BOOKING =============
  'advance_booking': {
    AppLanguage.english: 'Advance Booking',
    AppLanguage.bangla: 'অগ্রিম বুকিং',
  },
  'book_now': {
    AppLanguage.english: 'Book Now',
    AppLanguage.bangla: 'এখনই বুক করুন',
  },
  'booking_details': {
    AppLanguage.english: 'Booking Details',
    AppLanguage.bangla: 'বুকিং বিস্তারিত',
  },
  'payment_status': {
    AppLanguage.english: 'Payment Status',
    AppLanguage.bangla: 'পেমেন্ট স্ট্যাটাস',
  },
  'paid': {AppLanguage.english: 'Paid', AppLanguage.bangla: 'পরিশোধিত'},
  'unpaid': {AppLanguage.english: 'Unpaid', AppLanguage.bangla: 'অপরিশোধিত'},

  // ============= REVENUE =============
  'total_revenue': {
    AppLanguage.english: 'Total Revenue',
    AppLanguage.bangla: 'মোট আয়',
  },
  'daily_revenue': {
    AppLanguage.english: 'Daily Revenue',
    AppLanguage.bangla: 'দৈনিক আয়',
  },
  'revenue_analytics': {
    AppLanguage.english: 'Revenue Analytics',
    AppLanguage.bangla: 'আয় বিশ্লেষণ',
  },
  'income_report': {
    AppLanguage.english: 'Income Report',
    AppLanguage.bangla: 'আয়ের রিপোর্ট',
  },

  // ============= ERRORS =============
  'error_occurred': {
    AppLanguage.english: 'An error occurred',
    AppLanguage.bangla: 'একটি ত্রুটি ঘটেছে',
  },
  'please_wait': {
    AppLanguage.english: 'Please wait...',
    AppLanguage.bangla: 'দয়া করে অপেক্ষা করুন...',
  },
  'processing': {
    AppLanguage.english: 'Processing...',
    AppLanguage.bangla: 'প্রক্রিয়াকরণ হচ্ছে...',
  },

  // ============= ACTIONS =============
  'view_details': {
    AppLanguage.english: 'View Details',
    AppLanguage.bangla: 'বিস্তারিত দেখুন',
  },
  'view_all': {
    AppLanguage.english: 'View All',
    AppLanguage.bangla: 'সবগুলো দেখুন',
  },
  'manage': {AppLanguage.english: 'Manage', AppLanguage.bangla: 'পরিচালনা'},
  'create': {AppLanguage.english: 'Create', AppLanguage.bangla: 'তৈরি করুন'},
  'update': {AppLanguage.english: 'Update', AppLanguage.bangla: 'আপডেট'},
  'download': {AppLanguage.english: 'Download', AppLanguage.bangla: 'ডাউনলোড'},
  'share': {AppLanguage.english: 'Share', AppLanguage.bangla: 'শেয়ার'},
  'call': {AppLanguage.english: 'Call', AppLanguage.bangla: 'কল করুন'},
  'message': {AppLanguage.english: 'Message', AppLanguage.bangla: 'মেসেজ'},

  // ============= STATISTICS =============
  'statistics': {
    AppLanguage.english: 'Statistics',
    AppLanguage.bangla: 'পরিসংখ্যান',
  },
  'analytics': {
    AppLanguage.english: 'Analytics',
    AppLanguage.bangla: 'বিশ্লেষণ',
  },
  'reports': {AppLanguage.english: 'Reports', AppLanguage.bangla: 'রিপোর্ট'},
  'overview': {
    AppLanguage.english: 'Overview',
    AppLanguage.bangla: 'সারসংক্ষেপ',
  },
};

/// Extension for easy access to translations
extension LocalizationExtension on BuildContext {
  LocalizationService get locale => LocalizationService();
  String tr(String key) => LocalizationService().translate(key);
}
