import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utils/app_colors.dart';

class DonorsListDialog extends StatefulWidget {
  const DonorsListDialog({super.key});

  @override
  State<DonorsListDialog> createState() => _DonorsListDialogState();
}

class _DonorsListDialogState extends State<DonorsListDialog> {
  String _searchQuery = '';
  String _selectedBloodType = 'All';
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
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, color: AppColors.bloodRed, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'All Donors',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),

            // Search and Filter
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, phone...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedBloodType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: _bloodTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedBloodType = value ?? 'All'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Donors List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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

                  var donors = snapshot.data?.docs ?? [];

                  // Filter by blood type
                  if (_selectedBloodType != 'All') {
                    donors = donors.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['bloodType'] == _selectedBloodType;
                    }).toList();
                  }

                  // Filter by search query
                  if (_searchQuery.isNotEmpty) {
                    donors = donors.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['name'] ?? '')
                          .toString()
                          .toLowerCase();
                      final email = (data['email'] ?? '')
                          .toString()
                          .toLowerCase();
                      final phone = (data['phone'] ?? '')
                          .toString()
                          .toLowerCase();
                      return name.contains(_searchQuery) ||
                          email.contains(_searchQuery) ||
                          phone.contains(_searchQuery);
                    }).toList();
                  }

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
                            'No donors found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: donors.length,
                    itemBuilder: (context, index) {
                      final data = donors[index].data() as Map<String, dynamic>;
                      final bloodType = data['bloodType'] ?? '?';
                      final isAvailable = data['isAvailableToDonate'] ?? true;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.bloodRed,
                            child: Text(
                              bloodType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            data['name'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['email'] ?? ''),
                              if (data['phone'] != null)
                                Text(
                                  data['phone'],
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              if (data['district'] != null)
                                Text(
                                  '📍 ${data['district']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isAvailable
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isAvailable ? 'Available' : 'Unavailable',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isAvailable
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Donations: ${data['totalDonations'] ?? 0}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () => _showDonorDetails(
                            context,
                            data,
                            donors[index].id,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDonorDetails(
    BuildContext context,
    Map<String, dynamic> data,
    String donorId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.bloodRed,
              child: Text(
                data['bloodType'] ?? '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(data['name'] ?? 'Unknown')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Email', data['email'] ?? 'N/A'),
              _detailRow('Phone', data['phone'] ?? 'N/A'),
              _detailRow('Blood Type', data['bloodType'] ?? 'N/A'),
              _detailRow('District', data['district'] ?? 'N/A'),
              _detailRow('Upazila', data['upazila'] ?? 'N/A'),
              _detailRow('Total Donations', '${data['totalDonations'] ?? 0}'),
              _detailRow('Last Donation', data['lastDonationDate'] ?? 'Never'),
              _detailRow(
                'Status',
                (data['isAvailableToDonate'] ?? true)
                    ? 'Available'
                    : 'Unavailable',
              ),
              _detailRow(
                'Verified',
                (data['emailVerified'] ?? false) ? 'Yes ✓' : 'No',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
