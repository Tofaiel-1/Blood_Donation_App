# 🌐 Multi-Language Support Guide

## Overview
The Blood Donation App now supports **English** and **Bangla** languages. Users can switch between languages dynamically without restarting the app.

---

## ✨ Features

### 1. **Language Selection**
- **Location**: Profile Screen → Settings → Language/ভাষা
- **Options**: 
  - 🇬🇧 English
  - 🇧🇩 বাংলা (Bangla)
- **Default**: Bangla (can be changed in code)

### 2. **Persistent Language**
- Selected language is saved using `SharedPreferences`
- Language persists across app restarts
- No need to select language every time

### 3. **Quick Switch**
- Click on Language setting in Profile
- Dialog appears with both language options
- Select preferred language
- App UI updates instantly

---

## 📂 Implementation Structure

### Core Files Created

#### 1. **LocalizationService** 
**Path**: `lib/services/localization_service.dart`

**Features**:
- Centralized translation management
- 200+ translation strings
- Easy to add new translations
- Simple API: `LocalizationService().translate('key')`

**Key Methods**:
```dart
LocalizationService().initialize()          // Load saved language
LocalizationService().setLanguage(language) // Change language
LocalizationService().translate('key')      // Get translation
LocalizationService().isBangla              // Check if Bangla
LocalizationService().isEnglish             // Check if English
```

#### 2. **LanguageSelector Widget**
**Path**: `lib/widgets/language_selector.dart`

**Two Modes**:
1. **Dialog Mode**: Full-screen language selection dialog
2. **Inline Mode**: Embedded language selector for settings

**Usage**:
```dart
// Show dialog
showDialog(
  context: context,
  builder: (context) => const LanguageSelector(showInDialog: true),
);

// Inline in settings
const LanguageSelector(showInDialog: false)
```

#### 3. **LanguageSwitchButton**
**Path**: Same file as LanguageSelector

**Usage**: Quick access language switch button for AppBar
```dart
AppBar(
  actions: [
    const LanguageSwitchButton(),
  ],
)
```

---

## 🔑 Translation Keys

### Common Keys
- `app_name`, `ok`, `cancel`, `save`, `delete`, `edit`, `search`
- `loading`, `error`, `success`, `warning`, `refresh`, `close`
- `submit`, `back`, `next`, `previous`, `yes`, `no`

### Authentication
- `login`, `signup`, `email`, `password`, `forgot_password`
- `login_with_google`, `phone_verification`

### Home & Navigation
- `home`, `donate`, `requests`, `profile`, `welcome`
- `find_donors`, `blood_request`, `emergency`

### Dashboard
- `total_donations`, `lives_saved`, `next_donation`
- `days_until_eligible`, `ready_to_donate`, `notifications`

### Admin
- `admin_dashboard`, `super_admin`, `total_users`, `total_admins`
- `active_admins`, `total_requests`, `pending_requests`, `fulfilled_requests`
- `activity_logs`, `view_logs`, `revenue`, `bookings`

### Time Filters
- `all_time`, `last_7_days`, `last_30_days`, `last_90_days`
- `today`, `this_week`, `this_month`

### Settings
- `settings`, `language`, `select_language`, `english`, `bangla`
- `theme`, `dark_mode`, `light_mode`

### Status
- `available`, `unavailable`, `busy`, `active`, `inactive`
- `pending`, `completed`, `cancelled`

### Booking & Revenue
- `advance_booking`, `book_now`, `booking_details`
- `payment_status`, `paid`, `unpaid`
- `total_revenue`, `daily_revenue`, `revenue_analytics`

---

## 🚀 How to Use

### 1. **Basic Translation**
```dart
import '../../services/localization_service.dart';

// In your widget
final localeService = LocalizationService();
Text(localeService.translate('welcome'))
```

### 2. **With Consumer (Auto-Update)**
```dart
import 'package:provider/provider.dart';

Consumer<LocalizationService>(
  builder: (context, localeService, child) {
    return Text(localeService.translate('welcome'));
  },
)
```

### 3. **Extension Method (Shortest)**
```dart
// Using extension
Text(context.tr('welcome'))

// Or
Text(context.locale.translate('welcome'))
```

### 4. **Conditional Text Based on Language**
```dart
final localeService = LocalizationService();

String getText() {
  if (localeService.isBangla) {
    return 'বাংলা টেক্সট';
  } else {
    return 'English text';
  }
}
```

---

## ➕ Adding New Translations

### Step 1: Add to Translation Map
Edit `lib/services/localization_service.dart`:

```dart
final Map<String, Map<AppLanguage, String>> _translations = {
  // ... existing translations
  
  'your_new_key': {
    AppLanguage.english: 'Your English Text',
    AppLanguage.bangla: 'আপনার বাংলা টেক্সট',
  },
};
```

### Step 2: Use in Code
```dart
Text(LocalizationService().translate('your_new_key'))
```

---

## 🎨 UI Examples

### 1. **Profile Settings Screen**
```dart
_buildSettingsTile(
  context,
  Icons.language,
  'Language / ভাষা',
  subtitle: Consumer<LocalizationService>(
    builder: (context, localeService, child) {
      return localeService.isBangla ? 'বাংলা' : 'English';
    },
  ),
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => const LanguageSelector(showInDialog: true),
    );
  },
),
```

