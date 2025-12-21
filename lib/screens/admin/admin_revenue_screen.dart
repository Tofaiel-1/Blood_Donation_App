import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/payment_service.dart';

class AdminRevenueScreen extends StatefulWidget {
  const AdminRevenueScreen({super.key});

  @override
  State<AdminRevenueScreen> createState() => _AdminRevenueScreenState();
}

class _AdminRevenueScreenState extends State<AdminRevenueScreen> {
  final PaymentService _paymentService = PaymentService();
  Map<String, dynamic>? _revenueData;
  bool _isLoading = true;
  int? _selectedDaysFilter; // null = All Time, 7, 30, 90

  @override
  void initState() {
    super.initState();
    _loadRevenueData();
  }

  Future<void> _loadRevenueData() async {
    setState(() => _isLoading = true);
    try {
      DateTime? startDate;
      if (_selectedDaysFilter != null) {
        startDate = DateTime.now().subtract(
          Duration(days: _selectedDaysFilter!),
        );
      }

      final data = await _paymentService.getRevenueStats(startDate: startDate);
      setState(() {
        _revenueData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading revenue data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue Dashboard'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRevenueData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _revenueData == null
          ? const Center(child: Text('No revenue data available'))
          : Column(
              children: [
                // Time Filter Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border(
                      bottom: BorderSide(color: Colors.blue[100]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        size: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Period: ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      _buildTimeFilterChip('All Time', null),
                      _buildTimeFilterChip('7 Days', 7),
                      _buildTimeFilterChip('30 Days', 30),
                      _buildTimeFilterChip('90 Days', 90),
                      const Spacer(),
                      if (_selectedDaysFilter != null)
                        TextButton.icon(
                          onPressed: () {
                            setState(() => _selectedDaysFilter = null);
                            _loadRevenueData();
                          },
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Clear'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadRevenueData,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total Revenue Card
                          _buildTotalRevenueCard(),

                          const SizedBox(height: 24),

                          // Revenue by Type
                          const Text(
                            'Revenue by Type',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildRevenueByTypeCards(),

                          const SizedBox(height: 32),

                          // Pie Chart
                          const Text(
                            'Revenue Distribution',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildRevenuePieChart(),

                          const SizedBox(height: 32),

                          // Transaction Count
                          _buildTransactionCountCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTotalRevenueCard() {
    final totalRevenue = _revenueData!['totalRevenue'] ?? 0.0;
    final totalTransactions = _revenueData!['totalTransactions'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 40,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalTransactions Transactions',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Total Revenue',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '৳${totalRevenue.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueByTypeCards() {
    final revenueByType =
        _revenueData!['revenueByType'] as Map<String, dynamic>? ?? {};
    final countByType =
        _revenueData!['countByType'] as Map<String, dynamic>? ?? {};

    if (revenueByType.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No revenue data by type'),
        ),
      );
    }

    return Column(
      children: revenueByType.entries.map((entry) {
        final type = entry.key;
        final revenue = entry.value as double;
        final count = countByType[type] ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: _getIconForType(type),
            title: Text(
              _getNameForType(type),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('$count transactions'),
            trailing: Text(
              '৳${revenue.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRevenuePieChart() {
    final revenueByType =
        _revenueData!['revenueByType'] as Map<String, dynamic>? ?? {};

    if (revenueByType.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = revenueByType.values.fold<double>(
      0,
      (sum, val) => sum + (val as double),
    );

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: revenueByType.entries.map((entry) {
            final type = entry.key;
            final revenue = entry.value as double;
            final percentage = (revenue / total * 100);

            return PieChartSectionData(
              value: revenue,
              title: '${percentage.toStringAsFixed(1)}%',
              color: _getColorForType(type),
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildTransactionCountCard() {
    final countByType =
        _revenueData!['countByType'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...countByType.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(_getNameForType(entry.key))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getColorForType(entry.key).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.value}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getColorForType(entry.key),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Icon _getIconForType(String type) {
    switch (type) {
      case 'premiumSubscription':
        return const Icon(Icons.stars, color: Colors.orange);
      case 'transactionFee':
        return const Icon(Icons.money, color: Colors.green);
      case 'emergencyRequest':
        return const Icon(Icons.emergency, color: Colors.red);
      case 'hospitalSubscription':
        return const Icon(Icons.local_hospital, color: Colors.blue);
      case 'verification':
        return const Icon(Icons.verified, color: Colors.green);
      case 'advertisement':
        return const Icon(Icons.ad_units, color: Colors.purple);
      default:
        return const Icon(Icons.payment, color: Colors.grey);
    }
  }

  String _getNameForType(String type) {
    switch (type) {
      case 'premiumSubscription':
        return 'Premium Subscriptions';
      case 'transactionFee':
        return 'Transaction Fees';
      case 'emergencyRequest':
        return 'Emergency Requests';
      case 'hospitalSubscription':
        return 'Hospital Partnerships';
      case 'verification':
        return 'Verifications';
      case 'advertisement':
        return 'Advertisements';
      default:
        return type;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'premiumSubscription':
        return Colors.orange;
      case 'transactionFee':
        return Colors.green;
      case 'emergencyRequest':
        return Colors.red;
      case 'hospitalSubscription':
        return Colors.blue;
      case 'verification':
        return Colors.teal;
      case 'advertisement':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTimeFilterChip(String label, int? days) {
    final isSelected = _selectedDaysFilter == days;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedDaysFilter = days);
            _loadRevenueData();
          }
        },
        selectedColor: Colors.blue.withValues(alpha: 0.3),
        checkmarkColor: Colors.blue,
      ),
    );
  }
}
