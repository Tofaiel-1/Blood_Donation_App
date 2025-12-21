import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/advance_booking.dart';
import '../../services/advance_booking_service.dart';

class AdminBookingDashboard extends StatefulWidget {
  const AdminBookingDashboard({Key? key}) : super(key: key);

  @override
  State<AdminBookingDashboard> createState() => _AdminBookingDashboardState();
}

class _AdminBookingDashboardState extends State<AdminBookingDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _advanceBookingService = AdvanceBookingService();

  BookingStatus? _filterStatus;
  String? _filterBloodGroup;
  String? _filterDistrict;

  // For date range filtering
  int _selectedDays = 30;
  DateTime get _startDate =>
      DateTime.now().subtract(Duration(days: _selectedDays));
  DateTime get _endDate => DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('অগ্রিম বুকিং ড্যাশবোর্ড'),
        backgroundColor: Colors.red,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'পরিসংখ্যান', icon: Icon(Icons.analytics)),
            Tab(text: 'বুকিং তালিকা', icon: Icon(Icons.list)),
            Tab(text: 'আয় বিশ্লেষণ', icon: Icon(Icons.attach_money)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatisticsTab(),
          _buildBookingsListTab(),
          _buildIncomeAnalyticsTab(),
        ],
      ),
    );
  }

  // Statistics Tab
  Widget _buildStatisticsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _advanceBookingService.getIncomeStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('তথ্য লোড হচ্ছে...', style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'তথ্য লোড করতে সমস্যা হয়েছে',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'অনুগ্রহ করে আবার চেষ্টা করুন',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: const Text('আবার চেষ্টা করুন'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final stats = snapshot.data ?? {};

        // Handle empty/zero data gracefully
        final totalRevenue = stats['totalRevenue'] ?? 0.0;
        final totalBookings = stats['totalBookings'] ?? 0;

        if (totalBookings == 0) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'এখনও কোনো বুকিং নেই',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'প্রথম বুকিং হলে এখানে দেখাবে',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5, // Increased to prevent overflow
                children: [
                  _buildStatCard(
                    'মোট আয়',
                    '৳${stats['totalRevenue'].toStringAsFixed(0)}',
                    Icons.monetization_on,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'প্ল্যাটফর্ম ফি',
                    '৳${stats['totalPlatformFees'].toStringAsFixed(0)}',
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'মোট বুকিং',
                    '${stats['totalBookings']}',
                    Icons.bookmark,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'সম্পন্ন',
                    '${stats['completedBookings']}',
                    Icons.check_circle,
                    Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Completion Rate
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'সফলতার হার',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: stats['completionRate'] / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats['completionRate'].toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Blood Group Distribution
              const Text(
                'রক্তের গ্রুপ অনুযায়ী বুকিং',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 200,
                    child: _buildBloodGroupChart(
                      stats['bookingsByBloodGroup'] as Map<String, dynamic>,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // District Revenue
              const Text(
                'জেলা অনুযায়ী আয়',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._buildDistrictRevenueList(
                stats['revenueByDistrict'] as Map<String, dynamic>,
              ),
            ],
          ),
        );
      },
    );
  }

  // Bookings List Tab
  Widget _buildBookingsListTab() {
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<BookingStatus>(
                  value: _filterStatus,
                  decoration: const InputDecoration(
                    labelText: 'স্ট্যাটাস',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('সব')),
                    ...BookingStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(
                          AdvanceBloodBooking(
                            id: '',
                            userId: '',
                            userName: '',
                            userPhone: '',
                            bloodGroup: '',
                            patientName: '',
                            patientAge: '',
                            patientGender: '',
                            patientBloodGroup: '',
                            patientCondition: '',
                            hospitalName: '',
                            hospitalAddress: '',
                            division: '',
                            district: '',
                            upazila: '',
                            unitsRequired: 1,
                            requiredDate: DateTime.now(),
                            priority: BookingPriority.standard,
                            status: status,
                            bookingAmount: 0,
                            priorityCharge: 0,
                            platformFee: 0,
                            totalAmount: 0,
                            isPaid: false,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ).getStatusTextBangla(),
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) => setState(() => _filterStatus = value),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() {}),
              ),
            ],
          ),
        ),

        // Bookings List
        Expanded(
          child: StreamBuilder<List<AdvanceBloodBooking>>(
            stream: _advanceBookingService.getAllBookings(
              status: _filterStatus,
              bloodGroup: _filterBloodGroup,
              district: _filterDistrict,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('ত্রুটি: ${snapshot.error}'));
              }

              final bookings = snapshot.data ?? [];

              if (bookings.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('কোনো বুকিং নেই'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  return _buildBookingCard(bookings[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Income Analytics Tab
  Widget _buildIncomeAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range Selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'সময়কাল নির্বাচন করুন',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _selectDateRange(7),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedDays == 7
                                ? Colors.red
                                : Colors.grey,
                          ),
                          child: const Text('৭ দিন'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _selectDateRange(30),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedDays == 30
                                ? Colors.red
                                : Colors.grey,
                          ),
                          child: const Text('৩০ দিন'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _selectDateRange(90),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedDays == 90
                                ? Colors.red
                                : Colors.grey,
                          ),
                          child: const Text('৯০ দিন'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Revenue Chart
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _advanceBookingService.getDailyRevenue(
              startDate: _startDate,
              endDate: _endDate,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('গ্রাফ তৈরি হচ্ছে...'),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          size: 48,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'গ্রাফ লোড করতে সমস্যা হয়েছে',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'পরবর্তীতে আবার চেষ্টা করুন',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final data = snapshot.data ?? [];

              if (data.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'নির্বাচিত সময়ে কোনো আয় নেই',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'অন্য সময়কাল নির্বাচন করুন',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'দৈনিক আয় গ্রাফ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(height: 250, child: _buildRevenueChart(data)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(AdvanceBloodBooking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Color(
            int.parse('0xFF${booking.getStatusColor().substring(1)}'),
          ),
          child: Text(
            booking.bloodGroup,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(booking.patientName),
        subtitle: Text(
          '${booking.hospitalName} • ${booking.district}\n'
          '${DateFormat('dd MMM yyyy', 'bn').format(booking.requiredDate)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '৳${booking.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              booking.getStatusTextBangla(),
              style: TextStyle(
                fontSize: 11,
                color: Color(
                  int.parse('0xFF${booking.getStatusColor().substring(1)}'),
                ),
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
                _buildDetailRow('রোগী', booking.patientName),
                _buildDetailRow('বয়স', '${booking.patientAge} বছর'),
                _buildDetailRow('লিঙ্গ', booking.patientGender),
                _buildDetailRow('রোগ', booking.patientCondition),
                _buildDetailRow('ব্যাগ সংখ্যা', '${booking.unitsRequired}'),
                _buildDetailRow('ফোন', booking.userPhone),
                if (booking.matchedDonorName != null)
                  _buildDetailRow('ডোনার', booking.matchedDonorName!),
                if (booking.matchedDonorPhone != null)
                  _buildDetailRow('ডোনার ফোন', booking.matchedDonorPhone!),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (booking.status == BookingStatus.processing)
                      ElevatedButton.icon(
                        onPressed: () => _showMatchDonorDialog(booking),
                        icon: const Icon(Icons.person_add, size: 16),
                        label: const Text('ডোনার ম্যাচ'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    if (booking.status == BookingStatus.matched)
                      ElevatedButton.icon(
                        onPressed: () => _completeBooking(booking.id),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('সম্পন্ন'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    if (booking.status != BookingStatus.completed &&
                        booking.status != BookingStatus.cancelled)
                      OutlinedButton.icon(
                        onPressed: () => _showCancelDialog(booking),
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text('বাতিল'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
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
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodGroupChart(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return const Center(child: Text('কোনো ডেটা নেই'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final groups = data.keys.toList();
                if (value.toInt() >= 0 && value.toInt() < groups.length) {
                  return Text(groups[value.toInt()]);
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.entries.toList().asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value.toDouble(),
                color: Colors.red,
                width: 20,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildDistrictRevenueList(Map<String, dynamic> data) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));

    return sortedEntries.take(10).map((entry) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              '${sortedEntries.indexOf(entry) + 1}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(entry.key),
          trailing: Text(
            '৳${(entry.value as num).toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildRevenueChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Center(child: Text('কোনো ডেটা নেই'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 50),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final date = DateTime.parse(data[value.toInt()]['date']);
                  return Text(
                    DateFormat('dd/MM').format(date),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value['revenue'].toDouble(),
              );
            }).toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  void _selectDateRange(int days) {
    // Update selected days and refresh data
    setState(() {
      _selectedDays = days;
    });
  }

  Future<void> _showMatchDonorDialog(AdvanceBloodBooking booking) async {
    // Show dialog to manually match a donor
    // In production, this would show a list of available donors
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ডোনার ম্যাচিং ফিচার শীঘ্রই আসছে')),
    );
  }

  Future<void> _completeBooking(String bookingId) async {
    try {
      await _advanceBookingService.completeBooking(bookingId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('বুকিং সফলভাবে সম্পন্ন হয়েছে')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ত্রুটি: $e')));
    }
  }

  Future<void> _showCancelDialog(AdvanceBloodBooking booking) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        String cancelReason = '';
        return AlertDialog(
          title: const Text('বুকিং বাতিল'),
          content: TextField(
            onChanged: (value) => cancelReason = value,
            decoration: const InputDecoration(
              labelText: 'বাতিলের কারণ',
              hintText: 'কেন বাতিল করছেন?',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ফিরে যান'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, cancelReason),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('বাতিল করুন'),
            ),
          ],
        );
      },
    );

    if (reason != null && reason.isNotEmpty) {
      try {
        await _advanceBookingService.cancelBooking(
          bookingId: booking.id,
          reason: reason,
          refund: true,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('বুকিং বাতিল হয়েছে এবং টাকা ফেরত দেওয়া হবে'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ত্রুটি: $e')));
      }
    }
  }
}
