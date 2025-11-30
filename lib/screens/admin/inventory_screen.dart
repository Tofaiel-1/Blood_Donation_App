import 'package:flutter/material.dart';
import '../../services/inventory_service.dart';
import '../../utils/app_colors.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InventoryService inventoryService = InventoryService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Inventory'),
        backgroundColor: AppColors.bloodRed,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<Map<String, int>>(
        stream: inventoryService.getBloodStock(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final stock = snapshot.data!;
          final bloodTypes = stock.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bloodTypes.length,
            itemBuilder: (context, index) {
              final type = bloodTypes[index];
              final count = stock[type]!;
              final isLow = count < 5;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isLow
                        ? Colors.red[100]
                        : Colors.green[100],
                    child: Text(
                      type,
                      style: TextStyle(
                        color: isLow ? Colors.red : Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    '$count Units',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isLow ? Colors.red : Colors.black,
                    ),
                  ),
                  subtitle: isLow
                      ? const Text(
                          'Low Stock Warning!',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        )
                      : const Text('Stock Level: Normal'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Colors.red,
                        onPressed: () =>
                            _showUpdateDialog(context, type, false),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: Colors.green,
                        onPressed: () => _showUpdateDialog(context, type, true),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUpdateDialog(
    BuildContext context,
    String bloodType,
    bool isAdding,
  ) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String reason = isAdding ? 'donation' : 'usage';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isAdding ? 'Add Stock: $bloodType' : 'Remove Stock: $bloodType',
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity (Units)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (int.tryParse(v) == null || int.parse(v) <= 0) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: reason,
                decoration: const InputDecoration(labelText: 'Reason'),
                items:
                    (isAdding
                            ? ['donation', 'transfer', 'correction']
                            : ['usage', 'expired', 'transfer', 'correction'])
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.toUpperCase()),
                          ),
                        )
                        .toList(),
                onChanged: (v) => reason = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
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
              if (formKey.currentState!.validate()) {
                try {
                  final qty = int.parse(quantityController.text);
                  await InventoryService().updateStock(
                    bloodType: bloodType,
                    quantity: isAdding ? qty : -qty,
                    reason: reason,
                    notes: notesController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Stock updated successfully'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAdding ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isAdding ? 'Add' : 'Remove'),
          ),
        ],
      ),
    );
  }
}
