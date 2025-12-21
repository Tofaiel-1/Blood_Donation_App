import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/blood_buddy_service.dart';
import '../../utils/app_colors.dart';

class BuddySystemScreen extends StatefulWidget {
  const BuddySystemScreen({super.key});

  @override
  State<BuddySystemScreen> createState() => _BuddySystemScreenState();
}

class _BuddySystemScreenState extends State<BuddySystemScreen>
    with SingleTickerProviderStateMixin {
  final _buddyService = BloodBuddyService();
  late TabController _tabController;
  bool _isLoading = false;
  bool _isBuddy = false;
  List<Map<String, dynamic>> _myRelationships = [];
  List<Map<String, dynamic>> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // Check if user is buddy
        final buddyDoc = await FirebaseFirestore.instance
            .collection('buddies')
            .doc(userId)
            .get();

        final relationships = await _buddyService.getMyRelationships(userId);
        final leaderboard = await _buddyService.getBuddyLeaderboard(limit: 10);

        setState(() {
          _isBuddy = buddyDoc.exists;
          _myRelationships = relationships;
          _leaderboard = leaderboard;
        });
      }
    } catch (e) {
      debugPrint('Error loading buddy data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Buddy System'),
        backgroundColor: AppColors.bloodRed,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Find Buddy'),
            Tab(icon: Icon(Icons.emoji_people), text: 'Be a Buddy'),
            Tab(icon: Icon(Icons.leaderboard), text: 'Leaderboard'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFindBuddyTab(),
          _buildBeBuddyTab(),
          _buildLeaderboardTab(),
        ],
      ),
    );
  }

  Widget _buildFindBuddyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🤝 What is a Blood Buddy?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'A Blood Buddy is an experienced donor who helps first-time donors through their donation journey. They provide guidance, answer questions, and offer moral support.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Buddy Tips
          const Text(
            '💡 What Your Buddy Will Help With:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...BloodBuddyService.buddyTips.map(
            (tip) => Card(
              child: ListTile(
                leading: Text(
                  tip['icon']!,
                  style: const TextStyle(fontSize: 28),
                ),
                title: Text(
                  tip['title']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(tip['tip']!),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Find Buddy Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _showFindBuddyDialog,
              icon: const Icon(Icons.search),
              label: const Text('Find a Buddy Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bloodRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),

          // My Relationships
          if (_myRelationships.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              '📋 My Buddy Connections',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._myRelationships.map(
              (rel) => Card(
                child: ListTile(
                  title: Text('Status: ${rel['status']}'),
                  subtitle: Text(
                    'Created: ${rel['createdAt']?.toDate().toString().split(' ')[0]}',
                  ),
                  trailing: rel['status'] == 'pending'
                      ? const Icon(Icons.pending, color: Colors.orange)
                      : const Icon(Icons.check_circle, color: Colors.green),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBeBuddyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.green.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⭐ Become a Blood Buddy',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Share your experience and help first-time donors. Guide them through their first donation and earn rewards!',
                  ),
                  SizedBox(height: 12),
                  Text(
                    '💰 Earn ৳50 for each successful mentorship!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_isBuddy) ...[
            // Already a buddy
            Card(
              color: Colors.green.shade100,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 40),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✅ You are a Blood Buddy!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Thank you for helping first-time donors!'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildBuddyStats(),
          ] else ...[
            // Register as buddy
            const Text(
              'Requirements:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.bloodtype, color: AppColors.bloodRed),
                    title: Text('Donated blood at least once'),
                  ),
                  ListTile(
                    leading: Icon(Icons.favorite, color: Colors.red),
                    title: Text('Passionate about helping others'),
                  ),
                  ListTile(
                    leading: Icon(Icons.chat, color: Colors.blue),
                    title: Text('Good communication skills'),
                  ),
                  ListTile(
                    leading: Icon(Icons.schedule, color: Colors.orange),
                    title: Text('Available to mentor first-timers'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _registerAsBuddy,
                icon: const Icon(Icons.how_to_reg),
                label: const Text('Register as Blood Buddy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _leaderboard.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Card(
            color: Colors.amber.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.emoji_events, size: 48, color: Colors.amber),
                  SizedBox(height: 8),
                  Text(
                    '🏆 Top Blood Buddies',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('Our most helpful mentors'),
                ],
              ),
            ),
          );
        }

        final buddy = _leaderboard[index - 1];
        final rank = index;
        final medal = rank == 1
            ? '🥇'
            : rank == 2
            ? '🥈'
            : rank == 3
            ? '🥉'
            : '$rank';

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: rank <= 3 ? Colors.amber : Colors.grey,
              child: Text(
                medal,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              buddy['name'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Blood Type: ${buddy['bloodType']}\n'
              '${buddy['successfulReferrals']} successful mentorships',
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                Text(
                  '${buddy['rating']?.toStringAsFixed(1)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBuddyStats() {
    return FutureBuilder<Map<String, int>>(
      future: _buddyService.getBuddyStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📊 Overall Buddy Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total Buddies', stats['totalBuddies']!),
                    _buildStatItem('Active', stats['activeBuddies']!),
                    _buildStatItem(
                      'Success Rate',
                      stats['successRate']!,
                      suffix: '%',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, int value, {String suffix = ''}) {
    return Column(
      children: [
        Text(
          '$value$suffix',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.bloodRed,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showFindBuddyDialog() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Get user data
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    final userData = userDoc.data();
    final bloodType = userData?['bloodType'] ?? 'O+';
    final location = userData?['district'] ?? 'Dhaka';

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔍 Find Your Buddy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Finding a buddy with $bloodType blood type in $location...'),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );

    try {
      final buddy = await _buddyService.findBuddy(
        bloodType: bloodType,
        location: location,
        preferredLanguage: 'Bangla',
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (buddy != null) {
        _showBuddyFoundDialog(buddy, userId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('😔 No buddy found. Please try again later.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showBuddyFoundDialog(Map<String, dynamic> buddy, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Buddy Found!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('We found a perfect buddy for you:'),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Blood Type: ${buddy['bloodType']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Location: ${buddy['location']}'),
                    Text('Mentored: ${buddy['totalMentored']} donors'),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ${buddy['rating']?.toStringAsFixed(1)}/5.0'),
                      ],
                    ),
                  ],
                ),
              ),
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
              await _sendBuddyRequest(userId, buddy['userId'] as String);
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendBuddyRequest(String userId, String buddyId) async {
    try {
      await _buddyService.createBuddyRelationship(
        newDonorId: userId,
        buddyId: buddyId,
        message: 'Hi! This is my first donation. Please guide me!',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Buddy request sent! They will respond soon.'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _registerAsBuddy() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Get user data
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    final userData = userDoc.data();
    final bloodType = userData?['bloodType'] ?? 'O+';
    final location = userData?['district'] ?? 'Dhaka';

    try {
      await _buddyService.registerAsBuddy(
        userId: userId,
        bloodType: bloodType,
        location: location,
        languages: ['Bangla', 'English'],
        specialization: 'first_timer',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🎉 You are now a Blood Buddy! Thank you for helping!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
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
