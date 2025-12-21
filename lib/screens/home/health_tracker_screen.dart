import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/donor_health_tracker_service.dart';
import '../../utils/app_colors.dart';

class HealthTrackerScreen extends StatefulWidget {
  const HealthTrackerScreen({super.key});

  @override
  State<HealthTrackerScreen> createState() => _HealthTrackerScreenState();
}

class _HealthTrackerScreenState extends State<HealthTrackerScreen> {
  final _healthService = DonorHealthTrackerService();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _hemoglobinController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _weightController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _pulseController = TextEditingController();
  final _sleepController = TextEditingController();
  final _notesController = TextEditingController();

  String _hydrationLevel = 'good';
  DateTime _lastMealTime = DateTime.now().subtract(const Duration(hours: 3));
  List<String> _medications = [];
  bool _isLoading = false;
  Map<String, dynamic>? _latestRecord;
  List<Map<String, dynamic>> _healthHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  @override
  void dispose() {
    _hemoglobinController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _weightController.dispose();
    _temperatureController.dispose();
    _pulseController.dispose();
    _sleepController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadHealthData() async {
    setState(() => _isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final latest = await _healthService.getLatestHealthRecord(userId);
        final history = await _healthService.getHealthHistory(userId, limit: 5);
        setState(() {
          _latestRecord = latest;
          _healthHistory = history;
        });
      }
    } catch (e) {
      debugPrint('Error loading health data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveHealthRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      await _healthService.saveHealthRecord(
        userId: userId,
        hemoglobinLevel: double.parse(_hemoglobinController.text),
        bloodPressure:
            '${_systolicController.text}/${_diastolicController.text}',
        weight: double.parse(_weightController.text),
        temperature: double.parse(_temperatureController.text),
        pulse: int.parse(_pulseController.text),
        sleepHours: int.parse(_sleepController.text),
        hydrationLevel: _hydrationLevel,
        lastMealTime: _lastMealTime,
        medications: _medications.isEmpty ? null : _medications,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Health record saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadHealthData();
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _hemoglobinController.clear();
    _systolicController.clear();
    _diastolicController.clear();
    _weightController.clear();
    _temperatureController.clear();
    _pulseController.clear();
    _sleepController.clear();
    _notesController.clear();
    setState(() {
      _hydrationLevel = 'good';
      _medications = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Tracker'),
        backgroundColor: AppColors.bloodRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHealthHistory(),
            tooltip: 'Health History',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Latest Health Score Card
                  if (_latestRecord != null) _buildHealthScoreCard(),
                  const SizedBox(height: 20),

                  // Health Check Form
                  _buildHealthForm(),
                  const SizedBox(height: 20),

                  // Pre-Donation Checklist
                  _buildPreDonationChecklist(),
                  const SizedBox(height: 20),

                  // Post-Donation Care Tips
                  _buildPostDonationCare(),
                ],
              ),
            ),
    );
  }

  Widget _buildHealthScoreCard() {
    final score = _latestRecord!['eligibilityScore'] ?? 0;
    final isEligible = _latestRecord!['isEligible'] ?? false;
    final recommendations = _healthService.getHealthRecommendations(
      _latestRecord!,
    );

    return Card(
      color: isEligible ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isEligible ? Colors.green : Colors.orange,
                  child: Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEligible ? '✅ Eligible to Donate' : '⚠️ Not Eligible',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isEligible ? Colors.green : Colors.orange,
                        ),
                      ),
                      const Text('Health Score: Based on latest metrics'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              '💡 Recommendations:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(child: Text(rec)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📋 Health Check Form',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Hemoglobin
              TextFormField(
                controller: _hemoglobinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Hemoglobin Level (g/dL)',
                  hintText: 'e.g., 14.5',
                  prefixIcon: Icon(Icons.bloodtype),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final val = double.tryParse(value);
                  if (val == null || val < 8 || val > 20)
                    return 'Invalid value (8-20)';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Blood Pressure
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _systolicController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Systolic',
                        hintText: '120',
                        prefixIcon: Icon(Icons.favorite),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final val = int.tryParse(value);
                        if (val == null || val < 80 || val > 180)
                          return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('/', style: TextStyle(fontSize: 24)),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _diastolicController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Diastolic',
                        hintText: '80',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final val = int.tryParse(value);
                        if (val == null || val < 50 || val > 120)
                          return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Weight
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  hintText: 'e.g., 65',
                  prefixIcon: Icon(Icons.monitor_weight),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final val = double.tryParse(value);
                  if (val == null || val < 30 || val > 200)
                    return 'Invalid value';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Temperature & Pulse
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _temperatureController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Temp (°C)',
                        hintText: '36.8',
                        prefixIcon: Icon(Icons.thermostat),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final val = double.tryParse(value);
                        if (val == null || val < 35 || val > 42)
                          return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _pulseController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Pulse (bpm)',
                        hintText: '72',
                        prefixIcon: Icon(Icons.heart_broken),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final val = int.tryParse(value);
                        if (val == null || val < 40 || val > 120)
                          return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Sleep Hours
              TextFormField(
                controller: _sleepController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sleep Hours (last night)',
                  hintText: '8',
                  prefixIcon: Icon(Icons.bedtime),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final val = int.tryParse(value);
                  if (val == null || val < 0 || val > 24) return 'Invalid';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Hydration Level
              DropdownButtonFormField<String>(
                value: _hydrationLevel,
                decoration: const InputDecoration(
                  labelText: 'Hydration Level',
                  prefixIcon: Icon(Icons.water_drop),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'good', child: Text('😊 Good')),
                  DropdownMenuItem(
                    value: 'moderate',
                    child: Text('😐 Moderate'),
                  ),
                  DropdownMenuItem(value: 'low', child: Text('😰 Low')),
                ],
                onChanged: (value) => setState(() => _hydrationLevel = value!),
              ),
              const SizedBox(height: 12),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (optional)',
                  hintText: 'Any health concerns...',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveHealthRecord,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Health Record'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bloodRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreDonationChecklist() {
    final checklist = DonorHealthTrackerService.preDonationChecklist;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ Pre-Donation Checklist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...checklist.map(
              (item) => ListTile(
                leading: Text(
                  item['icon'] as String,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(item['item'] as String),
                subtitle: Text('Importance: ${item['importance']}'),
                dense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostDonationCare() {
    final care = DonorHealthTrackerService.postDonationCare;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💊 Post-Donation Care Tips',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...care.map(
              (item) => ListTile(
                leading: Text(
                  item['icon'] as String,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(item['tip'] as String),
                subtitle: Text('Duration: ${item['duration']}'),
                dense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHealthHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                '📊 Health History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _healthHistory.length,
                  itemBuilder: (context, index) {
                    final record = _healthHistory[index];
                    final score = record['eligibilityScore'] ?? 0;
                    final isEligible = record['isEligible'] ?? false;
                    final timestamp = record['timestamp'];
                    final date = timestamp != null
                        ? (timestamp as dynamic).toDate().toString().split(
                            ' ',
                          )[0]
                        : 'Unknown';

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isEligible
                              ? Colors.green
                              : Colors.orange,
                          child: Text(
                            '$score',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          isEligible ? '✅ Eligible' : '⚠️ Not Eligible',
                        ),
                        subtitle: Text(
                          'Date: $date\nHb: ${record['hemoglobinLevel']} g/dL, BP: ${record['bloodPressure']}',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
