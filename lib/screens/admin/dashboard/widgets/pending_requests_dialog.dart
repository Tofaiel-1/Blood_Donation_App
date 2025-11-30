import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingRequestsDialog extends StatefulWidget {
  const PendingRequestsDialog({super.key});

  @override
  State<PendingRequestsDialog> createState() => _PendingRequestsDialogState();
}

class _PendingRequestsDialogState extends State<PendingRequestsDialog> {
  String _selectedUrgency = 'All';
  final List<String> _urgencyLevels = ['All', 'Critical', 'Urgent', 'Normal'];

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
                    const Icon(
                      Icons.pending_actions,
                      color: Colors.orange,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Pending Blood Requests',
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

            // Urgency filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _urgencyLevels.map((level) {
                  final isSelected = _selectedUrgency == level;
                  Color chipColor;
                  switch (level) {
                    case 'Critical':
                      chipColor = Colors.red;
                      break;
                    case 'Urgent':
                      chipColor = Colors.orange;
                      break;
                    case 'Normal':
                      chipColor = Colors.blue;
                      break;
                    default:
                      chipColor = Colors.grey;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(level),
                      selected: isSelected,
                      onSelected: (selected) =>
                          setState(() => _selectedUrgency = level),
                      backgroundColor: Colors.grey[200],
                      selectedColor: chipColor.withValues(alpha: 0.2),
                      checkmarkColor: chipColor,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Pending Requests List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bloodRequests')
                    .where('status', isEqualTo: 'pending')
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

                  // Filter by urgency
                  if (_selectedUrgency != 'All') {
                    requests = requests.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return (data['urgency'] ?? '').toString().toLowerCase() ==
                          _selectedUrgency.toLowerCase();
                    }).toList();
                  }

                  if (requests.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.green[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No pending requests! 🎉',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final data =
                          requests[index].data() as Map<String, dynamic>;
                      final requestId = requests[index].id;
                      final urgency = (data['urgency'] ?? 'normal')
                          .toString()
                          .toLowerCase();

                      Color urgencyColor;
                      IconData urgencyIcon;
                      switch (urgency) {
                        case 'critical':
                          urgencyColor = Colors.red;
                          urgencyIcon = Icons.warning;
                          break;
                        case 'urgent':
                          urgencyColor = Colors.orange;
                          urgencyIcon = Icons.priority_high;
                          break;
                        default:
                          urgencyColor = Colors.blue;
                          urgencyIcon = Icons.info;
                      }

                      final requestDate = data['requestDate'];
                      String dateStr = 'Unknown date';
                      if (requestDate is Timestamp) {
                        final date = requestDate.toDate();
                        dateStr =
                            '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: urgencyColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
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
                                  data['bloodType'] ?? '?',
                                  style: TextStyle(
                                    color: urgencyColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${data['unitsNeeded'] ?? 1}U',
                                  style: TextStyle(
                                    color: urgencyColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data['patientName'] ?? 'Unknown Patient',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: urgencyColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      urgencyIcon,
                                      size: 12,
                                      color: urgencyColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      urgency.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: urgencyColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '🏥 ${data['hospitalName'] ?? 'Unknown Hospital'}',
                              ),
                              Text(
                                '📍 ${data['location'] ?? 'Unknown Location'}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                '📅 $dateStr',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(
                                    'Contact',
                                    data['contactPhone'] ?? 'N/A',
                                    Icons.phone,
                                  ),
                                  _buildInfoRow(
                                    'Requested By',
                                    data['requestedByName'] ?? 'N/A',
                                    Icons.person,
                                  ),
                                  if (data['notes'] != null &&
                                      data['notes'].toString().isNotEmpty)
                                    _buildInfoRow(
                                      'Notes',
                                      data['notes'],
                                      Icons.note,
                                    ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => _updateStatus(
                                          requestId,
                                          'cancelled',
                                        ),
                                        icon: const Icon(Icons.close, size: 16),
                                        label: const Text('Reject'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton.icon(
                                        onPressed: () => _updateStatus(
                                          requestId,
                                          'approved',
                                        ),
                                        icon: const Icon(Icons.check, size: 16),
                                        label: const Text('Approve'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String requestId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('bloodRequests')
          .doc(requestId)
          .update({'status': status});

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Request ${status == 'approved' ? 'approved' : 'rejected'} successfully',
          ),
          backgroundColor: status == 'approved' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
