# 👨‍💻 Developer Guide - Blood Donation App

## 📚 Quick Navigation

### 🔍 Finding Code
- [Code Structure](#-code-structure) - Where is what?
- [Common Tasks](#-common-tasks) - How to do X?
- [Quick Reference](#-quick-reference) - Code snippets
- [Performance Tips](#-performance-optimization) - Speed up app

---

## 📁 CODE STRUCTURE

### Folder Organization
```
lib/
├── config/           → routes.dart (all app routes)
├── models/           → Data models (User, BloodRequest, Donation, etc.)
├── screens/          → UI screens
│   ├── auth/         → Login, Signup, Verification
│   ├── home/         → Main app screens (Home, Search, Profile, etc.)
│   ├── admin/        → Admin dashboards & data management
│   └── chat/         → AI Chatbot
├── services/         → Business logic & Firebase
├── utils/            → Validators, Colors, Theme, Constants
└── widgets/          → Reusable UI components
```

### 🔐 Authentication
| File | Purpose | Key Functions |
|------|---------|--------------|
| `screens/auth/login_screen.dart` | Login UI | `_handleLogin()` line 370+ |
| `screens/auth/signup_screen.dart` | Registration | `_onSignupPressed()` line 420+ |
| `screens/auth/verification_screen.dart` | Email/Phone verify | Email line 80+, Phone line 120+ |
| `services/auth_service.dart` | Auth logic | All authentication methods |
| `utils/phone_validator.dart` | BD phone validation | 11-digit validation |

### 🏠 Main App Screens
| File | Purpose |
|------|---------|
| `screens/home/main_navigation_screen.dart` | Bottom nav (5 tabs) |
| `screens/home/home_screen.dart` | Dashboard with stats |
| `screens/home/search_screen.dart` | Find donors |
| `screens/home/donate_screen.dart` | Record donation |
| `screens/home/messages_screen.dart` | Chat |
| `screens/home/profile_screen.dart` | Profile & settings |
| `screens/home/user_blood_request_screen.dart` | Request blood with location |

### 👨‍💼 Admin
| File | Purpose |
|------|---------|
| `screens/admin/super_admin_screen.dart` | Super admin dashboard |
| `screens/admin/demo_data_screen.dart` | Create test data |
| `screens/admin/add_data_screen.dart` | Manual data entry |

### 🛠️ Services
| File | Purpose |
|------|---------|
| `services/auth_service.dart` | Authentication (login, signup, verify) |
| `services/firestore_service.dart` | Database operations |
| `services/location_service.dart` | GPS & location |
| `services/bangladesh_demo_data_service.dart` | BD demo data (20 users) |
| `services/gemini_chat_service.dart` | AI chatbot |

### 🎨 Utils
| File | Purpose |
|------|---------|
| `utils/app_colors.dart` | All colors (bloodRed, hopeGreen, etc.) |
| `utils/theme_manager.dart` | Light/dark theme |
| `utils/validators.dart` | Form validation |
| `utils/phone_validator.dart` | BD 11-digit phone validation |

---

## 🔍 COMMON TASKS

### Where is Login Logic?
```
File: lib/screens/auth/login_screen.dart
Function: _handleLogin() at line 370+
Service: lib/services/auth_service.dart → signInWithEmail()
```

### Where is Signup?
```
File: lib/screens/auth/signup_screen.dart
Function: _onSignupPressed() at line 420+
Service: lib/services/auth_service.dart → registerWithEmail()
```

### Where is Email Verification?
```
File: lib/screens/auth/verification_screen.dart
Function: _sendEmailVerification() at line 80+
Function: _checkEmailVerification() at line 90+
```

### Where is Phone Verification?
```
File: lib/screens/auth/verification_screen.dart
Function: _sendPhoneVerification() at line 120+
Function: _verifyOtp() at line 180+
Validator: lib/utils/phone_validator.dart
```

### Where is Blood Request Form?
```
File: lib/screens/home/user_blood_request_screen.dart
Location: _getCurrentLocation() at line 150+
Submit: _submitRequest() at line 200+
```

### Where is Bangladesh Demo Data?
```
File: lib/services/bangladesh_demo_data_service.dart
Function: createBangladeshDemoData() at line 80+
Features: 20 BD users, 11-digit phones, Dhaka locations
```

### Where are Routes?
```
File: lib/config/routes.dart
All app routes with comments
```

### Where are Colors?
```
File: lib/utils/app_colors.dart
bloodRed, hopeGreen, urgentRed, warningAmber, gradients
```

---

## 🚀 QUICK REFERENCE

### Authentication

#### Check if User Logged In
```dart
import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  print('Logged in: ${user.email}');
}
```

#### Login User
```dart
import '../../services/auth_service.dart';

final authService = AuthService();
try {
  await authService.signInWithEmail(email, password);
  // Success
} catch (e) {
  // Handle error
}
```

#### Get User Profile
```dart
final profile = await authService.getCurrentUserProfile();
final name = profile?.data()?['name'];
final bloodType = profile?.data()?['bloodType'];
```

#### Update Profile
```dart
await authService.updateUserProfile({
  'name': 'New Name',
  'bloodType': 'A+',
});
```

### Navigation

```dart
// Go to screen
Navigator.pushNamed(context, '/home');

// With data
Navigator.pushNamed(
  context, 
  '/verification',
  arguments: {'email': email, 'phone': phone},
);

// Go back
Navigator.pop(context);
```

### Colors

```dart
import '../../utils/app_colors.dart';

Container(
  color: AppColors.bloodRed,        // Primary red
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
  ),
)

// Status colors
AppColors.hopeGreen      // Success
AppColors.urgentRed      // Error
AppColors.warningAmber   // Warning
```

### Firestore

#### Add Document
```dart
await FirebaseFirestore.instance.collection('blood_requests').add({
  'userId': userId,
  'bloodType': 'A+',
  'createdAt': FieldValue.serverTimestamp(),
});
```

#### Get Documents
```dart
final snapshot = await FirebaseFirestore.instance
  .collection('blood_requests')
  .where('bloodType', isEqualTo: 'A+')
  .limit(10)
  .get();

for (var doc in snapshot.docs) {
  print(doc.data());
}
```

#### Real-time Updates
```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
    .collection('blood_requests')
    .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    final docs = snapshot.data!.docs;
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map;
        return ListTile(title: Text(data['bloodType']));
      },
    );
  },
)
```

### Form Validation

```dart
import '../../utils/validators.dart';
import '../../utils/phone_validator.dart';

TextFormField(
  validator: Validators.validateEmail,
)

TextFormField(
  validator: PhoneValidator.validatePhone, // BD 11-digit
)
```

### Theme

```dart
import 'package:provider/provider.dart';
import '../../utils/theme_manager.dart';

// Toggle theme
final themeManager = Provider.of<ThemeManager>(context);
themeManager.toggleTheme();

// Set specific
themeManager.setThemeMode(ThemeMode.dark);
```

### Show Messages

```dart
// SnackBar
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Success!'),
    backgroundColor: AppColors.hopeGreen,
  ),
);

// Dialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Title'),
    content: Text('Message'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('OK'),
      ),
    ],
  ),
);
```

---

## ⚡ PERFORMANCE OPTIMIZATION

### Best Practices

#### 1. Use const Constructors
```dart
// ✅ Good
const Text('Static Text')
const Icon(Icons.home)

// ❌ Avoid
Text('Static Text')
```

#### 2. ListView.builder for Lists
```dart
// ✅ Good - Lazy loading
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// ❌ Avoid - Loads all at once
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)
```

#### 3. Dispose Controllers
```dart
@override
void dispose() {
  _controller.dispose();
  _stream?.cancel();
  super.dispose();
}
```

#### 4. Limit Firestore Queries
```dart
// ✅ Good - With limit
FirebaseFirestore.instance
  .collection('users')
  .limit(20)
  .get();

// ❌ Avoid - Gets everything
FirebaseFirestore.instance
  .collection('users')
  .get();
```

#### 5. Batch Firestore Writes
```dart
// ✅ Good
WriteBatch batch = FirebaseFirestore.instance.batch();
for (var item in items) {
  var ref = FirebaseFirestore.instance.collection('items').doc();
  batch.set(ref, item);
}
await batch.commit();
```

### Code Quality Commands

```bash
# Check for issues
flutter analyze

# Format code
dart format lib/

# Fix issues
dart fix --apply

# Clean build
flutter clean
flutter pub get
```

### Build Optimized APK

```bash
# Split by architecture (smaller size)
flutter build apk --split-per-abi

# With obfuscation
flutter build apk --obfuscate --split-debug-info=./debug-info

# App bundle for Play Store
flutter build appbundle
```

---

## 🐛 DEBUGGING

### Common Issues

**Login not working?**
- Check: `lib/services/auth_service.dart`
- Check: Firebase Console → Authentication

**Phone verification failing?**
- Check: Firebase Console → Phone Auth enabled
- Check: SHA-1 certificate added (Android)
- Format: +880XXXXXXXXXX

**Build failed?**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Hot reload not working?**
- Press `R` for hot reload
- Press `Shift + R` for hot restart

---

## 📱 PROJECT STRUCTURE

### Total Files: 46 Dart files

**Screens:** 18 files
- Auth: 4 (login, signup, verification, phone auth)
- Home: 8 (main nav, home, search, donate, messages, profile, request, etc.)
- Admin: 6 (dashboards, data management)

**Services:** 10 files
- Auth, Firestore, Location, Storage, Messaging, etc.

**Models:** 8 files
- User, BloodRequest, Donation, Message, etc.

**Utils:** 6 files
- Colors, Theme, Validators, Phone Validator, etc.

**Widgets:** 2 files
- Themed widgets, Custom components

**Config:** 1 file
- Routes

---

## 🎯 QUICK TIPS

1. **Find code fast** → Search this guide for feature name
2. **Need example?** → Check Quick Reference section
3. **Performance issue?** → Check Optimization section
4. **Build error?** → Check Debugging section
5. **New feature?** → Follow existing patterns

---

## 📚 All Routes

```dart
/                      → Welcome Screen
/login                 → Login
/signup                → Signup
/verification          → Email/Phone verification
/home                  → Main app (bottom nav)
/search                → Search donors
/donate                → Record donation
/messages              → Chat
/profile               → Profile & settings
/user-blood-request    → Request blood with location
/chatbot               → AI assistant
/super-admin           → Super admin dashboard
/demo-data             → Demo data management
```

---

**Last Updated:** November 28, 2025  
**Version:** 1.0
