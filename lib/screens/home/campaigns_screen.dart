import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/donor_campaign_manager_service.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen>
    with SingleTickerProviderStateMixin {
  final _campaignService = DonorCampaignManagerService();
  late TabController _tabController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _activeCampaigns = [];
  List<Map<String, dynamic>> _upcomingCampaigns = [];
  List<Map<String, dynamic>> _myCampaigns = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCampaigns();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCampaigns() async {
    setState(() => _isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final active = await _campaignService.getActiveCampaigns();
        final upcoming = await _campaignService.getActiveCampaigns();
        final my = await _campaignService.getMyCampaigns(userId);

        setState(() {
          _activeCampaigns = active;
          _upcomingCampaigns = upcoming;
          _myCampaigns = my;
        });
      }
    } catch (e) {
      debugPrint('Error loading campaigns: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Donation Campaigns'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.campaign), text: 'Active'),
            Tab(icon: Icon(Icons.schedule), text: 'Upcoming'),
            Tab(icon: Icon(Icons.person), text: 'My Campaigns'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveCampaignsTab(),
          _buildUpcomingCampaignsTab(),
          _buildMyCampaignsTab(),
        ],
      ),
    );
  }

  Widget _buildActiveCampaignsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeCampaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No active campaigns',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCampaigns,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activeCampaigns.length,
        itemBuilder: (context, index) {
          final campaign = _activeCampaigns[index];
          return _buildCampaignCard(campaign, isActive: true);
        },
      ),
    );
  }

  Widget _buildUpcomingCampaignsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_upcomingCampaigns.isEmpty) {
      return const Center(child: Text('No upcoming campaigns'));
    }

    return RefreshIndicator(
      onRefresh: _loadCampaigns,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _upcomingCampaigns.length,
        itemBuilder: (context, index) {
          final campaign = _upcomingCampaigns[index];
          return _buildCampaignCard(campaign, isActive: false);
        },
      ),
    );
  }

  Widget _buildMyCampaignsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myCampaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('You haven\'t registered for any campaigns yet'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              child: const Text('Browse Active Campaigns'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCampaigns,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myCampaigns.length,
        itemBuilder: (context, index) {
          final campaign = _myCampaigns[index];
          return _buildCampaignCard(campaign, isMyCampaign: true);
        },
      ),
    );
  }

  Widget _buildCampaignCard(
    Map<String, dynamic> campaign, {
    bool isActive = false,
    bool isMyCampaign = false,
  }) {
    final startDate = (campaign['startDate'] as Timestamp).toDate();
    final endDate = (campaign['endDate'] as Timestamp).toDate();
    final currentDonations = campaign['currentDonations'] ?? 0;
    final targetDonations = campaign['targetDonations'] ?? 0;
    final progress = targetDonations > 0
        ? currentDonations / targetDonations
        : 0.0;
    final isRegistered = campaign['isRegistered'] ?? false;
    final hasDonated = campaign['hasDonated'] ?? false;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campaign Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isActive
                    ? [Colors.red.shade700, Colors.red.shade900]
                    : [Colors.orange.shade700, Colors.orange.shade900],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        campaign['campaignName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  campaign['organizerName'],
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  campaign['description'] ?? 'No description',
                  style: TextStyle(color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        campaign['venue'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Date & Time
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormat('dd MMM').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Campaign Progress',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$currentDonations / $targetDonations',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1.0 ? Colors.green : Colors.red.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}% Complete',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatChip(
                      Icons.people,
                      '${campaign['participantCount'] ?? 0}',
                      'Registered',
                    ),
                    _buildStatChip(
                      Icons.bloodtype,
                      '${campaign['currentDonations'] ?? 0}',
                      'Donations',
                    ),
                    _buildStatChip(
                      Icons.attach_money,
                      '৳75',
                      'Bonus',
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                if (isActive) ...[
                  if (isRegistered) ...[
                    if (hasDonated)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              '✅ You donated! Thank you!',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => _showDonationDialog(campaign),
                        icon: const Icon(Icons.bloodtype),
                        label: const Text('Mark as Donated'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                  ] else
                    ElevatedButton.icon(
                      onPressed: () => _registerForCampaign(campaign['id']),
                      icon: const Icon(Icons.how_to_reg),
                      label: const Text('Register Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                ] else
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.schedule),
                    label: Text(
                      'Starts ${DateFormat('dd MMM').format(startDate)}',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    IconData icon,
    String value,
    String label, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.grey[600], size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Future<void> _registerForCampaign(String campaignId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await _campaignService.registerForCampaign(campaignId, userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Successfully registered for campaign!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCampaigns();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDonationDialog(Map<String, dynamic> campaign) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Donation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉 Congratulations on donating!\n\n'
              'You will earn ৳75 campaign bonus.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any comments...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _recordDonation(
                campaign['id'],
                notesController.text.isEmpty ? null : notesController.text,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _recordDonation(String campaignId, String? notes) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Get user blood type
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final bloodType = userDoc.data()?['bloodType'] as String? ?? 'Unknown';

      await _campaignService.recordCampaignDonation(
        campaignId: campaignId,
        donorId: userId,
        bloodType: bloodType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Donation recorded! ৳75 bonus added!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        _loadCampaigns();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
