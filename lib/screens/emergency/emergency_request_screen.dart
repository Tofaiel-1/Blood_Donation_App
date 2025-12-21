import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/payment_transaction.dart';
import '../../models/user.dart' as app_user;
import '../../services/emergency_request_service.dart';
import '../../services/payment_service.dart';
import '../../services/location_service.dart';

class EmergencyRequestScreen extends StatefulWidget {
  const EmergencyRequestScreen({super.key});

  @override
  State<EmergencyRequestScreen> createState() => _EmergencyRequestScreenState();
}

class _EmergencyRequestScreenState extends State<EmergencyRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final EmergencyRequestService _emergencyService = EmergencyRequestService();
  final PaymentService _paymentService = PaymentService();

  String? _selectedBloodGroup;
  String _selectedUrgency = 'urgent';
  int _unitsNeeded = 1;
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.bkash;

  double? _latitude;
  double? _longitude;
  String? _address;
  bool _isLoadingLocation = false;
  bool _isProcessing = false;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];
  final List<String> _urgencyLevels = ['critical', 'urgent', 'moderate'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _messageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userId = auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (doc.exists) {
          final user = app_user.User.fromMap(doc.data()!);
          setState(() {
            _phoneController.text = user.phone ?? '';
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _address =
              'Lat: ${position.latitude.toStringAsFixed(4)}, '
              'Lng: ${position.longitude.toStringAsFixed(4)}';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not get location: $e')));
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _submitEmergencyRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a blood group')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final userId = auth.FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!userDoc.exists) throw Exception('User data not found');

      final user = app_user.User.fromMap(userDoc.data()!);

      // Create emergency request
      final request = await _emergencyService.createEmergencyRequest(
        userId: userId,
        userName: user.name,
        userPhone: _phoneController.text,
        bloodGroup: _selectedBloodGroup!,
        hospitalName: _hospitalController.text.isNotEmpty
            ? _hospitalController.text
            : null,
        location: _address,
        address: _address,
        latitude: _latitude,
        longitude: _longitude,
        urgencyLevel: _selectedUrgency,
        message: _messageController.text.isNotEmpty
            ? _messageController.text
            : null,
        unitsNeeded: _unitsNeeded,
      );

      // Process payment
      final paymentResult = await _paymentService
          .processEmergencyRequestPayment(
            userId: userId,
            emergencyRequestId: request.id,
            paymentMethod: _selectedPaymentMethod,
            phoneNumber: _phoneController.text,
          );

      if (paymentResult['success'] == true) {
        // Show payment success dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Payment Initiated'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your emergency request has been created!'),
                  const SizedBox(height: 16),
                  Text('Transaction ID: ${paymentResult['transactionId']}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Please complete the payment in your mobile banking app. '
                    'Once confirmed, we will notify all nearby donors immediately.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception(paymentResult['message'] ?? 'Payment failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Blood Request'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: Colors.red,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Emergency Service',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Service Fee: ৳150\nAll nearby donors will be notified immediately',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Blood Group Selection
              const Text(
                'Blood Group Needed *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _bloodGroups.map((bloodGroup) {
                  final isSelected = _selectedBloodGroup == bloodGroup;
                  return FilterChip(
                    selected: isSelected,
                    label: Text(bloodGroup),
                    onSelected: (selected) {
                      setState(() => _selectedBloodGroup = bloodGroup);
                    },
                    selectedColor: Colors.red,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Urgency Level
              const Text(
                'Urgency Level *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _urgencyLevels.map((level) {
                  final isSelected = _selectedUrgency == level;
                  return ChoiceChip(
                    label: Text(level.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedUrgency = level);
                    },
                    selectedColor: level == 'critical'
                        ? Colors.red.shade700
                        : level == 'urgent'
                        ? Colors.orange
                        : Colors.yellow.shade700,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Units Needed
              const Text(
                'Units Needed',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_unitsNeeded > 1) {
                        setState(() => _unitsNeeded--);
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_unitsNeeded',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_unitsNeeded < 10) {
                        setState(() => _unitsNeeded++);
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    color: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Hospital Name
              TextFormField(
                controller: _hospitalController,
                decoration: InputDecoration(
                  labelText: 'Hospital/Clinic Name',
                  prefixIcon: const Icon(Icons.local_hospital),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Location
              Card(
                child: ListTile(
                  leading: _isLoadingLocation
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.location_on, color: Colors.red),
                  title: const Text('Current Location'),
                  subtitle: Text(_address ?? 'Getting location...'),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _getCurrentLocation,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Message
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Additional Message',
                  hintText: 'Provide any additional details...',
                  prefixIcon: const Icon(Icons.message),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Divider(),
              const SizedBox(height: 16),

              // Payment Section
              const Text(
                'Payment Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Payment Method
              const Text('Select Payment Method'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildPaymentMethodChip(PaymentMethod.bkash, 'bKash'),
                  _buildPaymentMethodChip(PaymentMethod.nagad, 'Nagad'),
                  _buildPaymentMethodChip(PaymentMethod.rocket, 'Rocket'),
                ],
              ),

              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Mobile Number *',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _submitEmergencyRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Emergency Request (৳150)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                '* By submitting, you agree to pay ৳150 for emergency notification service.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodChip(PaymentMethod method, String label) {
    final isSelected = _selectedPaymentMethod == method;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedPaymentMethod = method);
        }
      },
      selectedColor: Colors.red.shade100,
      checkmarkColor: Colors.red,
    );
  }
}
