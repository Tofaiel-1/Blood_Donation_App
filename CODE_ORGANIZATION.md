# Blood Donation App - Code Organization Guide

## 📂 Complete Project Structure with Code Location

---

## 🎯 USER CODE vs ADMIN CODE - Quick Reference

### 👤 **USER FEATURES** (Regular Donors & Recipients)

| Feature | Code Location | Key Files | 🔗 Quick Links |
|---------|---------------|-----------|----------------|
| **Authentication** | `lib/screens/auth/` | `login_screen.dart`, `signup_screen.dart`, `phone_auth_screen.dart` | [Login](lib/screens/auth/login_screen.dart) • [Signup](lib/screens/auth/signup_screen.dart) • [Phone](lib/screens/auth/phone_auth_screen.dart) |
| **Home Dashboard** | `lib/screens/home/` | `home_screen.dart`, `main_navigation_screen.dart` | [Home](lib/screens/home/home_screen.dart) • [Navigation](lib/screens/home/main_navigation_screen.dart) |
| **Search Donors** | `lib/screens/home/` | `search_screen.dart` | [Search](lib/screens/home/search_screen.dart) |
| **Donate Blood** | `lib/screens/home/` | `donate_screen.dart` | [Donate](lib/screens/home/donate_screen.dart) |
| **User Profile** | `lib/screens/home/` | `profile_screen.dart` | [Profile](lib/screens/home/profile_screen.dart) |
| **Blood Requests** | `lib/screens/home/` | `user_blood_request_screen.dart`, `request_posting_screen.dart` | [View Requests](lib/screens/home/user_blood_request_screen.dart) • [Create Request](lib/screens/home/request_posting_screen.dart) |
| **Messaging/Chat** | `lib/screens/home/` + `lib/screens/chat/` | `messages_screen.dart`, `chatbot_screen.dart` | [Messages](lib/screens/home/messages_screen.dart) • [Chatbot](lib/screens/chat/chatbot_screen.dart) |
| **QR Code** | `lib/screens/home/` | `my_qr_code_screen.dart` | [QR Code](lib/screens/home/my_qr_code_screen.dart) |
| **Invite Friends** | `lib/screens/home/` | `invite_friends_screen.dart` | [Invite](lib/screens/home/invite_friends_screen.dart) |
| **Help & Support** | `lib/screens/home/` | `help_support_screen.dart` | [Help](lib/screens/home/help_support_screen.dart) |
| **About** | `lib/screens/home/` | `about_screen.dart` | [About](lib/screens/home/about_screen.dart) |

### 👨‍💼 **ADMIN FEATURES** (Super Admin & Organization Admin)

| Feature | Code Location | Key Files | 🔗 Quick Links |
|---------|---------------|-----------|----------------|
| **Admin Dashboard** | `lib/screens/admin/` | `admin_dashboard_screen.dart` | [Dashboard](lib/screens/admin/admin_dashboard_screen.dart) |
| **User Management** | `lib/screens/admin/` | `user_management_screen.dart` | [Users](lib/screens/admin/user_management_screen.dart) |
| **Request Management** | `lib/screens/admin/` | `blood_request_management_screen.dart` | [Requests](lib/screens/admin/blood_request_management_screen.dart) |
| **Inventory Control** | `lib/screens/admin/` | `inventory_management_screen.dart` | [Inventory](lib/screens/admin/inventory_management_screen.dart) |
| **Broadcast Alerts** | `lib/screens/admin/` | `broadcast_alert_screen.dart` | [Broadcast](lib/screens/admin/broadcast_alert_screen.dart) |
| **Add Data** | `lib/screens/admin/` | `add_data_screen.dart` | [Add Data](lib/screens/admin/add_data_screen.dart) |

---

## 📱 DETAILED CODE LOCATIONS

### 1️⃣ **USER AUTHENTICATION & ONBOARDING**

#### 📍 Location: `lib/screens/auth/`

🔗 **Quick Access:**
- [📄 login_screen.dart](lib/screens/auth/login_screen.dart) - Email/Password login
- [📄 signup_screen.dart](lib/screens/auth/signup_screen.dart) - User registration
- [📄 phone_auth_screen.dart](lib/screens/auth/phone_auth_screen.dart) - Phone OTP verification

```
lib/screens/auth/
├── login_screen.dart          # User Login
│   ├── Email/Password login
│   ├── Firebase Auth integration
│   └── Navigate to home after login
│
├── signup_screen.dart         # User Registration
│   ├── Create new account
│   ├── Collect: name, email, password, blood type
│   ├── Save to Firestore users/ collection
│   └── Auto-login after signup
│
└── phone_auth_screen.dart     # Phone OTP Login
    ├── Phone number verification
    ├── OTP code input
    └── Firebase Phone Auth
```

**Key Code Sections:**

**`login_screen.dart`** - Lines 80-120:
```dart
Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);
  
  try {
    final authService = AuthService();
    await authService.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  } catch (e) {
    // Error handling
  }
}
```

**`signup_screen.dart`** - Lines 100-150:
```dart
Future<void> _signup() async {
  try {
    final authService = AuthService();
    final userCredential = await authService.signUpWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    
    // Create user profile in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'bloodType': _selectedBloodType,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    // Error handling
  }
}
```

---

### 2️⃣ **USER HOME & NAVIGATION**

#### 📍 Location: `lib/screens/home/`

🔗 **Quick Access:**
- [📄 main_navigation_screen.dart](lib/screens/home/main_navigation_screen.dart) - Bottom navigation bar
- [📄 home_screen.dart](lib/screens/home/home_screen.dart) - User dashboard

```
lib/screens/home/
├── main_navigation_screen.dart    # Bottom Navigation Bar
│   ├── Tab 1: Home
│   ├── Tab 2: Search
│   ├── Tab 3: Donate
│   └── Tab 4: Profile
│
└── home_screen.dart               # User Dashboard
    ├── Welcome message
    ├── Blood request statistics
    ├── Recent donations
    ├── Urgent blood requests
    └── Quick action buttons
```

