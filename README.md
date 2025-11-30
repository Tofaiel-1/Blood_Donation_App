# 🩸 Blood Donation App

A comprehensive blood donation management system built with Flutter and Firebase, featuring location-based donor search, real-time notifications, and AI-powered assistance.

## ✨ Features

### 🔐 Authentication & Security
- Email/Password authentication
- Email verification
- Phone verification (SMS OTP)
- Google Sign-in
- Bangladesh phone validation (11-digit)
- Secure user profiles

### 🩸 Blood Management
- Request blood with urgency levels
- Search donors by blood type & location
- Real-time blood request updates
- Donation history tracking
- Clear donor-recipient tracking

### 📍 Location Services
- Auto-detect current location
- Find nearby donation centers (within 10km)
- Distance calculation (Haversine formula)
- 10 Dhaka donation centers with GPS coordinates
- Location-based donor matching

### 👨‍💼 Admin Features
- Super Admin dashboard
- Create Bangladesh demo data (20 users)
- Manual data entry
- User management
- Audit logs

### 🤖 AI Assistant
- Gemini AI chatbot
- Health & blood donation guidance
- 24/7 instant support

### 🎨 UI/UX
- Light & Dark theme
- Bengali + English interface
- Bottom navigation
- Responsive design
- Loading & error states

## 📚 Documentation

### Essential Guides
1. **[SETUP_GUIDE.md](./SETUP_GUIDE.md)** - Firebase setup, installation, configuration
2. **[DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md)** - Code structure, examples, optimization
3. **[README.md](./README.md)** - This file (project overview)

### Quick Links
- 🔧 [Setup & Installation](./SETUP_GUIDE.md#-quick-start)
- 🔥 [Firebase Configuration](./SETUP_GUIDE.md#-firebase-setup)
- 👨‍💻 [Code Structure](./DEVELOPER_GUIDE.md#-code-structure)
- 🚀 [Quick Reference](./DEVELOPER_GUIDE.md#-quick-reference)
- ⚡ [Performance Tips](./DEVELOPER_GUIDE.md#-performance-optimization)

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Firebase account

### Installation

```bash
# Clone repository
git clone https://github.com/Tofaiel-1/Blood_Donation_App.git
cd Blood_Donation_App

# Install dependencies
flutter pub get

# Run app
flutter run
```

**Need detailed setup?** → See [SETUP_GUIDE.md](./SETUP_GUIDE.md)

## 🏗️ Project Structure

```
lib/
├── config/           # Routes & configuration
├── models/           # Data models (User, BloodRequest, etc.)
├── screens/          # UI screens
│   ├── auth/         # Login, Signup, Verification
│   ├── home/         # Main app screens
│   ├── admin/        # Admin dashboards
│   └── chat/         # AI Chatbot
├── services/         # Business logic & Firebase
├── utils/            # Validators, Colors, Theme
└── widgets/          # Reusable components
```

**Need to find specific code?** → See [DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md#-code-structure)

## 🔥 Firebase Services Used

- **Authentication** - Email, Phone, Google Sign-in
- **Firestore** - Real-time database
- **Storage** - Profile pictures & documents
- **Cloud Messaging** - Push notifications
- **Analytics** - User behavior tracking

**Setup Firebase:** → See [SETUP_GUIDE.md](./SETUP_GUIDE.md#-firebase-setup)

## 🌍 Bangladesh-Specific Features

### Phone Validation
- 11-digit format (01XXX-XXXXXX)
- Operators: GP, Robi, Banglalink, Airtel, Teletalk
- International format: +880XXXXXXXXXX

### Locations
10 Dhaka areas with GPS:
- মিরপুর, ধানমন্ডি, উত্তরা, গুলশান, মোহাম্মদপুর, etc.

### Demo Data
- 20 Bangladeshi users with authentic names
- Real Dhaka locations & hospitals
- Location-based matching (within 5km)

## 🧪 Testing

### Test Accounts

**Super Admin:**
```
Email: admin@bloodbank.com
Password: admin123
```

**Demo Data:**
1. Login as Super Admin
2. Go to Demo Data screen
3. Create Bangladesh demo data

### Test Phone (Firebase Console)
```
Phone: +880 1711-123456
OTP: 123456
```

## 🛠️ Tech Stack

- **Framework:** Flutter 3.32.6
- **Language:** Dart 3.8.1+
- **Backend:** Firebase
- **State Management:** Provider
- **Location:** Geolocator
- **AI:** Google Gemini

## 📦 Main Dependencies

```yaml
firebase_core: ^3.8.1
firebase_auth: ^5.3.3
cloud_firestore: ^5.5.0
geolocator: ^13.0.2
google_sign_in: ^6.2.2
provider: ^6.1.2
google_generative_ai: ^0.4.6
```

## 🔧 Development

### Run in Debug Mode
```bash
flutter run
```

### Build Release APK
```bash
flutter build apk --split-per-abi
```

### Code Quality
```bash
flutter analyze
dart format lib/
```

**More commands:** → See [DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md#-performance-optimization)

## 🐛 Troubleshooting

### Common Issues

**Build failed?**
```bash
flutter clean
flutter pub get
```

**Firebase not working?**
- Check `google-services.json` exists
- Run `flutterfire configure`

**Phone verification failing?**
- Add SHA-1 certificate (Android)
- Use test numbers in development

**More solutions:** → See [SETUP_GUIDE.md](./SETUP_GUIDE.md#-troubleshooting)

## 📖 Documentation Structure

```
📚 Documentation (3 essential files)
├── README.md                    ← You are here (Overview)
├── SETUP_GUIDE.md              ← Installation & Firebase setup
└── DEVELOPER_GUIDE.md          ← Code structure & examples
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

### Code Standards
- Follow Dart style guide
- Add comments for complex logic
- Run `flutter analyze` before committing
- Update documentation if needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Developer

**Tofaiel Ahmed**
- GitHub: [@Tofaiel-1](https://github.com/Tofaiel-1)
- Repository: [Blood_Donation_App](https://github.com/Tofaiel-1/Blood_Donation_App)

## 🙏 Acknowledgments

- Flutter Team for the amazing framework
- Firebase for backend services
- Google Gemini for AI capabilities
- Bangladesh blood donation organizations for inspiration

## 📞 Support

- 📧 Email: support@blooddonationapp.com
- 🐛 Issues: [GitHub Issues](https://github.com/Tofaiel-1/Blood_Donation_App/issues)
- 📚 Docs: [SETUP_GUIDE.md](./SETUP_GUIDE.md) | [DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md)

---

**Status:** ✅ Production Ready  
**Version:** 1.0.0  
**Last Updated:** November 28, 2025

---

<div align="center">
  <p>Made with ❤️ for saving lives</p>
  <p>⭐ Star this repo if you found it helpful!</p>
</div>
