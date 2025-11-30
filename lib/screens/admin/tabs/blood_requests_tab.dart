import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/blood_request.dart';

/// Blood Requests Tab - Manage all blood donation requests
/// View, approve, reject, fulfill requests
class BloodRequestsTab extends StatelessWidget {
  const BloodRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bloodRequests')
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
                Icon(
                  Icons.bloodtype_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No blood requests yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = BloodRequest.fromFirestore(requests[index]);
            return _RequestCard(request: request);
          },
        );
      },
    );
  }
}

/// Individual Request Card Widget
class _RequestCard extends StatelessWidget {
  final BloodRequest request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _getUrgencyColor(request.urgency);
    final statusColor = _getStatusColor(request.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: urgencyColor,
          child: Text(
            request.bloodType,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          request.patientName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.hospitalName),
            Text(
              'Units needed: ${request.unitsNeeded}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            request.status.name.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: statusColor.withValues(alpha: 0.1),
          padding: EdgeInsets.zero,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.location_on, 'Location', request.location),
                _buildInfoRow(Icons.phone, 'Contact', request.contactPhone),
                _buildInfoRow(
                  Icons.person,
                  'Requested by',
                  request.requestedByName,
                ),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Date',
                  _formatDate(request.requestDate),
                ),
                _buildInfoRow(
                  Icons.priority_high,
                  'Urgency',
                  request.urgency.name.toUpperCase(),
                ),
                if (request.notes != null && request.notes!.isNotEmpty)
                  _buildInfoRow(Icons.notes, 'Notes', request.notes!),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (request.status == RequestStatus.pending) ...[
                      ElevatedButton.icon(
                        onPressed: () => _updateRequestStatus(
                          context,
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
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _updateRequestStatus(
                          context,
                          request.id,
                          RequestStatus.cancelled,
                        ),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ] else if (request.status == RequestStatus.approved) ...[
                      ElevatedButton.icon(
                        onPressed: () => _updateRequestStatus(
                          context,
                          request.id,
                          RequestStatus.fulfilled,
                        ),
                        icon: const Icon(Icons.done_all, size: 18),
                        label: const Text('Mark Fulfilled'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getUrgencyColor(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.critical:
        return Colors.red;
      case UrgencyLevel.urgent:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.fulfilled:
        return Colors.green;
      case RequestStatus.cancelled:
        return Colors.red;
      case RequestStatus.approved:
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static Future<void> _updateRequestStatus(
    BuildContext context,
    String requestId,
    RequestStatus newStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('bloodRequests')
          .doc(requestId)
          .update({'status': newStatus.name});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request ${newStatus.name} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
