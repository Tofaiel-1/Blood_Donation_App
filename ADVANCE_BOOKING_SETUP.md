# 🚀 অগ্রিম বুকিং সিস্টেম - কুইক সেটআপ

## ১. Dependencies ইনস্টল করুন

```bash
flutter pub get
```

## ২. Firebase Indexes ডিপ্লয় করুন

`firestore.indexes.json` ফাইলে নিচের কোড যুক্ত করুন:

```json
{
  "indexes": [
    {
      "collectionGroup": "advance_bookings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "advance_bookings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "advance_bookings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "isPaid", "order": "ASCENDING" },
        { "fieldPath": "paidAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```

তারপর ডিপ্লয় করুন:
```bash
firebase deploy --only firestore:indexes
```

## ৩. Firestore Security Rules আপডেট করুন

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Advance Bookings
    match /advance_bookings/{booking} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true);
      allow delete: if request.auth != null && 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Refund logs (admin only)
    match /refund_logs/{log} {
      allow read: if request.auth != null && 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
      allow write: if request.auth != null && 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

## ৪. Navigation Routes যুক্ত করুন

`lib/config/routes.dart`-এ নিচের routes যুক্ত করুন:

```dart
import '../screens/booking/advance_booking_screen.dart';
import '../screens/booking/booking_payment_screen.dart';
import '../screens/booking/booking_success_screen.dart';
import '../screens/admin/admin_booking_dashboard.dart';

// Routes Map-এ যুক্ত করুন:
'/advance-booking': (context) => AdvanceBookingScreen(),
'/admin/booking-dashboard': (context) => AdminBookingDashboard(),
```

## ৫. Home Screen-এ বাটন যুক্ত করুন

```dart
// Home Screen-এ একটি বাটন যুক্ত করুন
Card(
  child: ListTile(
    leading: Icon(Icons.bookmark_add, color: Colors.red),
    title: Text('অগ্রিম ব্লাড বুকিং'),
    subtitle: Text('আগে থেকে ব্লাড বুক করুন'),
    trailing: Icon(Icons.arrow_forward_ios),
    onTap: () {
      Navigator.pushNamed(context, '/advance-booking');
    },
  ),
)
```

## ৬. Admin Panel-এ মেনু যুক্ত করুন

```dart
// Admin Drawer বা Menu-তে যুক্ত করুন
ListTile(
  leading: Icon(Icons.analytics, color: Colors.blue),
  title: Text('বুকিং ড্যাশবোর্ড'),
  onTap: () {
    Navigator.pushNamed(context, '/admin/booking-dashboard');
  },
)
```

## ৭. Payment Gateway Setup (Production)

### bKash Setup:
1. bKash Merchant Portal-এ লগইন করুন
2. API Credentials নিন:
   - App Key
   - App Secret
   - Username
   - Password

3. `.env` ফাইলে যুক্ত করুন:
```bash
BKASH_APP_KEY=your_app_key
BKASH_APP_SECRET=your_app_secret
BKASH_USERNAME=your_username
BKASH_PASSWORD=your_password
BKASH_BASE_URL=https://tokenized.pay.bka.sh
```

4. `payment_service.dart`-এ bKash API integrate করুন (ADVANCE_BOOKING_GUIDE.md দেখুন)

### Nagad Setup:
Similar process, Nagad Merchant Portal থেকে credentials নিন।

## ৮. Test করুন

### User Flow Test:
1. App চালান
2. "অগ্রিম ব্লাড বুকিং" এ ক্লিক করুন
3. ফর্ম পূরণ করুন
4. পেমেন্ট করুন (test mode)
5. Success screen দেখুন

### Admin Flow Test:
1. Admin হিসেবে লগইন করুন
2. "বুকিং ড্যাশবোর্ড" এ যান
3. Statistics দেখুন
4. Bookings list চেক করুন
5. Income analytics দেখুন

## ৯. Production Checklist

- [ ] Firebase indexes deployed
- [ ] Security rules updated
- [ ] Payment gateway configured
- [ ] Environment variables set
- [ ] Routes configured
- [ ] UI integrated
- [ ] Notifications setup
- [ ] Testing completed
- [ ] Documentation reviewed

## 🎉 সম্পন্ন!

আপনার অগ্রিম বুকিং সিস্টেম এখন প্রস্তুত!

---

## 📊 প্রথম সপ্তাহের লক্ষ্য

- 🎯 ১০০+ বুকিং
- 💰 ৳৫০,০০০+ আয়
- ⭐ ৯০%+ সফলতার হার
- 📱 ৫০০+ অ্যাপ ডাউনলোড

---

## 🆘 সাহায্য প্রয়োজন?

বিস্তারিত গাইড: `ADVANCE_BOOKING_GUIDE.md`  
টেকনিক্যাল ডকুমেন্টেশন: `DEVELOPER_GUIDE.md`

**শুভকামনা! 🎊**
