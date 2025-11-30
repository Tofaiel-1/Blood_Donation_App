# 📝 Manual Donation Entry - Complete Guide

## Overview
এই guide এ দেখানো হয়েছে কিভাবে user manually past donations add করতে পারবে এবং Admin/Super Admin তা দেখতে পারবে।

---

## 🎯 Feature Summary

### For Users:
- ✅ App এর বাইরে করা donations manually add করা যায়
- ✅ Date, Location, Notes সহ পূর্ণ তথ্য দেওয়া যায়
- ✅ Automatically Firebase এ save হয়
- ✅ 120-day rule apply হয়
- ✅ Total donation count update হয়

### For Admins:
- ✅ সব donations (app + manual) একসাথে দেখা যায়
- ✅ Manual entries আলাদা badge দিয়ে চিহ্নিত
- ✅ Recipient information দেখা যায় (যদি থাকে)
- ✅ PDF export এ Entry Type column আছে
- ✅ Filter এবং search করা যায়

---

## 📱 User Flow: Manual Donation Add

### Step 1: Navigate to History Tab
```
Main App → Bottom Navigation → Donate (Blood Drop Icon) → History Tab
```

### Step 2: Click "Add Donation" Button
- FloatingActionButton (FAB) right-bottom corner এ দেখা যাবে
- Red color with "Add Donation" text
- Click করুন

### Step 3: Fill Donation Details
Dialog opens with:

#### Required Fields:
1. **রক্তদানের তারিখ** (Date)
   - Calendar icon দিয়ে date picker
   - Past dates select করা যায় (2020 থেকে today)
   - Default: Today

2. **স্থান / হাসপাতাল / ব্লাড ব্যাংক** (Location)
   - Text field
   - Example: "Dhaka Medical College"
   - Minimum 1 character required

#### Optional Fields:
3. **নোট** (Notes)
   - Multi-line text field
   - Any additional information
   - Example: "Emergency donation", "For friend", etc.

### Step 4: Save
- Click **"সংরক্ষণ করুন"** button
- Validation happens:
  - Location must not be empty
  - Date must be valid
- Success message shows: ✅ "Donation record added successfully!"
- History tab automatically refreshes

---

## 🔥 Firebase Structure

### Donation Document (Manual Entry):
```javascript
{
  // Core fields
  donorId: "uid_12345",
  donorName: "John Doe",
  bloodType: "A+",
  donationDate: Timestamp(2024-11-15),
  location: "Dhaka Medical College",
  status: "completed",
  notes: "Added manually",
  
  // Special marker
  isManualEntry: true,  // ⭐ This identifies manual entries
  
  // Timestamps
  createdAt: ServerTimestamp,
  
  // Recipient fields (null for manual entries)
  recipientRequestId: null,
  recipientPatientName: null,
  recipientHospital: null,
  recipientBloodType: null,
  recipientContactPhone: null,
}
```

### User Document Update:
```javascript
{
  totalDonations: increment(1),      // Auto increment
  lastDonationDate: Timestamp,       // Updated to donation date
}
```

---

## 👨‍💼 Admin View

### 1. Org Admin Dashboard → Donations Tab
**Path**: `lib/screens/admin/tabs/donations_tab.dart`

**Features**:
- ✅ All donations in chronological order
- ✅ Manual entries show blue "Manual" badge
- ✅ Recipient info displayed (if available)
- ✅ Status chips (Completed/Pending/Cancelled)
- ✅ Statistics: Total, Completed, Lives Saved

**Visual Indicators**:
```
┌─────────────────────────────────────────────┐
│ [A+] John Doe               [Manual] 🔵     │
│      Dhaka Medical College                  │
│      👤 Recipient: Jane Smith (if available)│
│      📅 15/11/2024                          │
│                            [COMPLETED] 🟢    │
└─────────────────────────────────────────────┘
```

### 2. Super Admin Dashboard → Donations List
**Path**: `lib/screens/admin/dashboard/widgets/donations_list_dialog.dart`

**Features**:
- ✅ Full-screen dialog with all donations
- ✅ Time filters: All / This Week / This Month / This Year
- ✅ Manual entry badge (blue "Manual" 🔵)
- ✅ Recipient info inline
- ✅ Export to PDF button

**Visual Indicators**:
```
┌──────────────────────────────────────────────┐
│ [A+] John Doe          [Manual] 🔵          │
│ 1U                                           │
│ 📅 15/11/2024                               │
│ 🏥 Dhaka Medical College                    │
│ 👤 For: Jane Smith                          │
│                            [Completed] 🟢    │
└──────────────────────────────────────────────┘
```

