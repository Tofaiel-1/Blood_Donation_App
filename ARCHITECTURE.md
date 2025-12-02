# Blood Donation App - Architecture Documentation

## 📋 Table of Contents
1. [System Overview](#system-overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Data Flow](#data-flow)
4. [Component Structure](#component-structure)
5. [Authentication Flow](#authentication-flow)
6. [Donation Flow](#donation-flow)
7. [Database Schema](#database-schema)

---

## 🎯 System Overview

**Blood Donation App** হল একটি comprehensive blood donation management system যা donors, admins এবং organizations কে connect করে।

### Key Features
- 🩸 Blood donation tracking (Individual + Global)
- 👥 Multi-role authentication (User, Org Admin, Super Admin)
- 🏥 Hospital suggestion system
- 📊 Real-time statistics
- 💬 AI Chatbot integration
- 🔔 Push notifications
- 📱 Responsive design (Mobile, Tablet, Desktop)

---

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐            │
│  │ Auth Screens │  │ Home Screens │  │ Admin Screens│            │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤            │
│  │ • Login      │  │ • Dashboard  │  │ • Super Admin│            │
│  │ • Signup     │  │ • Search     │  │ • Org Admin  │            │
│  │ • Verify     │  │ • Donate     │  │ • Analytics  │            │
│  │ • Welcome    │  │ • Messages   │  │ • User Mgmt  │            │
│  └──────────────┘  │ • Profile    │  └──────────────┘            │
│                    │ • Chat       │                               │
│                    └──────────────┘                               │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│                         WIDGET LAYER                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │ Themed Widgets (Reusable Components)                         │ │
│  ├──────────────────────────────────────────────────────────────┤ │
│  │ • StatCard        • GradientButton    • BloodTypeBadge      │ │
│  │ • EmergencyCard   • StatusChip        • InfoBanner          │ │
│  │ • NoticeBar       • Autocomplete      • CustomDialogs       │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│                         BUSINESS LOGIC LAYER                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────────┐ │
│  │ Services         │  │ State Management │  │ Utils           │ │
│  ├──────────────────┤  ├──────────────────┤  ├─────────────────┤ │
│  │ • AuthService    │  │ • Provider       │  │ • AppColors     │ │
│  │ • AdminService   │  │ • ThemeManager   │  │ • Responsive    │ │
│  │ • FirestoreServ  │  │ • User Context   │  │ • Validators    │ │
│  │ • DonationStats  │  └──────────────────┘  │ • DateUtils     │ │
│  │ • LocationServ   │                        └─────────────────┘ │
│  │ • MessagingServ  │                                            │ │
│  │ • AnalyticsServ  │                                            │ │
│  │ • GeminiChatServ │                                            │ │
│  └──────────────────┘                                            │ │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│                         DATA LAYER                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────────┐ │
│  │ Firebase         │  │ Local Storage    │  │ Models          │ │
│  ├──────────────────┤  ├──────────────────┤  ├─────────────────┤ │
│  │ • Firestore DB   │  │ • SharedPrefs    │  │ • User          │ │
│  │ • Authentication │  │ • Cache          │  │ • Donation      │ │
│  │ • Cloud Storage  │  └──────────────────┘  │ • BloodRequest  │ │
│  │ • FCM            │                        │ • Admin         │ │
│  │ • Analytics      │                        │ • Message       │ │
│  └──────────────────┘                        └─────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow

### 1. Authentication Flow

```
┌──────────┐
│  User    │
└────┬─────┘
     │
     ▼
┌─────────────────┐
│ Login Screen    │────────┐
│ • Email         │        │
│ • Password      │        │
└────┬────────────┘        │
     │                     │
     ▼                     ▼
┌─────────────────┐   ┌──────────────────┐
│ AuthService     │   │ Email Verify     │
│ • signIn()      │   │ Screen           │
│ • validateRole()│   └──────────────────┘
└────┬────────────┘
     │
     ▼
┌─────────────────────────────────────┐
│ Role-Based Navigation               │
├─────────────────────────────────────┤
│ • superAdmin → /super-admin         │
│ • orgAdmin   → /org-admin           │
│ • user       → /home                │
│ • !verified  → /verification        │
└─────────────────────────────────────┘
```

### 2. Blood Donation Add Flow

```
┌──────────────────┐
│ User Home Screen │
└────────┬─────────┘
         │ Click "Add Donation"
         ▼
┌────────────────────────────────┐
│ Add Donation Dialog            │
│ • Date Picker                  │
│ • Hospital (Autocomplete)      │◄──── Firebase Firestore
│ • Recipient Info (Optional)    │      • donationCenters
│ • Notes                        │      • bloodRequests
└────────┬───────────────────────┘      (Hospital suggestions)
         │
         ▼
┌────────────────────────────────┐
│ Validation Checks              │
├────────────────────────────────┤
│ ✓ Age ≥ 18 years              │
│ ✓ Weight ≥ 50 kg              │
│ ✓ 120-day rule                │
└────────┬───────────────────────┘
         │
         ▼ (Valid)
┌────────────────────────────────┐
│ Save to Firebase               │
├────────────────────────────────┤
│ 1. donations collection        │
│    • donorId, bloodType        │
│    • donationDate, location    │
│    • status: 'completed'       │
│                                │
│ 2. users/{uid} update          │
│    • totalDonations +1         │
│    • livesSaved +1             │
│    • lastDonationDate          │
│                                │
│ 3. globalStats/donations       │
│    • totalDonations +1         │
│    • totalLivesSaved +1        │
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ Reload Data                    │
│ • _loadDonationData()          │
│ • _loadUserData()              │
│ • Force server read (no cache) │
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ Update UI                      │
│ • Total Donations: X           │
│ • Lives Saved: X               │
│ • Next eligible: 120 days      │
└────────────────────────────────┘
```

### 3. Blood Request Response Flow

```
┌──────────────────┐
│ Blood Request    │
│ Card (Home)      │
└────────┬─────────┘
         │ User clicks "I Can Help"
         ▼
┌────────────────────────────────┐
│ Request Details Modal          │
│ • Patient Info                 │
│ • Hospital, Location           │
│ • Blood Type                   │
│ • Units Needed                 │
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ Blood Type Validation          │
├────────────────────────────────┤
│ userBloodType = A+             │
│ requestBloodType = O+          │
│                                │
│ IF userBloodType ≠ request:    │
│   → Show warning               │
│   → Disable button             │
│ ELSE:                          │
│   → Enable "I Can Help"        │
└────────┬───────────────────────┘
         │
         ▼ (Match)
┌────────────────────────────────┐
│ Save Volunteer Response        │
├────────────────────────────────┤
│ 1. donationVolunteers          │
│    • requestId                 │
│    • donorId, donorName        │
│    • bloodType, phone          │
│    • status: 'volunteered'     │
│                                │
│ 2. activityLogs                │
│    • action: 'Donor Volunteered'│
│    • description, timestamp    │
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ Notify Hospital                │
│ • Send donor contact           │
│ • Update request status        │
└────────────────────────────────┘
```

### 4. Super Admin Dashboard Flow

```
┌──────────────────┐
│ Super Admin      │
│ Dashboard        │
└────────┬─────────┘
         │
         ▼
┌────────────────────────────────────────┐
│ Load Statistics                        │
├────────────────────────────────────────┤
│ 1. Count documents in collections:     │
│    • users (totalUsers)                │
│    • admins (totalAdmins)              │
│    • bloodRequests (pending)           │
│                                        │
│ 2. Load global statistics:             │
│    • globalStats/donations             │
│    → totalDonations                    │
│    → totalLivesSaved                   │
│                                        │
│ 3. Blood type distribution:            │
│    • Group users by bloodType          │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│ Display Cards                          │
│ • Total Admins      → Click: View List│
│ • Organizations     → Click: Manage   │
│ • Total Donors      → Click: View All │
│ • Donations         → Click: History  │
│ • Lives Saved       → Show Count      │
│ • Pending Requests  → Click: Review   │
└────────────────────────────────────────┘
```

---

## 🗂️ Component Structure

### Screen Hierarchy

```
lib/
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart           # Email/Password login
│   │   ├── signup_screen.dart          # User registration
│   │   ├── email_verification_screen.dart
│   │   └── welcome_screen.dart         # Landing page
│   │
│   ├── home/
│   │   ├── main_navigation_screen.dart # Bottom nav container
│   │   ├── home_screen.dart            # Dashboard
│   │   ├── search_screen.dart          # Find donors
│   │   ├── donate_screen.dart          # Book appointments
│   │   ├── messages_screen.dart        # Chat
│   │   └── profile_screen.dart         # User profile
│   │
│   ├── admin/
│   │   ├── dashboard/
│   │   │   ├── super_admin_dashboard.dart
│   │   │   ├── org_admin_dashboard.dart
│   │   │   └── widgets/               # Stat cards, dialogs
│   │   └── tabs/
│   │       ├── users_tab.dart
│   │       ├── donations_tab.dart
│   │       └── requests_tab.dart
│   │
│   └── chat/
│       └── chatbot_screen.dart         # AI assistant
```

### Service Layer

```
lib/services/
├── auth_service.dart              # Firebase Auth wrapper
├── admin_service.dart             # Admin operations
├── firestore_service.dart         # Database CRUD
├── donation_stats_service.dart    # Statistics sync
│   ├── incrementGlobalStats()
│   ├── fixMismatchedLivesSaved()
│   └── recalculateGlobalStats()
├── messaging_service.dart         # FCM notifications
├── gemini_chat_service.dart       # AI chatbot
├── location_service.dart          # Geolocation
└── analytics_service.dart         # Firebase Analytics
```

### Models

```
lib/models/
├── user.dart
│   ├── email, name, bloodType
│   ├── totalDonations, livesSaved
│   ├── role (enum: user, orgAdmin, superAdmin)
│   └── canDonateNow getter (120-day rule)
│
├── donation.dart
│   ├── donorId, bloodType
│   ├── donationDate, location
│   └── status (completed, scheduled, cancelled)
│
├── blood_request.dart
│   ├── patientName, bloodType
│   ├── hospitalName, location
│   ├── urgency (critical, urgent, normal)
│   └── unitsNeeded
│
└── admin.dart
    ├── userId, organization
    └── permissions[]
```

---

## 🔐 Authentication Flow (Detailed)

### Login Process

```
┌─────────────┐
│ User Input  │
│ Email + Pwd │
└──────┬──────┘
       │
       ▼
┌──────────────────────────────────┐
│ AuthService.signIn()             │
│ • Firebase Auth login            │
│ • Get UserCredential             │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ Fetch User Profile               │
│ • Firestore: users/{uid}         │
│ • Get role, bloodType, etc.      │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ Role-Based Navigation            │
├──────────────────────────────────┤
│ IF emailVerified == false:       │
│   → /verification                │
│                                  │
│ ELSE IF role == 'superAdmin':    │
│   → /super-admin                 │
│                                  │
│ ELSE IF role == 'orgAdmin':      │
│   → /org-admin                   │
│                                  │
│ ELSE:                            │
│   → /home                        │
└──────────────────────────────────┘
```

### Signup Process

```
┌─────────────────────┐
│ Registration Form   │
│ • Name              │
│ • Email             │
│ • Password          │
│ • Blood Type        │
│ • Age (≥18)         │
│ • Weight (≥50kg)    │
│ • Phone             │
└──────┬──────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ Validation                       │
│ • Age ≥ 18                       │
│ • Weight ≥ 50                    │
│ • Valid email format             │
│ • Password strength (≥6 chars)   │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ Create Firebase Auth User        │
│ • createUserWithEmailAndPassword │
│ • Send verification email        │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ Create Firestore Profile         │
│ users/{uid}:                     │
│ {                                │
│   email, name, bloodType,        │
│   phone, age, weight,            │
│   role: 'user',                  │
│   totalDonations: 0,             │
│   livesSaved: 0,                 │
│   isActive: true,                │
│   createdAt: timestamp           │
│ }                                │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ Navigate to Verification Screen  │
└──────────────────────────────────┘
```

---

## 📊 Database Schema (Firestore)

### Collections Structure

```
Firestore Database
│
├── users/                          # User profiles
│   └── {userId}/
│       ├── email: string
│       ├── name: string
│       ├── bloodType: string
│       ├── phone: string
│       ├── age: number
│       ├── weight: number
│       ├── role: string            # user | orgAdmin | superAdmin
│       ├── totalDonations: number
│       ├── livesSaved: number
│       ├── lastDonationDate: timestamp
│       ├── availability: string    # available | busy | unavailable
│       ├── organization?: string   # For admins
│       ├── isActive: boolean
│       └── createdAt: timestamp
│
├── donations/                      # Donation records
│   └── {donationId}/
│       ├── donorId: string
│       ├── donorName: string
│       ├── bloodType: string
│       ├── donationDate: timestamp
│       ├── location: string
│       ├── status: string          # completed | scheduled | cancelled
│       ├── recipientPatientName?: string
│       ├── recipientHospital?: string
│       ├── notes?: string
│       ├── isManualEntry: boolean
│       └── createdAt: timestamp
│
├── bloodRequests/                  # Blood need requests
│   └── {requestId}/
│       ├── patientName: string
│       ├── bloodType: string
│       ├── hospitalName: string
│       ├── location: string
│       ├── contactPhone: string
│       ├── unitsNeeded: number
│       ├── urgency: string         # critical | urgent | normal
│       ├── status: string          # pending | approved | fulfilled
│       ├── requestDate: timestamp
│       ├── notes?: string
│       └── createdBy: string
│
├── donationVolunteers/             # Volunteer responses
│   └── {volunteerId}/
│       ├── requestId: string
│       ├── donorId: string
│       ├── donorName: string
│       ├── donorPhone: string
│       ├── bloodType: string
│       ├── status: string          # volunteered | contacted | completed
│       └── createdAt: timestamp
│
├── donationCenters/                # Blood donation centers
│   └── {centerId}/
│       ├── name: string
│       ├── address: string
│       ├── city: string
│       ├── phone: string
│       ├── openingHours: string
│       ├── latitude?: number
│       ├── longitude?: number
│       └── isActive: boolean
│
├── activityLogs/                   # System activity tracking
│   └── {logId}/
│       ├── action: string
│       ├── description: string
│       ├── user: string
│       ├── userId: string
│       ├── status: string
│       ├── timestamp: timestamp
│       └── createdAt: timestamp
│
├── globalStats/                    # Global statistics
│   └── donations/
│       ├── totalDonations: number
│       ├── totalLivesSaved: number
│       └── lastUpdated: timestamp
│
├── messages/                       # Chat messages
│   └── {messageId}/
│       ├── senderId: string
│       ├── receiverId: string
│       ├── text: string
│       ├── timestamp: timestamp
│       └── isRead: boolean
│
└── notifications/                  # Push notifications
    └── {notificationId}/
        ├── userId: string
        ├── title: string
        ├── body: string
        ├── type: string
        ├── isRead: boolean
        └── createdAt: timestamp
```

### Indexes Required

```sql
-- bloodRequests
CREATE INDEX idx_blood_requests_status 
ON bloodRequests (status, requestDate DESC);

-- donations
CREATE INDEX idx_donations_donor_status 
ON donations (donorId, status, donationDate DESC);

-- activityLogs
CREATE INDEX idx_activity_logs_timestamp 
ON activityLogs (timestamp DESC);

-- users
CREATE INDEX idx_users_role 
ON users (role, isActive);
```

---

## 🔄 State Management

### Theme Management

```
Provider Pattern
│
├── ThemeManager (ChangeNotifier)
│   ├── isDarkMode: bool
│   ├── toggleTheme()
│   └── savePreference()
│
└── Consumer Widgets
    ├── Main App
    ├── All Screens
    └── Themed Widgets
```

### User Context

```
User State Flow
│
├── Login/Signup
│   └── Store in Provider
│
├── Main Navigation
│   └── Pass to screens
│
└── Profile Updates
    └── Rebuild consumers
```

---

## 🎨 UI Components Flow

### Responsive Design

```
Screen Size Detection
│
├── Mobile (<600px)
│   ├── fontSize: 14-16
│   ├── padding: 12-16
│   └── grid: 1 column
│
├── Tablet (600-1200px)
│   ├── fontSize: 16-18
│   ├── padding: 16-24
│   └── grid: 2 columns
│
└── Desktop (>1200px)
    ├── fontSize: 18-20
    ├── padding: 24-32
    └── grid: 3-4 columns
```

### Color Scheme

```dart
AppColors:
├── primaryGradient      // Red gradient
├── bloodRed            // #D32F2F
├── trustBlue           // #1976D2
├── hopeGreen           // #388E3C
├── lifeOrange          // #F57C00
└── urgentRed           // #C62828
```

---

## 🔔 Notification Flow

```
Firebase Cloud Messaging
│
├── Token Registration
│   ├── On app start
│   ├── Save to Firestore
│   └── users/{uid}/fcmToken
│
├── Send Notification
│   ├── Admin trigger
│   ├── Cloud Function
│   └── FCM → User device
│
└── Handle Notification
    ├── Foreground: Show dialog
    ├── Background: System tray
    └── Tap: Navigate to screen
```

---

## 🤖 AI Chatbot Integration

```
Gemini AI Flow
│
├── User Query
│   └── "রক্তদানের যোগ্যতা কি?"
│
├── GeminiChatService
│   ├── Build context
│   ├── Send to Gemini API
│   └── Get response
│
└── Display in Chat UI
    ├── User message (right)
    └── Bot response (left)
```

---

## 📈 Performance Optimization

### Caching Strategy

```
Data Caching
│
├── User Profile
│   └── Cache in memory (_cachedUser)
│
├── Donation History
│   └── Load once, update on change
│
└── Statistics
    ├── Cache for 5 minutes
    └── Refresh on manual trigger
```

### Lazy Loading

```
Pagination Pattern
│
├── Initial Load: 20 items
├── Scroll to bottom
└── Load next 20 items
```

---

## 🔒 Security Measures

### Firebase Rules

```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can read their own data
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
    }
    
    // Only admins can manage blood requests
    match /bloodRequests/{requestId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'superAdmin'];
    }
    
    // Global stats readable by all, writable by system only
    match /globalStats/{docId} {
      allow read: if request.auth != null;
      allow write: if false; // Only server-side writes
    }
  }
}
```

### Input Validation

```
Validation Layers
│
├── Client-Side (Flutter)
│   ├── Form validators
│   ├── Age/Weight checks
│   └── Email format
│
└── Server-Side (Cloud Functions)
    ├── Firestore rules
    ├── Data sanitization
    └── Rate limiting
```

---

## 📱 Platform Support

```
Cross-Platform Support
│
├── Android
│   ├── Min SDK: 21 (Lollipop)
│   ├── Target SDK: 34
│   └── Firebase integration
│
├── iOS
│   ├── Min version: 12.0
│   ├── Firebase integration
│   └── Push notifications
│
└── Web
    ├── Responsive design
    ├── Firebase web SDK
    └── PWA support
```

---

## 🧪 Testing Strategy

```
Testing Pyramid
│
├── Unit Tests
│   ├── Services
│   ├── Models
│   └── Utilities
│
├── Widget Tests
│   ├── Screens
│   ├── Dialogs
│   └── Components
│
└── Integration Tests
    ├── Login flow
    ├── Donation flow
    └── Admin operations
```

---

## 📚 Key Dependencies

```yaml
dependencies:
  flutter: sdk
  
  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.0
  firebase_messaging: ^15.1.5
  firebase_analytics: ^11.3.5
  
  # UI
  provider: ^6.1.2
  google_fonts: ^6.2.1
  
  # AI
  google_generative_ai: ^0.4.6
  
  # Utils
  intl: ^0.19.0
  url_launcher: ^6.3.1
  image_picker: ^1.1.2
```

---

## 🚀 Deployment Flow

```
Development → Staging → Production
│
├── Dev
│   ├── Local testing
│   ├── Firebase Emulator
│   └── Debug builds
│
├── Staging
│   ├── Test Firebase project
│   ├── Beta testing
│   └── Release candidate
│
└── Production
    ├── Live Firebase project
    ├── Play Store / App Store
    └── Monitoring & Analytics
```

---

## 📊 Monitoring & Analytics

```
Firebase Analytics Events
│
├── User Events
│   ├── login_success
│   ├── signup_complete
│   └── profile_updated
│
├── Donation Events
│   ├── donation_added
│   ├── blood_request_created
│   └── volunteer_responded
│
└── Admin Events
    ├── user_approved
    ├── request_fulfilled
    └── stats_recalculated
```

---

## 🎯 Future Enhancements

1. **Real-time Location Tracking**
   - Find nearby donors
   - Distance calculation

2. **Advanced Matching**
   - Compatible blood types
   - AI-powered suggestions

3. **Gamification**
   - Badges & achievements
   - Leaderboards

4. **Social Features**
   - Share donations
   - Community forums

5. **Multi-language Support**
   - Bengali (current)
   - English, Hindi, etc.

---

## 📞 Support & Documentation

- **Developer Guide**: `DEVELOPER_GUIDE.md`
- **Setup Guide**: `SETUP_GUIDE.md`
- **API Documentation**: Auto-generated with DartDoc
- **Support**: Contact admin team

---

**Last Updated**: December 1, 2025
**Version**: 1.0.0
**Maintained by**: Blood Donation App Team
