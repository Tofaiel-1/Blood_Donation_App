import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import '../../models/donation.dart';
import '../../widgets/themed_widgets.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser;
  List<Donation> donationHistory = [];
  int daysUntilNextDonation = 0;
  bool isLoadingDonations = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedBloodType = 'A+';

  final List<String> _bloodTypes = [
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final auth = fb_auth.FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user == null) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/welcome',
            (route) => false,
          );
        }
        return;
      }

      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!profile.exists) {
        throw Exception('User profile not found');
      }

      final data = profile.data() ?? {};
      currentUser = User(
        email: user.email ?? data['email'] ?? '',
        name: data['name'] ?? user.displayName ?? '',
        bloodType: data['bloodType'] ?? 'Unknown',
        phone: data['phone'] ?? '',
        role: UserRole.user,
      );

      // Populate controllers and blood type
      _nameController.text = currentUser!.name;
      _phoneController.text = currentUser!.phone ?? '';
      _selectedBloodType = currentUser!.bloodType.isNotEmpty
          ? currentUser!.bloodType
          : 'A+';

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
          (route) => false,
        );
      }
    }
  }

  Future<void> _loadDonationHistory() async {
    try {
      final auth = fb_auth.FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user == null) return;

      setState(() {
        isLoadingDonations = true;
      });

      // Fetch donations from Firebase
      final donationsSnapshot = await FirebaseFirestore.instance
          .collection('donations')
          .where('donorId', isEqualTo: user.uid)
          .orderBy('donationDate', descending: true)
          .get();

      donationHistory = donationsSnapshot.docs.map((doc) {
        final data = doc.data();
        return Donation(
          id: doc.id,
          donorId: data['donorId'] ?? '',
          donorName: data['donorName'] ?? '',
          bloodType: data['bloodType'] ?? '',
          donationDate:
              (data['donationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          location: data['location'] ?? '',
          status: data['status'] ?? 'completed',
        );
      }).toList();

      // Calculate days until next donation (90 days from last donation)
      if (donationHistory.isNotEmpty) {
        final lastDonation = donationHistory.first.donationDate;
        final daysSinceLastDonation = DateTime.now()
            .difference(lastDonation)
            .inDays;
        daysUntilNextDonation = 90 - daysSinceLastDonation;
        if (daysUntilNextDonation < 0) {
          daysUntilNextDonation = 0; // Can donate now
        }
      } else {
        daysUntilNextDonation = 0; // No previous donations, can donate now
      }

      if (mounted) {
        setState(() {
          isLoadingDonations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingDonations = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading donations: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profile header with gradient
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            currentUser!.name.isNotEmpty
                                ? currentUser!.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentUser!.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currentUser!.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      BloodTypeBadge(
                        bloodType: currentUser!.bloodType,
                        size: 55,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // Edit profile
                  _showEditProfile();
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  isLoadingDonations
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                value: donationHistory.length.toString(),
                                label: 'Donations',
                                icon: Icons.bloodtype,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                value: daysUntilNextDonation.toString(),
                                label: daysUntilNextDonation == 0
                                    ? 'Can Donate'
                                    : 'Days Left',
                                icon: Icons.access_time,
                                color: daysUntilNextDonation == 0
                                    ? AppColors.hopeGreen
                                    : AppColors.warningAmber,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 24),

                  // Settings section
                  _buildSectionCard(context, 'Settings', [
                    _buildSettingsTile(
                      context,
                      Icons.dark_mode,
                      'Dark Mode',
                      trailing: Consumer<ThemeManager>(
                        builder: (context, themeManager, child) {
                          return Switch(
                            value: isDark,
                            onChanged: (value) {
                              themeManager.toggleTheme(value);
                            },
                          );
                        },
                      ),
                    ),
                    _buildSettingsTile(
                      context,
                      Icons.palette,
                      'Theme Showcase',
                      onTap: () =>
                          Navigator.pushNamed(context, '/theme-showcase'),
                    ),
                    _buildSettingsTile(
                      context,
                      Icons.notifications,
                      'Notifications',
                      trailing: Switch(value: true, onChanged: (v) {}),
                    ),
                    _buildSettingsTile(
                      context,
                      Icons.language,
                      'Language',
                      subtitle: 'English',
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Quick actions
                  _buildSectionCard(context, 'Quick Actions', [
                    _buildSettingsTile(context, Icons.qr_code, 'My QR Code'),
                    _buildSettingsTile(context, Icons.share, 'Invite Friends'),
                    _buildSettingsTile(context, Icons.help, 'Help & Support'),
                    _buildSettingsTile(context, Icons.info, 'About'),
                  ]),
                  const SizedBox(height: 24),

                  // Donation history
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Donation History',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // History list
                  donationHistory.isEmpty
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.bloodtype_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No donation history yet',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: donationHistory.length,
                          itemBuilder: (context, index) {
                            final donation = donationHistory[index];
                            return DonationHistoryTile(
                              bloodType: donation.bloodType,
                              location: donation.location,
                              date: donation.donationDate,
                              isCompleted: donation.status == 'completed',
                            );
                          },
                        ),
                  const SizedBox(height: 24),

                  // Logout button
                  OutlinedButton(
                    onPressed: _handleLogout,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title, {
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showEditProfile() {
    // Reset controllers and blood type to current values
    _nameController.text = currentUser!.name;
    _phoneController.text = currentUser!.phone ?? '';
    _selectedBloodType = currentUser!.bloodType.isNotEmpty
        ? currentUser!.bloodType
        : 'A+';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Edit Profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bloodtype, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        'Blood Type',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _bloodTypes.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final bloodType = _bloodTypes[index];
                        return RadioListTile<String>(
                          title: Text(bloodType),
                          value: bloodType,
                          groupValue: _selectedBloodType,
                          onChanged: (value) {
                            setModalState(() {
                              _selectedBloodType = value!;
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Save Changes',
                icon: Icons.check,
                isFullWidth: true,
                onPressed: () => _saveProfileChanges(context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfileChanges(BuildContext dialogContext) async {
    try {
      final auth = fb_auth.FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Validate inputs
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a name'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading
      if (dialogContext.mounted) {
        showDialog(
          context: dialogContext,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      // Update Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'bloodType': _selectedBloodType,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update local state
      setState(() {
        currentUser = User(
          email: currentUser!.email,
          name: _nameController.text.trim(),
          bloodType: _selectedBloodType,
          phone: _phoneController.text.trim(),
          role: currentUser!.role,
        );
      });

      // Close loading dialog
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      // Close edit sheet
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Profile updated successfully'),
              ],
            ),
            backgroundColor: AppColors.hopeGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await fb_auth.FirebaseAuth.instance.signOut();
      } catch (_) {}
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
          (route) => false,
        );
      }
    }
  }
}