### 3. PDF Export
**Entry Type Column Added**:
```
#  | Donor Name | Blood Type | Location          | Date       | Status    | Entry Type
---|------------|------------|-------------------|------------|-----------|------------
1  | John Doe   | A+         | DMC Hospital      | 15/11/2024 | Completed | Manual
2  | Jane Smith | O+         | Central Blood Bank| 14/11/2024 | Completed | App
3  | Ali Ahmed  | B+         | Square Hospital   | 13/11/2024 | Completed | App
```

---

## 🔍 Filtering & Search

### Manual Entry Detection:
```dart
final isManualEntry = data['isManualEntry'] ?? false;

if (isManualEntry) {
  // Show blue "Manual" badge
  // Different styling
  // Special handling in reports
}
```

### Query All Manual Entries:
```dart
final manualDonations = await FirebaseFirestore.instance
    .collection('donations')
    .where('isManualEntry', isEqualTo: true)
    .get();
```

### Query App Donations Only:
```dart
final appDonations = await FirebaseFirestore.instance
    .collection('donations')
    .where('isManualEntry', isEqualTo: false)
    .get();
```

---

## 🎨 Visual Design

### Manual Entry Badge (Blue):
```
┌─────────────┐
│ ✏️ Manual   │  ← Blue background (Colors.blue[100])
└─────────────┘     Blue text (Colors.blue[700])
```

### App Entry (Default):
```
No badge shown - standard display
```

### Recipient Info (When Available):
```
👤 Recipient: Patient Name
   (Grey italic text)
```

---

## 🧪 Testing Scenarios

### Test Case 1: Add Manual Donation
1. ✅ Navigate to History tab
2. ✅ Click "Add Donation" FAB
3. ✅ Select past date (e.g., 7 days ago)
4. ✅ Enter location: "Dhaka Medical College"
5. ✅ Add note: "Emergency donation for friend"
6. ✅ Click Save
7. ✅ Verify success message
8. ✅ Check donation appears in history with "Manual" badge

### Test Case 2: 120-Day Rule
1. ✅ Add manual donation with date 7 days ago
2. ✅ Check if next donation date is 113 days from now
3. ✅ Try to add another donation via app
4. ✅ Should show "wait X days" message

### Test Case 3: Admin View
1. ✅ Login as Org Admin
2. ✅ Go to Donations tab
3. ✅ Verify manual entries show blue "Manual" badge
4. ✅ Verify recipient info displays (if available)

### Test Case 4: Super Admin View
1. ✅ Login as Super Admin
2. ✅ Open Donations list dialog
3. ✅ Verify manual entries identified
4. ✅ Export to PDF
5. ✅ Check "Entry Type" column shows "Manual" vs "App"

### Test Case 5: Firebase Validation
1. ✅ Add manual donation
2. ✅ Check Firebase console
3. ✅ Verify `isManualEntry: true` field
4. ✅ Verify `totalDonations` incremented
5. ✅ Verify `lastDonationDate` updated

---

## 📊 Statistics Impact

### User Profile:
- **Total Donations**: ⬆️ Incremented by 1
- **Last Donation Date**: 📅 Updated to manual entry date
- **Days Until Next**: ⏳ Calculated from manual entry date
- **Badge Progress**: 🏆 Counts towards achievement badges

### Admin Dashboard:
- **Total Donations**: Includes manual + app entries
- **Completed Count**: Includes all completed donations
- **Lives Saved**: (Total × 3) includes manual entries

---

## 🚨 Edge Cases & Validation

### 1. Empty Location:
```
❌ Error: "দয়া করে স্থান লিখুন"
→ Must enter at least 1 character
```

### 2. Future Date:
```
❌ Blocked: Date picker maxDate = DateTime.now()
→ Cannot select future dates
```

### 3. Very Old Date:
```
✅ Allowed: Can add donations from 2020 onwards
→ firstDate = DateTime(2020)
```

### 4. Duplicate Detection:
```
ℹ️ Not implemented yet
→ User can add multiple donations on same date
→ Future enhancement: check for duplicates
```

### 5. Network Error:
```
❌ Error message: "Error adding donation: [error]"
→ Red snackbar shown
→ Data not saved
```

---

## 🔐 Security & Permissions