**Key Code:**

**`main_navigation_screen.dart`** - Lines 20-80:
```dart
class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),      // Index 0
    SearchScreen(),    // Index 1
    DonateScreen(),    // Index 2
    ProfileScreen(),   // Index 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.water_drop), label: 'Donate'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

**`home_screen.dart`** - Key Sections:
- Lines 50-100: Statistics display (total donors, active requests)
- Lines 150-200: Recent donations list
- Lines 250-300: Urgent blood requests carousel
- Lines 350-400: Quick action cards

---

### 3️⃣ **USER SEARCH & DISCOVERY**

#### 📍 Location: `lib/screens/home/search_screen.dart`

🔗 **[📄 Open search_screen.dart](lib/screens/home/search_screen.dart)**

**Purpose:** Search for blood donors by blood type, location, and availability

**Key Features:**
- Blood type filter dropdown
- Location-based search
- Availability status filter
- Real-time Firestore queries
- Donor list with contact options

**Main Code Sections:**

**Lines 80-150** - Search Filter UI:
```dart
Widget _buildFilters() {
  return Column(
    children: [
      // Blood Type Dropdown
      DropdownButton<String>(
        value: _selectedBloodType,
        items: ['All', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
            .toList(),
        onChanged: (value) {
          setState(() => _selectedBloodType = value);
          _searchDonors();
        },
      ),
      
      // Location Filter
      TextField(
        controller: _locationController,
        decoration: InputDecoration(labelText: 'Location'),
        onChanged: (_) => _searchDonors(),
      ),
      
      // Availability Filter
      CheckboxListTile(
        title: Text('Available Only'),
        value: _availableOnly,
        onChanged: (val) {
          setState(() => _availableOnly = val ?? false);
          _searchDonors();
        },
      ),
    ],
  );
}
```

**Lines 200-280** - Firebase Search Query:
```dart
Future<void> _searchDonors() async {
  setState(() => _isLoading = true);
  
  try {
    Query query = FirebaseFirestore.instance.collection('users');
    
    // Filter by blood type
    if (_selectedBloodType != null && _selectedBloodType != 'All') {
      query = query.where('bloodType', isEqualTo: _selectedBloodType);
    }
    
    // Filter by availability
    if (_availableOnly) {
      query = query.where('availability', isEqualTo: 'available');
    }
    
    // Filter by eligibility
    query = query.where('isEligibleToDonate', isEqualTo: true);
    
    final snapshot = await query.get();
    
    setState(() {
      _donors = snapshot.docs
          .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
  }
}
```

**Lines 350-450** - Donor List Display:
```dart
Widget _buildDonorCard(User donor) {
  return Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.red,
        child: Text(donor.bloodType, style: TextStyle(color: Colors.white)),
      ),
      title: Text(donor.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Blood Type: ${donor.bloodType}'),
          Text('Location: ${donor.address ?? "Not specified"}'),
          Text('Donations: ${donor.totalDonations}'),
          if (donor.badges.isNotEmpty)
            Text('Badges: ${donor.badges.length}'),
        ],
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () => _viewDonorProfile(donor),
    ),
  );
}
```

---

### 4️⃣ **USER BLOOD DONATION**

#### 📍 Location: `lib/screens/home/donate_screen.dart`

🔗 **[📄 Open donate_screen.dart](lib/screens/home/donate_screen.dart)**

**Purpose:** Schedule blood donations at nearby centers

**Key Features:**
- Map view of donation centers
- Filter by blood type availability
- Center details (hours, contact)
- Schedule donation appointment
- View donation history

**Main Code Sections:**

**Lines 100-200** - Donation Centers Map:
```dart
Future<void> _loadDonationCenters() async {
  setState(() => _isLoading = true);
  
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('donationCenters')
        .where('isActive', isEqualTo: true)
        .get();
    
    setState(() {
      _centers = snapshot.docs
          .map((doc) => DonationCenter.fromFirestore(doc))
          .toList();
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
  }
}
```

**Lines 300-400** - Schedule Donation:
```dart
Future<void> _scheduleDonation(DonationCenter center) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  
  try {
    // Create donation record
    await FirebaseFirestore.instance.collection('donations').add({
      'donorId': user.uid,
      'donorName': _currentUser?.name ?? '',
      'bloodType': _currentUser?.bloodType ?? '',
      'donationDate': _selectedDate.toIso8601String(),
      'location': center.name,
      'status': 'scheduled',
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Donation scheduled successfully!')),
    );
  } catch (e) {
    // Error handling
  }
}
```

---

### 5️⃣ **USER PROFILE & SETTINGS**

#### 📍 Location: `lib/screens/home/profile_screen.dart`

🔗 **[📄 Open profile_screen.dart](lib/screens/home/profile_screen.dart)**

**Purpose:** User profile management and quick actions

**Key Features:**
- Display user information
- Show donation statistics
- Display earned badges
- Quick action buttons
- Edit profile
- Theme settings

**Main Code Sections:**

**Lines 100-200** - User Profile Display:
```dart
Widget _buildProfileHeader() {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: _user?.profileImageUrl != null
                ? NetworkImage(_user!.profileImageUrl!)
                : null,
            child: _user?.profileImageUrl == null
                ? Icon(Icons.person, size: 50)
                : null,
          ),
          SizedBox(height: 16),
          Text(
            _user?.name ?? 'User',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(_user?.email ?? ''),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _user?.bloodType ?? 'N/A',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ),
  );
}
```

**Lines 250-300** - Donation Statistics:
```dart
Widget _buildStatistics() {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.water_drop,
            label: 'Donations',
            value: '${_user?.totalDonations ?? 0}',
          ),
          _buildStatItem(
            icon: Icons.favorite,
            label: 'Lives Saved',
            value: '${_user?.livesSaved ?? 0}',
          ),
          _buildStatItem(
            icon: Icons.emoji_events,
            label: 'Badges',
            value: '${_user?.badges.length ?? 0}',
          ),
        ],
      ),
    ),
  );
}
```

**Lines 400-500** - Quick Actions (NEW):
```dart
Widget _buildQuickActions() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      
      // My QR Code
      ListTile(
        leading: Icon(Icons.qr_code, color: Colors.blue),
        title: Text('My QR Code'),
        subtitle: Text('Show your donor QR code'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyQRCodeScreen()),
          );
        },
      ),
      
      // Invite Friends
      ListTile(
        leading: Icon(Icons.share, color: Colors.green),
        title: Text('Invite Friends'),
        subtitle: Text('Share this app with friends'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InviteFriendsScreen()),
          );
        },
      ),
      
      // Help & Support
      ListTile(
        leading: Icon(Icons.help, color: Colors.orange),
        title: Text('Help & Support'),
        subtitle: Text('Get help and support'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HelpSupportScreen()),
          );
        },
      ),
      
      // About
      ListTile(
        leading: Icon(Icons.info, color: Colors.purple),
        title: Text('About'),
        subtitle: Text('About this app'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AboutScreen()),
          );
        },
      ),
    ],
  );
}
```

---

### 6️⃣ **USER BLOOD REQUESTS**

#### 📍 Location: `lib/screens/home/`

🔗 **Quick Access:**
- [📄 user_blood_request_screen.dart](lib/screens/home/user_blood_request_screen.dart) - View own requests
- [📄 request_posting_screen.dart](lib/screens/home/request_posting_screen.dart) - Create new request

```
lib/screens/home/
├── user_blood_request_screen.dart    # View Own Requests
│   ├── List of user's blood requests
│   ├── Request status tracking
│   └── Cancel request option
│
└── request_posting_screen.dart       # Create New Request
    ├── Blood type selection
    ├── Hospital information
    ├── Patient details
    ├── Urgency level
    └── Submit to Firestore
