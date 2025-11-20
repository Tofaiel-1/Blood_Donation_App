# Blood Donation App - Project Overview

## 📋 Table of Contents
- [Project Description](#project-description)
- [Technology Stack](#technology-stack)
- [Architecture Overview](#architecture-overview)
- [Features & File Locations](#features--file-locations)
- [Directory Structure](#directory-structure)

---

## Project Description

A comprehensive Flutter-based blood donation application that connects blood donors with recipients, facilitates emergency blood requests, and provides AI-powered assistance for blood donation queries. The app supports multiple user roles (regular users, organization admins, and super admins) with Firebase backend integration.

---

## Technology Stack

### Frontend
- **Framework**: Flutter 3.8.1+
- **Language**: Dart
- **UI Libraries**: 
  - `flex_color_scheme` - Advanced theming
  - `google_fonts` - Custom typography
  - `provider` - State management

### Backend & Services
- **Firebase Core** (`firebase_core: ^3.4.0`)
- **Authentication** (`firebase_auth: ^5.2.0`, `google_sign_in: ^6.2.1`)
- **Database** (`cloud_firestore: ^5.2.0`)
- **Storage** (`firebase_storage: ^12.1.0`)
- **Messaging** (`firebase_messaging: ^15.1.0`)
- **Analytics** (`firebase_analytics: ^11.1.0`)

### AI Integration
- **Gemini AI** (`google_generative_ai: ^0.4.6`)
- **Environment Config** (`flutter_dotenv: ^5.1.0`)

### Location & Other
- **Geolocation** (`geolocator`)
- **URL Launcher** (`url_launcher`)
- **Package Info** (`package_info_plus`)
- **Permissions** (`permission_handler_android`)

---

## Architecture Overview

```
lib/
├── config/          # App configuration & routing
├── models/          # Data models
├── screens/         # UI screens (auth, home, admin, chat)
├── services/        # Business logic & API services
├── utils/           # Utilities, theme, validators
└── widgets/         # Reusable UI components
```

---

## Features & File Locations

### 🔐 Authentication & Authorization

#### **Email/Password Authentication**
- **File**: `lib/screens/auth/login_screen.dart`
- **Features**:
  - Email/password login
  - Form validation
  - Password visibility toggle
  - Google Sign-In integration
  - Forgot password functionality

#### **User Registration**
- **File**: `lib/screens/auth/signup_screen.dart`
- **Features**:
  - New user registration
  - Blood type selection
  - Phone number validation
  - Terms & conditions acceptance
  - Email verification

#### **Phone Authentication**
- **File**: `lib/screens/auth/phone_auth_screen.dart`
- **Features**:
  - OTP-based phone authentication
  - Admin invite code system (code: `ORGADMIN2025`)
  - Combined login/register flow
  - Firebase phone auth integration

#### **Authentication Service**
- **File**: `lib/services/auth_service.dart`
- **Features**:
  - Firebase auth wrapper
  - Email/password sign in & registration
  - Google Sign-In
  - Phone verification
  - Email verification
  - Auth state stream

---

### 🏠 Home & Navigation

#### **Main Navigation**
- **File**: `lib/screens/home/main_navigation_screen.dart`
- **Features**:
  - Bottom navigation bar
  - Tab-based navigation (Home, Search, Donate, Messages, Profile)
  - Role-based access control
  - Navigation state management

#### **Home Dashboard**
- **File**: `lib/screens/home/home_screen.dart`
- **Features**:
  - User profile summary (name, blood type)
  - Donation statistics
  - Days until next eligible donation
  - Quick action buttons
  - Recent donation history
  - Emergency alerts
  - AI Chatbot access
  - Real-time data loading from Firestore

---

### 🩸 Blood Donation Features

#### **Donation Management**
- **File**: `lib/screens/home/donate_screen.dart`
- **Features**:
  - **3 Tabs**: History, Centers, Checklist
  - **Donation History**:
    - View past donations with dates
    - Track donation frequency
    - Calculate next eligibility date
  - **Donation Centers**:
    - Browse nearby blood banks
    - Location-based sorting
    - Contact information (phone, directions)
    - Operating hours
    - Available blood types
  - **Pre-Donation Checklist**:
    - Health preparation guidelines
    - Checklist items tracking
    - Eligibility verification

#### **Blood Search**
- **File**: `lib/screens/home/search_screen.dart`
- **Features**:
  - Search donors by blood type
  - Location-based filtering
  - Distance calculation
  - Availability status
  - Last donation date tracking
  - Contact donors (phone/email)
  - Favorite donors list
  - Sorting options (relevance, distance, last donation)

#### **Emergency Request Posting**
- **File**: `lib/screens/home/request_posting_screen.dart`
- **Features**:
  - Post urgent blood requests
  - Blood type selection
  - Hospital/location specification
  - Urgency level (Urgent/Critical)
  - Additional notes
  - Real-time broadcasting

---

### 💬 Communication

#### **Messaging System**
- **File**: `lib/screens/home/messages_screen.dart`
- **Features**:
  - **2 Tabs**: Chats, Alerts
  - **Chat Rooms**:
    - Person-to-person messaging
    - Unread message counts
    - Last message preview
    - Chat history
  - **Emergency Notifications**:
    - System-wide emergency alerts
    - Blood request notifications
    - Donation reminders
    - Mark as read/unread

#### **AI Chatbot**
- **File**: `lib/screens/chat/chatbot_screen.dart` & `lib/screens/chatbot/chatbot_screen.dart`
- **Features**:
  - Gemini AI integration
  - Blood donation information
  - Eligibility criteria guidance
  - Preparation tips
  - FAQ responses
  - Quick suggestion buttons
  - Conversation history
  - Real-time AI responses

#### **Gemini AI Service**
- **File**: `lib/services/gemini_chat_service.dart`
- **Features**:
  - Gemini API integration
  - Model configuration (gemini-1.5-flash)
  - System prompt customization
  - Temperature control
  - Environment-based configuration
  - Error handling & offline mode

#### **Firebase Messaging**
- **File**: `lib/services/messaging_service.dart`
- **Features**:
  - Push notifications
  - FCM token management
  - Topic subscription (emergencies)
  - Foreground message handling

---

### 👤 User Profile

#### **Profile Management**
- **File**: `lib/screens/home/profile_screen.dart`
- **Features**:
  - View/edit profile information
  - Blood type display
  - Contact information (phone)
  - Donation statistics
  - Achievements & badges
  - Theme toggle (Light/Dark)
  - Notification preferences
  - Account settings
  - Logout functionality

---

### 👔 Admin Features

#### **Organization Admin Dashboard**
- **File**: `lib/screens/admin/org_admin_screen.dart`
- **Features**:
  - Manage organization blood requests
  - View organization statistics
  - Access control (org admin role required)

#### **Super Admin Dashboard**
- **File**: `lib/screens/admin/super_admin_screen.dart`
- **Features**:
  - System-wide administration
  - Organization management
  - Global settings
  - Access to audit logs

#### **Audit Log System**
- **File**: `lib/screens/admin/audit_log_screen.dart`
- **Features**:
  - View system audit logs
  - User action tracking
  - Real-time Firestore streaming
  - Log details: timestamp, action, email, role, status, user ID
  - Firebase configuration check
  - Sortable data table

---

### 🎨 Theming & UI

#### **Theme Management**
- **File**: `lib/utils/theme_manager.dart`
- **Features**:
  - Light/Dark theme support
  - System theme detection
  - FlexColorScheme integration
  - Custom color schemes (Blood Red, Life Orange, Hope Green)
  - Google Fonts integration
  - Dynamic theme switching
  - Provider-based state management

#### **App Colors**
- **File**: `lib/utils/app_colors.dart`
- **Features**:
  - Centralized color definitions
  - Blood-themed color palette
  - Light/dark mode variants
  - Gradient definitions

#### **Text Styles**
- **File**: `lib/utils/app_text_styles.dart`
- **Features**:
  - Consistent typography
  - Responsive text sizing
  - Custom font styles

#### **Themed Widgets**
- **File**: `lib/widgets/themed_widgets.dart`
- **Features**:
  - Reusable UI components
  - Consistent styling
  - Custom buttons, cards, inputs

#### **Theme Showcase**
- **File**: `lib/screens/theme_showcase_screen.dart`
- **Features**:
  - Visual theme demonstration
  - Component gallery
  - Color palette display

---

### 🌐 Welcome & Onboarding

#### **Welcome Screen**
- **File**: `lib/screens/welcome_screen.dart`
- **Features**:
  - App introduction
  - Animated hero section
  - Feature highlights
  - Login/Signup navigation
  - Gradient background

---

### 📊 Data Models

#### **User Model**
- **File**: `lib/models/user.dart`
- **Properties**: email, name, bloodType, phone, role (superAdmin, orgAdmin, user)

#### **Donation Model**
- **File**: `lib/models/donation.dart`
- **Properties**: Donation records, DonationCenter details

#### **Message Model**
- **File**: `lib/models/message.dart`
- **Properties**: ChatRoom, Message, MessageType (normal, emergency)

#### **Search Model**
- **File**: `lib/models/search.dart`
- **Properties**: SearchResult with donor information

---

### 🛠️ Services

#### **Firestore Service**
- **File**: `lib/services/firestore_service.dart`
- **Features**: Database CRUD operations

#### **Storage Service**
- **File**: `lib/services/storage_service.dart`
- **Features**: File upload/download (Firebase Storage)

#### **Location Service**
- **File**: `lib/services/location_service.dart`
- **Features**: GPS location, distance calculation, geolocation permissions

#### **Analytics Service**
- **File**: `lib/services/analytics_service.dart`
- **Features**: Firebase Analytics tracking

---

### ⚙️ Configuration & Utilities

#### **Routes**
- **File**: `lib/config/routes.dart`
- **Routes**:
  - `/` - Welcome Screen
  - `/login` - Login Screen
  - `/signup` - Signup Screen
  - `/phone-auth` - Phone Authentication
  - `/home` - Main Navigation (Home)
  - `/search` - Search Screen
  - `/donate` - Donate Screen
  - `/messages` - Messages Screen
  - `/profile` - Profile Screen
  - `/super-admin` - Super Admin Dashboard
  - `/org-admin` - Organization Admin Dashboard
  - `/audit-logs` - Audit Logs
  - `/chatbot` - AI Chatbot
  - `/theme-showcase` - Theme Showcase

#### **Validators**
- **File**: `lib/utils/validators.dart`
- **Features**: Email, phone, password validation

#### **Constants**
- **File**: `lib/utils/constants.dart`
- **Features**: App-wide constants, configuration values

#### **Firebase Options**
- **File**: `lib/firebase_options.dart`
- **Features**: Firebase platform-specific configuration

---

### 📱 Platform-Specific

#### **Android**
- **Location**: `android/`
- **Files**:
  - `build.gradle.kts` - Gradle configuration
  - `app/google-services.json` - Firebase Android config

#### **iOS**
- **Location**: `ios/`
- **Files**: Xcode project, Podfile, Runner configuration

#### **Web**
- **Location**: `web/`
- **Files**: `index.html`, `manifest.json`, icons

#### **Windows**
- **Location**: `windows/`
- **Files**: CMake configuration, runner

#### **Linux**
- **Location**: `linux/`
- **Files**: CMake configuration, runner

#### **macOS**
- **Location**: `macos/`
- **Files**: Xcode project, Podfile

---

## Directory Structure

### Core Application (`lib/`)

```
lib/
├── main.dart                          # App entry point, Firebase initialization
├── firebase_options.dart              # Firebase configuration
│
├── config/
│   └── routes.dart                    # Route definitions
│
├── models/
│   ├── user.dart                      # User data model (roles, blood type)
│   ├── donation.dart                  # Donation & center models
│   ├── message.dart                   # Message & chat room models
│   └── search.dart                    # Search result model
│
├── screens/
│   ├── welcome_screen.dart            # Landing page
│   ├── theme_showcase_screen.dart     # Theme demo
│   │
│   ├── auth/
│   │   ├── login_screen.dart          # Email/password login
│   │   ├── signup_screen.dart         # User registration
│   │   └── phone_auth_screen.dart     # Phone OTP authentication
│   │
│   ├── home/
│   │   ├── main_navigation_screen.dart    # Bottom nav container
│   │   ├── home_screen.dart               # Dashboard
│   │   ├── search_screen.dart             # Donor search
│   │   ├── donate_screen.dart             # Donation management
│   │   ├── messages_screen.dart           # Chat & notifications
│   │   ├── profile_screen.dart            # User profile
│   │   └── request_posting_screen.dart    # Emergency requests
│   │
│   ├── admin/
│   │   ├── super_admin_screen.dart    # Super admin dashboard
│   │   ├── org_admin_screen.dart      # Org admin dashboard
│   │   └── audit_log_screen.dart      # System audit logs
│   │
│   ├── chat/
│   │   └── chatbot_screen.dart        # AI chatbot interface
│   │
│   └── chatbot/
│       ├── chatbot_screen.dart        # AI chatbot (alternate)
│       └── chatbot_screen_old.dart    # Legacy version
│
├── services/
│   ├── auth_service.dart              # Authentication logic
│   ├── firestore_service.dart         # Database operations
│   ├── storage_service.dart           # File storage
│   ├── messaging_service.dart         # Push notifications
│   ├── analytics_service.dart         # Analytics tracking
│   ├── location_service.dart          # GPS & location
│   └── gemini_chat_service.dart       # AI chat integration
│
├── utils/
│   ├── theme_manager.dart             # Theme state management
│   ├── app_colors.dart                # Color palette
│   ├── app_text_styles.dart           # Typography
│   ├── constants.dart                 # App constants
│   └── validators.dart                # Form validators
│
└── widgets/
    ├── themed_widgets.dart            # Reusable themed components
    └── custom_widget.dart             # Custom widgets
```

### Platform Directories

```
android/                   # Android-specific configuration
ios/                       # iOS-specific configuration
web/                       # Web-specific assets
windows/                   # Windows desktop configuration
linux/                     # Linux desktop configuration
macos/                     # macOS desktop configuration
```

### Build & Configuration

```
build/                     # Generated build files
test/                      # Unit & widget tests
scripts/                   # Setup scripts (e.g., FlutterFire)
```

### Documentation

```
README.md                  # Basic project info
README_FIREBASE.md         # Firebase setup guide
AI_ASSISTANT_GUIDE.md      # AI integration guide
AI_INTEGRATION_SUMMARY.md  # AI features summary
AI_QUICK_START.md          # Quick start for AI
TESTING_GUIDE.md           # Testing documentation
THEMING_GUIDE.md           # Theme system guide
THEMING_SUMMARY.md         # Theme features summary
UI_REDESIGN_SUMMARY.md     # UI changes log
IMPROVEMENTS_SUMMARY.md    # Feature improvements log
PROJECT_OVERVIEW.md        # This file
```

---

## User Roles & Access Control

### Regular User
- View profile
- Search for donors
- Manage donations
- Post emergency requests
- Access AI chatbot
- Receive messages & alerts

### Organization Admin
- All regular user features
- Organization-specific management
- Access via invite code: `ORGADMIN2025`

### Super Admin
- Full system access
- Manage all organizations
- View audit logs
- Global settings control

---

## Key Technologies & Patterns

### State Management
- **Provider**: Theme management, user state
- **StatefulWidget**: Screen-level state
- **StreamBuilder**: Real-time Firebase data

### Firebase Integration
- **Authentication**: Multi-method (email, Google, phone)
- **Firestore**: NoSQL database for user data, donations, messages
- **Storage**: File uploads (profile pictures, documents)
- **Messaging**: Push notifications via FCM
- **Analytics**: User behavior tracking

### AI Integration
- **Google Gemini**: Conversational AI for blood donation queries
- **Environment Variables**: Secure API key management via `.env`

### Location Services
- **Geolocator**: User location tracking
- **Distance Calculation**: Find nearby donors & centers

### UI/UX Patterns
- **Material Design 3**: Modern Flutter UI
- **FlexColorScheme**: Advanced theming
- **Responsive Design**: Adaptive layouts
- **Animations**: Smooth transitions & micro-interactions

---

## Setup & Configuration Files

- **`pubspec.yaml`**: Dependencies & project metadata
- **`firebase.json`**: Firebase hosting/deployment config
- **`analysis_options.yaml`**: Dart linter rules
- **`.env`**: Environment variables (API keys)
- **`google-services.json`**: Firebase Android config
- **`GoogleService-Info.plist`**: Firebase iOS config

---

## Testing

- **Location**: `test/`
- **File**: `widget_test.dart`
- **Coverage**: Unit tests, widget tests
- **Documentation**: See `TESTING_GUIDE.md`

---

## Build Outputs

- **Location**: `build/`
- **Contents**: Platform-specific compiled binaries, APKs, app bundles
- **Generated**: Automatic via `flutter build`

---

## Recent Updates & Improvements

- ✅ AI chatbot integration with Gemini
- ✅ Advanced theming system (light/dark modes)
- ✅ Phone authentication with admin invite codes
- ✅ Audit logging system
- ✅ Emergency blood request system
- ✅ Location-based donor search
- ✅ Real-time messaging
- ✅ Donation eligibility tracking
- ✅ Multi-role user system

For detailed improvement logs, see:
- `IMPROVEMENTS_SUMMARY.md`
- `UI_REDESIGN_SUMMARY.md`
- `AI_INTEGRATION_SUMMARY.md`
- `THEMING_SUMMARY.md`

---

## Running the Application

### Prerequisites
1. Flutter SDK 3.8.1+
2. Firebase project configured
3. `.env` file with Gemini API key (optional)

### Commands
```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Build for production
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
flutter build windows      # Windows
```

### Firebase Setup
See `README_FIREBASE.md` for detailed Firebase configuration steps.

---

## Contact & Support

For questions or issues, refer to:
- `instructions.md` - Development guidelines
- `AI_ASSISTANT_GUIDE.md` - AI feature documentation
- `TESTING_GUIDE.md` - Testing procedures

---

**Last Updated**: November 19, 2025  
**App Version**: 1.0.0+1  
**Flutter Version**: 3.8.1+  
**Dart Version**: 3.8.1+
