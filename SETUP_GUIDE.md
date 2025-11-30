# 🔧 Setup Guide - Blood Donation App

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Firebase Account

---

## 📱 Installation  

### 1. Clone Repository
```bash
git clone https://github.com/Tofaiel-1/Blood_Donation_App.git
cd Blood_Donation_App
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run App
```bash
flutter run
```

---

## 🔥 FIREBASE SETUP

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "Blood Donation App"
4. Enable Google Analytics (optional)
5. Create project

### Step 2: Add Android App

1. In Firebase Console → Project Settings
2. Click Android icon
3. Enter package name: `com.example.blood_bank`
4. Download `google-services.json`
5. Place in `android/app/google-services.json`

### Step 3: Add iOS App (Optional)

1. Click iOS icon in Firebase
2. Enter bundle ID: `com.example.bloodBank`
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/GoogleService-Info.plist`

### Step 4: Enable Firebase Services

#### Authentication
1. Firebase Console → Authentication → Sign-in method
2. Enable:
   - ✅ Email/Password
   - ✅ Google
   - ✅ Phone (for verification)

#### Firestore Database
1. Firebase Console → Firestore Database → Create database
2. Start in **test mode** (or production with rules)
3. Select location: `asia-south1` (India) or closest

#### Storage
1. Firebase Console → Storage → Get started
2. Start in test mode
3. For profile pictures and documents

#### Cloud Messaging (Optional)
1. Firebase Console → Cloud Messaging
2. For push notifications

### Step 5: FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This will automatically:
- Select Firebase project
- Generate `lib/firebase_options.dart`
- Configure Android & iOS

### Step 6: Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Blood requests
    match /blood_requests/{requestId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Donations
    match /donations/{donationId} {
      allow read: if true;
      allow create: if request.auth != null;
    }
    
    // Admin only
    match /admins/{adminId} {
      allow read: if request.auth != null;
      allow write: if false; // Only via Cloud Functions
    }
  }
}
```

---

## 🔐 VERIFICATION SETUP

### Email Verification

**Already configured!** Works automatically with Firebase Auth.

How it works:
1. User signs up
2. System sends verification email automatically
3. User clicks link in email
4. Email verified

### Phone Verification (SMS OTP)

#### Enable in Firebase
1. Firebase Console → Authentication → Sign-in method
2. Enable "Phone" provider
3. Add test phone numbers (for development):
   - Phone: `+880 1711-123456`
   - Code: `123456`

#### For Android (Production)
1. Get SHA-1 certificate:
```bash
cd android
./gradlew signingReport
```

2. Copy SHA-1 fingerprint
3. Firebase Console → Project Settings → Android app
4. Add SHA-1 certificate fingerprint

#### For iOS
Already works with `GoogleService-Info.plist`

#### Phone Format
```dart
// Bangladesh format: +880XXXXXXXXXX
// Example: +880 1711-123456
// The app automatically formats to international format
```

---

## 🎨 FEATURES

### ✅ Implemented Features

#### 1. **Authentication**
- ✅ Email/Password login & signup
- ✅ Email verification (with auto-check)
- ✅ Phone verification (SMS OTP)
- ✅ Google Sign-in
- ✅ 11-digit Bangladesh phone validation
- ✅ Password validation (min 6 chars)

#### 2. **Blood Request System**
- ✅ Request blood with form
- ✅ Auto-detect current location
- ✅ Show nearby donation centers (within 10km)
- ✅ Calculate distance using Haversine formula
- ✅ Filter by blood type, urgency
- ✅ Real-time request updates

#### 3. **Donor Search**
- ✅ Search by blood type
- ✅ Location-based search
- ✅ Filter by availability
- ✅ Show donor profiles

#### 4. **Donation Management**
- ✅ Record blood donations
- ✅ Donation history
- ✅ Track donor-recipient pairs
- ✅ Donation statistics

#### 5. **Location Services**
- ✅ GPS location detection
- ✅ Distance calculation
- ✅ Nearby centers finder
- ✅ 10 Dhaka donation centers with coordinates

#### 6. **Admin Features**
- ✅ Super Admin dashboard
- ✅ Create demo data (Bangladesh-specific)
- ✅ Manual data entry (4 tabs)
- ✅ Audit logs
- ✅ User management

#### 7. **Demo Data**
- ✅ 20 Bangladeshi users with authentic names
- ✅ 10 Dhaka locations with GPS coordinates
- ✅ 15 blood requests
- ✅ 20 donations with clear tracking
- ✅ Location-based matching (within 5km)
- ✅ 11-digit BD phone numbers

#### 8. **UI/UX**
- ✅ Light & Dark theme
- ✅ Bengali + English mixed interface
- ✅ Bottom navigation (5 tabs)
- ✅ Floating action buttons
- ✅ Back button confirmation dialog
- ✅ Loading states
- ✅ Error handling

#### 9. **AI Chatbot**
- ✅ Gemini AI integration
- ✅ Health-related Q&A
- ✅ Blood donation guidance

#### 10. **Profile & Settings**
- ✅ Edit profile
- ✅ Theme toggle
- ✅ View donation history
- ✅ Logout

---

## 🌍 BANGLADESH-SPECIFIC FEATURES

### Phone Numbers
- 11-digit validation
- Operators: GP (013, 017), Robi (018), Banglalink (014, 019), Airtel (016), Teletalk (015)
- Format: 01711-123456
- International: +880 1711-123456

### Locations
10 Dhaka areas with GPS coordinates:
- মিরপুর (Mirpur)
- ধানমন্ডি (Dhanmondi)
- মোহাম্মদপুর (Mohammadpur)
- উত্তরা (Uttara)
- গুলশান (Gulshan)
- বনানী (Banani)
- মতিঝিল (Motijheel)
- শাহবাগ (Shahbag)
- জাতীয় সংসদ এলাকা (National Parliament)
- ঢাকা বিশ্ববিদ্যালয় (Dhaka University)

### Hospitals
8 major Dhaka hospitals with Bengali names:
- ঢাকা মেডিকেল কলেজ হাসপাতাল
- শহীদ সোহরাওয়ার্দী মেডিকেল কলেজ
- বঙ্গবন্ধু শেখ মুজিব মেডিকেল বিশ্ববিদ্যালয়
- And more...

### Demo Users
20 authentic Bangladeshi names:
- মো. রহিম উদ্দিন
- আবুল কালাম আজাদ
- সালমা বেগম
- ফাতেমা খাতুন
- And more...

---

## 🏗️ PROJECT STRUCTURE

```
lib/
├── config/
│   └── routes.dart                    # All app routes
├── models/                            # Data models
│   ├── user.dart
│   ├── blood_request.dart
│   ├── donation.dart
│   └── ...
├── screens/
│   ├── auth/                          # Authentication
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── verification_screen.dart
│   ├── home/                          # Main app
│   │   ├── main_navigation_screen.dart
│   │   ├── home_screen.dart
│   │   ├── search_screen.dart
│   │   └── ...
│   └── admin/                         # Admin panels
│       ├── super_admin_screen.dart
│       └── demo_data_screen.dart
├── services/                          # Business logic
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── location_service.dart
│   └── bangladesh_demo_data_service.dart
├── utils/                             # Utilities
│   ├── app_colors.dart
│   ├── theme_manager.dart
│   ├── validators.dart
│   └── phone_validator.dart
└── widgets/                           # Reusable components
```

---

## 🔧 CONFIGURATION

### Environment Variables (Optional)

Create `.env` file in root:
```bash
GEMINI_API_KEY=your_gemini_api_key_here
```

For AI chatbot feature.

### Android Configuration

`android/app/build.gradle`:
```gradle
minSdkVersion 21
targetSdkVersion 34
compileSdkVersion 34
```

### iOS Configuration

`ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find nearby blood donors</string>

