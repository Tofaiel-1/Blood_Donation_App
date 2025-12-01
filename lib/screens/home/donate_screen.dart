import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/donation.dart';
import '../../models/blood_request.dart';
import '../../services/location_service.dart';
import '../../utils/app_colors.dart';

class DonateScreen extends StatefulWidget {
  final int initialTabIndex;

  const DonateScreen({super.key, this.initialTabIndex = 0});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  List<Donation> donationHistory = [];
  List<DonationCenter> donationCenters = [];
  bool canDonate = true;
  DateTime? nextEligibleDate;
  late TabController _tabController;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isLoadingData = true;
  String? _userId;

  // Checklist items state
  final Map<String, bool> _checklistItems = {
    'Eat a healthy meal 2-3 hours before donating': false,
    'Drink plenty of water': false,
    'Get a good night\'s sleep': false,
    'Bring a valid ID': false,
    'Avoid alcohol 24 hours before': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _selectedTabIndex = widget.initialTabIndex;
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
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

    _userId = user.uid;
    await Future.wait([_loadDonationHistory(), _loadDonationCenters()]);

    _checkEligibility();

    if (mounted) {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _loadDonationHistory() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('donations')
          .where('donorId', isEqualTo: _userId)
          .orderBy('donationDate', descending: true)
          .get();

      donationHistory = snapshot.docs.map((doc) {
        final data = doc.data();
        return Donation(
          id: doc.id,
          donorId: data['donorId'] ?? '',
          donorName: data['donorName'] ?? '',
          bloodType: data['bloodType'] ?? '',
          donationDate: (data['donationDate'] as Timestamp).toDate(),
          location: data['location'] ?? '',
          status: data['status'] ?? '',
          notes: data['notes'],
          // Recipient information
          recipientRequestId: data['recipientRequestId'],
          recipientPatientName: data['recipientPatientName'],
          recipientHospital: data['recipientHospital'],
          recipientBloodType: data['recipientBloodType'],
          recipientContactPhone: data['recipientContactPhone'],
        );
      }).toList();
    } catch (e) {
      // Print full error to debug console for index URL
      debugPrint('\n========== DONATION HISTORY ERROR ==========');
      debugPrint('Error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      if (e.toString().contains('index')) {
        debugPrint(
          '\nCOPY THE URL ABOVE AND PASTE IT IN YOUR BROWSER TO CREATE THE INDEX',
        );
      }
      debugPrint('==========================================\n');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading donation history - Check debug console',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadDonationCenters() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('donationCenters')
          .where('isActive', isEqualTo: true)
          .get();

      donationCenters = snapshot.docs.map((doc) {
        final data = doc.data();
        return DonationCenter(
          id: doc.id,
          name: data['name'] ?? '',
          address: data['address'] ?? '',
          latitude: (data['latitude'] ?? 0.0).toDouble(),
          longitude: (data['longitude'] ?? 0.0).toDouble(),
          phone: data['phone'] ?? '',
          operatingHours: List<String>.from(data['operatingHours'] ?? []),
          isActive: data['isActive'] ?? false,
        );
      }).toList();
    } catch (e) {
      // Print full error to debug console for index URL
      debugPrint('\n========== DONATION CENTERS ERROR ==========');
      debugPrint('Error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      if (e.toString().contains('index')) {
        debugPrint(
          '\nCOPY THE URL ABOVE AND PASTE IT IN YOUR BROWSER TO CREATE THE INDEX',
        );
      }
      debugPrint('==========================================\n');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading donation centers - Check debug console',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _checkEligibility() {
    if (donationHistory.isNotEmpty) {
      final lastDonation = donationHistory.first.donationDate;
      final daysSinceLastDonation = DateTime.now()
          .difference(lastDonation)
          .inDays;

      // Minimum 120 days between donations (4 months)
      if (daysSinceLastDonation < 120) {
        setState(() {
          canDonate = false;
          nextEligibleDate = lastDonation.add(Duration(days: 120));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Donate Blood',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.bloodRed,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Donate Blood',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.bloodRed,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => setState(() => _selectedTabIndex = index),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Schedule'),
            Tab(text: 'Complete'),
            Tab(text: 'History'),
            Tab(text: 'Centers'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          _buildScheduleTab(),
          _buildCompleteDonationTab(),
          _buildHistoryTab(),
          _buildCentersTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    // For Centers tab - show location button
    if (_selectedTabIndex == 3) {
      return FloatingActionButton.extended(
        onPressed: _getUserLocation,
        icon: _isLoadingLocation
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.my_location),
        label: Text(
          _currentPosition != null ? 'Location Updated' : 'Get My Location',
        ),
        backgroundColor: AppColors.bloodRed,
        foregroundColor: Colors.white,
      );
    }

    // For History tab - show manual donation add button
    if (_selectedTabIndex == 2) {
      return FloatingActionButton.extended(
        onPressed: _showManualDonationDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Donation'),
        backgroundColor: AppColors.bloodRed,
        foregroundColor: Colors.white,
      );
    }

    return null;
  }

  /// Show dialog to manually add a past donation
  Future<void> _showManualDonationDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _ManualDonationDialog(),
    );

    if (result != null && result['confirmed'] == true) {
      await _saveManualDonation(result);
    }
  }

  /// Save manual donation to Firebase
  Future<void> _saveManualDonation(Map<String, dynamic> data) async {
    try {
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get user profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data() ?? {};

      // Create donation record
      final donationData = {
        'donorId': user.uid,
        'donorName': userData['name'] ?? 'User',
        'bloodType': userData['bloodType'] ?? 'Unknown',
        'donationDate': Timestamp.fromDate(data['date'] as DateTime),
        'location': data['location'] as String,
        'status': 'completed',
        'notes': data['notes'] as String? ?? 'Added manually',
        'createdAt': FieldValue.serverTimestamp(),
        'isManualEntry': true, // Mark as manual entry
      };

      // Add to Firebase
      await FirebaseFirestore.instance
          .collection('donations')
          .add(donationData);

      // Update user's donation count
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'totalDonations': FieldValue.increment(1),
            'lastDonationDate': Timestamp.fromDate(data['date'] as DateTime),
          });

      // Reload history
      await _loadDonationHistory();
      _checkEligibility();

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Donation record added successfully!'),
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
            content: Text('Error adding donation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCompleteDonationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volunteer_activism,
                      color: Colors.green,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete Your Donation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Log your completed blood donation',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Total Donations: ${donationHistory.where((d) => d.status == 'completed').length}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'You have saved approximately ${donationHistory.where((d) => d.status == 'completed').length * 3} lives!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 30),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Log New Donation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select where you donated:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ...donationCenters.map(
                    (center) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(
                          Icons.location_on,
                          color: AppColors.bloodRed,
                        ),
                        title: Text(center.name),
                        subtitle: Text(center.address),
                        trailing: ElevatedButton(
                          onPressed: () => _completeDonation(center),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Complete'),
                        ),
                      ),
                    ),
                  ),
                  if (donationCenters.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No donation centers available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'After Donation Care',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildAfterCareItem('Rest for 10-15 minutes'),
                  _buildAfterCareItem('Drink plenty of fluids'),
                  _buildAfterCareItem('Eat a healthy snack'),
                  _buildAfterCareItem('Avoid heavy lifting for 24 hours'),
                  _buildAfterCareItem('Keep the bandage on for 4-6 hours'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAfterCareItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }

  Future<void> _completeDonation(DonationCenter center) async {
    // First check if user is eligible to donate (120 days rule)
    if (!canDonate) {
      final daysRemaining =
          nextEligibleDate?.difference(DateTime.now()).inDays ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'আপনি এখনও রক্তদান করতে পারবেন না। আরও $daysRemaining দিন অপেক্ষা করুন।',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Show dialog to select recipient (optional)
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _RecipientSelectionDialog(center: center),
    );

    if (result != null && result['confirmed'] == true) {
      await _saveDonation(
        center,
        recipient: result['recipient'] as BloodRequest?,
      );
    }
  }

  Future<void> _saveDonation(
    DonationCenter center, {
    BloodRequest? recipient,
  }) async {
    try {
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Get user profile for name and blood type
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data() ?? {};

      // Create donation data
      final donationData = {
        'donorId': user.uid,
        'donorName': userData['name'] ?? 'User',
        'bloodType': userData['bloodType'] ?? 'Unknown',
        'donationDate': Timestamp.fromDate(DateTime.now()),
        'location': center.name,
        'status': 'completed',
        'notes': 'Completed via app',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add recipient info if available
      if (recipient != null) {
        donationData['recipientRequestId'] = recipient.id;
        donationData['recipientPatientName'] = recipient.patientName;
        donationData['recipientHospital'] = recipient.hospitalName;
        donationData['recipientBloodType'] = recipient.bloodType;
        donationData['recipientContactPhone'] = recipient.contactPhone;
      }

      // Add donation to Firestore
      await FirebaseFirestore.instance
          .collection('donations')
          .add(donationData);

      // Update user's total donation count in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'totalDonations': FieldValue.increment(1),
            'lastDonationDate': Timestamp.fromDate(DateTime.now()),
          });

      // If there was a recipient, update the blood request status
      if (recipient != null) {
        await FirebaseFirestore.instance
            .collection('bloodRequests')
            .doc(recipient.id)
            .update({
              'status': 'fulfilled',
              'fulfilledDate': Timestamp.fromDate(DateTime.now()),
              'fulfilledByDonorId': user.uid,
              'fulfilledByDonorName': userData['name'] ?? 'User',
            });
      }

      // Reload donation history
      await _loadDonationHistory();

      if (mounted) {
        setState(() {});

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🎉 Donation Recorded!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        recipient != null
                            ? 'Donated to: ${recipient.patientName} at ${recipient.hospitalName}'
                            : 'Total donations: ${donationHistory.where((d) => d.status == "completed").length}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Show congratulations dialog
        _showCongratulationsDialog(
          donationHistory.where((d) => d.status == 'completed').length,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording donation: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showCongratulationsDialog(int totalDonations) {
    final livesImpacted = totalDonations * 3;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: Colors.green, size: 32),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Thank You!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You have completed',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              '$totalDonations',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.bloodRed,
              ),
            ),
            Text(
              totalDonations == 1 ? 'donation' : 'donations',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '💚 Lives Potentially Saved',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Up to $livesImpacted people',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your generosity makes a real difference!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Switch to history tab to see the new donation
              setState(() {
                _selectedTabIndex = 2;
                _tabController.animateTo(2);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bloodRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('View History'),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eligibility Card
          Card(
            color: canDonate ? Colors.green[50] : Colors.orange[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        canDonate ? Icons.check_circle : Icons.schedule,
                        color: canDonate ? Colors.green : Colors.orange,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        canDonate ? 'Eligible to Donate' : 'Not Eligible Yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: canDonate
                              ? Colors.green[800]
                              : Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    canDonate
                        ? 'You can donate blood now. Schedule your appointment!'
                        : 'Next eligible date: ${_formatDate(nextEligibleDate!)}',
                    style: TextStyle(
                      color: canDonate ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Pre-donation Checklist
          Text(
            'Pre-donation Checklist',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ..._checklistItems.entries.map(
            (entry) => _buildChecklistItem(entry.key, entry.value, () {
              setState(() {
                _checklistItems[entry.key] = !entry.value;
              });
            }),
          ),

          SizedBox(height: 30),

          // Schedule Appointment Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canDonate ? _scheduleAppointment : null,
              icon: Icon(Icons.calendar_today),
              label: Text('Schedule Appointment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
                disabledBackgroundColor: Colors.grey[300],
              ),
            ),
          ),

          if (!canDonate) ...[
            SizedBox(height: 16),
            Text(
              'You must wait at least 120 days (4 months) between blood donations for your safety.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          SizedBox(height: 30),

          // Benefits of Donating
          Text(
            'Benefits of Donating Blood',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildBenefitCard(
            icon: Icons.favorite,
            title: 'Save Lives',
            description: 'One donation can save up to 3 lives',
            color: Colors.red,
          ),
          _buildBenefitCard(
            icon: Icons.health_and_safety,
            title: 'Health Check',
            description: 'Free health screening with every donation',
            color: Colors.blue,
          ),
          _buildBenefitCard(
            icon: Icons.psychology,
            title: 'Feel Good',
            description: 'Experience the joy of helping others',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return donationHistory.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No donation history',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Your donation history will appear here',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: donationHistory.length,
            itemBuilder: (context, index) {
              final donation = donationHistory[index];
              return _buildHistoryCard(donation);
            },
          );
  }

  Widget _buildCentersTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: donationCenters.length,
      itemBuilder: (context, index) {
        final center = donationCenters[index];
        return _buildCenterCard(center);
      },
    );
  }

  Widget _buildChecklistItem(String text, bool isChecked, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isChecked ? Colors.green : Colors.grey,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isChecked ? Colors.green[800] : Colors.grey[700],
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(description, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Donation donation) {
    Color statusColor = donation.status == 'completed'
        ? Colors.green
        : Colors.orange;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(donation.donationDate),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    donation.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  donation.location,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            // Show recipient information if available
            if (donation.hasRecipient) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bloodRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.bloodRed.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: AppColors.bloodRed),
                        SizedBox(width: 6),
                        Text(
                          'রোগী: ${donation.recipientPatientName}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.bloodRed,
                          ),
                        ),
                      ],
                    ),
                    if (donation.recipientHospital != null) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.local_hospital,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              donation.recipientHospital!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (donation.recipientBloodType != null) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.bloodtype,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Blood Type: ${donation.recipientBloodType}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (donation.notes != null && !donation.hasRecipient) ...[
              SizedBox(height: 8),
              Text(
                donation.notes!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCenterCard(DonationCenter center) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    center.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: center.isActive
                        ? Colors.green[100]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    center.isActive ? 'Open' : 'Closed',
                    style: TextStyle(
                      color: center.isActive
                          ? Colors.green[800]
                          : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    center.address,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    center.operatingHours.join('\n'),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callCenter(center.phone),
                    icon: Icon(Icons.phone, size: 16),
                    label: Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red[700]!),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: center.isActive
                        ? () => _getDirections(center)
                        : null,
                    icon: Icon(Icons.directions, size: 16),
                    label: Text('Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _scheduleAppointment() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule Appointment',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Select a donation center:'),
            SizedBox(height: 10),
            ...donationCenters
                .where((c) => c.isActive)
                .map(
                  (center) => ListTile(
                    title: Text(center.name),
                    subtitle: Text(center.address),
                    leading: Icon(Icons.location_on),
                    onTap: () => _confirmAppointment(center),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _confirmAppointment(DonationCenter center) async {
    Navigator.pop(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Appointment'),
        content: Text('Schedule appointment at ${center.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _saveAppointment(center);
    }
  }

  Future<void> _saveAppointment(DonationCenter center) async {
    try {
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get user profile for name and blood type
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data() ?? {};

      await FirebaseFirestore.instance.collection('donations').add({
        'donorId': user.uid,
        'donorName': userData['name'] ?? 'User',
        'bloodType': userData['bloodType'] ?? 'Unknown',
        'donationDate': Timestamp.fromDate(
          DateTime.now().add(Duration(days: 7)),
        ),
        'location': center.name,
        'status': 'scheduled',
        'notes': 'Scheduled via app',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Reload donation history
      await _loadDonationHistory();

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment scheduled at ${center.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scheduling appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _callCenter(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  Future<void> _getUserLocation() async {
    if (_isLoadingLocation) return;

    setState(() => _isLoadingLocation = true);

    try {
      final position = await LocationService.getCurrentLocation();

      if (position != null) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Location updated! Tap directions to navigate.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Sort centers by distance
        _sortCentersByDistance();
      } else {
        setState(() => _isLoadingLocation = false);
        if (mounted) {
          _showLocationErrorDialog();
        }
      }
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sortCentersByDistance() {
    if (_currentPosition == null) return;

    donationCenters.sort((a, b) {
      final distanceA = LocationService.calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        a.latitude,
        a.longitude,
      );
      final distanceB = LocationService.calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        b.latitude,
        b.longitude,
      );
      return distanceA.compareTo(distanceB);
    });

    setState(() {});
  }

  void _showLocationErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs location permission to show directions to donation centers. Please enable location services in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await LocationService.openAppSettings();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.bloodRed),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _getDirections(DonationCenter center) async {
    try {
      // If we have current position, use it; otherwise use default coordinates
      final startLat = _currentPosition?.latitude ?? 22.3569;
      final startLng = _currentPosition?.longitude ?? 90.3294;

      // Google Maps URL scheme for directions
      final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&origin=$startLat,$startLng'
        '&destination=${center.latitude},${center.longitude}'
        '&travelmode=driving'
        '&dir_action=navigate',
      );

      // Try to launch Google Maps
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: Open in browser
        final Uri browserUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1'
          '&query=${center.latitude},${center.longitude}',
        );

        if (await canLaunchUrl(browserUrl)) {
          await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Could not open Maps. Please install Google Maps.',
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening maps: $e')));
      }
    }
  }
}

// Recipient Selection Dialog
class _RecipientSelectionDialog extends StatefulWidget {
  final DonationCenter center;

  const _RecipientSelectionDialog({required this.center});

  @override
  State<_RecipientSelectionDialog> createState() =>
      _RecipientSelectionDialogState();
}

class _RecipientSelectionDialogState extends State<_RecipientSelectionDialog> {
  List<BloodRequest> _pendingRequests = [];
  BloodRequest? _selectedRecipient;
  bool _isLoading = true;
  bool _skipRecipient = false;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bloodRequests')
          .where('status', whereIn: ['pending', 'approved'])
          .limit(10)
          .get();

      if (mounted) {
        setState(() {
          _pendingRequests = snapshot.docs
              .map((doc) => BloodRequest.fromFirestore(doc))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading pending requests: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.volunteer_activism, color: AppColors.bloodRed),
          const SizedBox(width: 12),
          const Text('রক্তদান নিশ্চিত করুন'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'আপনি ${widget.center.name} এ রক্ত দিয়েছেন?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Option to skip recipient selection
            CheckboxListTile(
              value: _skipRecipient,
              onChanged: (value) {
                setState(() {
                  _skipRecipient = value ?? false;
                  if (_skipRecipient) _selectedRecipient = null;
                });
              },
              title: const Text('সাধারণ রক্তদান (কোনো নির্দিষ্ট রোগী নেই)'),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),

            if (!_skipRecipient) ...[
              const Divider(),
              const Text(
                'অথবা কোন রোগীর জন্য রক্ত দিয়েছেন সিলেক্ট করুন:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_pendingRequests.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'কোনো পেন্ডিং রক্তের অনুরোধ নেই',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _pendingRequests.length,
                    itemBuilder: (context, index) {
                      final request = _pendingRequests[index];
                      final isSelected = _selectedRecipient?.id == request.id;

                      return Card(
                        color: isSelected
                            ? AppColors.bloodRed.withValues(alpha: 0.1)
                            : null,
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.bloodRed,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                request.bloodType,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          title: Text(request.patientName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(request.hospitalName),
                              Text(
                                request.urgency == UrgencyLevel.critical
                                    ? '🔴 CRITICAL'
                                    : request.urgency == UrgencyLevel.urgent
                                    ? '🟠 URGENT'
                                    : '🟢 Normal',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      request.urgency == UrgencyLevel.critical
                                      ? Colors.red
                                      : request.urgency == UrgencyLevel.urgent
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.bloodRed,
                                )
                              : const Icon(Icons.radio_button_unchecked),
                          onTap: () {
                            setState(() {
                              _selectedRecipient = request;
                              _skipRecipient = false;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, {'confirmed': false}),
          child: const Text('বাতিল'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'confirmed': true,
              'recipient': _skipRecipient ? null : _selectedRecipient,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('নিশ্চিত করুন'),
        ),
      ],
    );
  }
}

/// Dialog for manually adding a past donation
class _ManualDonationDialog extends StatefulWidget {
  const _ManualDonationDialog();

  @override
  State<_ManualDonationDialog> createState() => _ManualDonationDialogState();
}

class _ManualDonationDialogState extends State<_ManualDonationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final bool _isSubmitting = false;

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.bloodRed,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bloodRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_circle, color: AppColors.bloodRed),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Add Past Donation', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'আপনি যদি এই অ্যাপের বাইরে রক্তদান করে থাকেন, সেই তথ্য এখানে যোগ করুন।',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Date Picker
              const Text(
                'রক্তদানের তারিখ *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.bloodRed,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Location
              const Text(
                'স্থান / হাসপাতাল / ব্লাড ব্যাংক *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'যেমন: ঢাকা মেডিকেল কলেজ',
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: AppColors.bloodRed,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.bloodRed),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'দয়া করে স্থান লিখুন';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes (optional)
              const Text(
                'নোট (ঐচ্ছিক)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'কোনো বিশেষ মন্তব্য...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.note, color: Colors.grey),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'এই তথ্য আপনার donation history তে যোগ হবে এবং 120 দিনের নিয়ম প্রযোজ্য হবে।',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
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
          child: const Text('বাতিল'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      'confirmed': true,
                      'date': _selectedDate,
                      'location': _locationController.text.trim(),
                      'notes': _notesController.text.trim(),
                    });
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bloodRed,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('সংরক্ষণ করুন'),
        ),
      ],
    );
  }
}
