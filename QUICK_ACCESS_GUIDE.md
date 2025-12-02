# 🚀 Blood Donation App - Quick Access Guide

## 📱 DIRECT LINKS TO ALL WORK

---

## 🎯 FIND YOUR WORK IN 3 SECONDS

### 👤 **USER FEATURES** (Click to Open)

| # | Feature | File | Location |
|---|---------|------|----------|
| 1 | **Login/Signup** | [login_screen.dart](lib/screens/auth/login_screen.dart) | `lib/screens/auth/` |
| 2 | **Phone OTP** | [phone_auth_screen.dart](lib/screens/auth/phone_auth_screen.dart) | `lib/screens/auth/` |
| 3 | **Home Dashboard** | [home_screen.dart](lib/screens/home/home_screen.dart) | `lib/screens/home/` |
| 4 | **Bottom Navigation** | [main_navigation_screen.dart](lib/screens/home/main_navigation_screen.dart) | `lib/screens/home/` |
| 5 | **Search Donors** | [search_screen.dart](lib/screens/home/search_screen.dart) | `lib/screens/home/` |
| 6 | **Donate Blood** | [donate_screen.dart](lib/screens/home/donate_screen.dart) | `lib/screens/home/` |
| 7 | **User Profile** | [profile_screen.dart](lib/screens/home/profile_screen.dart) | `lib/screens/home/` |
| 8 | **View Requests** | [user_blood_request_screen.dart](lib/screens/home/user_blood_request_screen.dart) | `lib/screens/home/` |
| 9 | **Create Request** | [request_posting_screen.dart](lib/screens/home/request_posting_screen.dart) | `lib/screens/home/` |
| 10 | **Messages/Chat** | [messages_screen.dart](lib/screens/home/messages_screen.dart) | `lib/screens/home/` |
| 11 | **AI Chatbot** | [chatbot_screen.dart](lib/screens/chat/chatbot_screen.dart) | `lib/screens/chat/` |
| 12 | **My QR Code** | [my_qr_code_screen.dart](lib/screens/home/my_qr_code_screen.dart) | `lib/screens/home/` |
| 13 | **Invite Friends** | [invite_friends_screen.dart](lib/screens/home/invite_friends_screen.dart) | `lib/screens/home/` |
| 14 | **Help & Support** | [help_support_screen.dart](lib/screens/home/help_support_screen.dart) | `lib/screens/home/` |
| 15 | **About App** | [about_screen.dart](lib/screens/home/about_screen.dart) | `lib/screens/home/` |

### 👨‍💼 **ADMIN FEATURES** (Click to Open)

| # | Feature | File | Location |
|---|---------|------|----------|
| 1 | **Admin Dashboard** | [admin_dashboard_screen.dart](lib/screens/admin/admin_dashboard_screen.dart) | `lib/screens/admin/` |
| 2 | **User Management** | [user_management_screen.dart](lib/screens/admin/user_management_screen.dart) | `lib/screens/admin/` |
| 3 | **Request Management** | [blood_request_management_screen.dart](lib/screens/admin/blood_request_management_screen.dart) | `lib/screens/admin/` |
| 4 | **Inventory** | [inventory_management_screen.dart](lib/screens/admin/inventory_management_screen.dart) | `lib/screens/admin/` |
| 5 | **Broadcast Alerts** | [broadcast_alert_screen.dart](lib/screens/admin/broadcast_alert_screen.dart) | `lib/screens/admin/` |
| 6 | **Add Demo Data** | [add_data_screen.dart](lib/screens/admin/add_data_screen.dart) | `lib/screens/admin/` |

### 🔧 **SERVICES** (Backend Logic - Click to Open)