```

**`request_posting_screen.dart`** - Lines 150-250:
```dart
Future<void> _submitRequest() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);
  
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not logged in');
    
    // Get user data
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userData = User.fromMap(userDoc.data()!);
    
    // Create blood request
    await FirebaseFirestore.instance.collection('bloodRequests').add({
      'bloodType': _selectedBloodType,
      'hospitalName': _hospitalController.text.trim(),
      'location': _locationController.text.trim(),
      'contactPhone': _phoneController.text.trim(),
      'patientName': _patientNameController.text.trim(),
      'unitsNeeded': int.parse(_unitsController.text),
      'urgency': _urgencyLevel.name,
      'status': 'pending',
      'requestedBy': user.uid,
      'requestedByName': userData.name,
      'requestDate': FieldValue.serverTimestamp(),
      'notes': _notesController.text.trim(),
    });
    
    // Send broadcast alert to matching donors
    await _sendBroadcastAlert();
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Blood request submitted successfully!')),
    );
  } catch (e) {
    // Error handling
  }
}
```

---

### 7️⃣ **USER MESSAGING & CHAT**

#### 📍 Location: `lib/screens/home/messages_screen.dart` + `lib/screens/chat/chatbot_screen.dart`

🔗 **Quick Access:**
- [📄 messages_screen.dart](lib/screens/home/messages_screen.dart) - User-to-user chat
- [📄 chatbot_screen.dart](lib/screens/chat/chatbot_screen.dart) - AI chatbot

**Messages Screen** - User-to-User Chat:

**Lines 100-200** - Chat Room List:
```dart
Widget _buildChatRoomsList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('chatRooms')
        .where('participants', arrayContains: _currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();
      
      final chatRooms = snapshot.data!.docs
          .map((doc) => ChatRoom.fromFirestore(doc))
          .toList();
      
      return ListView.builder(
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          final room = chatRooms[index];
          return ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text(room.otherParticipantName),
            subtitle: Text(room.lastMessage),
            trailing: room.unreadCount > 0
                ? CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Text('${room.unreadCount}'),
                  )
                : null,
            onTap: () => _openChat(room),
          );
        },
      );
    },
  );
}
```

**Chatbot Screen** - AI Support:

**Lines 50-150** - Gemini AI Integration:
```dart
class _ChatbotScreenState extends State<ChatbotScreen> {
  final GeminiChatService _chatService = GeminiChatService();
  final List<Message> _messages = [];
  
  Future<void> _sendMessage(String text) async {
    // Add user message
    setState(() {
      _messages.add(Message(
        senderId: 'user',
        content: text,
        timestamp: DateTime.now(),
      ));
    });
    
    // Get AI response
    final response = await _chatService.sendMessage(text);
    
    // Add bot message
    setState(() {
      _messages.add(Message(
        senderId: 'bot',
        content: response,
        timestamp: DateTime.now(),
      ));
    });
  }
}
```

---

### 8️⃣ **USER QUICK ACTIONS (NEW)**

#### 📍 Location: `lib/screens/home/`

🔗 **Quick Access:**
- [📄 my_qr_code_screen.dart](lib/screens/home/my_qr_code_screen.dart) - QR code display
- [📄 invite_friends_screen.dart](lib/screens/home/invite_friends_screen.dart) - Share app
- [📄 help_support_screen.dart](lib/screens/home/help_support_screen.dart) - Help & FAQs
- [📄 about_screen.dart](lib/screens/home/about_screen.dart) - App information

```
lib/screens/home/
├── my_qr_code_screen.dart        # QR Code Display
│   ├── Load user data from Firebase
│   ├── Generate QR with user info
│   ├── Display blood type badge
│   └── Show donation statistics
│
├── invite_friends_screen.dart    # Share App
│   ├── Share app link
│   ├── Share via SMS/Email/WhatsApp
│   ├── Show app benefits
│   └── Display statistics
│
├── help_support_screen.dart      # Help & FAQs
│   ├── FAQ section with answers
│   ├── Contact support (email/phone)
│   ├── Report issue button
│   └── User guide access
│
└── about_screen.dart             # App Information
    ├── App version & build number
    ├── Mission statement
    ├── Key features list
    ├── Impact statistics
    └── Legal links (Privacy, Terms)
