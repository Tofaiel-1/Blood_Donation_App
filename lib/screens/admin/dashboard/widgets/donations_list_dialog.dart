import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../../utils/app_colors.dart';

class DonationsListDialog extends StatefulWidget {
  const DonationsListDialog({super.key});

  @override
  State<DonationsListDialog> createState() => _DonationsListDialogState();
}

class _DonationsListDialogState extends State<DonationsListDialog> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'This Week', 'This Month', 'This Year'];
  List<Map<String, dynamic>> _currentDonations = [];
  bool _isExporting = false;

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
                    _currentDonations = [];
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

                  // Store donations for export
                  _currentDonations = donations.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {...data, 'id': doc.id};
                  }).toList();

                  return ListView.builder(
                    itemCount: donations.length,
                    itemBuilder: (context, index) {
                      final data =
                          donations[index].data() as Map<String, dynamic>;
                      final donationDate = data['donationDate'];
                      final isManualEntry = data['isManualEntry'] ?? false;
                      final hasRecipient =
                          data['recipientPatientName'] != null &&
                          (data['recipientPatientName'] as String).isNotEmpty;

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
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data['donorName'] ?? 'Anonymous Donor',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (isManualEntry)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 10,
                                        color: Colors.blue[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Manual',
                                        style: TextStyle(
                                          fontSize: 9,
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
                              Text('📅 $dateStr'),
                              Text(
                                '🏥 ${data['center'] ?? data['donationCenter'] ?? data['location'] ?? 'Unknown Center'}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (hasRecipient) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'For: ${data['recipientPatientName']}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[700],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                      onPressed: _isExporting || _currentDonations.isEmpty
                          ? null
                          : () => _exportToPdf(context),
                      icon: _isExporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf, size: 18),
                      label: Text(_isExporting ? 'Exporting...' : 'Export PDF'),
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

  Future<void> _exportToPdf(BuildContext context) async {
    if (_currentDonations.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No donations to export')));
      return;
    }

    setState(() => _isExporting = true);

    // Capture context references before async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final dateStr = '${now.day}/${now.month}/${now.year}';

      // Create PDF content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Blood Donation Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red900,
                    ),
                  ),
                  pw.Text(
                    'Generated: $dateStr',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Filter: $_selectedFilter | Total Records: ${_currentDonations.length}',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Divider(color: PdfColors.red900, thickness: 2),
              pw.SizedBox(height: 10),
            ],
          ),
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ),
          build: (context) => [
            pw.TableHelper.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 10,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.red900),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
              },
              headers: [
                '#',
                'Donor Name',
                'Blood Type',
                'Location',
                'Date',
                'Status',
                'Entry Type',
              ],
              data: _currentDonations.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final data = entry.value;
                final donationDate = data['donationDate'];
                final isManualEntry = data['isManualEntry'] ?? false;
                String dateStr = 'N/A';
                if (donationDate is Timestamp) {
                  final date = donationDate.toDate();
                  dateStr = '${date.day}/${date.month}/${date.year}';
                }
                return [
                  '$index',
                  data['donorName'] ?? 'Anonymous',
                  data['bloodType'] ?? '?',
                  data['center'] ??
                      data['donationCenter'] ??
                      data['location'] ??
                      'Unknown',
                  dateStr,
                  _getStatusText(data['status']),
                  isManualEntry ? 'Manual' : 'App',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Summary',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem(
                        'Total Donations',
                        '${_currentDonations.length}',
                      ),
                      _buildSummaryItem(
                        'Completed',
                        '${_currentDonations.where((d) => d['status']?.toLowerCase() == 'completed').length}',
                      ),
                      _buildSummaryItem(
                        'Pending',
                        '${_currentDonations.where((d) => d['status']?.toLowerCase() == 'pending').length}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      // Save PDF file
      final output = await getApplicationDocumentsDirectory();
      final fileName = 'donations_report_${now.millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        setState(() => _isExporting = false);

        // Show options dialog
        if (!mounted) return;
        showDialog(
          context: this.context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                const Text('PDF Created!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('File saved: $fileName'),
                const SizedBox(height: 8),
                Text(
                  'Location: ${file.path}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await OpenFile.open(file.path);
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Open PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bloodRed,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
                },
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error creating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.red900,
          ),
        ),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ],
    );
  }
}
