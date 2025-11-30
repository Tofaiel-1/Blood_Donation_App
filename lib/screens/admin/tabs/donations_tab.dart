import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Donations Tab - Track and manage blood donations
/// View donation history and statistics
class DonationsTab extends StatelessWidget {
  const DonationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donations')
          .orderBy('donationDate', descending: true)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final donations = snapshot.data?.docs ?? [];

        if (donations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No donations recorded yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final completed = donations
            .where((d) => (d.data() as Map)['status'] == 'completed')
            .length;

        return Column(
          children: [
            // Statistics
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickStat(
                    'Total Donations',
                    donations.length.toString(),
                    Icons.favorite,
                    Colors.red,
                  ),
                  _buildQuickStat(
                    'Completed',
                    completed.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildQuickStat(
                    'Lives Saved',
                    (completed * 3).toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ],
              ),
            ),

            // Donations List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  final doc = donations[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return _DonationCard(donationId: doc.id, data: data);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
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
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

/// Individual Donation Card
class _DonationCard extends StatelessWidget {
  final String donationId;
  final Map<String, dynamic> data;

  const _DonationCard({required this.donationId, required this.data});

  @override
  Widget build(BuildContext context) {
    final donorName = data['donorName'] ?? 'Unknown';
    final bloodType = data['bloodType'] ?? 'Unknown';
    final location = data['location'] ?? 'Unknown';
    final status = data['status'] ?? 'completed';
    final donationDate =
        (data['donationDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    final isManualEntry = data['isManualEntry'] ?? false;
    final hasRecipient =
        data['recipientPatientName'] != null &&
        (data['recipientPatientName'] as String).isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: status == 'completed' ? Colors.green : Colors.orange,
          child: Text(
            bloodType,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                donorName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (isManualEntry)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 12, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      'Manual',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[700],
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
            Text(location),
            if (hasRecipient) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Recipient: ${data['recipientPatientName']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatDate(donationDate),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            status.toUpperCase(),
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: status == 'completed'
              ? Colors.green[100]
              : Colors.orange[100],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