```

**`my_qr_code_screen.dart`** - Lines 50-150:
```dart
class _MyQRCodeScreenState extends State<MyQRCodeScreen> {
  User? _user;
  bool _isLoading = true;
  String _qrData = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        setState(() {
          _user = User.fromMap(doc.data()!);
          _qrData = _generateQRData(_user!);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _generateQRData(User user) {
    return '''
Donor ID: ${user.id}
Name: ${user.name}
Blood Type: ${user.bloodType}
Phone: ${user.phone ?? 'N/A'}
Email: ${user.email}
Donations: ${user.totalDonations}
Lives Saved: ${user.livesSaved}
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Donor QR Code')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // QR Code
                  QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: 250.0,
                  ),
                  SizedBox(height: 24),
                  // User Info
                  Text(_user?.name ?? '', style: TextStyle(fontSize: 24)),
                  Text('Blood Type: ${_user?.bloodType}'),
                  Text('Total Donations: ${_user?.totalDonations}'),
                ],
              ),
            ),
    );
  }
}
```

---

## 👨‍💼 ADMIN CODE SECTIONS

### 9️⃣ **ADMIN DASHBOARD**

#### 📍 Location: `lib/screens/admin/admin_dashboard_screen.dart`

🔗 **[📄 Open admin_dashboard_screen.dart](lib/screens/admin/admin_dashboard_screen.dart)**

**Purpose:** Central admin control panel

**Key Features:**
- Overview statistics
- Quick access to all admin features
- Real-time data monitoring
- Recent activities log

**Main Code Sections:**

**Lines 80-150** - Statistics Cards:
```dart
Widget _buildStatisticsSection() {
  return FutureBuilder<Map<String, dynamic>>(
    future: _loadStatistics(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();
      
      final stats = snapshot.data!;
      
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildStatCard(
            title: 'Total Users',
            value: '${stats['totalUsers']}',
            icon: Icons.people,
            color: Colors.blue,
          ),
          _buildStatCard(
            title: 'Active Requests',
            value: '${stats['activeRequests']}',
            icon: Icons.emergency,
            color: Colors.red,
          ),
          _buildStatCard(
            title: 'Total Donations',
            value: '${stats['totalDonations']}',
            icon: Icons.water_drop,
            color: Colors.green,
          ),
          _buildStatCard(
            title: 'Available Donors',
            value: '${stats['availableDonors']}',
            icon: Icons.favorite,
            color: Colors.pink,
          ),
        ],
      );
    },
  );
}

Future<Map<String, dynamic>> _loadStatistics() async {
  final usersCount = await FirebaseFirestore.instance
      .collection('users')
      .count()
      .get();
  
  final requestsCount = await FirebaseFirestore.instance
      .collection('bloodRequests')
      .where('status', whereIn: ['pending', 'approved'])
      .count()
      .get();
  
  final donationsCount = await FirebaseFirestore.instance
      .collection('donations')
      .where('status', isEqualTo: 'completed')
      .count()
      .get();
  
  final availableDonors = await FirebaseFirestore.instance
      .collection('users')
      .where('availability', isEqualTo: 'available')
      .where('isEligibleToDonate', isEqualTo: true)
      .count()
      .get();
  
  return {
    'totalUsers': usersCount.count,
    'activeRequests': requestsCount.count,
    'totalDonations': donationsCount.count,
    'availableDonors': availableDonors.count,
  };
}
```

**Lines 200-280** - Quick Admin Actions:
```dart
Widget _buildAdminActions() {
  return Column(
    children: [
      ListTile(
        leading: Icon(Icons.people, color: Colors.blue),
        title: Text('User Management'),
        subtitle: Text('Manage all users'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, '/admin/users'),
      ),
      ListTile(
        leading: Icon(Icons.emergency, color: Colors.red),
        title: Text('Blood Requests'),
        subtitle: Text('Manage blood requests'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, '/admin/requests'),
      ),
      ListTile(
        leading: Icon(Icons.inventory, color: Colors.green),
        title: Text('Inventory'),
        subtitle: Text('Manage blood inventory'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, '/admin/inventory'),
      ),
      ListTile(
        leading: Icon(Icons.notifications, color: Colors.orange),
        title: Text('Broadcast Alerts'),
        subtitle: Text('Send alerts to donors'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, '/admin/broadcast'),
      ),
    ],
  );
}
```

---

### 🔟 **ADMIN USER MANAGEMENT**

#### 📍 Location: `lib/screens/admin/user_management_screen.dart`

🔗 **[📄 Open user_management_screen.dart](lib/screens/admin/user_management_screen.dart)**

**Purpose:** Manage all users in the system

**Key Features:**
- View all users
- Search & filter users
- Edit user profiles
- Change user roles
- Deactivate/delete users
- View user donation history

**Main Code Sections:**

**Lines 100-200** - User List with Filters:
```dart
Widget _buildUsersList() {
  return StreamBuilder<QuerySnapshot>(
    stream: _getUsersStream(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();
      
      final users = snapshot.data!.docs
          .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
          .where((user) => _matchesFilters(user))
          .toList();
      
      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getBloodTypeColor(user.bloodType),
                child: Text(user.bloodType, style: TextStyle(color: Colors.white)),
              ),
              title: Text(user.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${user.email}'),
                  Text('Role: ${user.role.name}'),
                  Text('Donations: ${user.totalDonations}'),
                  Text('Status: ${user.availability.name}'),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text('View Details'),
                    onTap: () => _viewUserDetails(user),
                  ),
                  PopupMenuItem(
                    child: Text('Edit Profile'),
                    onTap: () => _editUser(user),
                  ),
                  PopupMenuItem(
                    child: Text('Change Role'),
                    onTap: () => _changeUserRole(user),
                  ),
                  PopupMenuItem(
                    child: Text('Delete User', style: TextStyle(color: Colors.red)),
                    onTap: () => _deleteUser(user),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
```

**Lines 300-380** - Change User Role:
```dart
Future<void> _changeUserRole(User user) async {
  final newRole = await showDialog<UserRole>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Change User Role'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<UserRole>(
            title: Text('Regular User'),
            value: UserRole.user,
            groupValue: user.role,
            onChanged: (val) => Navigator.pop(context, val),
          ),
          RadioListTile<UserRole>(
            title: Text('Organization Admin'),
            value: UserRole.orgAdmin,
            groupValue: user.role,
            onChanged: (val) => Navigator.pop(context, val),
          ),
          RadioListTile<UserRole>(
            title: Text('Super Admin'),
            value: UserRole.superAdmin,
            groupValue: user.role,
            onChanged: (val) => Navigator.pop(context, val),
          ),
        ],
      ),
    ),
  );
  
  if (newRole != null && newRole != user.role) {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .update({'role': newRole.name});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User role updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update role: $e')),
      );
    }
  }
}
```

---

### 1️⃣1️⃣ **ADMIN BLOOD REQUEST MANAGEMENT**

#### 📍 Location: `lib/screens/admin/blood_request_management_screen.dart`

🔗 **[📄 Open blood_request_management_screen.dart](lib/screens/admin/blood_request_management_screen.dart)**

**Purpose:** Approve, manage, and fulfill blood requests

**Key Features:**
- View all blood requests
- Filter by status/urgency
- Approve/reject requests
- Assign donors
- Mark as fulfilled
- Send notifications

**Main Code Sections:**

**Lines 120-220** - Request List:
```dart
Widget _buildRequestsList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('bloodRequests')
        .orderBy('requestDate', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();
      
      final requests = snapshot.data!.docs
          .map((doc) => BloodRequest.fromFirestore(doc))
          .where((req) => _matchesFilter(req))
          .toList();
      
      return ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return Card(
            color: _getUrgencyColor(request.urgency),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(request.status),
                child: Icon(Icons.water_drop, color: Colors.white),
              ),
              title: Text('${request.patientName} - ${request.bloodType}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hospital: ${request.hospitalName}'),
                  Text('Location: ${request.location}'),
                  Text('Units: ${request.unitsNeeded}'),
                  Text('Urgency: ${request.urgency.name.toUpperCase()}'),
                  Text('Status: ${request.status.name.toUpperCase()}'),
                ],
              ),
              children: [
                _buildRequestActions(request),
              ],
            ),
          );
        },
      );
    },
  );
}
```

**Lines 300-400** - Approve Request:
```dart
Future<void> _approveRequest(BloodRequest request) async {
  try {
    // Update request status
    await FirebaseFirestore.instance
        .collection('bloodRequests')
        .doc(request.id)
        .update({
      'status': RequestStatus.approved.name,
      'assignedAdminId': FirebaseAuth.instance.currentUser!.uid,
      'approvedAt': FieldValue.serverTimestamp(),
    });
    
    // Send notification to requester
    await _sendNotification(
      userId: request.requestedBy,
      title: 'Request Approved',
      message: 'Your blood request for ${request.patientName} has been approved.',
    );
    
    // Notify matching donors
    await _notifyMatchingDonors(request);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request approved successfully')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to approve request: $e')),
    );
  }
}

Future<void> _notifyMatchingDonors(BloodRequest request) async {
  // Find donors with matching blood type
  final donorsSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('bloodType', isEqualTo: request.bloodType)
      .where('availability', isEqualTo: 'available')
      .where('isEligibleToDonate', isEqualTo: true)
      .get();
  
  // Send notification to each donor
  for (var doc in donorsSnapshot.docs) {
    await _sendNotification(
      userId: doc.id,
      title: 'Urgent Blood Request',
      message: 'Blood needed for ${request.patientName} at ${request.hospitalName}',
    );
  }
}
```

---

### 1️⃣2️⃣ **ADMIN INVENTORY MANAGEMENT**

#### 📍 Location: `lib/screens/admin/inventory_management_screen.dart`

🔗 **[📄 Open inventory_management_screen.dart](lib/screens/admin/inventory_management_screen.dart)**

**Purpose:** Track and manage blood unit inventory

**Key Features:**
- View current inventory by blood type
- Add new blood units
- Update quantities
- Track expiry dates
- Generate inventory reports
- Low stock alerts

**Main Code Sections:**

**Lines 100-200** - Inventory Display:
```dart
Widget _buildInventoryGrid() {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: _loadInventory(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();
      
      final inventory = snapshot.data!;
      
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
        ),
        itemCount: inventory.length,
        itemBuilder: (context, index) {
          final item = inventory[index];
          final bloodType = item['bloodType'] as String;
          final units = item['unitsAvailable'] as int;
          final isLow = units < 10;
          
          return Card(
            color: isLow ? Colors.red[50] : Colors.white,
            child: InkWell(
              onTap: () => _editInventory(item),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop,
                    size: 48,
                    color: isLow ? Colors.red : Colors.blue,
                  ),
                  SizedBox(height: 8),
                  Text(
                    bloodType,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$units units',
                    style: TextStyle(fontSize: 16),
                  ),
                  if (isLow)
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'LOW STOCK',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
```

**Lines 250-330** - Update Inventory:
```dart
Future<void> _updateInventory(String bloodType, int newUnits) async {
  try {
    // Find existing inventory record
    final snapshot = await FirebaseFirestore.instance
        .collection('inventory')
        .where('bloodType', isEqualTo: bloodType)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) {
      // Create new inventory record
      await FirebaseFirestore.instance.collection('inventory').add({
        'bloodType': bloodType,
        'unitsAvailable': newUnits,
        'location': 'Main Blood Bank',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } else {
      // Update existing record
      await FirebaseFirestore.instance
          .collection('inventory')
          .doc(snapshot.docs.first.id)
          .update({
        'unitsAvailable': newUnits,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
    
    // Check for low stock alert
    if (newUnits < 10) {
      await _sendLowStockAlert(bloodType, newUnits);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Inventory updated successfully')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update inventory: $e')),
    );
  }
}
```

---

### 1️⃣3️⃣ **ADMIN BROADCAST ALERTS**

#### 📍 Location: `lib/screens/admin/broadcast_alert_screen.dart`

🔗 **[📄 Open broadcast_alert_screen.dart](lib/screens/admin/broadcast_alert_screen.dart)**

**Purpose:** Send mass notifications to donors

**Key Features:**
- Compose broadcast messages
- Target specific blood types
- Set urgency level
- Send to all or filtered donors
- Track delivery status

**Main Code Sections:**

**Lines 100-200** - Broadcast Form:
```dart
Widget _buildBroadcastForm() {
  return Column(
    children: [
      TextField(
        controller: _titleController,
        decoration: InputDecoration(
          labelText: 'Alert Title',
          prefixIcon: Icon(Icons.title),
        ),
      ),
      SizedBox(height: 16),
      TextField(
        controller: _messageController,
        maxLines: 5,
        decoration: InputDecoration(
          labelText: 'Message',
          prefixIcon: Icon(Icons.message),
          hintText: 'Enter your broadcast message...',
        ),
      ),
      SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _targetBloodType,
        decoration: InputDecoration(labelText: 'Target Blood Type'),
        items: ['All', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
            .toList(),
        onChanged: (value) => setState(() => _targetBloodType = value),
      ),
      SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _urgencyLevel,
        decoration: InputDecoration(labelText: 'Urgency Level'),
        items: ['normal', 'urgent', 'critical']
            .map((level) => DropdownMenuItem(value: level, child: Text(level)))
            .toList(),
        onChanged: (value) => setState(() => _urgencyLevel = value),
      ),
      SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: _sendBroadcast,
        icon: Icon(Icons.send),
        label: Text('Send Broadcast'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
    ],
  );
}
```

**Lines 250-350** - Send Broadcast:
```dart
Future<void> _sendBroadcast() async {
  if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill in all fields')),
    );
    return;
  }
  
  setState(() => _isSending = true);
  
  try {
    // Get target users
    Query query = FirebaseFirestore.instance.collection('users');
    
    if (_targetBloodType != 'All') {
      query = query.where('bloodType', isEqualTo: _targetBloodType);
    }
    
    // Only send to available and eligible donors
    query = query
        .where('availability', isEqualTo: 'available')
        .where('isEligibleToDonate', isEqualTo: true);
    
    final usersSnapshot = await query.get();
    
    // Create broadcast record
    final broadcastRef = await FirebaseFirestore.instance
        .collection('broadcastAlerts')
        .add({
      'title': _titleController.text.trim(),
      'message': _messageController.text.trim(),
      'bloodType': _targetBloodType,
      'urgency': _urgencyLevel,
      'createdBy': FirebaseAuth.instance.currentUser!.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'sentToCount': usersSnapshot.docs.length,
    });
    
    // Send notification to each user
    for (var doc in usersSnapshot.docs) {
      await _sendNotification(
        userId: doc.id,
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
      );
    }
    
    setState(() => _isSending = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Broadcast sent to ${usersSnapshot.docs.length} users')),
    );
    
    // Clear form
    _titleController.clear();
    _messageController.clear();
  } catch (e) {
    setState(() => _isSending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to send broadcast: $e')),
    );
  }
}
```

---

## 🔧 SERVICES LAYER - Shared Business Logic

### 📍 Location: `lib/services/`

🔗 **Quick Access to All Services:**
- [📄 auth_service.dart](lib/services/auth_service.dart) - Authentication
- [📄 firestore_service.dart](lib/services/firestore_service.dart) - Database operations
- [📄 messaging_service.dart](lib/services/messaging_service.dart) - Chat & messaging
- [📄 admin_service.dart](lib/services/admin_service.dart) - Admin operations
- [📄 inventory_service.dart](lib/services/inventory_service.dart) - Inventory management
- [📄 location_service.dart](lib/services/location_service.dart) - GPS & location
- [📄 gemini_chat_service.dart](lib/services/gemini_chat_service.dart) - AI chatbot
- [📄 broadcast_alert_service.dart](lib/services/broadcast_alert_service.dart) - Mass notifications
- [📄 analytics_service.dart](lib/services/analytics_service.dart) - Analytics tracking
- [📄 notification_service.dart](lib/services/notification_service.dart) - Push notifications
- [📄 storage_service.dart](lib/services/storage_service.dart) - File storage
- [📄 demo_data_service.dart](lib/services/demo_data_service.dart) - Demo data
- [📄 bangladesh_demo_data_service.dart](lib/services/bangladesh_demo_data_service.dart) - Bangladesh data

```
lib/services/
├── auth_service.dart              # Authentication Logic
│   ├── signInWithEmailAndPassword()
│   ├── signUpWithEmailAndPassword()
│   ├── signInWithPhoneNumber()
│   ├── signOut()
│   └── getCurrentUser()
│
├── firestore_service.dart         # Database Operations
│   ├── getUser(userId)
│   ├── updateUser(userId, data)
│   ├── createBloodRequest(data)
│   ├── getBloodRequests(filters)
│   └── updateDonation(donationId, data)
│
├── messaging_service.dart         # Chat & Messaging
│   ├── sendMessage(senderId, receiverId, message)
│   ├── getMessages(chatRoomId)
│   ├── createChatRoom(participants)
│   └── markAsRead(messageId)
│
├── admin_service.dart             # Admin Operations
│   ├── getAllUsers()
│   ├── updateUserRole(userId, role)
│   ├── deleteUser(userId)
│   ├── approveRequest(requestId)
│   └── getStatistics()
│
├── inventory_service.dart         # Inventory Management
│   ├── getInventory()
│   ├── updateInventory(bloodType, units)
│   ├── checkLowStock()
│   └── addInventoryRecord(data)
│
├── location_service.dart          # GPS & Location
│   ├── getCurrentLocation()
│   ├── getNearbyDonationCenters(lat, lng)
│   ├── getDistanceBetween(point1, point2)
│   └── requestLocationPermission()
│
├── gemini_chat_service.dart       # AI Chatbot
│   ├── sendMessage(userMessage)
│   ├── startChat()
│   ├── getResponse()
│   └── clearHistory()
│
├── broadcast_alert_service.dart   # Mass Notifications
│   ├── sendBroadcastAlert(title, message, filters)
│   ├── getAlertRecipients(bloodType)
│   └── trackDeliveryStatus()
│
├── analytics_service.dart         # Analytics Tracking
│   ├── logEvent(eventName, parameters)
│   ├── logScreenView(screenName)
│   └── logUserAction(action)
│
├── notification_service.dart      # Push Notifications
│   ├── initializeNotifications()
│   ├── sendNotification(userId, title, body)
│   ├── handleNotificationTap()
│   └── requestPermission()
│
└── storage_service.dart           # File Storage
    ├── uploadProfileImage(userId, file)
    ├── getImageUrl(path)
    ├── deleteFile(path)
    └── uploadDocument(file)
```

**Example Service Code:**

**`auth_service.dart`** - Lines 20-80:
```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }
  
  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
```

---

## 📊 MODELS - Data Structures

### 📍 Location: `lib/models/`

🔗 **Quick Access to All Models:**
- [📄 user.dart](lib/models/user.dart) - User model with roles & badges
- [📄 blood_request.dart](lib/models/blood_request.dart) - Blood request model
- [📄 donation.dart](lib/models/donation.dart) - Donation model
- [📄 donation_center.dart](lib/models/donation_center.dart) - Donation center model
- [📄 message.dart](lib/models/message.dart) - Message & chat room models
- [📄 admin.dart](lib/models/admin.dart) - Admin model
- [📄 search.dart](lib/models/search.dart) - Search filters

```
lib/models/
├── user.dart                    # User Model
│   ├── enum UserRole
│   ├── enum DonorAvailability
│   ├── enum DonorBadge
│   └── class User { ... }
│
├── blood_request.dart           # Blood Request Model
│   ├── enum RequestStatus
│   ├── enum UrgencyLevel
│   └── class BloodRequest { ... }
│
├── donation.dart                # Donation Model
│   └── class Donation { ... }
│
├── donation_center.dart         # Donation Center Model
│   └── class DonationCenter { ... }
│
├── message.dart                 # Message Model
│   ├── enum MessageType
│   ├── class Message { ... }
│   └── class ChatRoom { ... }
│
└── admin.dart                   # Admin Model
    └── class Admin { ... }
```

---

## 🎨 UI COMPONENTS

### 📍 Location: `lib/widgets/`

🔗 **Quick Access to Widgets:**
- [📄 themed_widgets.dart](lib/widgets/themed_widgets.dart) - Reusable themed components
- [📄 donor_card.dart](lib/widgets/donor_card.dart) - Donor display card
- [📄 request_card.dart](lib/widgets/request_card.dart) - Request display card
- [📄 badge_display.dart](lib/widgets/badge_display.dart) - Achievement badges

```
lib/widgets/
├── themed_widgets.dart          # Reusable UI Components
│   ├── ThemedButton
│   ├── ThemedTextField
│   ├── ThemedCard
│   ├── ThemedAppBar
│   └── LoadingIndicator
│
├── donor_card.dart              # Donor Display Card
├── request_card.dart            # Request Display Card
└── badge_display.dart           # Achievement Badge Display
```

---

## 🔐 ROLE-BASED ACCESS CONTROL

### Permission Checking Code

**Location:** Throughout the app, but primarily in `lib/services/auth_service.dart` and individual screens

```dart
// Check if user is admin
bool isAdmin(User user) {
  return user.role == UserRole.superAdmin || user.role == UserRole.orgAdmin;
}

// Check if user is super admin
bool isSuperAdmin(User user) {
  return user.role == UserRole.superAdmin;
}

// Check if user can approve requests
bool canApproveRequests(User user) {
  return user.role == UserRole.superAdmin || user.role == UserRole.orgAdmin;
}

// Usage in screens
@override
Widget build(BuildContext context) {
  final user = Provider.of<User>(context);
  
  if (isAdmin(user)) {
    // Show admin features
    return AdminDashboard();
  } else {
    // Show user features
    return UserHome();
  }
}
```

---

## 🔄 DATA FLOW SUMMARY

### User Flow:
1. **Authentication** → `auth/` screens → `auth_service.dart` → Firebase Auth
2. **Home** → `home_screen.dart` → `firestore_service.dart` → Firestore
3. **Search** → `search_screen.dart` → Firestore query → Display results
4. **Donate** → `donate_screen.dart` → Create donation → Update user stats
5. **Request** → `request_posting_screen.dart` → Create request → Notify donors
6. **Profile** → `profile_screen.dart` → Display user data → Quick actions

### Admin Flow:
1. **Dashboard** → `admin_dashboard_screen.dart` → Load statistics
2. **Manage Users** → `user_management_screen.dart` → CRUD operations
3. **Approve Requests** → `blood_request_management_screen.dart` → Update status
4. **Inventory** → `inventory_management_screen.dart` → Update stock
5. **Broadcast** → `broadcast_alert_screen.dart` → Send notifications

---

## 📝 KEY TAKEAWAYS

### User Code Locations:
- **Main User Features:** `lib/screens/home/` (10+ files)
- **Authentication:** `lib/screens/auth/` (3 files)
- **Chat/Messaging:** `lib/screens/home/messages_screen.dart` + `lib/screens/chat/chatbot_screen.dart`
- **Quick Actions:** `my_qr_code_screen.dart`, `invite_friends_screen.dart`, `help_support_screen.dart`, `about_screen.dart`

### Admin Code Locations:
- **All Admin Features:** `lib/screens/admin/` (6 files)
- **Admin Dashboard:** `admin_dashboard_screen.dart`
- **User Management:** `user_management_screen.dart`
- **Request Management:** `blood_request_management_screen.dart`
- **Inventory:** `inventory_management_screen.dart`
- **Broadcast:** `broadcast_alert_screen.dart`

### Shared Code:
- **Services:** `lib/services/` (14 files) - Used by both user and admin
- **Models:** `lib/models/` (6 files) - Data structures for all features
- **Widgets:** `lib/widgets/` - Reusable UI components

---

**🎯 Quick Navigation Tips:**

- Looking for **user login**? → [📄 login_screen.dart](lib/screens/auth/login_screen.dart)
- Looking for **donor search**? → [📄 search_screen.dart](lib/screens/home/search_screen.dart)
- Looking for **admin panel**? → [📄 admin_dashboard_screen.dart](lib/screens/admin/admin_dashboard_screen.dart)
- Looking for **Firebase operations**? → [📄 firestore_service.dart](lib/services/firestore_service.dart)
- Looking for **data models**? → [📁 lib/models/](lib/models/)
- Looking for **new Quick Actions**? → [📄 my_qr_code](lib/screens/home/my_qr_code_screen.dart) • [📄 invite_friends](lib/screens/home/invite_friends_screen.dart) • [📄 help_support](lib/screens/home/help_support_screen.dart) • [📄 about](lib/screens/home/about_screen.dart)

---

## 🚀 QUICK START GUIDE

### 📋 Most Important Files to Show:

#### **User Features (Show First):**
1. [🏠 Home Screen](lib/screens/home/home_screen.dart) - Main user dashboard
2. [🔍 Search Screen](lib/screens/home/search_screen.dart) - Find donors
3. [👤 Profile Screen](lib/screens/home/profile_screen.dart) - User profile & Quick Actions
4. [🩸 Donate Screen](lib/screens/home/donate_screen.dart) - Schedule donations
5. [📝 Request Posting](lib/screens/home/request_posting_screen.dart) - Create blood request

#### **Admin Features (Show to Administrators):**
1. [📊 Admin Dashboard](lib/screens/admin/admin_dashboard_screen.dart) - Admin control panel
2. [👥 User Management](lib/screens/admin/user_management_screen.dart) - Manage all users
3. [🩸 Request Management](lib/screens/admin/blood_request_management_screen.dart) - Approve requests
4. [📦 Inventory](lib/screens/admin/inventory_management_screen.dart) - Blood inventory
5. [📢 Broadcast Alerts](lib/screens/admin/broadcast_alert_screen.dart) - Send mass alerts

#### **Core Services (Backend Logic):**
1. [🔐 Auth Service](lib/services/auth_service.dart) - Authentication logic
2. [🗄️ Firestore Service](lib/services/firestore_service.dart) - Database operations
3. [💬 Messaging Service](lib/services/messaging_service.dart) - Chat functionality
4. [🤖 Gemini Chat](lib/services/gemini_chat_service.dart) - AI chatbot
5. [📍 Location Service](lib/services/location_service.dart) - GPS & maps

#### **Data Models (Show Structure):**
1. [👤 User Model](lib/models/user.dart) - User data structure with roles & badges
2. [🩸 Blood Request Model](lib/models/blood_request.dart) - Request data structure
3. [💉 Donation Model](lib/models/donation.dart) - Donation data structure
4. [🏥 Donation Center](lib/models/donation_center.dart) - Center data with locations
5. [💬 Message Model](lib/models/message.dart) - Chat message structure

---

## 📱 DEMO FLOW (For Presentation)

### **User Flow Demo:**
1. Start: [Welcome Screen](lib/screens/welcome_screen.dart)
2. Login: [Login Screen](lib/screens/auth/login_screen.dart)
3. Home: [Main Navigation](lib/screens/home/main_navigation_screen.dart) → [Home Screen](lib/screens/home/home_screen.dart)
4. Search: [Search Donors](lib/screens/home/search_screen.dart)
5. Profile: [Profile Screen](lib/screens/home/profile_screen.dart) → [My QR Code](lib/screens/home/my_qr_code_screen.dart)

### **Admin Flow Demo:**
1. Login as Admin: [Login Screen](lib/screens/auth/login_screen.dart)
2. Dashboard: [Admin Dashboard](lib/screens/admin/admin_dashboard_screen.dart)
3. Manage Users: [User Management](lib/screens/admin/user_management_screen.dart)
4. Approve Request: [Request Management](lib/screens/admin/blood_request_management_screen.dart)
5. Send Alert: [Broadcast Alerts](lib/screens/admin/broadcast_alert_screen.dart)

---

**Version:** 1.0.0  
**Last Updated:** December 2025  
**Total Files:** 50+ screen files, 14 service files, 6 model files
