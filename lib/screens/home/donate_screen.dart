import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/donation.dart';
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
      length: 3,
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
        );
      }).toList();
    } catch (e) {
      // Print full error to debug console for index URL
      print('\n========== DONATION HISTORY ERROR ==========');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      if (e.toString().contains('index')) {
        print(
          '\nCOPY THE URL ABOVE AND PASTE IT IN YOUR BROWSER TO CREATE THE INDEX',
        );
      }
      print('==========================================\n');

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
      print('\n========== DONATION CENTERS ERROR ==========');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      if (e.toString().contains('index')) {
        print(
          '\nCOPY THE URL ABOVE AND PASTE IT IN YOUR BROWSER TO CREATE THE INDEX',
        );
      }
      print('==========================================\n');

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

      // Minimum 56 days between donations
      if (daysSinceLastDonation < 56) {
        setState(() {
          canDonate = false;
          nextEligibleDate = lastDonation.add(Duration(days: 56));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
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
            Tab(text: 'History'),
            Tab(text: 'Centers'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [_buildScheduleTab(), _buildHistoryTab(), _buildCentersTab()],
      ),
      floatingActionButton: _selectedTabIndex == 2
          ? FloatingActionButton.extended(
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
                _currentPosition != null
                    ? 'Location Updated'
                    : 'Get My Location',
              ),
              backgroundColor: AppColors.bloodRed,
              foregroundColor: Colors.white,
            )
          : null,
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
              'You must wait at least 56 days between blood donations for your safety.',
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
            if (donation.notes != null) ...[
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
