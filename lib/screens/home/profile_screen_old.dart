import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import '../../models/donation.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser;
  List<Donation> donationHistory = [];
  bool isEditingProfile = false;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? selectedBloodType;
  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDonationHistory();
  }

  Future<void> _loadUserData() async {
    try {
      final auth = fb_auth.FirebaseAuth.instance;
      final user = auth.currentUser;
      if (user == null) return; // Not signed in
      // Fetch Firestore profile if available.
      DocumentSnapshot<Map<String, dynamic>>? profile;
      try {
        profile = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
      } catch (_) {}
      final data = profile?.data() ?? {};
      currentUser = User(
        email: user.email ?? data['email'] ?? '',
        name: data['name'] ?? user.displayName ?? '',
        bloodType: data['bloodType'] ?? 'Unknown',
        phone: data['phone'] ?? '',
        role: UserRole.user,
      );
      _nameController.text = currentUser!.name;
      _emailController.text = currentUser!.email;
      _phoneController.text = currentUser!.phone ?? '';
      _addressController.text = data['address'] ?? '';
      selectedBloodType = currentUser!.bloodType;
      setState(() {});
    } catch (e) {
      // Fallback demo user if anything fails.
      currentUser = User(
        email: 'demo@example.com',
        name: 'Demo User',
        bloodType: 'O+',
      );
      _nameController.text = currentUser!.name;
      _emailController.text = currentUser!.email;
      selectedBloodType = currentUser!.bloodType;
      setState(() {});
    }
  }

  void _loadDonationHistory() {
    donationHistory = [
      Donation(
        id: '1',
        donorId: 'user1',
        donorName: 'Tofaiel',
        bloodType: 'B+',
        donationDate: DateTime.now().subtract(Duration(days: 90)),
        location: 'PSTU Health Center, Patuakhali',
        status: 'completed',
      ),
      Donation(
        id: '2',
        donorId: 'user1',
        donorName: 'Tofaiel',
        bloodType: 'B+',
        donationDate: DateTime.now().subtract(Duration(days: 180)),
        location: 'Patuakhali City Hospital',
        status: 'completed',
      ),
      Donation(
        id: '3',
        donorId: 'user1',
        donorName: 'Tofaiel',
        bloodType: 'B+',
        donationDate: DateTime.now().subtract(Duration(days: 270)),
        location: 'Red Crescent Blood Center, Barishal',
        status: 'completed',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.red[700],
        actions: [
          IconButton(
            onPressed: () =>
                setState(() => isEditingProfile = !isEditingProfile),
            icon: Icon(isEditingProfile ? Icons.close : Icons.edit),
          ),
          IconButton(onPressed: _showSettingsMenu, icon: Icon(Icons.settings)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildProfileStats(),
            SizedBox(height: 20),
            if (isEditingProfile)
              _buildEditProfileForm()
            else
              _buildProfileContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[700]!, Colors.red[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              currentUser!.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            currentUser!.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Blood Type: ${currentUser!.bloodType}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats() {
    final totalDonations = donationHistory.length;
    final lastDonation = donationHistory.isNotEmpty
        ? donationHistory.first.donationDate
        : null;
    final daysSinceLastDonation = lastDonation != null
        ? DateTime.now().difference(lastDonation).inDays
        : 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.favorite,
              title: 'Total Donations',
              value: '$totalDonations',
              color: Colors.red,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.access_time,
              title: 'Days Since Last',
              value: lastDonation != null ? '$daysSinceLastDonation' : 'Never',
              color: Colors.blue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.people,
              title: 'Lives Saved',
              value: '${totalDonations * 3}',
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileForm() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your name';
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your email';
                if (!value!.contains('@')) return 'Please enter a valid email';
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedBloodType,
              decoration: InputDecoration(
                labelText: 'Blood Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.bloodtype),
              ),
              items: bloodTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => selectedBloodType = value);
              },
              validator: (value) {
                if (value == null) return 'Please select your blood type';
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return Column(
      children: [
        _buildInfoSection(),
        _buildDonationHistorySection(),
        _buildAchievementsSection(),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildInfoRow(Icons.email, 'Email', currentUser!.email),
          _buildInfoRow(Icons.phone, 'Phone', '+880123456789'),
          _buildInfoRow(Icons.location_on, 'Address', 'PSTU, Patuakhali'),
          _buildInfoRow(Icons.bloodtype, 'Blood Type', currentUser!.bloodType),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 12),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationHistorySection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Donations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full donation history
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening full donation history...')),
                  );
                },
                child: Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...donationHistory
              .take(3)
              .map((donation) => _buildDonationTile(donation)),
        ],
      ),
    );
  }

  Widget _buildDonationTile(Donation donation) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.favorite, color: Colors.red[700], size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation.location,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  _formatDate(donation.donationDate),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              donation.status.toUpperCase(),
              style: TextStyle(
                color: Colors.green[800],
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildAchievementTile(
            icon: Icons.star,
            title: 'First Donation',
            description: 'Completed your first blood donation',
            isEarned: donationHistory.isNotEmpty,
          ),
          _buildAchievementTile(
            icon: Icons.local_fire_department,
            title: 'Life Saver',
            description: 'Saved 3 lives through donations',
            isEarned: donationHistory.isNotEmpty,
          ),
          _buildAchievementTile(
            icon: Icons.emoji_events,
            title: 'Regular Donor',
            description: 'Made 5 donations',
            isEarned: donationHistory.length >= 5,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile({
    required IconData icon,
    required String title,
    required String description,
    required bool isEarned,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEarned ? Colors.amber : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isEarned ? Colors.amber[700] : Colors.grey[400],
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isEarned ? Colors.black : Colors.grey[600],
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          if (isEarned) Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final authService = AuthService();
    try {
      await authService.updateUserProfile({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'bloodType': selectedBloodType,
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });
      if (!mounted) return;
      setState(() {
        currentUser = User(
          email: _emailController.text.trim(),
          name: _nameController.text.trim(),
          bloodType: selectedBloodType!,
          phone: _phoneController.text.trim(),
          role: currentUser?.role ?? UserRole.user,
        );
        isEditingProfile = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated and saved to cloud!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.red[700]),
              title: Text('Notification Settings'),
              onTap: () {
                Navigator.pop(context);
                _showNotificationSettings();
              },
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip, color: Colors.red[700]),
              title: Text('Privacy Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening privacy settings...')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.help, color: Colors.red[700]),
              title: Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening help center...')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red[700]),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    bool emergencyAlerts = true;
    bool donationReminders = true;
    bool messageNotifications = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Notification Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: Text('Emergency Alerts'),
                value: emergencyAlerts,
                onChanged: (value) {
                  setDialogState(() => emergencyAlerts = value ?? true);
                },
                activeColor: Colors.red[700],
              ),
              CheckboxListTile(
                title: Text('Donation Reminders'),
                value: donationReminders,
                onChanged: (value) {
                  setDialogState(() => donationReminders = value ?? true);
                },
                activeColor: Colors.red[700],
              ),
              CheckboxListTile(
                title: Text('Message Notifications'),
                value: messageNotifications,
                onChanged: (value) {
                  setDialogState(() => messageNotifications = value ?? true);
                },
                activeColor: Colors.red[700],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notification settings saved!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/welcome');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