| # | Service | File | Purpose |
|---|---------|------|---------|
| 1 | **Authentication** | [auth_service.dart](lib/services/auth_service.dart) | Login, signup, logout |
| 2 | **Database** | [firestore_service.dart](lib/services/firestore_service.dart) | Firestore operations |
| 3 | **Messaging** | [messaging_service.dart](lib/services/messaging_service.dart) | Chat functionality |
| 4 | **Admin** | [admin_service.dart](lib/services/admin_service.dart) | Admin operations |
| 5 | **Inventory** | [inventory_service.dart](lib/services/inventory_service.dart) | Blood inventory |
| 6 | **Location** | [location_service.dart](lib/services/location_service.dart) | GPS & maps |
| 7 | **AI Chatbot** | [gemini_chat_service.dart](lib/services/gemini_chat_service.dart) | Gemini AI |
| 8 | **Notifications** | [notification_service.dart](lib/services/notification_service.dart) | Push notifications |
| 9 | **Broadcast** | [broadcast_alert_service.dart](lib/services/broadcast_alert_service.dart) | Mass alerts |
| 10 | **Analytics** | [analytics_service.dart](lib/services/analytics_service.dart) | Event tracking |
| 11 | **Storage** | [storage_service.dart](lib/services/storage_service.dart) | File uploads |
| 12 | **Demo Data** | [demo_data_service.dart](lib/services/demo_data_service.dart) | Sample data |
| 13 | **BD Data** | [bangladesh_demo_data_service.dart](lib/services/bangladesh_demo_data_service.dart) | Bangladesh data |

### 📊 **MODELS** (Data Structures - Click to Open)

| # | Model | File | Contains |
|---|-------|------|----------|
| 1 | **User** | [user.dart](lib/models/user.dart) | User, roles, badges |
| 2 | **Blood Request** | [blood_request.dart](lib/models/blood_request.dart) | Request data |
| 3 | **Donation** | [donation.dart](lib/models/donation.dart) | Donation records |
| 4 | **Donation Center** | [donation_center.dart](lib/models/donation_center.dart) | Center info |
| 5 | **Message** | [message.dart](lib/models/message.dart) | Chat messages |
| 6 | **Admin** | [admin.dart](lib/models/admin.dart) | Admin data |
| 7 | **Search** | [search.dart](lib/models/search.dart) | Search filters |

### 🎨 **UI WIDGETS** (Reusable Components - Click to Open)

| # | Widget | File | Purpose |
|---|--------|------|---------|
| 1 | **Themed Widgets** | [themed_widgets.dart](lib/widgets/themed_widgets.dart) | Buttons, cards, etc. |
| 2 | **Donor Card** | [donor_card.dart](lib/widgets/donor_card.dart) | Display donor info |
| 3 | **Request Card** | [request_card.dart](lib/widgets/request_card.dart) | Display request |
| 4 | **Badge Display** | [badge_display.dart](lib/widgets/badge_display.dart) | Achievement badges |

### ⚙️ **CONFIGURATION** (Click to Open)

| # | File | Purpose |
|---|------|---------|
| 1 | [main.dart](lib/main.dart) | App entry point |
| 2 | [firebase_options.dart](lib/firebase_options.dart) | Firebase config |
| 3 | [routes.dart](lib/config/routes.dart) | Route definitions |
| 4 | [pubspec.yaml](pubspec.yaml) | Dependencies |
| 5 | [.env](.env) | Environment variables |

---

## 🔍 SEARCH BY TASK

### Need to work on **Authentication**?
- [Login Screen](lib/screens/auth/login_screen.dart)
- [Signup Screen](lib/screens/auth/signup_screen.dart)
- [Phone Auth](lib/screens/auth/phone_auth_screen.dart)
- [Auth Service](lib/services/auth_service.dart)

### Need to work on **User Dashboard**?
- [Home Screen](lib/screens/home/home_screen.dart)
- [Main Navigation](lib/screens/home/main_navigation_screen.dart)
- [Profile Screen](lib/screens/home/profile_screen.dart)

### Need to work on **Donor Search**?
- [Search Screen](lib/screens/home/search_screen.dart)
- [User Model](lib/models/user.dart)
- [Firestore Service](lib/services/firestore_service.dart)

### Need to work on **Blood Requests**?
- [Create Request](lib/screens/home/request_posting_screen.dart)
- [View Requests](lib/screens/home/user_blood_request_screen.dart)
- [Request Management (Admin)](lib/screens/admin/blood_request_management_screen.dart)
- [Blood Request Model](lib/models/blood_request.dart)

