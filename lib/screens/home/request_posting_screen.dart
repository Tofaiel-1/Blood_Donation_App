import 'package:flutter/material.dart';

class RequestPostingScreen extends StatefulWidget {
  final String? initialBloodType;
  final String? initialHospital;
  final String? initialUrgency; // 'Urgent' | 'Critical'
  final String? initialNote;

  const RequestPostingScreen({
    super.key,
    this.initialBloodType,
    this.initialHospital,
    this.initialUrgency,
    this.initialNote,
  });

  @override
  State<RequestPostingScreen> createState() => _RequestPostingScreenState();
}

class _RequestPostingScreenState extends State<RequestPostingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalController = TextEditingController();
  final _noteController = TextEditingController();
  String? _bloodType;
  String _urgency = 'Urgent';

  @override
  void initState() {
    super.initState();
    _bloodType = widget.initialBloodType;
    _hospitalController.text = widget.initialHospital ?? '';
    _urgency = (widget.initialUrgency == 'Critical') ? 'Critical' : 'Urgent';
    _noteController.text = widget.initialNote ?? '';
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Emergency Request'),
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _bloodType,
                decoration: InputDecoration(
                  labelText: 'Blood Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _bloodType = v),
                validator: (v) =>
                    v == null ? 'Please select a blood type' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hospitalController,
                decoration: InputDecoration(
                  labelText: 'Hospital/Location',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Urgency',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Urgent'),
                      selected: _urgency == 'Urgent',
                      onSelected: (_) => setState(() => _urgency = 'Urgent'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Critical'),
                      selected: _urgency == 'Critical',
                      onSelected: (_) => setState(() => _urgency = 'Critical'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Details (optional)',
                  prefixIcon: const Icon(Icons.notes),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.bolt),
                  label: const Text('Post Emergency Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emergency request posted (mock)')),
    );
    Navigator.pop(context);
  }
}
