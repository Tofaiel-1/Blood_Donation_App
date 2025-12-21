import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user.dart' as app_user;
import '../../models/blood_request.dart';
import '../../utils/app_colors.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  final _auth = fb_auth.FirebaseAuth.instance;
  late TabController _tabController;
  String? _currentUserBloodType;
  String _selectedBloodFilter = 'All';
  String _searchQuery = '';
  String _selectedStatusFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  bool _showOnlyAvailable = true;

  final List<String> _bloodTypes = [
    'All',
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
    _tabController = TabController(length: 3, vsync: this);
    _loadCurrentUserBloodType();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserBloodType() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        setState(() {
          _currentUserBloodType = doc.data()?['bloodType'] ?? 'Unknown';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Blood Requests',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.bloodRed,
        ),
        body: _buildLoginPrompt(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Blood Requests',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.bloodRed,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Available Donors'),
            Tab(icon: Icon(Icons.send), text: 'My Requests'),
            Tab(icon: Icon(Icons.inbox), text: 'For Me'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableDonorsTab(uid),
          _buildMyRequestsTab(uid),
          _buildRequestsForMeTab(uid),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emergency Broadcast button
          FloatingActionButton(
            heroTag: 'emergency_broadcast',
            onPressed: () => _showEmergencyBroadcast(uid),
            backgroundColor: Colors.red[900],
            foregroundColor: Colors.white,
            mini: true,
            tooltip: 'Emergency Broadcast',
            child: const Icon(Icons.campaign),
          ),
          const SizedBox(height: 8),
          // New Request button
          FloatingActionButton.extended(
            heroTag: 'new_request',
            onPressed: () => _createNewBloodRequest(uid),
            backgroundColor: AppColors.bloodRed,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('New Request'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Please login to access blood requests',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Tab 1: Available Donors
  Widget _buildAvailableDonorsTab(String uid) {
    return Column(
      children: [
        // Search Bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search donors by name...',
              prefixIcon: const Icon(Icons.search, color: AppColors.bloodRed),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),

        // Filters Row
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Blood type filter
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _bloodTypes.map((bloodType) {
                      final isSelected = _selectedBloodFilter == bloodType;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            bloodType,
                            style: const TextStyle(fontSize: 12),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedBloodFilter = bloodType;
                            });
                          },
                          selectedColor: AppColors.bloodRed,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Available only toggle
              FilterChip(
                label: const Text('Available', style: TextStyle(fontSize: 11)),
                selected: _showOnlyAvailable,
                onSelected: (selected) {
                  setState(() {
                    _showOnlyAvailable = selected;
                  });
                },
                selectedColor: Colors.green[100],
                checkmarkColor: Colors.green[700],
              ),
            ],
          ),
        ),

        // Statistics Banner
        Container(
          color: AppColors.bloodRed.withValues(alpha: 0.05),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'user')
                .where('emailVerified', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              final totalDonors = snapshot.data?.docs.length ?? 0;
              final availableDonors =
                  snapshot.data?.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['availability']?.toString().contains(
                          'available',
                        ) ??
                        false;
                  }).length ??
                  0;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.people, '$totalDonors', 'Total Donors'),
                  _buildStatItem(
                    Icons.check_circle,
                    '$availableDonors',
                    'Available Now',
                  ),
                  _buildStatItem(
                    Icons.bloodtype,
                    _selectedBloodFilter,
                    'Filter',
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'user')
                .where('emailVerified', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              var donors = snapshot.data?.docs ?? [];

              // Filter by blood type
              if (_selectedBloodFilter != 'All') {
                donors = donors.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['bloodType'] == _selectedBloodFilter;
                }).toList();
              }

              // Filter by availability
              if (_showOnlyAvailable) {
                donors = donors.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final availabilityStr =
                      data['availability']?.toString() ?? 'available';
                  return availabilityStr.contains('available');
                }).toList();
              }

              // Filter by search query
              if (_searchQuery.isNotEmpty) {
                donors = donors.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();
              }

              // Filter out current user
              donors = donors.where((doc) => doc.id != uid).toList();

              // Sort by availability (available first), then by total donations
              donors.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;

                final aAvail = aData['availability']?.toString() ?? '';
                final bAvail = bData['availability']?.toString() ?? '';

                if (aAvail.contains('available') &&
                    !bAvail.contains('available'))
                  return -1;
                if (!aAvail.contains('available') &&
                    bAvail.contains('available'))
                  return 1;

                final aDonations = aData['totalDonations'] ?? 0;
                final bDonations = bData['totalDonations'] ?? 0;
                return bDonations.compareTo(aDonations);
              });

              if (donors.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No donors available',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: donors.length,
                itemBuilder: (context, index) {
                  final donorDoc = donors[index];
                  final data = donorDoc.data() as Map<String, dynamic>;
                  return _buildDonorCard(donorDoc.id, data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDonorCard(String donorId, Map<String, dynamic> data) {
    final name = data['name'] ?? 'Unknown';
    final bloodType = data['bloodType'] ?? '?';
    final phone = data['phone'] ?? 'Not provided';
    final availabilityStr = data['availability']?.toString() ?? 'available';
    final totalDonations = data['totalDonations'] ?? 0;
    final profileImageUrl = data['profileImageUrl'] as String?;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (availabilityStr.contains('available')) {
      statusColor = Colors.green;
      statusText = 'Available';
      statusIcon = Icons.check_circle;
    } else if (availabilityStr.contains('busy')) {
      statusColor = Colors.orange;
      statusText = 'Busy';
      statusIcon = Icons.schedule;
    } else {
      statusColor = Colors.red;
      statusText = 'Unavailable';
      statusIcon = Icons.cancel;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.bloodRed.withValues(alpha: 0.1),
              backgroundImage:
                  profileImageUrl != null && profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : null,
              child: profileImageUrl == null || profileImageUrl.isEmpty
                  ? Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.bloodRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(statusIcon, size: 12, color: Colors.white),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bloodRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bloodType,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text('📞 $phone', style: const TextStyle(fontSize: 12)),
            Text(
              '🩸 $totalDonations donations',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: statusText == 'Available'
              ? () => _sendBloodRequest(donorId, name, bloodType)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bloodRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Request'),
        ),
      ),
    );
  }

  // Tab 2: My Requests
  Widget _buildMyRequestsTab(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bloodRequests')
          .where('requestedBy', isEqualTo: uid)
          .orderBy('requestDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final requests = snapshot.data?.docs ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No blood requests sent yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a new request to find donors',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final requestDoc = requests[index];
            final request = BloodRequest.fromFirestore(requestDoc);
            return _buildRequestCard(request, isMyRequest: true);
          },
        );
      },
    );
  }

  // Tab 3: Requests for Me (matching my blood type)
  Widget _buildRequestsForMeTab(String uid) {
    if (_currentUserBloodType == null || _currentUserBloodType == 'Unknown') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bloodtype, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Please update your blood type',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bloodRequests')
          .where('bloodType', isEqualTo: _currentUserBloodType)
          .where('status', whereIn: ['pending', 'approved'])
          .orderBy('requestDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var requests = snapshot.data?.docs ?? [];

        // Filter out own requests
        requests = requests.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['requestedBy'] != uid;
        }).toList();

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No matching blood requests',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ll see requests for $_currentUserBloodType blood here',
                  style: TextStyle(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final requestDoc = requests[index];
            final request = BloodRequest.fromFirestore(requestDoc);
            return _buildRequestCard(
              request,
              isMyRequest: false,
              canRespond: true,
            );
          },
        );
      },
    );
  }

  Widget _buildRequestCard(
    BloodRequest request, {
    required bool isMyRequest,
    bool canRespond = false,
  }) {
    Color urgencyColor;
    String urgencyText;

    switch (request.urgency) {
      case UrgencyLevel.critical:
        urgencyColor = Colors.red;
        urgencyText = 'CRITICAL';
        break;
      case UrgencyLevel.urgent:
        urgencyColor = Colors.orange;
        urgencyText = 'URGENT';
        break;
      case UrgencyLevel.normal:
        urgencyColor = Colors.blue;
        urgencyText = 'NORMAL';
        break;
    }

    Color statusColor;
    String statusText;

    switch (request.status) {
      case RequestStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case RequestStatus.approved:
        statusColor = Colors.blue;
        statusText = 'Approved';
        break;
      case RequestStatus.fulfilled:
        statusColor = Colors.green;
        statusText = 'Fulfilled';
        break;
      case RequestStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: urgencyColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: urgencyColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    urgencyText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bloodRed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        request.bloodType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),

            // Patient info
            _buildInfoRow(Icons.person, 'Patient', request.patientName),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.local_hospital,
              'Hospital',
              request.hospitalName,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, 'Location', request.location),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, 'Contact', request.contactPhone),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.opacity,
              'Units',
              '${request.unitsNeeded} unit${request.unitsNeeded > 1 ? 's' : ''}',
            ),

            if (request.notes != null && request.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.note, 'Notes', request.notes!),
            ],

            const SizedBox(height: 8),
            Text(
              '📅 ${_formatDate(request.requestDate)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),

            // Actions
            if (canRespond && request.status == RequestStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _respondToRequest(request, true),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('I Can Help'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _respondToRequest(request, false),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Can\'t Help'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (isMyRequest && request.status == RequestStatus.pending) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _cancelRequest(request),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.bloodRed),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  // Action Methods

  void _sendBloodRequest(
    String donorId,
    String donorName,
    String bloodType,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _RequestFormDialog(bloodType: bloodType),
    );

    if (result == null) return;

    try {
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final currentUserData = currentUserDoc.data() ?? {};
      final currentUserName = currentUserData['name'] ?? 'Unknown';

      await FirebaseFirestore.instance.collection('bloodRequests').add({
        'bloodType': bloodType,
        'hospitalName': result['hospital'],
        'location': result['location'],
        'contactPhone': result['phone'],
        'patientName': result['patientName'],
        'unitsNeeded': result['units'] ?? 1,
        'urgency': result['urgency'],
        'status': 'pending',
        'requestedBy': uid,
        'requestedByName': currentUserName,
        'requestDate': FieldValue.serverTimestamp(),
        'notes': result['notes'],
        'targetDonorId': donorId,
        'targetDonorName': donorName,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Blood request sent successfully!')),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _createNewBloodRequest(String uid) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          _RequestFormDialog(bloodType: _currentUserBloodType ?? 'A+'),
    );

    if (result == null) return;

    try {
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final currentUserData = currentUserDoc.data() ?? {};
      final currentUserName = currentUserData['name'] ?? 'Unknown';

      await FirebaseFirestore.instance.collection('bloodRequests').add({
        'bloodType': result['bloodType'],
        'hospitalName': result['hospital'],
        'location': result['location'],
        'contactPhone': result['phone'],
        'patientName': result['patientName'],
        'unitsNeeded': result['units'] ?? 1,
        'urgency': result['urgency'],
        'status': 'pending',
        'requestedBy': uid,
        'requestedByName': currentUserName,
        'requestDate': FieldValue.serverTimestamp(),
        'notes': result['notes'],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Blood request created successfully!')),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _respondToRequest(BloodRequest request, bool canHelp) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(canHelp ? 'Confirm Donation' : 'Decline Request'),
        content: Text(
          canHelp
              ? 'Are you sure you want to help?\n\nPatient: ${request.patientName}\nHospital: ${request.hospitalName}'
              : 'Are you sure you cannot help?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: canHelp ? Colors.green : Colors.grey,
            ),
            child: Text(canHelp ? 'Confirm' : 'Decline'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (canHelp) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        final userData = userDoc.data() ?? {};

        await FirebaseFirestore.instance
            .collection('bloodRequests')
            .doc(request.id)
            .collection('responses')
            .add({
              'donorId': uid,
              'donorName': userData['name'] ?? 'Unknown',
              'donorPhone': userData['phone'] ?? 'Not provided',
              'responseDate': FieldValue.serverTimestamp(),
              'status': 'accepted',
            });

        await FirebaseFirestore.instance
            .collection('bloodRequests')
            .doc(request.id)
            .update({
              'status': 'approved',
              'approvedAt': FieldValue.serverTimestamp(),
            });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.favorite, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Thank you! Your response has been sent.'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _cancelRequest(BloodRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text('Are you sure you want to cancel this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('bloodRequests')
          .doc(request.id)
          .update({
            'status': 'cancelled',
            'cancelledAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request cancelled successfully'),
            backgroundColor: Colors.orange,
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

  // Helper Methods

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.bloodRed),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.bloodRed,
              ),
            ),
          ],
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    try {
      // Format phone number - remove any spaces or special characters
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

      // Create tel: URL
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

      // Launch phone app with external application mode (works offline)
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.phone, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('📞 Calling $cleanNumber...')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Call করতে সমস্যা: $phoneNumber')),
              ],
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'আবার চেষ্টা করুন',
              textColor: Colors.white,
              onPressed: () => _makePhoneCall(phoneNumber),
            ),
          ),
        );
      }
    }
  }

  void _sendSMS(String phoneNumber, String donorName) async {
    try {
      // Format phone number
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

      // Pre-filled message for blood donation request
      final message =
          'Hello $donorName, I urgently need blood donation. Can you help? - Blood Donation App';

      // Create SMS URL with pre-filled message
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: cleanNumber,
        queryParameters: {'body': message},
      );

      // Launch SMS app with external application mode (works offline)
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.sms, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(child: Text('💬 SMS app খুলছে...')),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Cannot open SMS app: $e')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEmergencyBroadcast(String uid) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.campaign, color: Colors.red[900]),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Emergency Broadcast',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Emergency Alert',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This will notify ALL donors matching your blood type requirement.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final formResult = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => _RequestFormDialog(
                  bloodType: _currentUserBloodType ?? 'A+',
                ),
              );
              if (formResult != null) {
                Navigator.pop(context, formResult);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[900],
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.campaign),
            label: const Text('Broadcast'),
          ),
        ],
      ),
    );

    if (result == null) return;

    try {
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final currentUserData = currentUserDoc.data() ?? {};
      final currentUserName = currentUserData['name'] ?? 'Unknown';

      await FirebaseFirestore.instance.collection('bloodRequests').add({
        'bloodType': result['bloodType'],
        'hospitalName': result['hospital'],
        'location': result['location'],
        'contactPhone': result['phone'],
        'patientName': result['patientName'],
        'unitsNeeded': result['units'] ?? 1,
        'urgency': 'critical',
        'status': 'pending',
        'requestedBy': uid,
        'requestedByName': currentUserName,
        'requestDate': FieldValue.serverTimestamp(),
        'notes': result['notes'],
        'isEmergencyBroadcast': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🚨 Emergency broadcast sent to all matching donors!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[900],
            duration: const Duration(seconds: 5),
          ),
        );
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error broadcasting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Request Form Dialog
class _RequestFormDialog extends StatefulWidget {
  final String bloodType;

  const _RequestFormDialog({required this.bloodType});

  @override
  State<_RequestFormDialog> createState() => _RequestFormDialogState();
}

class _RequestFormDialogState extends State<_RequestFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedBloodType = 'A+';
  int _units = 1;
  String _urgency = 'normal';

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
    _selectedBloodType = widget.bloodType;
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _hospitalController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Blood Request Form'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedBloodType,
                decoration: const InputDecoration(
                  labelText: 'Blood Type *',
                  prefixIcon: Icon(Icons.bloodtype),
                ),
                items: _bloodTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBloodType = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(
                  labelText: 'Patient Name *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hospitalController,
                decoration: const InputDecoration(
                  labelText: 'Hospital Name *',
                  prefixIcon: Icon(Icons.local_hospital),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone *',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.opacity, color: Colors.grey),
                  const SizedBox(width: 12),
                  const Text('Units needed:'),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      if (_units > 1) setState(() => _units--);
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_units', style: const TextStyle(fontSize: 18)),
                  IconButton(
                    onPressed: () {
                      setState(() => _units++);
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _urgency,
                decoration: const InputDecoration(
                  labelText: 'Urgency Level',
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: const [
                  DropdownMenuItem(value: 'normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                  DropdownMenuItem(value: 'critical', child: Text('Critical')),
                ],
                onChanged: (value) {
                  setState(() {
                    _urgency = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'bloodType': _selectedBloodType,
                'patientName': _patientNameController.text.trim(),
                'hospital': _hospitalController.text.trim(),
                'location': _locationController.text.trim(),
                'phone': _phoneController.text.trim(),
                'units': _units,
                'urgency': _urgency,
                'notes': _notesController.text.trim(),
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bloodRed,
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit Request'),
        ),
      ],
    );
  }
}