### Need to work on **Chat/Messaging**?
- [Messages Screen](lib/screens/home/messages_screen.dart)
- [Chatbot Screen](lib/screens/chat/chatbot_screen.dart)
- [Messaging Service](lib/services/messaging_service.dart)
- [Gemini Chat Service](lib/services/gemini_chat_service.dart)

### Need to work on **Admin Panel**?
- [Admin Dashboard](lib/screens/admin/admin_dashboard_screen.dart)
- [User Management](lib/screens/admin/user_management_screen.dart)
- [Request Management](lib/screens/admin/blood_request_management_screen.dart)
- [Inventory Management](lib/screens/admin/inventory_management_screen.dart)
- [Broadcast Alerts](lib/screens/admin/broadcast_alert_screen.dart)

### Need to work on **Notifications**?
- [Notification Service](lib/services/notification_service.dart)
- [Broadcast Alert Service](lib/services/broadcast_alert_service.dart)
- [Broadcast Alert Screen](lib/screens/admin/broadcast_alert_screen.dart)

### Need to work on **Maps/Location**?
- [Donate Screen](lib/screens/home/donate_screen.dart)
- [Location Service](lib/services/location_service.dart)
- [Donation Center Model](lib/models/donation_center.dart)

### Need to work on **Profile Features**?
- [Profile Screen](lib/screens/home/profile_screen.dart)
- [My QR Code](lib/screens/home/my_qr_code_screen.dart)
- [Invite Friends](lib/screens/home/invite_friends_screen.dart)
- [Help & Support](lib/screens/home/help_support_screen.dart)
- [About Screen](lib/screens/home/about_screen.dart)

---

## 📂 FOLDER STRUCTURE (Quick Reference)

```
lib/
├── 📱 screens/
│   ├── 🔐 auth/                    ← Login, Signup, Phone Auth
│   ├── 🏠 home/                    ← All user screens (15 files)
│   ├── 👨‍💼 admin/                   ← All admin screens (6 files)
│   └── 💬 chat/                    ← Chatbot screen
│
├── 🔧 services/                   ← Backend logic (13 files)
├── 📊 models/                     ← Data structures (7 files)
├── 🎨 widgets/                    ← Reusable UI (4 files)
├── 🎨 utils/                      ← Utilities (colors, theme)
├── ⚙️ config/                     ← App configuration
└── 📄 main.dart                   ← Entry point
```

---

## 🎯 TOP 10 FILES TO KNOW

### **Must Know (Core Files):**

1. **[main.dart](lib/main.dart)** - App starts here
2. **[home_screen.dart](lib/screens/home/home_screen.dart)** - Main user interface
3. **[search_screen.dart](lib/screens/home/search_screen.dart)** - Most used feature
4. **[profile_screen.dart](lib/screens/home/profile_screen.dart)** - User profile + actions
5. **[auth_service.dart](lib/services/auth_service.dart)** - Authentication logic
6. **[firestore_service.dart](lib/services/firestore_service.dart)** - Database operations
7. **[user.dart](lib/models/user.dart)** - Core data structure
8. **[admin_dashboard_screen.dart](lib/screens/admin/admin_dashboard_screen.dart)** - Admin control
9. **[blood_request_management_screen.dart](lib/screens/admin/blood_request_management_screen.dart)** - Request approval
10. **[gemini_chat_service.dart](lib/services/gemini_chat_service.dart)** - AI chatbot

---

## 🚀 QUICK START WORKFLOW

### **For New Feature Development:**

1. **Check Model** → [lib/models/](lib/models/)
2. **Create/Update Service** → [lib/services/](lib/services/)
3. **Create/Update Screen** → [lib/screens/](lib/screens/)
4. **Add Route** → [routes.dart](lib/config/routes.dart)
5. **Test** → Run app

### **For Bug Fixes:**

1. **Identify Feature** → Use table above
2. **Open Related Files** → Screen + Service + Model
3. **Check Firebase** → Firebase Console
4. **Fix & Test** → Save and run

