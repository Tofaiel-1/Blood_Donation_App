import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utils/app_colors.dart';

class DonationsListDialog extends StatefulWidget {
  const DonationsListDialog({super.key});

  @override
  State<DonationsListDialog> createState() => _DonationsListDialogState();
}

class _DonationsListDialogState extends State<DonationsListDialog> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'This Week', 'This Month', 'This Year'];

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
                    Icon(Icons.bloodtype, color: AppColors.bloodRed, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'All Donations',
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

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) =>
                          setState(() => _selectedFilter = filter),
                      backgroundColor: Colors.grey[200],
                      selectedColor: AppColors.bloodRed.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.bloodRed,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Donations List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('donations')
                    .orderBy('donationDate', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  var donations = snapshot.data?.docs ?? [];

                  // Apply time filter
                  if (_selectedFilter != 'All') {
                    final now = DateTime.now();
                    DateTime startDate;

                    switch (_selectedFilter) {
                      case 'This Week':
                        startDate = now.subtract(const Duration(days: 7));
                        break;
                      case 'This Month':
                        startDate = DateTime(now.year, now.month, 1);
                        break;
                      case 'This Year':
                        startDate = DateTime(now.year, 1, 1);
                        break;
                      default:
                        startDate = DateTime(2000);
                    }

                    donations = donations.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final donationDate = data['donationDate'];
                      if (donationDate is Timestamp) {
                        return donationDate.toDate().isAfter(startDate);
                      }
                      return true;
                    }).toList();
                  }

                  if (donations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bloodtype_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No donations found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: donations.length,
                    itemBuilder: (context, index) {
                      final data =
                          donations[index].data() as Map<String, dynamic>;
                      final donationDate = data['donationDate'];
                      String dateStr = 'Unknown date';
                      if (donationDate is Timestamp) {
                        final date = donationDate.toDate();
                        dateStr = '${date.day}/${date.month}/${date.year}';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.bloodRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  data['bloodType'] ?? '?',
                                  style: TextStyle(
                                    color: AppColors.bloodRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${data['units'] ?? 1}U',
                                  style: TextStyle(
                                    color: AppColors.bloodRed,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          title: Text(
                            data['donorName'] ?? 'Anonymous Donor',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📅 $dateStr'),
                              Text(
                                '🏥 ${data['center'] ?? data['donationCenter'] ?? 'Unknown Center'}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                data['status'],
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusText(data['status']),
                              style: TextStyle(
                                color: _getStatusColor(data['status']),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Summary footer
            const Divider(),
            StreamBuilder<AggregateQuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('donations')
                  .count()
                  .get()
                  .asStream(),
              builder: (context, snapshot) {
                final count = snapshot.data?.count ?? 0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Donations: $count',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Export functionality placeholder
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Export feature coming soon!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Export'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bloodRed,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String? status) {
    if (status == null || status.isEmpty) return 'Completed';
    return status[0].toUpperCase() + status.substring(1);
  }
}
