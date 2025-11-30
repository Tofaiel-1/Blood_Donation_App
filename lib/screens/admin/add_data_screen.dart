import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/donation_center.dart';
import '../../utils/app_colors.dart';

class AddDataScreen extends StatefulWidget {
  const AddDataScreen({super.key});

  @override
  State<AddDataScreen> createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Add Data to System'),
        backgroundColor: AppColors.bloodRed,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.location_on), text: 'Centers'),
            Tab(icon: Icon(Icons.bloodtype), text: 'Request'),
            Tab(icon: Icon(Icons.favorite), text: 'Donation'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDonationCentersTab(),
          _buildBloodRequestTab(),
          _buildDonationTab(),
          _buildUsersTab(),
        ],
      ),
    );
  }

  // ==================== DONATION CENTERS TAB ====================
  Widget _buildDonationCentersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'ডোনেশন সেন্টার যোগ করুন',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ঢাকার ১০টি প্রধান রক্তদান কেন্দ্র অটোমেটিক যুক্ত করুন',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _addDefaultDonationCenters,
            icon: const Icon(Icons.add_location),
            label: const Text('Add Default Centers (10)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showAddCustomCenterDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Custom Center'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 24),
          _buildCentersList(),
        ],
      ),
    );
  }

  Widget _buildCentersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donationCenters')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final centers = snapshot.data?.docs ?? [];

        if (centers.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No donation centers added yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Added Centers (${centers.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...centers.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.bloodRed,
                    child: const Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(data['name'] ?? 'Unknown'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['address'] ?? ''),
                      Text(
                        'Area: ${data['area'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCenter(doc.id, data['name']),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // ==================== BLOOD REQUEST TAB ====================
  Widget _buildBloodRequestTab() {
    final patientNameController = TextEditingController();
    final bloodTypeController = TextEditingController();
    final unitsController = TextEditingController(text: '1');
    final hospitalController = TextEditingController();
    final locationController = TextEditingController();
    final phoneController = TextEditingController();
    final notesController = TextEditingController();
    String urgency = 'urgent';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bloodtype, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Text(
                        'নতুন রক্তের রিকোয়েস্ট যোগ করুন',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: patientNameController,
            decoration: const InputDecoration(
              labelText: 'Patient Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: bloodTypeController.text.isEmpty
                ? null
                : bloodTypeController.text,
            decoration: const InputDecoration(
              labelText: 'Blood Type',
              prefixIcon: Icon(Icons.bloodtype),
              border: OutlineInputBorder(),
            ),
            items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) => bloodTypeController.text = value ?? '',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: unitsController,
            decoration: const InputDecoration(
              labelText: 'Units Needed',
              prefixIcon: Icon(Icons.numbers),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: hospitalController,
            decoration: const InputDecoration(
              labelText: 'Hospital Name',
              prefixIcon: Icon(Icons.local_hospital),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Contact Phone',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: urgency,
            decoration: const InputDecoration(
              labelText: 'Urgency',
              prefixIcon: Icon(Icons.priority_high),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'critical', child: Text('Critical')),
              DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
              DropdownMenuItem(value: 'normal', child: Text('Normal')),
            ],
            onChanged: (value) => urgency = value ?? 'urgent',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              prefixIcon: Icon(Icons.notes),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addBloodRequest(
              patientNameController.text,
              bloodTypeController.text,
              int.tryParse(unitsController.text) ?? 1,
              hospitalController.text,
              locationController.text,
              phoneController.text,
              urgency,
              notesController.text,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Blood Request'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bloodRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DONATION TAB ====================
  Widget _buildDonationTab() {
    final donorNameController = TextEditingController();
    final bloodTypeController = TextEditingController();
    final locationController = TextEditingController();
    final centerController = TextEditingController();
    final notesController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'নতুন ডোনেশন রেকর্ড যোগ করুন',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: donorNameController,
            decoration: const InputDecoration(
              labelText: 'Donor Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: bloodTypeController.text.isEmpty
                ? null
                : bloodTypeController.text,
            decoration: const InputDecoration(
              labelText: 'Blood Type',
              prefixIcon: Icon(Icons.bloodtype),
              border: OutlineInputBorder(),
            ),
            items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) => bloodTypeController.text = value ?? '',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: centerController,
            decoration: const InputDecoration(
              labelText: 'Donation Center',
              prefixIcon: Icon(Icons.local_hospital),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              prefixIcon: Icon(Icons.notes),
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addDonation(
              donorNameController.text,
              bloodTypeController.text,
              locationController.text,
              centerController.text,
              notesController.text,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Donation Record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== USERS TAB ====================
  Widget _buildUsersTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'User Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Users can sign up through the app.\nDemo users can be added via Demo Data screen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/demo-data'),
              icon: const Icon(Icons.data_object),
              label: const Text('Go to Demo Data'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== FUNCTIONS ====================
  Future<void> _addDefaultDonationCenters() async {
    setState(() => _isLoading = true);

    try {
      final centers = DhakaDonationCenters.getDefaultCenters();
      final batch = FirebaseFirestore.instance.batch();

      for (var centerData in centers) {
        final docRef = FirebaseFirestore.instance
            .collection('donationCenters')
            .doc();
        batch.set(docRef, {
          ...centerData,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${centers.length} donation centers added successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddCustomCenterDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final areaController = TextEditingController();
    final latController = TextEditingController();
    final lonController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Center'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Center Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: areaController,
                decoration: const InputDecoration(
                  labelText: 'Area',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: latController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lonController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
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
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill required fields')),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection('donationCenters')
                    .add({
                      'name': nameController.text,
                      'address': addressController.text,
                      'area': areaController.text,
                      'latitude':
                          double.tryParse(latController.text) ?? 23.8103,
                      'longitude':
                          double.tryParse(lonController.text) ?? 90.4125,
                      'phone': phoneController.text,
                      'type': 'hospital',
                      'availableBloodTypes': ['A+', 'B+', 'O+', 'AB+'],
                      'isActive': true,
                      'workingHours': {
                        'Saturday': '9:00 AM - 5:00 PM',
                        'Sunday': '9:00 AM - 5:00 PM',
                        'Monday': '9:00 AM - 5:00 PM',
                        'Tuesday': '9:00 AM - 5:00 PM',
                        'Wednesday': '9:00 AM - 5:00 PM',
                        'Thursday': '9:00 AM - 5:00 PM',
                        'Friday': 'Closed',
                      },
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Center added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCenter(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Center'),
        content: Text('Delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('donationCenters')
            .doc(id)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Center deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _addBloodRequest(
    String patientName,
    String bloodType,
    int units,
    String hospital,
    String location,
    String phone,
    String urgency,
    String notes,
  ) async {
    if (patientName.isEmpty || bloodType.isEmpty || hospital.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('bloodRequests').add({
        'patientName': patientName,
        'bloodType': bloodType,
        'unitsNeeded': units,
        'hospitalName': hospital,
        'location': location,
        'contactPhone': phone,
        'urgency': urgency,
        'status': 'pending',
        'requestDate': FieldValue.serverTimestamp(),
        'requestedByName': 'Super Admin',
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Blood request added successfully!'),
            backgroundColor: Colors.green,
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

  Future<void> _addDonation(
    String donorName,
    String bloodType,
    String location,
    String center,
    String notes,
  ) async {
    if (donorName.isEmpty || bloodType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('donations').add({
        'donorName': donorName,
        'bloodType': bloodType,
        'location': location,
        'center': center,
        'donationDate': FieldValue.serverTimestamp(),
        'status': 'completed',
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Donation record added successfully!'),
            backgroundColor: Colors.green,
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
}