### **For UI Changes:**

1. **Find Screen** → [lib/screens/](lib/screens/)
2. **Check Widgets** → [lib/widgets/](lib/widgets/)
3. **Update Theme** → [lib/utils/theme_manager.dart](lib/utils/theme_manager.dart)
4. **Preview** → Hot reload

---

## 📱 DEMO ACCOUNTS (For Testing)

### **Regular User:**
- Email: `user@test.com`
- Password: `123456`

### **Admin:**
- Email: `admin@test.com`
- Password: `admin123`

### **Super Admin:**
- Email: `super@admin.com`
- Password: `super123`

---

## 🔗 EXTERNAL LINKS

### **Documentation:**
- [📖 Full Code Organization](CODE_ORGANIZATION.md)
- [📐 Project Schema](PROJECT_SCHEMA.md)
- [📊 ER Diagram](ER_DIAGRAM.md)
- [🏗️ Architecture](ARCHITECTURE.md)
- [📋 Project Report](PROJECT_REPORT.md)

### **Setup Guides:**
- [⚙️ Setup Guide](SETUP_GUIDE.md)
- [👨‍💻 Developer Guide](DEVELOPER_GUIDE.md)
- [🔍 Search Guide](SEARCH_SCREEN_GUIDE.md)

### **Firebase Console:**
- [🔥 Firebase Console](https://console.firebase.google.com/)
- [☁️ Firestore Database](https://console.firebase.google.com/project/_/firestore)
- [🔐 Authentication](https://console.firebase.google.com/project/_/authentication)
- [📦 Storage](https://console.firebase.google.com/project/_/storage)

---

## 💡 PRO TIPS

### **VS Code Shortcuts:**

- `Ctrl + P` → Quick open file (type file name)
- `Ctrl + Shift + F` → Search in all files
- `Ctrl + Click` → Go to definition
- `F12` → Go to declaration
- `Shift + F12` → Find all references

### **Find Code Quickly:**

```bash
# Search for a function
Ctrl + Shift + F → Type: "sendMessage"

# Search for a screen
Ctrl + P → Type: "home_screen"

# Search for a service
Ctrl + P → Type: "auth_service"

# Search for a model
Ctrl + P → Type: "user.dart"
```

### **Common File Paths (Type in Ctrl + P):**

- `home` → home_screen.dart
- `search` → search_screen.dart
- `profile` → profile_screen.dart
- `auth` → auth_service.dart
- `firestore` → firestore_service.dart
- `user` → user.dart
- `admin` → admin_dashboard_screen.dart

---

## 📞 NEED HELP?

### **Can't Find Something?**

1. **Use Ctrl + Shift + F** to search across all files
2. **Check** [CODE_ORGANIZATION.md](CODE_ORGANIZATION.md) for detailed docs
3. **Look at** [PROJECT_SCHEMA.md](PROJECT_SCHEMA.md) for database structure

### **Common Questions:**

**Q: Where is the login code?**  
A: [lib/screens/auth/login_screen.dart](lib/screens/auth/login_screen.dart)

**Q: Where is the Firebase connection?**  
A: [lib/firebase_options.dart](lib/firebase_options.dart) + [lib/services/firestore_service.dart](lib/services/firestore_service.dart)

**Q: Where are user roles defined?**  
A: [lib/models/user.dart](lib/models/user.dart) (enum UserRole)

**Q: How to add a new screen?**  
A: Create file in [lib/screens/](lib/screens/) → Add route in [lib/config/routes.dart](lib/config/routes.dart)

**Q: Where is the admin code?**  
A: [lib/screens/admin/](lib/screens/admin/) (6 files)

**Q: Where is the chatbot?**  
A: [lib/screens/chat/chatbot_screen.dart](lib/screens/chat/chatbot_screen.dart) + [lib/services/gemini_chat_service.dart](lib/services/gemini_chat_service.dart)

---

**Last Updated:** December 2, 2025  
**Version:** 1.0.0  
**Total Files:** 50+ screens, 13 services, 7 models

**🎯 Remember:** Click any blue link to open the file directly!
