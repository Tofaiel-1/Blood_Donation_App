import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../models/user.dart';
import '../../models/donation.dart';
import '../../models/blood_request.dart';
import '../../widgets/themed_widgets.dart';
import '../../widgets/notice_bar.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive.dart';
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
  int _livesSaved = 0; // 1 donation = 1 life saved
  int _daysUntilNextDonation = 0;
  bool _isLoading = true;
  User? _cachedUser;
  List<BloodRequest> _bloodRequests = [];

  @override
  void initState() {
    super.initState();
    _cachedUser = widget.user;
    _ensureUserDataExists(); // Ensure Firebase has user data
    _loadUserData();
    _loadDonationData();
    _loadBloodRequests();
    WidgetsBinding.instance.addObserver(this);
  }

  /// Ensure user document has required fields
  Future<void> _ensureUserDataExists() async {
    try {
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() ?? {};

        // Check if essential fields are missing
        final updates = <String, dynamic>{};

        if (!data.containsKey('totalDonations')) {
          updates['totalDonations'] = 0;
          debugPrint('Setting initial totalDonations to 0');
        }
        if (!data.containsKey('livesSaved')) {
          updates['livesSaved'] = data['totalDonations'] ?? 0;
          debugPrint('Setting initial livesSaved to 0');
        }
        if (!data.containsKey('name') ||
            (data['name'] as String?)?.isEmpty == true) {
          updates['name'] =
              currentUser.displayName ??
              currentUser.email?.split('@')[0] ??
              'User';
        }
        if (!data.containsKey('bloodType')) {
          updates['bloodType'] = 'Unknown';
        }

        // Update if needed
        if (updates.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .update(updates);
          debugPrint(
            '✅ Updated user document with missing fields: ${updates.keys.join(", ")}',
          );
        }
      } else {
        // User document doesn't exist - create it
        debugPrint('⚠️ User document not found, creating new one');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({
              'email': currentUser.email ?? '',
              'name':
                  currentUser.displayName ??
                  currentUser.email?.split('@')[0] ??
                  'User',
              'bloodType': 'Unknown',
              'totalDonations': 0,
              'livesSaved': 0,
              'role': 'user',
              'isActive': true,
              'createdAt': FieldValue.serverTimestamp(),
            });
        debugPrint('✅ Created new user document with initial values');
      }
    } catch (e) {
      debugPrint('❌ Error ensuring user data: $e');
    }
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
      _loadBloodRequests();
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

          if (mounted) {
            setState(() {
              _cachedUser = User(
                email: currentFirebaseUser.email ?? data['email'] ?? '',
                name: data['name'] ?? currentFirebaseUser.displayName ?? 'User',
                bloodType: data['bloodType'] ?? 'Unknown',
                phone: data['phone'] ?? '',
                role: UserRole.user,
                totalDonations: data['totalDonations'] ?? 0,
                livesSaved: data['livesSaved'] ?? data['totalDonations'] ?? 0,
              );

              // Also update stats from user document
              _totalDonations = data['totalDonations'] ?? 0;
              _livesSaved = data['livesSaved'] ?? data['totalDonations'] ?? 0;
            });
          }
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
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // First, load from user document (primary source)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          // Get stats from user document
          final totalFromUser = userData['totalDonations'] ?? 0;
          final livesFromUser = userData['livesSaved'] ?? totalFromUser;

          // Calculate days until next donation
          int daysUntilNext = 0;
          if (userData['lastDonationDate'] != null) {
            final lastDonationDate = (userData['lastDonationDate'] as Timestamp)
                .toDate();
            final nextEligibleDate = lastDonationDate.add(
              const Duration(days: 120),
            );
            final now = DateTime.now();
            final difference = nextEligibleDate.difference(now).inDays;
            daysUntilNext = difference > 0 ? difference : 0;
          }

          if (mounted) {
            setState(() {
              _totalDonations = totalFromUser;
              _livesSaved = livesFromUser;
              _daysUntilNextDonation = daysUntilNext;
              _isLoading = false;
            });
          }
          return;
        }
      }

      // Fallback: Fetch from donations collection if user doc doesn't have data
      final donationsSnapshot = await FirebaseFirestore.instance
          .collection('donations')
          .where('donorId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'completed')
          .get();

      final donations = donationsSnapshot.docs
          .map((doc) => Donation.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      donations.sort((a, b) => b.donationDate.compareTo(a.donationDate));

      final totalDonations = donations.length;
      int daysUntilNext = 0;

      if (donations.isNotEmpty) {
        final lastDonationDate = donations.first.donationDate;
        final nextEligibleDate = lastDonationDate.add(
          const Duration(days: 120),
        );
        final now = DateTime.now();
        final difference = nextEligibleDate.difference(now).inDays;
        daysUntilNext = difference > 0 ? difference : 0;
      }

      if (mounted) {
        setState(() {
          _totalDonations = totalDonations;
          _livesSaved = totalDonations; // 1 donation = 1 life saved
          _daysUntilNextDonation = daysUntilNext;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading donation data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadBloodRequests() async {
    try {
      // Fetch pending/approved blood requests (active requests)
      final snapshot = await FirebaseFirestore.instance
          .collection('bloodRequests')
          .where('status', whereIn: ['pending', 'approved'])
          .orderBy('requestDate', descending: true)
          .limit(5)
          .get();

      if (mounted) {
        setState(() {
          _bloodRequests = snapshot.docs
              .map((doc) => BloodRequest.fromFirestore(doc))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading blood requests: $e');
      // Try without ordering if index issue
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('bloodRequests')
            .where('status', whereIn: ['pending', 'approved'])
            .limit(5)
            .get();

        if (mounted) {
          setState(() {
            _bloodRequests = snapshot.docs
                .map((doc) => BloodRequest.fromFirestore(doc))
                .toList();
          });
        }
      } catch (e2) {
        debugPrint('Error loading blood requests (fallback): $e2');
      }
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
            expandedHeight: Responsive.isMobile(context) ? 160 : 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: Responsive.responsivePadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: Responsive.isMobile(context) ? 24 : 30,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.3,
                              ),
                              child: Text(
                                currentUser.name.isNotEmpty
                                    ? currentUser.name[0].toUpperCase()
                                    : 'G',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Responsive.responsiveTextSize(
                                    context,
                                    mobile: 18.0,
                                    tablet: 22.0,
                                    desktop: 24.0,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: Responsive.responsiveSpacing(context),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome Back,',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                          fontSize:
                                              Responsive.responsiveTextSize(
                                                context,
                                                mobile: 12.0,
                                                tablet: 14.0,
                                                desktop: 16.0,
                                              ),
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    currentUser.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              Responsive.responsiveTextSize(
                                                context,
                                                mobile: 18.0,
                                                tablet: 22.0,
                                                desktop: 24.0,
                                              ),
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            BloodTypeBadge(
                              bloodType: currentUser.bloodType,
                              size: Responsive.isMobile(context) ? 40.0 : 50.0,
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
              padding: Responsive.responsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notice Bar - Shows broadcast alerts from admin
                  const NoticeBar(),

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
                                label: Responsive.isMobile(context)
                                    ? 'Donations'
                                    : 'Total\nDonations',
                                icon: Icons.bloodtype,
                              ),
                            ),
                            SizedBox(
                              width:
                                  Responsive.responsiveSpacing(context) * 0.5,
                            ),
                            Expanded(
                              child: StatCard(
                                value: _livesSaved.toString(),
                                label: Responsive.isMobile(context)
                                    ? 'Lives'
                                    : 'Lives\nSaved',
                                icon: Icons.favorite,
                                color: AppColors.urgentRed,
                              ),
                            ),
                            SizedBox(
                              width:
                                  Responsive.responsiveSpacing(context) * 0.5,
                            ),
                            Expanded(
                              child: StatCard(
                                value: _daysUntilNextDonation == 0
                                    ? 'Ready'
                                    : _daysUntilNextDonation.toString(),
                                label: _daysUntilNextDonation == 0
                                    ? (Responsive.isMobile(context)
                                          ? 'Ready'
                                          : 'You Can\nDonate Now')
                                    : (Responsive.isMobile(context)
                                          ? 'Days Left'
                                          : 'Days Until\nNext Donation'),
                                icon: Icons.calendar_today,
                                color: _daysUntilNextDonation == 0
                                    ? AppColors.hopeGreen
                                    : AppColors.lifeOrange,
                              ),
                            ),
                          ],
                        ),
                  SizedBox(height: Responsive.responsiveSpacing(context)),

                  // Emergency Requests Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Blood Requests',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: Responsive.responsiveTextSize(
                            context,
                            mobile: 18.0,
                            tablet: 20.0,
                            desktop: 22.0,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to all requests
                          widget.onNavigateToTab?.call(1);
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            fontSize: Responsive.responsiveTextSize(
                              context,
                              mobile: 12.0,
                              tablet: 14.0,
                              desktop: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Blood request cards from Firebase
                  if (_bloodRequests.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 48,
                                color: Colors.green[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No pending blood requests',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'All blood needs are currently met!',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...(_bloodRequests.take(3).map((request) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EmergencyCard(
                          bloodType: request.bloodType,
                          hospital: request.hospitalName,
                          urgency: request.urgency == UrgencyLevel.critical
                              ? 'CRITICAL'
                              : request.urgency == UrgencyLevel.urgent
                              ? 'URGENT'
                              : 'NORMAL',
                          onTap: () =>
                              _showBloodRequestDetails(context, request),
                        ),
                      );
                    })),
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
                        Icons.add_circle,
                        'Add Donation',
                        AppColors.urgentRed,
                        _showAddDonationDialog,
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

  void _showBloodRequestDetails(BuildContext context, BloodRequest request) {
    final timeSinceRequest = DateTime.now().difference(request.requestDate);
    String timeAgo;
    if (timeSinceRequest.inDays > 0) {
      timeAgo = '${timeSinceRequest.inDays} days ago';
    } else if (timeSinceRequest.inHours > 0) {
      timeAgo = '${timeSinceRequest.inHours} hours ago';
    } else {
      timeAgo = '${timeSinceRequest.inMinutes} minutes ago';
    }

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
                    BloodTypeBadge(bloodType: request.bloodType, size: 60),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Blood Request',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          StatusChip(
                            label: request.urgency == UrgencyLevel.critical
                                ? 'CRITICAL'
                                : request.urgency == UrgencyLevel.urgent
                                ? 'URGENT'
                                : 'NORMAL',
                            type: request.urgency == UrgencyLevel.critical
                                ? StatusType.busy
                                : request.urgency == UrgencyLevel.urgent
                                ? StatusType.busy
                                : StatusType.available,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow(
                  Icons.person,
                  'Patient: ${request.patientName}',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.local_hospital, request.hospitalName),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.location_on, request.location),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.phone, request.contactPhone),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.bloodtype,
                  '${request.unitsNeeded} unit(s) needed',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.access_time, 'Posted $timeAgo'),
                if (request.notes != null && request.notes!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    request.notes!,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
                const SizedBox(height: 32),
                GradientButton(
                  text: _daysUntilNextDonation == 0
                      ? 'I Can Help'
                      : 'Not Eligible Yet',
                  icon: Icons.volunteer_activism,
                  isFullWidth: true,
                  onPressed: _daysUntilNextDonation == 0
                      ? () => _volunteerToDonate(context, request)
                      : null,
                ),
                if (_daysUntilNextDonation > 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    'You can donate again in $_daysUntilNextDonation days',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show dialog to add manual donation
  Future<void> _showAddDonationDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          _AddDonationDialog(daysUntilNextDonation: _daysUntilNextDonation),
    );

    if (result != null && result['confirmed'] == true) {
      await _saveManualDonation(result);
    }
  }

  /// Save manual donation to Firebase
  Future<void> _saveManualDonation(Map<String, dynamic> data) async {
    try {
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Get user profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final userData = userDoc.data() ?? {};

      // Create donation record
      final donationData = {
        'donorId': currentUser.uid,
        'donorName': userData['name'] ?? 'User',
        'bloodType': userData['bloodType'] ?? 'Unknown',
        'donationDate': Timestamp.fromDate(data['date'] as DateTime),
        'location': data['location'] as String,
        'status': 'completed',
        'notes': data['notes'] as String? ?? 'Added manually',
        'createdAt': FieldValue.serverTimestamp(),
        'isManualEntry': true,
        'canEditByUser': false, // User cannot edit, only admin can
        'createdBy': currentUser.uid,
        'createdByRole': userData['role'] ?? 'user',
      };

      // Add recipient info if provided
      if (data['recipientName'] != null &&
          (data['recipientName'] as String).isNotEmpty) {
        donationData['recipientPatientName'] = data['recipientName'];
        donationData['recipientHospital'] = data['recipientHospital'] ?? '';
      }

      // Add to Firebase
      await FirebaseFirestore.instance
          .collection('donations')
          .add(donationData);

      // Update user's donation count and lives saved
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
            'totalDonations': FieldValue.increment(1),
            'livesSaved': FieldValue.increment(1), // 1 donation = 1 life saved
            'lastDonationDate': Timestamp.fromDate(data['date'] as DateTime),
          });

      // Reload data
      await _loadDonationData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      '✅ Donation added successfully!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total donations: $_totalDonations | Lives saved: $_livesSaved',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  'Next eligible in: $_daysUntilNextDonation days',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _volunteerToDonate(
    BuildContext context,
    BloodRequest request,
  ) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    navigator.pop();

    try {
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Record the user's intent to donate for this request
      await FirebaseFirestore.instance.collection('donationVolunteers').add({
        'requestId': request.id,
        'donorId': currentUser.uid,
        'bloodType': _cachedUser?.bloodType ?? 'Unknown',
        'donorName': _cachedUser?.name ?? 'User',
        'donorPhone': _cachedUser?.phone ?? '',
        'status': 'volunteered',
        'createdAt': FieldValue.serverTimestamp(),
      });

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'আপনার সাহায্যের জন্য ধন্যবাদ! ${request.hospitalName} আপনার সাথে শীঘ্রই যোগাযোগ করবে।',
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
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

/// Dialog for adding manual donation
class _AddDonationDialog extends StatefulWidget {
  final int daysUntilNextDonation;

  const _AddDonationDialog({required this.daysUntilNextDonation});

  @override
  State<_AddDonationDialog> createState() => _AddDonationDialogState();
}

class _AddDonationDialogState extends State<_AddDonationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientHospitalController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    _recipientNameController.dispose();
    _recipientHospitalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      helpText: 'Select Donation Date',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _canAddDonation() {
    // Check if selected date respects 120-day rule
    if (widget.daysUntilNextDonation > 0) {
      final daysSinceSelected = DateTime.now().difference(_selectedDate).inDays;
      final daysFromLastToSelected =
          120 - widget.daysUntilNextDonation - daysSinceSelected;
      return daysFromLastToSelected >= 120;
    }
    return true; // No previous donation or already eligible
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = _canAddDonation();

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.bloodtype, color: AppColors.bloodRed),
          const SizedBox(width: 12),
          const Text('Add Blood Donation'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.daysUntilNextDonation > 0) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'আপনার পরবর্তী donation ${widget.daysUntilNextDonation} দিন পরে। Previous donation ছাড়া নতুন donation add করতে পারবেন না।',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'Donation Date *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDate(_selectedDate)),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              if (!canAdd) ...[
                const SizedBox(height: 8),
                Text(
                  '⚠️ এই তারিখটি 120 দিনের নিয়ম মানে না',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Location *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'e.g., Dhaka Medical College',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Recipient Name (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _recipientNameController,
                decoration: InputDecoration(
                  hintText: 'কাকে দিয়েছেন',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hospital/Center (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _recipientHospitalController,
                decoration: InputDecoration(
                  hintText: 'কোথায় দিয়েছেন',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.local_hospital),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Notes (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Additional information...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Important:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• এই donation আপনার history তে যোগ হবে\n'
                      '• 120 দিনের নিয়ম প্রযোজ্য হবে\n'
                      '• Previous donation add করতে পারবেন (120 days আগের)',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting || !canAdd
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      'confirmed': true,
                      'date': _selectedDate,
                      'location': _locationController.text.trim(),
                      'notes': _notesController.text.trim(),
                      'recipientName': _recipientNameController.text.trim(),
                      'recipientHospital': _recipientHospitalController.text
                          .trim(),
                    });
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: canAdd ? AppColors.bloodRed : Colors.grey,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Donation'),
        ),
      ],
    );
  }
}
