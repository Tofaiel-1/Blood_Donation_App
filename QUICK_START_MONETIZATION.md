# Monetization Features - Quick Start Guide

## 🚀 এখনই ব্যবহার করার জন্য নির্দেশাবলী

আপনার Blood Donation App এ ৬টি monetization feature add করা হয়েছে। এগুলো activate করার জন্য নিচের steps follow করুন:

---

## 📋 Step 1: Navigation Routes Setup

আপনার main navigation/home screen এ এই buttons যোগ করুন:

### Profile Screen এ যোগ করুন:

```dart
// lib/screens/home/profile_screen.dart এর build method এ

// Premium Membership Button
if (!currentUser.isPremium)
  ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PremiumMembershipScreen(),
        ),
      );
    },
    icon: Icon(Icons.stars),
    label: Text('Upgrade to Premium'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
    ),
  ),

// Verification Button
if (!currentUser.isVerified)
  ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(),
        ),
      );
    },
    icon: Icon(Icons.verified),
    label: Text('Get Verified Badge'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
    ),
  ),
```

### Home Screen এ Emergency Button যোগ করুন:

```dart
// lib/screens/home/home_screen.dart

FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencyRequestScreen(),
      ),
    );
  },
  backgroundColor: Colors.red,
  child: Icon(Icons.emergency),
  tooltip: 'Emergency Blood Request',
)
```

---

## 📋 Step 2: Import Statements যোগ করুন

যেখানে আপনি এই screens navigate করবেন, সেখানে import করুন:

```dart
// Top of the file
import '../premium/premium_membership_screen.dart';
import '../verification/verification_screen.dart';
import '../emergency/emergency_request_screen.dart';
import '../admin/admin_revenue_screen.dart';
```

---

## 📋 Step 3: Admin Dashboard Access

Super Admin দের জন্য dashboard access:

```dart
// Admin Panel/Settings screen এ

if (currentUser.role == UserRole.superAdmin) {
  ListTile(
    leading: Icon(Icons.analytics),
    title: Text('Revenue Dashboard'),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminRevenueScreen(),
        ),
      );
    },
  ),
}
```

---

## 📋 Step 4: Premium Badge Display

User profile card এ premium badge show করুন:

```dart
// Profile display widget এ

Row(
  children: [
    Text(user.name),
    if (user.isPremium)
      Container(
        margin: EdgeInsets.only(left: 8),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.stars, size: 14, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'PREMIUM',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    if (user.isVerified)
      Padding(
        padding: EdgeInsets.only(left: 4),
        child: Icon(Icons.verified, color: Colors.blue, size: 20),
      ),
  ],
)
```

---

## 📋 Step 5: AdMob Initialization

`main.dart` এ AdMob initialize করুন:

```dart
// lib/main.dart

import 'services/admob_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize AdMob
  await AdMobService.initialize();
  
  runApp(MyApp());
}
```

---

## 📋 Step 6: Banner Ad Display (Optional)

Non-premium users এর জন্য banner ad show করুন:

```dart
// Any screen (e.g., home_screen.dart)

import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/admob_service.dart';

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    // Only show ads for non-premium users
    if (!currentUser.isPremium) {
      _bannerAd = AdMobService.instance.createBannerAd(
        onAdLoaded: () {
          setState(() => _isBannerAdLoaded = true);
        },
      );
      _bannerAd?.load();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Your content here
          
          // Banner Ad at bottom
          if (_isBannerAdLoaded && _bannerAd != null)
            Container(
              height: 60,
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
```

---

## 📋 Step 7: Payment Completion Webhook (Production)

যখন আপনি production এ যাবেন, payment gateway থেকে callback handle করতে হবে:

### Create a Cloud Function (Firebase):

