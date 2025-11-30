import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../models/blood_request.dart';
import '../../utils/app_colors.dart';

class OrgAdminScreen extends StatefulWidget {
  const OrgAdminScreen({super.key});

  @override
  State<OrgAdminScreen> createState() => _OrgAdminScreenState();
}

class _OrgAdminScreenState extends State<OrgAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _adminId;
  String? _adminName;
  String? _organization;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAdminInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminInfo() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _adminId = user.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _adminName = data['name'] ?? 'Admin';
        _organization = data['organization'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Dashboard'),
            if (_organization != null)
              Text(_organization!, style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: AppColors.bloodRed,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.bloodtype), text: 'Requests'),
            Tab(icon: Icon(Icons.people), text: 'Donors'),
            Tab(icon: Icon(Icons.analytics), text: 'Stats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildRequestsTab(), _buildDonorsTab(), _buildStatsTab()],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _showAddRequestDialog,
              icon: const Icon(Icons.add),
              label: const Text('New Request'),
              backgroundColor: AppColors.bloodRed,
            )
          : null,
    );
  }

  // ==================== REQUESTS TAB ====================
  Widget _buildRequestsTab() {
    if (_adminId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                onSelected: (v) => setState(() {}),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Pending'),
                onSelected: (v) => setState(() {}),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Approved'),
                onSelected: (v) => setState(() {}),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Fulfilled'),
                onSelected: (v) => setState(() {}),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bloodRequests')
                .where('assignedAdminId', isEqualTo: _adminId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final docs = snapshot.data?.docs ?? [];
              // Sort client-side to avoid composite index requirement
              docs.sort((a, b) {
                final aDate =
                    (a.data() as Map<String, dynamic>)['requestDate']
                        as Timestamp?;
                final bDate =
                    (b.data() as Map<String, dynamic>)['requestDate']
                        as Timestamp?;
                if (aDate == null && bDate == null) return 0;
                if (aDate == null) return 1;
                if (bDate == null) return -1;
                return bDate.compareTo(aDate); // descending
              });

              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bloodtype_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No blood requests assigned',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Requests will appear here when assigned',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final request = BloodRequest.fromFirestore(docs[index]);
                  return _buildRequestCard(request);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(BloodRequest request) {
    Color urgencyColor;
    switch (request.urgency) {
      case UrgencyLevel.critical:
        urgencyColor = Colors.red;
        break;
      case UrgencyLevel.urgent:
        urgencyColor = Colors.orange;
        break;
      default:
        urgencyColor = Colors.blue;
    }

    Color statusColor;
    IconData statusIcon;
    switch (request.status) {
      case RequestStatus.fulfilled:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case RequestStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case RequestStatus.approved:
        statusColor = Colors.blue;
        statusIcon = Icons.verified;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: urgencyColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                request.bloodType,
                style: TextStyle(
                  color: urgencyColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${request.unitsNeeded}U',
                style: TextStyle(color: urgencyColor, fontSize: 10),
              ),
            ],
          ),
        ),
        title: Text(
          request.patientName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.hospitalName,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    request.location,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(statusIcon, color: statusColor, size: 24),
            const SizedBox(height: 4),
            Text(
              request.status.name.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Contact', request.contactPhone, Icons.phone),
                _buildDetailRow(
                  'Requested by',
                  request.requestedByName,
                  Icons.person,
                ),
                _buildDetailRow(
                  'Date',
                  _formatDate(request.requestDate),
                  Icons.calendar_today,
                ),
                _buildDetailRow(
                  'Urgency',
                  request.urgency.name.toUpperCase(),
                  Icons.priority_high,
                  textColor: urgencyColor,
                ),
                if (request.notes != null && request.notes!.isNotEmpty)
                  _buildDetailRow('Notes', request.notes!, Icons.notes),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (request.status == RequestStatus.pending) ...[
                      OutlinedButton.icon(
                        onPressed: () => _updateRequestStatus(
                          request.id,
                          RequestStatus.cancelled,
                        ),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _updateRequestStatus(
                          request.id,
                          RequestStatus.approved,
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ] else if (request.status == RequestStatus.approved) ...[
                      ElevatedButton.icon(
                        onPressed: () => _updateRequestStatus(
                          request.id,
                          RequestStatus.fulfilled,
                        ),
                        icon: const Icon(Icons.done_all, size: 18),
                        label: const Text('Mark Fulfilled'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bloodRed,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showEditRequestDialog(request),
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor ?? Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DONORS TAB ====================
  Widget _buildDonorsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final donors = snapshot.data?.docs ?? [];

        if (donors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No donors registered yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // Group by blood type
        final bloodTypeGroups = <String, List<QueryDocumentSnapshot>>{};
        for (var doc in donors) {
          final data = doc.data() as Map<String, dynamic>;
          final bloodType = data['bloodType'] ?? 'Unknown';
          bloodTypeGroups.putIfAbsent(bloodType, () => []).add(doc);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: bloodTypeGroups.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.bloodRed,
                  child: Text(
                    entry.key,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                title: Text(
                  'Blood Type ${entry.key}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${entry.value.length} donors'),
                children: entry.value.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text((data['name'] ?? 'U')[0].toUpperCase()),
                    ),
                    title: Text(data['name'] ?? 'Unknown'),
                    subtitle: Text(data['email'] ?? ''),
                    trailing: data['phone'] != null
                        ? IconButton(
                            icon: const Icon(Icons.phone),
                            onPressed: () {
                              // TODO: Implement call functionality
                            },
                          )
                        : null,
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ==================== STATS TAB ====================
  Widget _buildStatsTab() {
    if (_adminId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bloodRequests')
          .where('assignedAdminId', isEqualTo: _adminId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data?.docs ?? [];
        final totalRequests = requests.length;
        final pending = requests
            .where((d) => (d.data() as Map)['status'] == 'pending')
            .length;
        final approved = requests
            .where((d) => (d.data() as Map)['status'] == 'approved')
            .length;
        final fulfilled = requests
            .where((d) => (d.data() as Map)['status'] == 'fulfilled')
            .length;
        final cancelled = requests
            .where((d) => (d.data() as Map)['status'] == 'cancelled')
            .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Performance',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _buildStatCard(
                    'Total Requests',
                    totalRequests.toString(),
                    Icons.all_inbox,
                    AppColors.bloodRed,
                  ),
                  _buildStatCard(
                    'Pending',
                    pending.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Approved',
                    approved.toString(),
                    Icons.verified,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Fulfilled',
                    fulfilled.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Cancelled',
                    cancelled.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                  _buildStatCard(
                    'Success Rate',
                    totalRequests > 0
                        ? '${((fulfilled / totalRequests) * 100).toStringAsFixed(1)}%'
                        : '0%',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Activity',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...requests.take(5).map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final date = (data['requestDate'] as Timestamp?)?.toDate();
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.bloodRed.withValues(alpha: 0.1),
                    child: Text(
                      data['bloodType'] ?? '?',
                      style: TextStyle(
                        color: AppColors.bloodRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(data['patientName'] ?? 'Unknown'),
                  subtitle: Text(data['hospitalName'] ?? ''),
                  trailing: Text(
                    date != null ? _formatDate(date) : '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DIALOGS ====================
  Future<void> _showAddRequestDialog() async {
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    String? selectedBloodType;
    final patientController = TextEditingController();
    final hospitalController = TextEditingController();
    final locationController = TextEditingController();
    final phoneController = TextEditingController();
    final unitsController = TextEditingController(text: '1');
    final notesController = TextEditingController();
    UrgencyLevel urgency = UrgencyLevel.urgent;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Blood Request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedBloodType,
                  decoration: const InputDecoration(
                    labelText: 'Blood Type *',
                    border: OutlineInputBorder(),
                  ),
                  items: bloodTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) =>
                      setDialogState(() => selectedBloodType = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: patientController,
                  decoration: const InputDecoration(
                    labelText: 'Patient Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hospitalController,
                  decoration: const InputDecoration(
                    labelText: 'Hospital Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Phone *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: unitsController,
                  decoration: const InputDecoration(
                    labelText: 'Units Needed *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UrgencyLevel>(
                  value: urgency,
                  decoration: const InputDecoration(
                    labelText: 'Urgency Level',
                    border: OutlineInputBorder(),
                  ),
                  items: UrgencyLevel.values.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => urgency = value!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedBloodType == null ||
                    patientController.text.isEmpty ||
                    hospitalController.text.isEmpty ||
                    locationController.text.isEmpty ||
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please fill all required fields (marked with *)',
                      ),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                final units = int.tryParse(unitsController.text) ?? 0;
                if (units < 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Units needed must be at least 1'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                await _createBloodRequest(
                  bloodType: selectedBloodType!,
                  patientName: patientController.text,
                  hospitalName: hospitalController.text,
                  location: locationController.text,
                  contactPhone: phoneController.text,
                  unitsNeeded: int.tryParse(unitsController.text) ?? 1,
                  urgency: urgency,
                  notes: notesController.text,
                );
              },
              child: const Text('Create Request'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBloodRequest({
    required String bloodType,
    required String patientName,
    required String hospitalName,
    required String location,
    required String contactPhone,
    required int unitsNeeded,
    required UrgencyLevel urgency,
    required String notes,
  }) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('bloodRequests')
          .add({
            'bloodType': bloodType,
            'patientName': patientName,
            'hospitalName': hospitalName,
            'location': location,
            'contactPhone': contactPhone,
            'unitsNeeded': unitsNeeded,
            'urgency': urgency.name,
            'status': RequestStatus.pending.name,
            'requestedBy': _adminId,
            'requestedByName': _adminName ?? 'Admin',
            'requestDate': FieldValue.serverTimestamp(),
            'assignedAdminId': _adminId,
            'notes': notes.isNotEmpty ? notes : null,
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Blood request created successfully!\nID: ${docRef.id.substring(0, 8)}...',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating request: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _showEditRequestDialog(BloodRequest request) async {
    final patientController = TextEditingController(text: request.patientName);
    final hospitalController = TextEditingController(
      text: request.hospitalName,
    );
    final locationController = TextEditingController(text: request.location);
    final phoneController = TextEditingController(text: request.contactPhone);
    final unitsController = TextEditingController(
      text: request.unitsNeeded.toString(),
    );
    final notesController = TextEditingController(text: request.notes);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Request'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: patientController,
                decoration: const InputDecoration(
                  labelText: 'Patient Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hospitalController,
                decoration: const InputDecoration(
                  labelText: 'Hospital Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: unitsController,
                decoration: const InputDecoration(
                  labelText: 'Units Needed',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('bloodRequests')
                  .doc(request.id)
                  .update({
                    'patientName': patientController.text,
                    'hospitalName': hospitalController.text,
                    'location': locationController.text,
                    'contactPhone': phoneController.text,
                    'unitsNeeded':
                        int.tryParse(unitsController.text) ??
                        request.unitsNeeded,
                    'notes': notesController.text,
                  });

              messenger.showSnackBar(
                const SnackBar(content: Text('Request updated')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bloodRed,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRequestStatus(
    String requestId,
    RequestStatus status,
  ) async {
    try {
      final updateData = {'status': status.name};
      if (mounted) {
        Color bgColor;
        String message;
        switch (status) {
          case RequestStatus.approved:
            bgColor = Colors.blue;
            message = 'Request APPROVED';
            break;
          case RequestStatus.fulfilled:
            bgColor = Colors.green;
            message = 'Request FULFILLED';
            break;
          case RequestStatus.cancelled:
            bgColor = Colors.red;
            message = 'Request CANCELLED';
            break;
          default:
            bgColor = Colors.grey;
            message = 'Request updated';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: bgColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      await FirebaseFirestore.instance
          .collection('bloodRequests')
          .doc(requestId)
          .update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Request ${status.name}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
