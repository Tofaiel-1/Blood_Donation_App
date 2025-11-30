import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utils/app_colors.dart';

class ManageOrgsDialog extends StatefulWidget {
  const ManageOrgsDialog({super.key});

  @override
  State<ManageOrgsDialog> createState() => _ManageOrgsDialogState();
}

class _ManageOrgsDialogState extends State<ManageOrgsDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
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
                    Icon(Icons.business, color: AppColors.bloodRed, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Manage Organizations',
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

            // Search and Add button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search organizations...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showAddOrgDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Org'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bloodRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Organizations List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'orgAdmin')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var orgs = snapshot.data?.docs ?? [];

                  // Get unique organizations
                  final orgMap = <String, List<QueryDocumentSnapshot>>{};
                  for (var doc in orgs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final orgName =
                        data['organization'] ?? 'Unknown Organization';
                    orgMap.putIfAbsent(orgName, () => []).add(doc);
                  }

                  // Filter by search
                  if (_searchQuery.isNotEmpty) {
                    orgMap.removeWhere(
                      (key, value) => !key.toLowerCase().contains(_searchQuery),
                    );
                  }

                  if (orgMap.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No organizations found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _showAddOrgDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add First Organization'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: orgMap.length,
                    itemBuilder: (context, index) {
                      final orgName = orgMap.keys.elementAt(index);
                      final admins = orgMap[orgName]!;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.bloodRed.withValues(
                              alpha: 0.1,
                            ),
                            child: Icon(
                              Icons.business,
                              color: AppColors.bloodRed,
                            ),
                          ),
                          title: Text(
                            orgName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${admins.length} admin(s)'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showEditOrgDialog(
                                  context,
                                  orgName,
                                  admins,
                                ),
                                tooltip: 'Edit',
                              ),
                              const Icon(Icons.expand_more),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Organization Admins:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...admins.map((doc) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    return ListTile(
                                      dense: true,
                                      leading: CircleAvatar(
                                        radius: 16,
                                        child: Text(
                                          (data['name'] ?? 'A')[0]
                                              .toUpperCase(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      title: Text(data['name'] ?? 'Unknown'),
                                      subtitle: Text(data['email'] ?? ''),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (data['isActive'] ?? true)
                                              ? Colors.green[100]
                                              : Colors.red[100],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          (data['isActive'] ?? true)
                                              ? 'Active'
                                              : 'Inactive',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: (data['isActive'] ?? true)
                                                ? Colors.green[800]
                                                : Colors.red[800],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            _deleteOrg(orgName, admins),
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 16,
                                        ),
                                        label: const Text('Delete Org'),
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
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOrgDialog(BuildContext context) {
    final nameController = TextEditingController();
    final adminNameController = TextEditingController();
    final adminEmailController = TextEditingController();
    final adminPhoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.add_business, color: Colors.blue),
            SizedBox(width: 12),
            Text('Add Organization'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Organization Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text(
                'Primary Admin Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: adminNameController,
                decoration: const InputDecoration(
                  labelText: 'Admin Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: adminEmailController,
                decoration: const InputDecoration(
                  labelText: 'Admin Email *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: adminPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Admin Phone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
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
              if (nameController.text.isEmpty ||
                  adminNameController.text.isEmpty ||
                  adminEmailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill required fields'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              try {
                await FirebaseFirestore.instance.collection('users').add({
                  'name': adminNameController.text,
                  'email': adminEmailController.text,
                  'phone': adminPhoneController.text,
                  'organization': nameController.text,
                  'role': 'orgAdmin',
                  'isActive': true,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Organization added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Add Organization'),
          ),
        ],
      ),
    );
  }

  void _showEditOrgDialog(
    BuildContext context,
    String orgName,
    List<QueryDocumentSnapshot> admins,
  ) {
    final nameController = TextEditingController(text: orgName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Organization'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Organization Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              try {
                // Update all admins with new org name
                for (var doc in admins) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(doc.id)
                      .update({'organization': nameController.text});
                }

                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Organization updated!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOrg(
    String orgName,
    List<QueryDocumentSnapshot> admins,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Organization?'),
        content: Text(
          'This will remove "$orgName" and all its admins. This action cannot be undone.',
        ),
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

    if (confirmed != true || !mounted) return;

    try {
      for (var doc in admins) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .delete();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Organization deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