```javascript
// functions/index.js

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// bKash payment callback
exports.bkashCallback = functions.https.onRequest(async (req, res) => {
  const { transactionId, status, paymentId } = req.body;
  
  if (status === 'Completed') {
    // Get transaction from Firestore
    const transactionRef = admin.firestore()
      .collection('payment_transactions')
      .doc(transactionId);
    
    const doc = await transactionRef.get();
    if (!doc.exists) {
      return res.status(404).send('Transaction not found');
    }
    
    const transaction = doc.data();
    
    // Update transaction
    await transactionRef.update({
      status: 'completed',
      transactionId: paymentId,
      completedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    // Activate service based on transaction type
    if (transaction.type === 'premiumSubscription') {
      // Activate premium
      const metadata = transaction.metadata;
      await activatePremium(transaction.userId, metadata.plan, transactionId);
    } else if (transaction.type === 'verification') {
      // Verify user
      await verifyUser(transaction.userId, transactionId);
    } else if (transaction.type === 'emergencyRequest') {
      // Activate emergency request
      const emergencyId = transaction.metadata.emergencyRequestId;
      await activateEmergencyRequest(emergencyId, transactionId);
    }
    
    res.status(200).send('Payment processed successfully');
  } else {
    res.status(400).send('Payment failed');
  }
});

async function activatePremium(userId, plan, transactionId) {
  const now = new Date();
  let endDate;
  
  switch(plan) {
    case 'monthly':
      endDate = new Date(now.setMonth(now.getMonth() + 1));
      break;
    case 'quarterly':
      endDate = new Date(now.setMonth(now.getMonth() + 3));
      break;
    case 'yearly':
      endDate = new Date(now.setFullYear(now.getFullYear() + 1));
      break;
  }
  
  // Update user
  await admin.firestore().collection('users').doc(userId).update({
    isPremium: true,
    premiumPlan: plan,
    premiumExpiryDate: admin.firestore.Timestamp.fromDate(endDate)
  });
  
  // Create subscription record
  await admin.firestore().collection('premium_subscriptions').add({
    userId,
    plan,
    amount: plan === 'monthly' ? 100 : plan === 'quarterly' ? 250 : 900,
    startDate: admin.firestore.Timestamp.now(),
    endDate: admin.firestore.Timestamp.fromDate(endDate),
    isActive: true,
    paymentTransactionId: transactionId,
    createdAt: admin.firestore.Timestamp.now()
  });
}

async function verifyUser(userId, transactionId) {
  await admin.firestore().collection('users').doc(userId).update({
    isVerified: true,
    verifiedAt: admin.firestore.Timestamp.now(),
    verificationTransactionId: transactionId
  });
}

async function activateEmergencyRequest(emergencyId, transactionId) {
  await admin.firestore().collection('emergency_requests').doc(emergencyId).update({
    status: 'active',
    isPaid: true,
    paymentTransactionId: transactionId
  });
  
  // TODO: Send notifications to donors
}
```

---

## 📋 Step 8: Test করুন

### Test Premium Subscription:
1. Profile screen এ যান
2. "Upgrade to Premium" button click করুন
3. একটি plan select করুন
4. Payment method select করুন (bKash/Nagad/Rocket)
5. Phone number দিন
6. Submit করুন
7. Payment simulation দেখবেন

### Test Emergency Request:
1. Home screen এ emergency button click করুন
2. Blood group select করুন
3. Details fill করুন
4. Payment করুন
5. Emergency request create হবে

### Test Verification:
1. Profile screen এ "Get Verified" click করুন
2. Payment করুন
3. Verified badge পাবেন

---

## 📋 Step 9: Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Payment Transactions
    match /payment_transactions/{transactionId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'superAdmin');
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'superAdmin';
    }
    
    // Premium Subscriptions
    match /premium_subscriptions/{subscriptionId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'superAdmin');
      allow create, update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'superAdmin';
    }
    
    // Emergency Requests
    match /emergency_requests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'superAdmin');
    }
    
    // Hospital Partnerships
    match /hospital_partnerships/{partnershipId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'superAdmin');
    }
  }
}
```

---

## 🎯 Production Checklist

- [ ] Replace test AdMob IDs with production IDs
- [ ] Set up payment gateway accounts (bKash/Nagad/Rocket)
- [ ] Implement real payment API integration
- [ ] Set up webhook endpoints
- [ ] Update Firestore security rules
- [ ] Test all payment flows
- [ ] Create Terms of Service
- [ ] Create Privacy Policy
- [ ] Create Refund Policy
- [ ] Test on real devices
- [ ] Set up error monitoring
- [ ] Set up analytics tracking

---

## 💰 Pricing Strategy

### Current Pricing:
- Premium Monthly: ৳100
- Premium Quarterly: ৳250 (save ৳50)
- Premium Yearly: ৳900 (save ৳300)
- Emergency Request: ৳150
- Verification: ৳50
- Hospital Basic: ৳500/month
- Hospital Standard: ৳1000/month
- Hospital Premium: ৳2000/month
- Transaction Fee: ৳20-50 per donation

### Discount Strategies:
- First month free for premium
- Referral bonuses
- Bundle offers (Premium + Verification: ৳140 instead of ৳150)
- Hospital annual plans (12 months for 10 months price)
- Early bird discounts

---

## 📞 Support

যদি কোন সমস্যা হয়:
1. Check error logs
2. Verify Firebase configuration
3. Check payment gateway credentials
4. Test network connectivity
5. Review security rules

---

**সব features ready! এখন শুধু payment gateway integrate করে launch করুন! 🚀**

বাংলাদেশের প্রথম complete monetized blood donation app! 🇧🇩🩸
