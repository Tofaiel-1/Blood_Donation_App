# Email Verification Troubleshooting Guide

## ✅ যদি Email না আসে, এই steps follow করুন:

### 1. Gmail Check করুন
- **Inbox** folder
- **Spam/Junk** folder  
- **Promotions** tab
- **Social** tab
- **All Mail** এ search করুন: "Firebase"

### 2. Firebase Console Check করুন
1. https://console.firebase.google.com/ এ যান
2. আপনার project select করুন
3. **Authentication** → **Templates** এ যান
4. **Email address verification** template check করুন
5. Verify করুন:
   - Template enabled আছে কিনা
   - Language সঠিক আছে কিনা
   - From email সঠিক আছে কিনা

### 3. Firebase Settings Check
1. **Authentication** → **Settings** → **Authorized domains**
2. নিশ্চিত করুন যে `localhost` authorized আছে
3. Email verification এর জন্য SMTP settings configured আছে কিনা

### 4. Common Issues

#### Issue: Email পাঠানো হচ্ছে না
**Solution:**
```dart
// Check if user is logged in
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
  print('❌ User not logged in');
  return;
}

// Check if already verified
if (user.emailVerified) {
  print('✅ Already verified');
  return;
}

// Send email
await user.sendEmailVerification();
print('📧 Email sent to: ${user.email}');
```

#### Issue: Gmail blocking Firebase emails
**Solution:**
- Gmail এর spam filter খুব strict
- Firebase এর email প্রথমবার spam এ যেতে পারে
- Spam folder থেকে "Not Spam" mark করুন

#### Issue: Rate limiting
**Solution:**
- Firebase একই email address এ বারবার email পাঠায় না
- 1-2 মিনিট wait করুন তারপর resend করুন

### 5. Manual Testing Steps
1. App থেকে logout করুন
2. নতুন email দিয়ে signup করুন
3. Verification screen এ যান
4. "আবার ইমেইল পাঠান" বাটনে click করুন
5. Gmail খুলুন এবং:
   - Inbox check করুন
   - Spam check করুন
   - Search করুন: "verify your email"

### 6. Debug Log Check
Terminal এ এই message গুলো দেখুন:
```
📧 ভেরিফিকেশন ইমেইল পাঠানো হয়েছে mdtofaielhussaintota@gmail.com এ
```

যদি error দেখায়:
```
ইমেইল পাঠাতে সমস্যা: ...
```

### 7. Super Admin Email Specific
Current super admin email: `mdtofaielhussaintota@gmail.com`

Check করুন:
1. এই email টি Firebase Auth এ registered আছে কিনা
2. Firebase Console → **Authentication** → **Users** এ গিয়ে email দেখুন
3. Email verified column check করুন

### 8. Alternative Solution
যদি email না আসে, তাহলে:
1. "Skip" button click করে app ব্যবহার করতে পারবেন
2. পরে Profile থেকে verification করতে পারবেন
3. অথবা direct Firebase Console থেকে manually verify করতে পারেন

## 🔧 Firebase Console এ Manual Verification
1. https://console.firebase.google.com/ → Your Project
2. **Authentication** → **Users**
3. User এর email এ click করুন
4. "Email verified" এ checkmark দিন
5. App এ refresh করুন

---

**Test Email:** mdtofaielhussaintota@gmail.com  
**Last Updated:** November 28, 2025
