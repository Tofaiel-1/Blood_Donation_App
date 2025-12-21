# অগ্রিম ব্লাড বুকিং সিস্টেম (Advance Blood Booking System)

## 📋 সিস্টেম ওভারভিউ

এই ফিচার ইউজারদের অগ্রিম ব্লাড বুক করার সুবিধা দেয় যেখানে তারা পেমেন্ট করে নিশ্চিত ডোনার পাবে।

---

## 💰 মূল্য কাঠামো (Pricing Structure)

### বেস প্রাইসিং
- **প্রতি ব্যাগ**: ৳300
- **প্ল্যাটফর্ম ফি**: 15% (অ্যাডমিন কমিশন)

### জরুরী চার্জ (Priority Charges)
1. **সাধারণ (Standard)**: ৳0 অতিরিক্ত
2. **জরুরী (Urgent - ৭ দিনের মধ্যে)**: ৳50-100 অতিরিক্ত
3. **অতি জরুরী (Critical - ২৪-৪৮ ঘন্টা)**: ৳150-200 অতিরিক্ত

### উদাহরণ হিসাব
```
2 ব্যাগ ব্লাড + Urgent Priority:
- বেস প্রাইস: 2 × ৳300 = ৳600
- জরুরী চার্জ: ৳100
- প্ল্যাটফর্ম ফি (15%): ৳90
- **মোট**: ৳790
```

---

## 🏗️ সিস্টেম আর্কিটেকচার

### ডাটাবেস স্ট্রাকচার

#### 1. `advance_bookings` Collection
```javascript
{
  id: "booking_id",
  userId: "user_id",
  userName: "রোগীর নাম",
  userPhone: "01XXXXXXXXX",
  
  // Patient Info
  patientName: "রোগীর নাম",
  patientAge: "45",
  patientGender: "পুরুষ",
  patientBloodGroup: "A+",
  patientCondition: "হার্ট সার্জারি",
  
  // Location
  hospitalName: "ঢাকা মেডিকেল কলেজ",
  hospitalAddress: "বকশিবাজার, ঢাকা",
  division: "Dhaka",
  district: "Dhaka",
  upazila: "Shahbag",
  latitude: 23.7257,
  longitude: 90.3993,
  
  // Booking Details
  unitsRequired: 2,
  requiredDate: Timestamp,
  priority: "urgent",
  status: "confirmed",
  
  // Payment
  bookingAmount: 600.0,
  priorityCharge: 100.0,
  platformFee: 90.0,
  totalAmount: 790.0,
  isPaid: true,
  paymentMethod: "bkash",
  transactionId: "TXN123456789",
  paidAt: Timestamp,
  
  // Donor Matching
  matchedDonorId: "donor_id",
  matchedDonorName: "ডোনারের নাম",
  matchedDonorPhone: "01XXXXXXXXX",
  matchedAt: Timestamp,
  
  // Timestamps
  createdAt: Timestamp,
  updatedAt: Timestamp,
  completedAt: Timestamp,
  cancelledAt: Timestamp,
  
  // Additional
  specialInstructions: "অতিরিক্ত নির্দেশনা",
  cancellationReason: "বাতিলের কারণ",
  notifiedDonorIds: [],
  notificationsSent: 15
}
```

#### 2. Status Flow
```
pending → confirmed → processing → matched → completed
                    ↓
                 cancelled / refunded / expired
```

---

## 🔧 ইমপ্লিমেন্টেশন গাইড

### ফাইল স্ট্রাকচার
```
lib/
├── models/
│   └── advance_booking.dart          # বুকিং মডেল
├── services/
│   └── advance_booking_service.dart  # বুকিং সার্ভিস
│   └── payment_service.dart          # পেমেন্ট সার্ভিস (আপডেটেড)
└── screens/
    ├── booking/
    │   ├── advance_booking_screen.dart      # বুকিং ফর্ম
    │   ├── booking_payment_screen.dart      # পেমেন্ট স্ক্রিন
    │   └── booking_success_screen.dart      # সাকসেস স্ক্রিন
    └── admin/
        └── admin_booking_dashboard.dart     # অ্যাডমিন ড্যাশবোর্ড
```

### কোড ইউসেজ উদাহরণ

#### 1. বুকিং তৈরি করা
```dart
final bookingService = AdvanceBookingService();

final bookingId = await bookingService.createBooking(
  patientName: 'রহিম উদ্দিন',
  patientAge: '45',
  patientGender: 'পুরুষ',
  patientBloodGroup: 'A+',
  patientCondition: 'হার্ট সার্জারি',
  hospitalName: 'ঢাকা মেডিকেল',
  hospitalAddress: 'বকশিবাজার',
  division: 'Dhaka',
  district: 'Dhaka',
  upazila: 'Shahbag',
  unitsRequired: 2,
  requiredDate: DateTime.now().add(Duration(days: 3)),
  priority: BookingPriority.urgent,
);
```

