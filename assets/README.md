# Assets Folder

এই folder এ app এর সব images, icons, এবং অন্যান্য resources রাখুন।

## 📁 Folder Structure

```
assets/
├── app_icon.png          # Main app icon (1024x1024 px recommended)
├── logo.png              # App logo for splash/welcome screen
├── images/               # Other images (if needed)
└── README.md             # This file
```

## 🎨 Icon Setup Instructions

### আপনার LifeFlow logo এখানে রাখুন:

1. **Logo save করুন:**
   - আপনার LifeFlow logo image টি এই folder এ `app_icon.png` নামে save করুন
   - Recommended size: 1024x1024 px
   - Format: PNG (transparent background preferred)

2. **pubspec.yaml এ flutter_launcher_icons add করুন:**

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/app_icon.png"
  adaptive_icon_background: "#FFFFFF"  # White background
  adaptive_icon_foreground: "assets/app_icon.png"
```

3. **Icons generate করুন:**

Terminal এ run করুন:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

এটি automatically Android এবং iOS এর জন্য সব size এর icons create করবে!

## 📱 Generated Icon Locations

**Android:**
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- All resolutions (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)

**iOS:**
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- All required sizes for iPhone and iPad

## ✅ Next Steps

1. আপনার LifeFlow logo টি এখানে `app_icon.png` হিসেবে copy করুন
2. `pubspec.yaml` এ `flutter_launcher_icons` dependency add করুন
3. `flutter pub get` run করুন
4. `flutter pub run flutter_launcher_icons` run করুন
5. App rebuild করুন: `flutter run`

Done! আপনার app এ LifeFlow logo icon হিসেবে দেখাবে! 🎉
