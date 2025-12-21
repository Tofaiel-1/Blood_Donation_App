/// Bangla Localization Service
/// Full Bangla language support for Bangladesh users
class BanglaLocalizationService {
  static final BanglaLocalizationService _instance =
      BanglaLocalizationService._internal();
  factory BanglaLocalizationService() => _instance;
  BanglaLocalizationService._internal();

  // Language preferences
  String _currentLanguage = 'bn'; // bn = Bangla, en = English

  String get currentLanguage => _currentLanguage;

  void setLanguage(String lang) {
    _currentLanguage = lang;
  }

  /// Get translated text
  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  /// All translations
  static const Map<String, Map<String, String>> _translations = {
    'bn': {
      // Home Screen
      'home': 'হোম',
      'search': 'খুঁজুন',
      'requests': 'অনুরোধ',
      'profile': 'প্রোফাইল',
      'emergency': 'জরুরি',

      // Blood Types
      'A+': 'এ পজিটিভ',
      'A-': 'এ নেগেটিভ',
      'B+': 'বি পজিটিভ',
      'B-': 'বি নেগেটিভ',
      'AB+': 'এবি পজিটিভ',
      'AB-': 'এবি নেগেটিভ',
      'O+': 'ও পজিটিভ',
      'O-': 'ও নেগেটিভ',

      // Actions
      'donate_blood': 'রক্তদান করুন',
      'request_blood': 'রক্ত অনুরোধ করুন',
      'find_donors': 'দাতা খুঁজুন',
      'donate_now': 'এখনই দান করুন',
      'register': 'নিবন্ধন করুন',
      'login': 'লগইন',
      'logout': 'লগআউট',
      'save': 'সংরক্ষণ করুন',
      'cancel': 'বাতিল',
      'submit': 'জমা দিন',
      'confirm': 'নিশ্চিত করুন',
      'edit': 'সম্পাদনা',
      'delete': 'মুছুন',
      'share': 'শেয়ার',

      // Profile
      'my_profile': 'আমার প্রোফাইল',
      'name': 'নাম',
      'phone': 'ফোন',
      'email': 'ইমেইল',
      'blood_type': 'রক্তের গ্রুপ',
      'location': 'অবস্থান',
      'total_donations': 'মোট দান',
      'last_donation': 'শেষ দান',
      'available_to_donate': 'দান করতে প্রস্তুত',
      'not_available': 'প্রস্তুত নন',

      // Bangladesh Locations
      'dhaka': 'ঢাকা',
      'chittagong': 'চট্টগ্রাম',
      'rajshahi': 'রাজশাহী',
      'khulna': 'খুলনা',
      'barisal': 'বরিশাল',
      'sylhet': 'সিলেট',
      'rangpur': 'রংপুর',
      'mymensingh': 'ময়মনসিংহ',

      // Blood Request
      'blood_needed': 'রক্তের প্রয়োজন',
      'patient_name': 'রোগীর নাম',
      'hospital': 'হাসপাতাল',
      'urgency': 'জরুরি অবস্থা',
      'critical': 'অত্যন্ত জরুরি',
      'urgent': 'জরুরি',
      'normal': 'সাধারণ',
      'units_needed': 'ব্যাগ প্রয়োজন',
      'contact_number': 'যোগাযোগ নম্বর',

      // Notifications
      'notifications': 'বিজ্ঞপ্তি',
      'new_request': 'নতুন অনুরোধ',
      'donation_reminder': 'দানের স্মরণপত্র',
      'thank_you': 'ধন্যবাদ',
      'you_saved_life': 'আপনি একটি জীবন বাঁচিয়েছেন!',

      // Premium
      'become_premium': 'প্রিমিয়াম হন',
      'premium_benefits': 'প্রিমিয়াম সুবিধা',
      'monthly': 'মাসিক',
      'yearly': 'বার্ষিক',
      'price_per_month': '৳১০০/মাস',
      'price_per_year': '৳১০০০/বছর',

      // Wallet
      'wallet': 'মানিব্যাগ',
      'balance': 'ব্যালেন্স',
      'withdraw': 'উত্তোলন করুন',
      'minimum_withdrawal': 'ন্যূনতম উত্তোলন: ৳১০০',
      'bkash': 'বিকাশ',
      'nagad': 'নগদ',
      'rocket': 'রকেট',

      // Messages
      'welcome': 'স্বাগতম',
      'save_lives': 'জীবন বাঁচান',
      'be_a_hero': 'একজন হিরো হন',
      'donate_blood_save_lives': 'রক্তদান করুন, জীবন বাঁচান',
      'every_drop_counts': 'প্রতিটি ফোঁটা গুরুত্বপূর্ণ',
      'join_us': 'আমাদের সাথে যুক্ত হন',

      // Stats
      'lives_saved': 'জীবন বাঁচানো',
      'active_donors': 'সক্রিয় দাতা',
      'blood_units': 'ব্যাগ রক্ত',
      'hospitals': 'হাসপাতাল',

      // Days
      'today': 'আজ',
      'yesterday': 'গতকাল',
      'days_ago': 'দিন আগে',
      'monday': 'সোমবার',
      'tuesday': 'মঙ্গলবার',
      'wednesday': 'বুধবার',
      'thursday': 'বৃহস্পতিবার',
      'friday': 'শুক্রবার',
      'saturday': 'শনিবার',
      'sunday': 'রবিবার',

      // Months
      'january': 'জানুয়ারি',
      'february': 'ফেব্রুয়ারি',
      'march': 'মার্চ',
      'april': 'এপ্রিল',
      'may': 'মে',
      'june': 'জুন',
      'july': 'জুলাই',
      'august': 'আগস্ট',
      'september': 'সেপ্টেম্বর',
      'october': 'অক্টোবর',
      'november': 'নভেম্বর',
      'december': 'ডিসেম্বর',

      // Health
      'health_tracker': 'স্বাস্থ্য ট্র্যাকার',
      'hemoglobin': 'হিমোগ্লোবিন',
      'blood_pressure': 'রক্তচাপ',
      'weight': 'ওজন',
      'eligible': 'যোগ্য',
      'not_eligible': 'যোগ্য নন',

      // Badges
      'badge': 'ব্যাজ',
      'hero': 'হিরো',
      'legend': 'কিংবদন্তি',
      'champion': 'চ্যাম্পিয়ন',

      // Errors
      'error': 'ত্রুটি',
      'success': 'সফল',
      'loading': 'লোড হচ্ছে...',
      'no_data': 'কোন তথ্য নেই',
      'try_again': 'আবার চেষ্টা করুন',

      // Campaigns
      'campaigns': 'ক্যাম্পেইন',
      'blood_donation_camp': 'রক্তদান শিবির',
      'register_campaign': 'ক্যাম্পেইনে নিবন্ধন',
      'venue': 'স্থান',
      'date': 'তারিখ',
      'time': 'সময়',

      // Emergency Network
      'emergency_network': 'জরুরি নেটওয়ার্ক',
      'family_network': 'পরিবার নেটওয়ার্ক',
      'workplace_network': 'কর্মক্ষেত্র নেটওয়ার্ক',
      'alumni_network': 'প্রাক্তন ছাত্র নেটওয়ার্ক',
      'create_network': 'নেটওয়ার্ক তৈরি করুন',
      'join_network': 'নেটওয়ার্কে যোগ দিন',

      // Buddy System
      'blood_buddy': 'রক্ত বন্ধু',
      'find_buddy': 'বন্ধু খুঁজুন',
      'be_a_buddy': 'একজন বন্ধু হন',
      'mentor': 'পরামর্শদাতা',

      // Universal Donor
      'universal_donor': 'সর্বজনীন দাতা',
      'universal_donor_rewards': 'সর্বজনীন দাতা পুরস্কার',
      'lives_you_saved': 'আপনি যতজনকে বাঁচিয়েছেন',

      // Settings
      'settings': 'সেটিংস',
      'language': 'ভাষা',
      'english': 'ইংরেজি',
      'bangla': 'বাংলা',
      'change_language': 'ভাষা পরিবর্তন করুন',
      'privacy': 'গোপনীয়তা',
      'terms': 'শর্তাবলী',
      'help': 'সাহায্য',
      'about': 'সম্পর্কে',
      'version': 'সংস্করণ',

      // Common Phrases
      'yes': 'হ্যাঁ',
      'no': 'না',
      'ok': 'ঠিক আছে',
      'done': 'সম্পন্ন',
      'next': 'পরবর্তী',
      'previous': 'পূর্ববর্তী',
      'skip': 'এড়িয়ে যান',
      'continue': 'চালিয়ে যান',
    },
    'en': {
      // English translations (original keys)
      'home': 'Home',
      'search': 'Search',
      'requests': 'Requests',
      'profile': 'Profile',
      'emergency': 'Emergency',
      'donate_blood': 'Donate Blood',
      'request_blood': 'Request Blood',
      'find_donors': 'Find Donors',
      'donate_now': 'Donate Now',
      // ... (all keys map to themselves for English)
    },
  };

  /// Get blood type in Bangla
  String getBloodTypeBangla(String bloodType) {
    return translate(bloodType);
  }

  /// Get division name in Bangla
  String getDivisionBangla(String division) {
    return translate(division.toLowerCase());
  }

  /// Format number in Bangla
  String formatNumberBangla(int number) {
    if (_currentLanguage != 'bn') return number.toString();

    const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final numStr = number.toString();
    var result = '';

    for (var char in numStr.split('')) {
      if (char == '-') {
        result += char;
      } else {
        result += banglaDigits[int.parse(char)];
      }
    }

    return result;
  }

  /// Format currency in Taka
  String formatCurrency(double amount) {
    if (_currentLanguage == 'bn') {
      return '৳${formatNumberBangla(amount.toInt())}';
    }
    return '৳${amount.toInt()}';
  }
}