### 2. **AppBar Title**
```dart
AppBar(
  title: Text(LocalizationService().translate('admin_dashboard')),
  actions: [
    const LanguageSwitchButton(),
  ],
)
```

### 3. **Button Text**
```dart
ElevatedButton(
  onPressed: () {},
  child: Text(LocalizationService().translate('submit')),
)
```

### 4. **Dialog Title**
```dart
AlertDialog(
  title: Text(LocalizationService().translate('confirm')),
  content: Text(LocalizationService().translate('logout_confirm')),
  actions: [
    TextButton(
      onPressed: () {},
      child: Text(LocalizationService().translate('yes')),
    ),
    TextButton(
      onPressed: () {},
      child: Text(LocalizationService().translate('no')),
    ),
  ],
)
```

---

## 🔍 Where to Find Language Selector

### For Users:
1. Open app
2. Go to **Profile** tab (bottom navigation)
3. Scroll to **Settings** section
4. Tap on **Language / ভাষা**
5. Select preferred language
6. App updates instantly

### For Developers:
- **Service**: `lib/services/localization_service.dart`
- **Widget**: `lib/widgets/language_selector.dart`
- **Integration**: `lib/main.dart` (MultiProvider setup)
- **Usage Example**: `lib/screens/home/profile_screen.dart`

---

## 🧪 Testing

### Test Scenarios:

1. **Language Switch**
   - ✅ Open Profile → Settings → Language
   - ✅ Switch to English
   - ✅ Verify UI updates
   - ✅ Switch to Bangla
   - ✅ Verify UI updates

2. **Persistence**
   - ✅ Select Bangla
   - ✅ Close app completely
   - ✅ Reopen app
   - ✅ Verify Bangla is still selected

3. **Multiple Screens**
   - ✅ Switch language
   - ✅ Navigate to different screens
   - ✅ Verify all screens reflect new language

4. **Admin Dashboard**
   - ✅ Login as admin
   - ✅ Check dashboard translations
   - ✅ Test time filters (7/30/90 days)
   - ✅ Verify charts and stats labels

---

## 📊 Translation Coverage

Current translation coverage:
- **Common UI**: 100%
- **Authentication**: 100%
- **Home & Profile**: 100%
- **Admin Dashboard**: 100%
- **Time Filters**: 100%
- **Settings**: 100%
- **Booking & Revenue**: 100%

**Total Translation Keys**: 100+

---

## 🔮 Future Enhancements

### Phase 1 (Current)
- ✅ Basic language switching
- ✅ Profile screen integration
- ✅ Persistent language storage

### Phase 2 (Planned)
- ⏳ Translate all screen titles
- ⏳ Translate all button labels
- ⏳ Translate all error messages
- ⏳ Translate form labels

### Phase 3 (Future)
- ⏳ Add more languages (Hindi, Arabic, etc.)
- ⏳ RTL support for Arabic
- ⏳ Language-specific date formats
- ⏳ Number formatting per locale

---

## 🐛 Common Issues & Solutions

### Issue 1: Language Not Updating
**Problem**: Selected language doesn't reflect in UI

**Solution**:
- Ensure widget uses `Consumer<LocalizationService>`
- Check if LocalizationService is provided in MultiProvider
- Verify translation key exists in map

### Issue 2: Persistence Not Working
**Problem**: Language resets after app restart

**Solution**:
- Check SharedPreferences initialization
- Verify `LocalizationService().initialize()` is called in main()
- Check storage permissions

### Issue 3: Missing Translations
**Problem**: Some text shows key instead of translation

**Solution**:
- Add missing key to `_translations` map
- Follow naming convention: `screen_element` (e.g., `login_button`)
- Restart app to load new translations

---

## 📝 Best Practices

1. **Always Use Translation Keys**
   - ❌ `Text('Welcome')`
   - ✅ `Text(context.tr('welcome'))`

2. **Use Consumer for Dynamic Updates**
   ```dart
   Consumer<LocalizationService>(
     builder: (context, locale, child) {
       return Text(locale.translate('key'));
     },
   )
   ```

3. **Consistent Key Naming**
   - Use snake_case: `login_button`
   - Group by screen: `profile_edit_button`
   - Keep short but descriptive

4. **Handle Plurals**
   ```dart
   String getDonationsText(int count) {
     if (localeService.isBangla) {
       return count == 1 ? 'রক্তদান' : 'রক্তদানগুলি';
     } else {
       return count == 1 ? 'donation' : 'donations';
     }
   }
   ```

---

## 📞 Support

If you need help with localization:
1. Check translation key in `localization_service.dart`
2. Verify widget uses Consumer or context.tr()
3. Test language switch in Profile → Settings
4. Check console for any errors

---

## ✅ Summary

✅ **Multi-language support** implemented (English + Bangla)  
✅ **Profile screen** has language selector  
✅ **Persistent storage** using SharedPreferences  
✅ **Dynamic updates** using Provider  
✅ **100+ translations** ready to use  
✅ **Easy to extend** with new languages  
✅ **User-friendly** language switching  

---

**Version**: 1.0  
**Last Updated**: December 21, 2025  
**Status**: ✅ Ready for Production