### User Permissions:
- ✅ Can add own donations only
- ✅ Cannot edit others' donations
- ✅ Cannot delete donations
- ❌ Cannot mark as "from app" (isManualEntry always true)

### Admin Permissions:
- ✅ Can view all donations
- ✅ Can see manual vs app entries
- ✅ Can export reports
- ❌ Cannot edit donation records (read-only)

### Data Integrity:
- ✅ `donorId` auto-set from current user
- ✅ `donorName` fetched from user profile
- ✅ `bloodType` fetched from user profile
- ✅ `status` always set to "completed"
- ✅ `isManualEntry` always true
- ✅ `createdAt` server timestamp

---

## 📈 Future Enhancements

### Planned Features:
1. **Edit Manual Entry**:
   - Allow users to edit location/notes
   - Show edit history
   - Admin approval required

2. **Verification System**:
   - Upload donation certificate photo
   - Admin can verify manual entries
   - Verified badge (🔒)

3. **Duplicate Detection**:
   - Warn if donation on same date exists
   - Smart suggestions based on location
   - Merge duplicate entries

4. **Import from CSV**:
   - Bulk upload past donations
   - CSV template download
   - Validation before import

5. **Donation Proof**:
   - Attach certificate image
   - QR code scanning
   - Verification token

---

## 🎓 Code Reference

### Key Files:
```
lib/screens/home/donate_screen.dart
├── _buildFloatingActionButton()       // Shows FAB on History tab
├── _showManualDonationDialog()        // Opens dialog
├── _saveManualDonation()              // Saves to Firebase
└── _ManualDonationDialog class        // Dialog UI

lib/screens/admin/tabs/donations_tab.dart
├── _DonationCard class                // Shows donations
└── Manual entry badge logic           // Blue badge display

lib/screens/admin/dashboard/widgets/donations_list_dialog.dart
├── Manual entry badge in list         // Blue badge
├── Recipient info display             // Inline recipient
└── PDF export with Entry Type         // Manual/App column
```

### Key Methods:
```dart
// Save manual donation
Future<void> _saveManualDonation(Map<String, dynamic> data) async {
  final donationData = {
    'donorId': user.uid,
    'donorName': userData['name'],
    'bloodType': userData['bloodType'],
    'donationDate': Timestamp.fromDate(data['date']),
    'location': data['location'],
    'status': 'completed',
    'notes': data['notes'] ?? 'Added manually',
    'createdAt': FieldValue.serverTimestamp(),
    'isManualEntry': true,  // ⭐ Key field
  };
  
  await FirebaseFirestore.instance
      .collection('donations')
      .add(donationData);
  
  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .update({
        'totalDonations': FieldValue.increment(1),
        'lastDonationDate': Timestamp.fromDate(data['date']),
      });
}
```

---

## 📞 Support & Troubleshooting

### Common Issues:

#### 1. "Add Donation" button not showing:
- ✅ Make sure you're on History tab (tab index 2)
- ✅ Check if `_buildFloatingActionButton()` returns FAB for index 2

#### 2. Donation not showing after save:
- ✅ Check Firebase console for new document
- ✅ Verify `_loadDonationHistory()` is called after save
- ✅ Check network connection

#### 3. Manual badge not showing:
- ✅ Verify `isManualEntry: true` in Firebase
- ✅ Check `data['isManualEntry'] ?? false` logic
- ✅ Ensure badge widget is in build tree

#### 4. 120-day rule not working:
- ✅ Check `lastDonationDate` updated in users collection
- ✅ Verify `_checkEligibility()` called after save
- ✅ Test with console.log of date calculation

---

## ✅ Summary

### What Works:
✅ User can manually add past donations  
✅ Firebase automatically saves with `isManualEntry: true`  
✅ User's `totalDonations` and `lastDonationDate` update  
✅ 120-day rule applies to manual entries  
✅ Admin sees all donations with "Manual" badge  
✅ Super Admin can filter and export with Entry Type  
✅ PDF reports include Manual/App distinction  
✅ Recipient info shown when available  

### User Benefits:
💚 Complete donation history in one place  
💚 No donations lost or forgotten  
💚 Accurate badge/achievement calculations  
💚 Better 120-day tracking  
💚 Motivation to record all donations  

### Admin Benefits:
💙 Complete overview of all donations  
💙 Distinguish app vs manual entries  
💙 Better data quality  
💙 Accurate reporting  
💙 PDF exports with full details  

---

**Last Updated**: November 30, 2025  
**Version**: 2.0.0  
**Status**: ✅ Fully Implemented & Working
