import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/emergency_contact_network_service.dart';
import '../../utils/app_colors.dart';

class EmergencyNetworkScreen extends StatefulWidget {
  const EmergencyNetworkScreen({super.key});

  @override
  State<EmergencyNetworkScreen> createState() => _EmergencyNetworkScreenState();
}

class _EmergencyNetworkScreenState extends State<EmergencyNetworkScreen>
    with SingleTickerProviderStateMixin {
  final _networkService = EmergencyContactNetworkService();
  late TabController _tabController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _myNetworks = [];
  List<Map<String, dynamic>> _availableNetworks = [];

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
        final myNetworks = await _networkService.getMyNetworks(userId);
        final available = await _networkService.searchNetworks();

        setState(() {
          _myNetworks = myNetworks;
          _availableNetworks = available
              .where((n) => !(n['members'] as List).contains(userId))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading networks: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Networks'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.group), text: 'My Networks'),
            Tab(icon: Icon(Icons.search), text: 'Join Network'),
            Tab(icon: Icon(Icons.sos), text: 'Send SOS'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyNetworksTab(),
          _buildJoinNetworkTab(),
          _buildSendSOSTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateNetworkDialog,
        backgroundColor: Colors.red.shade700,
        icon: const Icon(Icons.add),
        label: const Text('Create Network'),
      ),
    );
  }

  Widget _buildMyNetworksTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myNetworks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No networks yet',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text('Create or join a network to get started'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showCreateNetworkDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Network'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myNetworks.length,
      itemBuilder: (context, index) {
        final network = _myNetworks[index];
        final networkType = EmergencyContactNetworkService.networkTypes
            .firstWhere((t) => t['type'] == network['networkType']);

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.shade700,
              child: Text(
                networkType['icon']!,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            title: Text(
              network['networkName'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${networkType['name']}\n'
              '${network['memberCount']} members • ${network['totalAlerts']} alerts sent',
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.sos, color: Colors.red),
              onPressed: () => _sendEmergencyAlert(network),
            ),
            onTap: () => _showNetworkDetails(network),
          ),
        );
      },
    );
  }

  Widget _buildJoinNetworkTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableNetworks.isEmpty) {
      return const Center(child: Text('No available networks to join'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableNetworks.length,
      itemBuilder: (context, index) {
        final network = _availableNetworks[index];
        final networkType = EmergencyContactNetworkService.networkTypes
            .firstWhere((t) => t['type'] == network['networkType']);

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade700,
              child: Text(
                networkType['icon']!,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            title: Text(
              network['networkName'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${networkType['name']}\n'
              'Blood Type: ${network['bloodType']} • ${network['memberCount']} members',
            ),
            isThreeLine: true,
            trailing: ElevatedButton(
              onPressed: () => _joinNetwork(network['id']),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Join'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSendSOSTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.red.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sos, color: Colors.red, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '🚨 Emergency SOS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Send emergency blood request to all your networks instantly. '
                    'All members will receive immediate notification.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_myNetworks.isEmpty) ...[
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '⚠️ You need to join or create a network first to send SOS alerts.',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ),
          ] else ...[
            const Text(
              'Select Network to Alert:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._myNetworks.map((network) {
              final networkType = EmergencyContactNetworkService.networkTypes
                  .firstWhere((t) => t['type'] == network['networkType']);

              return Card(
                child: ListTile(
                  leading: Text(
                    networkType['icon']!,
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(network['networkName']),
                  subtitle: Text(
                    '${network['memberCount']} members will be notified',
                  ),
                  trailing: ElevatedButton.icon(
                    onPressed: () => _sendEmergencyAlert(network),
                    icon: const Icon(Icons.send),
                    label: const Text('Send SOS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              );
            }),
          ],

          const SizedBox(height: 20),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💰 Emergency Help Bonus',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Network members who help in emergencies earn ৳100 bonus instantly!',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateNetworkDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'family';
    String selectedBloodType = 'O+';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Emergency Network'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Network Name',
                    hintText: 'e.g., Rahman Family',
                    prefixIcon: Icon(Icons.group),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Network Type',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: EmergencyContactNetworkService.networkTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type['type'],
                          child: Text('${type['icon']} ${type['name']}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedBloodType,
                  decoration: const InputDecoration(
                    labelText: 'Blood Type',
                    prefixIcon: Icon(Icons.bloodtype),
                  ),
                  items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedBloodType = value!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Brief description...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;

                Navigator.pop(context);
                await _createNetwork(
                  nameController.text,
                  selectedType,
                  selectedBloodType,
                  descriptionController.text,
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createNetwork(
    String name,
    String type,
    String bloodType,
    String description,
  ) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await _networkService.createNetwork(
        creatorId: userId,
        networkName: name,
        networkType: type,
        bloodType: bloodType,
        description: description.isEmpty ? null : description,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Network created successfully!'),
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

  Future<void> _joinNetwork(String networkId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await _networkService.joinNetwork(networkId, userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Joined network successfully!'),
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

  void _sendEmergencyAlert(Map<String, dynamic> network) {
    final hospitalController = TextEditingController();
    final addressController = TextEditingController();
    final patientController = TextEditingController();
    final contactController = TextEditingController();
    final notesController = TextEditingController();
    String urgency = 'critical';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('🚨 Send Emergency SOS'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: hospitalController,
                  decoration: const InputDecoration(
                    labelText: 'Hospital Name *',
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Hospital Address *',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: patientController,
                  decoration: const InputDecoration(
                    labelText: 'Patient Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: urgency,
                  decoration: const InputDecoration(
                    labelText: 'Urgency Level',
                    prefixIcon: Icon(Icons.warning),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'critical',
                      child: Text('🚨 CRITICAL'),
                    ),
                    DropdownMenuItem(value: 'urgent', child: Text('⚠️ URGENT')),
                  ],
                  onChanged: (value) => setState(() => urgency = value!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Additional Notes',
                    hintText: 'Any important details...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (hospitalController.text.isEmpty ||
                    addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill required fields'),
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                await _sendAlert(
                  network['id'],
                  network['bloodType'],
                  hospitalController.text,
                  addressController.text,
                  urgency,
                  patientController.text,
                  contactController.text,
                  notesController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send SOS'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendAlert(
    String networkId,
    String bloodType,
    String hospitalName,
    String address,
    String urgency,
    String? patientName,
    String? contact,
    String? notes,
  ) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await _networkService.sendEmergencyAlert(
        networkId: networkId,
        senderId: userId,
        bloodType: bloodType,
        hospitalName: hospitalName,
        hospitalAddress: address,
        latitude: 23.8103, // Default coordinates
        longitude: 90.4125,
        urgency: urgency,
        patientName: patientName?.isEmpty == true ? null : patientName,
        contactNumber: contact?.isEmpty == true ? null : contact,
        additionalNotes: notes?.isEmpty == true ? null : notes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚨 Emergency SOS sent to all network members!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showNetworkDetails(Map<String, dynamic> network) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                network['networkName'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.bloodtype),
                title: const Text('Blood Type'),
                trailing: Text(network['bloodType']),
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Members'),
                trailing: Text('${network['memberCount']}'),
              ),
              ListTile(
                leading: const Icon(Icons.sos),
                title: const Text('Total Alerts'),
                trailing: Text('${network['totalAlerts']}'),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Successful Helps'),
                trailing: Text('${network['successfulHelps']}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
