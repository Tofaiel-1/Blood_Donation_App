import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import '../../models/donation.dart';
import '../../widgets/themed_widgets.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import 'my_qr_code_screen.dart';
import 'invite_friends_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  User? currentUser;
  List<Donation> donationHistory = [];
  int daysUntilNextDonation = 0;
  bool isLoadingDonations = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedBloodType = 'A+';
  DonorAvailability _availability = DonorAvailability.available;

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
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _loadDonationHistory();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload data when user comes back to this screen
      _loadUserData();
      _loadDonationHistory();
    }
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

      // Force read from server to get latest data (not cache)
      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));

      if (!profile.exists) {
        throw Exception('User profile not found');
      }

      final data = profile.data() ?? {};

      // Get stats and fix if needed
      final totalDonations = data['totalDonations'] ?? 0;
      var livesSaved = data['livesSaved'] ?? 0;

      debugPrint('📊 Profile loading user data:');
      debugPrint('   totalDonations: $totalDonations');
      debugPrint('   livesSaved from DB: ${data['livesSaved']}');

      // If livesSaved is 0 but totalDonations > 0, fix it
      if (livesSaved == 0 && totalDonations > 0) {
        livesSaved = totalDonations;

        // Update Firebase
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'livesSaved': totalDonations});

        debugPrint('   ✅ Fixed livesSaved to: $livesSaved');
      }

      debugPrint('   Final livesSaved: $livesSaved');

      // Parse availability
      DonorAvailability avail = DonorAvailability.available;
      final availStr = data['availability']?.toString().toLowerCase() ?? '';
      if (availStr == 'unavailable') {
        avail = DonorAvailability.unavailable;
      } else if (availStr == 'busy') {
        avail = DonorAvailability.busy;
      }
      _availability = avail;

      currentUser = User(
        email: user.email ?? data['email'] ?? '',
        name: data['name'] ?? user.displayName ?? '',
        bloodType: data['bloodType'] ?? 'Unknown',
        phone: data['phone'] ?? '',
        role: UserRole.user,
        availability: avail,
        totalDonations: totalDonations,
        livesSaved: livesSaved,
      );

      // Populate controllers and blood type
      _nameController.text = currentUser!.name;
      _phoneController.text = currentUser!.phone ?? '';
      _selectedBloodType = currentUser!.bloodType.isNotEmpty
          ? currentUser!.bloodType
          : 'A+';

      debugPrint('👤 Profile UI update:');
      debugPrint('   User: ${currentUser!.name}');
      debugPrint('   Donations: ${currentUser!.totalDonations}');
      debugPrint('   Lives Saved: ${currentUser!.livesSaved}');

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
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
          notes: data['notes'],
          // Recipient information
          recipientRequestId: data['recipientRequestId'],
          recipientPatientName: data['recipientPatientName'],
          recipientHospital: data['recipientHospital'],
          recipientBloodType: data['recipientBloodType'],
          recipientContactPhone: data['recipientContactPhone'],
        );
      }).toList();

      // Calculate days until next donation (120 days from last donation)
      if (donationHistory.isNotEmpty) {
        final lastDonation = donationHistory.first.donationDate;
        final daysSinceLastDonation = DateTime.now()
            .difference(lastDonation)
            .inDays;
        daysUntilNextDonation =
            120 - daysSinceLastDonation; // 120 days between donations
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profile header with gradient
          SliverAppBar(
            expandedHeight: isSmallScreen ? 240 : 280,
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
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      // Avatar
                      Container(
                        width: isSmallScreen ? 70 : 90,
                        height: isSmallScreen ? 70 : 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.3),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            currentUser!.name.isNotEmpty
                                ? currentUser!.name[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 32 : 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          currentUser!.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 18 : 24,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          currentUser!.email,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      BloodTypeBadge(
                        bloodType: currentUser!.bloodType,
                        size: isSmallScreen ? 45 : 55,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: _showEditProfile,
                tooltip: 'Edit Profile',
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
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
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final isVerySmall = constraints.maxWidth < 320;
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: StatCard(
                                        value:
                                            (currentUser?.totalDonations ?? 0)
                                                .toString(),
                                        label: isVerySmall
                                            ? 'Donations'
                                            : 'Total\nDonations',
                                        icon: Icons.bloodtype,
                                        color: AppColors.bloodRed,
                                      ),
                                    ),
                                    SizedBox(width: isSmallScreen ? 8 : 12),
                                    Expanded(
                                      child: StatCard(
                                        value: (currentUser?.livesSaved ?? 0)
                                            .toString(),
                                        label: 'Lives\nSaved',
                                        icon: Icons.favorite,
                                        color: AppColors.urgentRed,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmallScreen ? 8 : 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: StatCard(
                                        value: daysUntilNextDonation == 0
                                            ? 'Ready'
                                            : daysUntilNextDonation.toString(),
                                        label: daysUntilNextDonation == 0
                                            ? (isVerySmall
                                                  ? 'Ready'
                                                  : 'You Can\nDonate Now')
                                            : (isVerySmall
                                                  ? 'Days Left'
                                                  : 'Days Until\nNext Donation'),
                                        icon: Icons.calendar_today,
                                        color: daysUntilNextDonation == 0
                                            ? AppColors.hopeGreen
                                            : AppColors.lifeOrange,
                                      ),
                                    ),
                                    SizedBox(width: isSmallScreen ? 8 : 12),
                                    Expanded(
                                      child: StatCard(
                                        value: donationHistory
                                            .where(
                                              (d) => d.status == 'scheduled',
                                            )
                                            .length
                                            .toString(),
                                        label: 'Scheduled',
                                        icon: Icons.calendar_today,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Achievements/Badges Section
                  if (!isLoadingDonations && currentUser != null)
                    _buildBadgesSection(context),
                  const SizedBox(height: 24),

                  // Settings section
                  _buildSectionCard(context, 'Settings', [
                    _buildAvailabilityTile(context),
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
                    _buildSettingsTile(
                      context,
                      Icons.qr_code,
                      'My QR Code',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyQRCodeScreen(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      context,
                      Icons.share,
                      'Invite Friends',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InviteFriendsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      context,
                      Icons.help,
                      'Help & Support',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      context,
                      Icons.info,
                      'About',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutScreen(),
                          ),
                        );
                      },
                    ),
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
                              recipientPatientName:
                                  donation.recipientPatientName,
                              recipientHospital: donation.recipientHospital,
                              recipientBloodType: donation.recipientBloodType,
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

  Widget _buildBadgesSection(BuildContext context) {
    final totalDonations = donationHistory
        .where((d) => d.status == 'completed')
        .length;
    final currentBadge = _getBadgeForDonations(totalDonations);
    final nextBadge = _getNextBadge(totalDonations);
    final donationsUntilNext = nextBadge?['required'] as int? ?? 0;
    final remaining = totalDonations < donationsUntilNext
        ? donationsUntilNext - totalDonations
        : 0;

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber[700],
                  size: isSmallScreen ? 20 : 24,
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: Text(
                    'Achievements',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 18 : 22,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // Current Badge
            if (currentBadge != null) ...[
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (currentBadge['color'] as Color).withValues(alpha: 0.2),
                      (currentBadge['color'] as Color).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (currentBadge['color'] as Color).withValues(
                      alpha: 0.3,
                    ),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      currentBadge['emoji'] as String,
                      style: TextStyle(fontSize: isSmallScreen ? 36 : 48),
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentBadge['name'] as String,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 20,
                              fontWeight: FontWeight.bold,
                              color: currentBadge['color'] as Color,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 2 : 4),
                          Text(
                            currentBadge['description'] as String,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
            ],

            // Progress to Next Badge
            if (nextBadge != null && remaining > 0) ...[
              const Divider(),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                'Next Milestone',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Row(
                children: [
                  Text(
                    nextBadge['emoji'] as String,
                    style: TextStyle(fontSize: isSmallScreen ? 24 : 32),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nextBadge['name'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        LinearProgressIndicator(
                          value: totalDonations / donationsUntilNext,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            nextBadge['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$remaining more donation${remaining > 1 ? 's' : ''} to unlock',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            // All Badges Preview
            SizedBox(height: isSmallScreen ? 16 : 20),
            const Divider(),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'All Badges',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: isSmallScreen ? 13 : 14,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Wrap(
              spacing: isSmallScreen ? 8 : 12,
              runSpacing: isSmallScreen ? 8 : 12,
              children: _getAllBadges().map((badge) {
                final isUnlocked = totalDonations >= (badge['required'] as int);
                final badgeSize = isSmallScreen ? 48.0 : 56.0;
                final emojiSize = isSmallScreen ? 24.0 : 28.0;

                return Opacity(
                  opacity: isUnlocked ? 1.0 : 0.3,
                  child: Tooltip(
                    message: badge['name'] as String,
                    child: Container(
                      width: badgeSize,
                      height: badgeSize,
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? (badge['color'] as Color).withValues(alpha: 0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 8 : 12,
                        ),
                        border: Border.all(
                          color: isUnlocked
                              ? (badge['color'] as Color)
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          badge['emoji'] as String,
                          style: TextStyle(fontSize: emojiSize),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? _getBadgeForDonations(int donations) {
    final allBadges = _getAllBadges();
    Map<String, dynamic>? currentBadge;

    for (var badge in allBadges) {
      if (donations >= (badge['required'] as int)) {
        currentBadge = badge;
      }
    }

    return currentBadge;
  }

  Map<String, dynamic>? _getNextBadge(int donations) {
    final allBadges = _getAllBadges();

    for (var badge in allBadges) {
      if (donations < (badge['required'] as int)) {
        return badge;
      }
    }

    return null; // Already at max badge
  }

  List<Map<String, dynamic>> _getAllBadges() {
    return [
      {
        'name': 'First Time Donor',
        'emoji': '🩸',
        'required': 1,
        'color': Colors.pink,
        'description': 'Congratulations on your first donation!',
      },
      {
        'name': 'Bronze Donor',
        'emoji': '🥉',
        'required': 3,
        'color': Colors.brown,
        'description': '3 successful blood donations',
      },
      {
        'name': 'Silver Donor',
        'emoji': '🥈',
        'required': 5,
        'color': Colors.grey,
        'description': '5 successful blood donations',
      },
      {
        'name': 'Gold Donor',
        'emoji': '🥇',
        'required': 10,
        'color': Colors.amber,
        'description': '10 successful blood donations',
      },
      {
        'name': 'Platinum Donor',
        'emoji': '💎',
        'required': 20,
        'color': Colors.blue,
        'description': '20 successful blood donations',
      },
      {
        'name': 'Legendary Donor',
        'emoji': '👑',
        'required': 50,
        'color': Colors.purple,
        'description': '50 successful blood donations - You are a legend!',
      },
    ];
  }

  Widget _buildAvailabilityTile(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (_availability) {
      case DonorAvailability.available:
        statusColor = Colors.green;
        statusText = 'Available';
        statusIcon = Icons.check_circle;
        break;
      case DonorAvailability.unavailable:
        statusColor = Colors.red;
        statusText = 'Unavailable';
        statusIcon = Icons.cancel;
        break;
      case DonorAvailability.busy:
        statusColor = Colors.orange;
        statusText = 'Busy';
        statusIcon = Icons.schedule;
        break;
    }

    return ListTile(
      leading: Icon(statusIcon, color: statusColor),
      title: const Text('Donation Availability'),
      subtitle: Text(
        statusText,
        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
      ),
      trailing: PopupMenuButton<DonorAvailability>(
        icon: const Icon(Icons.arrow_drop_down),
        onSelected: (DonorAvailability value) async {
          setState(() {
            _availability = value;
          });
          await _updateAvailability(value);
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: DonorAvailability.available,
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                const Text('Available'),
              ],
            ),
          ),
          PopupMenuItem(
            value: DonorAvailability.busy,
            child: Row(
              children: [
                Icon(Icons.schedule, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                const Text('Busy'),
              ],
            ),
          ),
          PopupMenuItem(
            value: DonorAvailability.unavailable,
            child: Row(
              children: [
                Icon(Icons.cancel, color: Colors.red, size: 20),
                const SizedBox(width: 12),
                const Text('Unavailable'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAvailability(DonorAvailability availability) async {
    try {
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'availability': availability.toString().split('.').last,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Availability updated to ${availability.toString().split('.').last}',
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating availability: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 20,
                right: 20,
                top: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
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

                  // Title
                  Text(
                    'Edit Profile',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name field
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter your name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),

                  // Phone field
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      hintText: 'Enter your phone number',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),

                  // Blood Type section
                  Text(
                    'Blood Type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Blood type chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _bloodTypes.map((bloodType) {
                      final isSelected = _selectedBloodType == bloodType;
                      return ChoiceChip(
                        label: Text(
                          bloodType,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedBloodType = bloodType;
                          });
                        },
                        selectedColor: AppColors.bloodRed,
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _saveProfileChanges(context),
                      icon: const Icon(Icons.check),
                      label: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bloodRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
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
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.bloodRed, size: 28),
            const SizedBox(width: 12),
            const Text(
              'লগআউট করবেন?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'আপনি কি নিশ্চিত যে আপনি লগআউট করতে চান?\n\nলগআউট করলে আপনাকে আবার লগইন করতে হবে।',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'না, থাকবো',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bloodRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'হ্যাঁ, লগআউট করুন',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await fb_auth.FirebaseAuth.instance.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('সফলভাবে লগআউট হয়েছে'),
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('লগআউট করতে সমস্যা: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