#### 2. পেমেন্ট কনফার্ম করা
```dart
await bookingService.confirmPayment(
  bookingId: bookingId,
  paymentMethod: 'bkash',
  transactionId: 'TXN123456789',
);
```

#### 3. ইউজারের বুকিং লিস্ট
```dart
Stream<List<AdvanceBloodBooking>> bookings = 
  bookingService.getUserBookings(userId);
```

#### 4. অ্যাডমিন - সব বুকিং দেখা
```dart
Stream<List<AdvanceBloodBooking>> allBookings = 
  bookingService.getAllBookings(
    status: BookingStatus.processing,
    district: 'Dhaka',
  );
```

---

## 💳 পেমেন্ট ইন্টিগ্রেশন

### সাপোর্টেড পেমেন্ট মেথড
1. **bKash**
2. **Nagad**
3. **Rocket**
4. **Credit/Debit Card** (SSLCommerz)

### পেমেন্ট ফ্লো
```
1. ইউজার বুকিং ফর্ম পূরণ করে
   ↓
2. সিস্টেম মোট মূল্য ক্যালকুলেট করে
   ↓
3. পেমেন্ট মেথড সিলেক্ট করে
   ↓
4. পেমেন্ট গেটওয়ে-তে রিডাইরেক্ট
   ↓
5. পেমেন্ট সফল হলে বুকিং কনফার্ম
   ↓
6. ডোনার খোঁজা শুরু হয়
```

### বাস্তবায়ন (Production Implementation)

#### bKash Integration
```dart
// payment_service.dart-এ আপডেট করুন

Future<Map<String, dynamic>> initiateBkashPayment({
  required String transactionId,
  required double amount,
  required String phoneNumber,
}) async {
  // Step 1: Get Grant Token
  final tokenResponse = await http.post(
    Uri.parse('https://tokenized.pay.bka.sh/v1.2.0-beta/tokenized/checkout/token/grant'),
    headers: {
      'Content-Type': 'application/json',
      'username': 'YOUR_USERNAME',
      'password': 'YOUR_PASSWORD',
    },
    body: jsonEncode({
      'app_key': 'YOUR_APP_KEY',
      'app_secret': 'YOUR_APP_SECRET',
    }),
  );

  final token = jsonDecode(tokenResponse.body)['id_token'];

  // Step 2: Create Payment
  final paymentResponse = await http.post(
    Uri.parse('https://tokenized.pay.bka.sh/v1.2.0-beta/tokenized/checkout/create'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
      'X-APP-Key': 'YOUR_APP_KEY',
    },
    body: jsonEncode({
      'mode': '0011',
      'payerReference': phoneNumber,
      'callbackURL': 'YOUR_CALLBACK_URL',
      'amount': amount.toString(),
      'currency': 'BDT',
      'intent': 'sale',
      'merchantInvoiceNumber': transactionId,
    }),
  );

  return jsonDecode(paymentResponse.body);
}
```

---

## 📊 অ্যাডমিন ড্যাশবোর্ড ফিচার

### 1. পরিসংখ্যান (Statistics)
- মোট আয়
- প্ল্যাটফর্ম ফি (কমিশন)
- মোট বুকিং সংখ্যা
- সম্পন্ন বুকিং
- বাতিল/ফেরত
- সফলতার হার

### 2. বুকিং ম্যানেজমেন্ট
- সব বুকিং লিস্ট
- ফিল্টার (স্ট্যাটাস, রক্তের গ্রুপ, জেলা)
- ডোনার ম্যাচ করা
- বুকিং সম্পন্ন করা
- বুকিং বাতিল ও রিফান্ড

### 3. আয় বিশ্লেষণ
- দৈনিক আয়ের গ্রাফ
- রক্তের গ্রুপ অনুযায়ী বুকিং
- জেলা অনুযায়ী আয়
- মাসিক/বার্ষিক রিপোর্ট

### অ্যাক্সেস
```dart
// main.dart বা routes.dart-এ যুক্ত করুন
'/admin/booking-dashboard': (context) => AdminBookingDashboard(),
```

---

## 🚀 ডিপ্লয়মেন্ট চেকলিস্ট

### 1. Firebase Setup
```bash
# Firestore Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /advance_bookings/{booking} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true);
    }
  }
}
```

### 2. Firestore Indexes
```javascript
// firestore.indexes.json
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
        { "fieldPath": "isPaid", "order": "ASCENDING" },
        { "fieldPath": "paidAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "advance_bookings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "district", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```

### 3. Environment Variables
```bash
# .env
BKASH_APP_KEY=your_app_key
BKASH_APP_SECRET=your_app_secret
BKASH_USERNAME=your_username
BKASH_PASSWORD=your_password
NAGAD_MERCHANT_ID=your_merchant_id
NAGAD_MERCHANT_KEY=your_merchant_key
```

