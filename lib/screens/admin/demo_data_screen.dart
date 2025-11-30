import 'package:flutter/material.dart';
import '../../services/demo_data_service.dart';
import '../../services/bangladesh_demo_data_service.dart';
import '../../utils/app_colors.dart';

class DemoDataScreen extends StatefulWidget {
  const DemoDataScreen({super.key});

  @override
  State<DemoDataScreen> createState() => _DemoDataScreenState();
}

class _DemoDataScreenState extends State<DemoDataScreen> {
  final _demoService = DemoDataService();
  final _bdDemoService = BangladeshDemoDataService();
  bool _isLoading = false;
  bool _isDemoDataCreated = false;
  bool _isOnline = false;
  Map<String, dynamic> _stats = {};
  String _message = '';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);

    _isDemoDataCreated = await _demoService.isDemoDataCreated();
    _isOnline = await _demoService.isOnline();
    _stats = await _demoService.getDemoStats();

    setState(() => _isLoading = false);
  }

  Future<void> _createDemoData() async {
    setState(() {
      _isLoading = true;
      _message = 'ডেমো ডাটা তৈরি হচ্ছে...';
    });

    try {
      await _demoService.createAllDemoData();

      setState(() {
        _message = '✅ ডেমো ডাটা সফলভাবে তৈরি হয়েছে!';
        _isDemoDataCreated = true;
      });

      await _checkStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ডেমো ডাটা তৈরি সম্পন্ন!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _message = '⚠️ অফলাইনে সেভ হয়েছে। নেট সংযুক্ত হলে অটো সিঙ্ক হবে।';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('অফলাইনে সেভ হয়েছে: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createBangladeshDemoData() async {
    setState(() {
      _isLoading = true;
      _message = '🇧🇩 বাংলাদেশ ডেমো ডাটা তৈরি হচ্ছে...';
    });

    try {
      await _bdDemoService.createBangladeshDemoData();

      // Get enhanced stats
      final bdStats = await _bdDemoService.getDemoStats();
      setState(() {
        _stats = bdStats;
        _isDemoDataCreated = true;
        _message = '✅ বাংলাদেশ ডেমো ডাটা সফলভাবে তৈরি হয়েছে!';
      });

      await _checkStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✅ বাংলাদেশ ডেমো ডাটা তৈরি সম্পন্ন!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${bdStats['totalUsers']} ইউজার • ${bdStats['totalRequests']} রিকোয়েস্ট • ${bdStats['totalDonations']} ডোনেশন',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '📍 ${bdStats['locationBasedMatches']} location matches (${bdStats['matchPercentage']}%)',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _message = '❌ ডাটা তৈরিতে সমস্যা হয়েছে';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('সমস্যা: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncOfflineData() async {
    setState(() {
      _isLoading = true;
      _message = 'অফলাইন ডাটা সিঙ্ক হচ্ছে...';
    });

    try {
      await _demoService.syncOfflineData();

      setState(() {
        _message = '✅ সব ডাটা Firebase এ সিঙ্ক হয়েছে!';
      });

      await _checkStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ সিঙ্ক সম্পন্ন!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _message = '❌ সিঙ্ক করতে সমস্যা হয়েছে';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('সিঙ্ক ব্যর্থ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearDemoData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('নিশ্চিত করুন'),
        content: const Text('সব ডেমো ডাটা মুছে ফেলবেন?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('না'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('হ্যাঁ, মুছুন'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _message = 'ডাটা মুছে ফেলা হচ্ছে...';
    });

    try {
      await _demoService.clearAllDemoData();

      setState(() {
        _message = '✅ ডেমো ডাটা মুছে ফেলা হয়েছে';
        _isDemoDataCreated = false;
      });

      await _checkStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ডাটা মুছে ফেলা হয়েছে'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('সমস্যা: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ডেমো ডাটা ম্যানেজমেন্ট'),
        backgroundColor: AppColors.bloodRed,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Card
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            _isOnline ? Icons.cloud_done : Icons.cloud_off,
                            size: 64,
                            color: _isOnline ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isOnline ? '🟢 অনলাইন' : '🟠 অফলাইন',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isOnline
                                ? 'Firebase এর সাথে সংযুক্ত'
                                : 'ইন্টারনেট সংযোগ নেই',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Statistics Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'বর্তমান ডাটা',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          _buildStatRow(
                            '👥 ইউজার',
                            _stats['totalUsers'] ?? _stats['users'] ?? 0,
                          ),
                          _buildStatRow(
                            '🩸 রক্তের রিকোয়েস্ট',
                            _stats['totalRequests'] ?? _stats['requests'] ?? 0,
                          ),
                          _buildStatRow(
                            '❤️ ডোনেশন',
                            _stats['totalDonations'] ??
                                _stats['donations'] ??
                                0,
                          ),
                          if (_stats['locationBasedMatches'] != null) ...[
                            const Divider(),
                            _buildStatRow(
                              '📍 Location Match',
                              _stats['locationBasedMatches'] ?? 0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 32, top: 4),
                              child: Text(
                                '${_stats['matchPercentage'] ?? '0'}% success rate',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Message Card
                  if (_message.isNotEmpty)
                    Card(
                      color: _message.contains('✅')
                          ? Colors.green[50]
                          : _message.contains('⚠️')
                          ? Colors.orange[50]
                          : Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _message,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  if (!_isDemoDataCreated) ...[
                    // Bangladesh Demo Data Button (NEW)
                    ElevatedButton.icon(
                      onPressed: _createBangladeshDemoData,
                      icon: const Icon(Icons.flag),
                      label: const Text('🇧🇩 Bangladesh Demo Data তৈরি করুন'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '✨ নতুন! বাংলাদেশী ডাটা:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• ২০ জন বাংলাদেশী নামের ইউজার\n'
                              '• ঢাকার ১০টি এলাকার লোকেশন\n'
                              '• ১৫টি রক্তের রিকোয়েস্ট (location-based)\n'
                              '• ২০টি ডোনেশন (কে দিয়েছে ও কে নিয়েছে)\n'
                              '• ১১ ডিজিটের BD ফোন নম্বর (GP, Robi, Banglalink)',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _createDemoData,
                      icon: const Icon(Icons.add_circle),
                      label: const Text('সাধারণ ডেমো ডাটা তৈরি করুন'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• ১৫টি ডেমো ইউজার\n• ২০টি রক্তের রিকোয়েস্ট\n• ২৫টি ডোনেশন রেকর্ড\n• ৩টি অ্যাডমিন',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: _isOnline ? _syncOfflineData : null,
                      icon: const Icon(Icons.sync),
                      label: const Text('অফলাইন ডাটা সিঙ্ক করুন'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _clearDemoData,
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('ডেমো ডাটা মুছুন'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.all(16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Info Card
                  Card(
                    color: Colors.amber[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'গুরুত্বপূর্ণ তথ্য',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[900],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• অফলাইনে ডাটা তৈরি করলেও সমস্যা নেই\n'
                            '• ইন্টারনেট সংযুক্ত হলে অটো সিঙ্ক হবে\n'
                            '• ডেমো ডাটা শুধু টেস্টিং এর জন্য\n'
                            '• যেকোনো সময় মুছে ফেলতে পারবেন',
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.bloodRed,
            ),
          ),
        ],
      ),
    );
  }
}