<key>NSCameraUsageDescription</key>
<string>We need camera access for profile photo</string>
```

---

## 🧪 TESTING

### Test Accounts

**Super Admin:**
- Email: `admin@bloodbank.com`
- Password: `admin123`

**Test Users:**
Created via demo data (20 users)

**Test Phone (Firebase):**
- Phone: `+880 1711-123456`
- OTP: `123456`

### Demo Data

Run the app and:
1. Login as Super Admin
2. Go to "Demo Data" screen
3. Click "🇧🇩 Bangladesh Demo Data তৈরি করুন"

This creates:
- 20 Bangladeshi users
- 15 blood requests
- 20 donations with tracking
- Location-based matching

---

## 🐛 TROUBLESHOOTING

### Build Errors

**Gradle Build Failed:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Pod Install Failed (iOS):**
```bash
cd ios
pod deintegrate
pod install
cd ..
```

### Firebase Errors

**google-services.json not found:**
- Download from Firebase Console
- Place in `android/app/`

**Firebase not initialized:**
```bash
flutterfire configure
```

### Phone Verification Issues

**SMS not received:**
- Check Firebase Console → Authentication → Phone enabled
- Use test phone numbers in development
- For production, add SHA-1 certificate

**Invalid phone format:**
- Must be +880XXXXXXXXXX
- App auto-formats Bangladesh numbers

### Location Errors

**Permission denied:**
- Check `AndroidManifest.xml` has location permissions
- Check `Info.plist` has location usage description
- Request permission at runtime

---

## 📦 DEPENDENCIES

Main packages used:
```yaml
firebase_core: ^3.8.1
firebase_auth: ^5.3.3
cloud_firestore: ^5.5.0
firebase_storage: ^12.3.7
firebase_messaging: ^15.1.5
geolocator: ^13.0.2
google_sign_in: ^6.2.2
provider: ^6.1.2
google_generative_ai: ^0.4.6
```

---

## 🚀 DEPLOYMENT

### Android APK

```bash
# Build APK
flutter build apk --release

# Split by architecture (smaller)
flutter build apk --split-per-abi
```

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release
```

### iOS (Mac required)

```bash
flutter build ios --release
```

---

## 📞 SUPPORT

### Common Issues

**Q: Email verification not working?**  
A: Check spam folder, resend email, wait 2-3 minutes

**Q: Phone verification failing?**  
A: Use test numbers first, check SHA-1 for production

**Q: Location not detected?**  
A: Enable GPS, grant permissions, check internet

**Q: App crashing?**  
A: Check Firebase configuration, run `flutter clean`

---

## ✅ CHECKLIST

Before Production:
- [ ] Firebase security rules configured
- [ ] SHA-1 certificate added (Android)
- [ ] Test phone numbers removed
- [ ] API keys secured (.env)
- [ ] Icon & splash screen updated
- [ ] Privacy policy & terms added
- [ ] Test on real devices
- [ ] Performance optimization done

---

**Setup Status:** ✅ Complete  
**Last Updated:** November 28, 2025  
**Version:** 1.0
