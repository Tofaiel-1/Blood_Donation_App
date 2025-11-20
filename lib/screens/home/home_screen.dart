import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../models/user.dart';
import '../../models/donation.dart';
import '../../widgets/themed_widgets.dart';
import '../../utils/app_colors.dart';
import '../chat/chatbot_screen.dart';

/// Redesigned HomeScreen with modern UI and themed widgets
class HomeScreen extends StatefulWidget {
  final User? user;
  final Function(int)? onNavigateToTab;
  const HomeScreen({super.key, this.user, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => false; // Don't keep alive to ensure fresh data

  final bool _alertsEnabled = true;
  int _totalDonations = 0;
  int _daysUntilNextDonation = 0;
  bool _isLoading = true;
  User? _cachedUser;

  @override
  void initState() {
    super.initState();
    _cachedUser = widget.user;
    _loadUserData();
    _loadDonationData();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes to foreground
      _loadUserData();
      _loadDonationData();
    }
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data if user changed or when returning to this screen
    if (oldWidget.user != widget.user) {
      _cachedUser = widget.user;
      _loadUserData();
      _loadDonationData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final currentFirebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (currentFirebaseUser != null) {
        final profile = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentFirebaseUser.uid)
            .get();

        if (profile.exists) {
          final data = profile.data() ?? {};
          setState(() {
            _cachedUser = User(
              email: currentFirebaseUser.email ?? data['email'] ?? '',
              name: data['name'] ?? currentFirebaseUser.displayName ?? '',
              bloodType: data['bloodType'] ?? 'Unknown',
              phone: data['phone'] ?? '',
              role: UserRole.user,
            );
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _loadDonationData() async {
    try {
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Fetch all completed donations for the current user
      final donationsSnapshot = await FirebaseFirestore.instance
          .collection('donations')
          .where('donorId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'completed')
          .get();

      final donations = donationsSnapshot.docs
          .map((doc) => Donation.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      // Sort by donation date to find the most recent
      donations.sort((a, b) => b.donationDate.compareTo(a.donationDate));

      final totalDonations = donations.length;
      int daysUntilNext = 0;

      if (donations.isNotEmpty) {
        final lastDonationDate = donations.first.donationDate;
        final nextEligibleDate = lastDonationDate.add(const Duration(days: 56));
        final now = DateTime.now();
        final difference = nextEligibleDate.difference(now).inDays;
        daysUntilNext = difference > 0 ? difference : 0;
      }

      setState(() {
        _totalDonations = totalDonations;
        _daysUntilNextDonation = daysUntilNext;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading donation data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final User currentUser =
        _cachedUser ??
        widget.user ??
        User(email: 'guest@example.com', name: 'Guest', bloodType: 'Unknown');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              child: Text(
                                currentUser.name.isNotEmpty
                                    ? currentUser.name[0].toUpperCase()
                                    : 'G',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome Back,',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                  ),
                                  Text(
                                    currentUser.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            BloodTypeBadge(
                              bloodType: currentUser.bloodType,
                              size: 50,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  _isLoading
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
                                value: _totalDonations.toString(),
                                label: 'Total\nDonations',
                                icon: Icons.bloodtype,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                value: _daysUntilNextDonation == 0
                                    ? 'Ready'
                                    : _daysUntilNextDonation.toString(),
                                label: _daysUntilNextDonation == 0
                                    ? 'You Can\nDonate Now'
                                    : 'Days Until\nNext Donation',
                                icon: Icons.calendar_today,
                                color: _daysUntilNextDonation == 0
                                    ? AppColors.hopeGreen
                                    : AppColors.lifeOrange,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 24),

                  // Emergency Requests Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Emergency Requests',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to all requests
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Emergency cards
                  EmergencyCard(
                    bloodType: 'B+',
                    hospital: 'City General Hospital',
                    urgency: 'URGENT',
                    onTap: () {
                      // Handle emergency tap
                      _showEmergencyDetails(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  EmergencyCard(
                    bloodType: 'O-',
                    hospital: 'Memorial Medical Center',
                    urgency: 'CRITICAL',
                    onTap: () {
                      _showEmergencyDetails(context);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildQuickAction(
                        context,
                        Icons.search,
                        'Find Donors',
                        AppColors.trustBlue,
                        () => widget.onNavigateToTab?.call(1),
                      ),
                      _buildQuickAction(
                        context,
                        Icons.event,
                        'Book Appointment',
                        AppColors.lifeOrange,
                        () => widget.onNavigateToTab?.call(2),
                      ),
                      _buildQuickAction(
                        context,
                        Icons.history,
                        'My Donations',
                        AppColors.hopeGreen,
                        () => widget.onNavigateToTab?.call(4),
                      ),
                      _buildQuickAction(
                        context,
                        Icons.message,
                        'Messages',
                        AppColors.bloodRed,
                        () => widget.onNavigateToTab?.call(3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Info banner
                  if (_alertsEnabled && !_isLoading)
                    InfoBanner(
                      message: _daysUntilNextDonation == 0
                          ? 'You are eligible to donate blood now!'
                          : 'Your next donation eligibility date is in $_daysUntilNextDonation days',
                      type: _daysUntilNextDonation == 0
                          ? BannerType.success
                          : BannerType.info,
                      onDismiss: () {
                        setState(() {
                          // Handle dismiss
                        });
                      },
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home_chatbot_fab',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.smart_toy, color: Colors.white),
        label: const Text(
          'AI Assistant',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmergencyDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
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
                Row(
                  children: [
                    const BloodTypeBadge(bloodType: 'B+', size: 60),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency Request',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          const StatusChip(
                            label: 'URGENT',
                            type: StatusType.busy,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow(Icons.local_hospital, 'City General Hospital'),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.location_on, '123 Main St, City'),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.phone, '+1 234 567 8900'),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.access_time, 'Posted 2 hours ago'),
                const SizedBox(height: 24),
                const Text(
                  'A critical patient needs B+ blood urgently for surgery. The operation is scheduled for tomorrow morning.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  text: 'I Can Help',
                  icon: Icons.volunteer_activism,
                  isFullWidth: true,
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Request received! Hospital will contact you soon.',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.hopeGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}