### 4. Dependencies Install
```bash
flutter pub get
```

---

## 📱 ইউজার ইন্টারফেস গাইড

### স্ক্রিন ফ্লো
1. **Home Screen** → "অগ্রিম বুকিং" বাটন
2. **Advance Booking Screen** → ফর্ম পূরণ
3. **Payment Screen** → পেমেন্ট মেথড সিলেক্ট
4. **Success Screen** → কনফার্মেশন
5. **My Bookings** → বুকিং স্ট্যাটাস ট্র্যাক

### UI/UX বৈশিষ্ট্য
- ✅ সম্পূর্ণ বাংলা ইন্টারফেস
- ✅ রিয়েল-টাইম মূল্য ক্যালকুলেশন
- ✅ ইন্টারেক্টিভ ফর্ম ভ্যালিডেশন
- ✅ সুন্দর অ্যানিমেশন (confetti)
- ✅ রেসপন্সিভ ডিজাইন

---

## 🔔 নোটিফিকেশন সিস্টেম

### নোটিফিকেশন টাইপ

1. **পেমেন্ট কনফার্মেশন**
   ```
   "আপনার বুকিং সফল হয়েছে! আমরা ডোনার খুঁজছি।"
   ```

2. **ডোনার ম্যাচড**
   ```
   "ডোনার পাওয়া গেছে! [নাম], [ফোন]"
   ```

3. **বুকিং সম্পন্ন**
   ```
   "ব্লাড ডোনেশন সফল! ধন্যবাদ।"
   ```

4. **রিমাইন্ডার**
   ```
   "আপনার বুকিং তারিখ আগামীকাল। প্রস্তুত থাকুন।"
   ```

---

## 💡 মনিটাইজেশন স্ট্র্যাটেজি

### আয়ের উৎস
1. **প্ল্যাটফর্ম ফি**: প্রতি বুকিং থেকে 15%
2. **জরুরী চার্জ**: ৳50-200 অতিরিক্ত
3. **ভলিউম বোনাস**: বেশি বুকিং = বেশি আয়

### প্রত্যাশিত আয় (মাসিক)
```
যদি দৈনিক 10টি বুকিং হয়:
- গড় বুকিং মূল্য: ৳500
- প্ল্যাটফর্ম ফি (15%): ৳75
- দৈনিক আয়: ৳750
- মাসিক আয়: ৳22,500

যদি দৈনিক 50টি বুকিং হয়:
- মাসিক আয়: ৳1,12,500
```

---

## 🔒 সিকিউরিটি

### ইমপ্লিমেন্টেড ফিচার
1. ✅ Firebase Authentication
2. ✅ Firestore Security Rules
3. ✅ Payment Transaction Logging
4. ✅ Refund Protection
5. ✅ User Verification

### রিস্ক ম্যানেজমেন্ট
- অটোমেটিক এক্সপায়ারি (30 দিন পর)
- রিফান্ড পলিসি (বাতিলের ক্ষেত্রে)
- ফ্রড ডিটেকশন (একাধিক বুকিং ব্লক)

---

## 📞 সাপোর্ট ও ট্রাবলশুটিং

### সাধারণ সমস্যা

1. **পেমেন্ট ফেইল**
   - চেক করুন: ইন্টারনেট কানেকশন
   - চেক করুন: পর্যাপ্ত ব্যালেন্স
   - পুনরায় চেষ্টা করুন

2. **ডোনার পাওয়া যাচ্ছে না**
   - এরিয়া বড় করুন
   - তারিখ পরিবর্তন করুন
   - জরুরী প্রায়োরিটি নির্বাচন করুন

3. **বুকিং বাতিল**
   - অ্যাডমিন প্যানেল থেকে রিফান্ড প্রসেস করুন
   - 3-5 কার্যদিবসে টাকা ফেরত

---

## 🎯 ভবিষ্যত উন্নয়ন

### পরবর্তী ফিচার
- [ ] অটোমেটিক ডোনার ম্যাচিং (ML)
- [ ] রিয়েল-টাইম লোকেশন ট্র্যাকিং
- [ ] SMS নোটিফিকেশন
- [ ] মাল্টিপল ডোনার অপশন
- [ ] রেটিং ও রিভিউ সিস্টেম
- [ ] বুকিং হিস্ট্রি অ্যানালিটিক্স

---

## 📝 লাইসেন্স ও কন্ট্রিবিউশন

এই সিস্টেম Blood Donation App প্রজেক্টের অংশ।
কোনো প্রশ্ন বা সাজেশন থাকলে ইস্যু ক্রিয়েট করুন।

---

**তৈরি করেছেন**: Blood Donation App Team  
**সর্বশেষ আপডেট**: December 2025  
**ভার্সন**: 1.0.0
