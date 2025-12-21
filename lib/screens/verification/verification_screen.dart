import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/payment_transaction.dart';
import '../../models/user.dart' as app_user;
import '../../services/payment_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final PaymentService _paymentService = PaymentService();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.bkash;
  final TextEditingController _phoneController = TextEditingController();
  bool _isProcessing = false;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
    _loadUserPhone();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _checkVerificationStatus() async {
    final userId = auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (doc.exists) {
          final user = app_user.User.fromMap(doc.data()!);
          setState(() => _isVerified = user.isVerified);
        }
      } catch (e) {
        print('Error checking verification: $e');
      }
    }
  }

  Future<void> _loadUserPhone() async {
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

  Future<void> _processVerification() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final userId = auth.FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final result = await _paymentService.processVerificationPayment(
        userId: userId,
        paymentMethod: _selectedPaymentMethod,
        phoneNumber: _phoneController.text,
      );

      if (result['success'] == true) {
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
                  Text(result['message'] ?? 'Payment initiated successfully'),
                  const SizedBox(height: 16),
                  Text('Transaction ID: ${result['transactionId']}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Please complete the payment in your mobile banking app. Your account will be verified once payment is confirmed.',
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
        throw Exception(result['message'] ?? 'Payment failed');
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
    if (_isVerified) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Verification'),
          backgroundColor: Colors.green,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user, size: 120, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                'You are Verified!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Your account has been verified. You now have a verified badge on your profile.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Verified'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.green, Colors.greenAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.verified, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Get Your Verified Badge',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'One-time fee: ৳50',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Benefits
            const Text(
              'Benefits of Verification',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildBenefitItem('✓ Verified badge on your profile'),
            _buildBenefitItem('✓ Increased trust from donors/recipients'),
            _buildBenefitItem('✓ Priority in search results'),
            _buildBenefitItem('✓ Access to premium features'),
            _buildBenefitItem('✓ Stand out from other users'),

            const SizedBox(height: 32),

            // Payment Method
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildPaymentMethodChip(
                  PaymentMethod.bkash,
                  'bKash',
                  Icons.account_balance_wallet,
                ),
                _buildPaymentMethodChip(
                  PaymentMethod.nagad,
                  'Nagad',
                  Icons.payment,
                ),
                _buildPaymentMethodChip(
                  PaymentMethod.rocket,
                  'Rocket',
                  Icons.rocket,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Phone Number
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                hintText:
                    'Enter your ${_selectedPaymentMethod.toString().split('.').last} number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 32),

            // Get Verified Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Get Verified for ৳50',
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
              'By proceeding, you agree to pay ৳50 for account verification. '
              'This is a one-time payment.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(benefit, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodChip(
    PaymentMethod method,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedPaymentMethod == method;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedPaymentMethod = method);
        }
      },
      selectedColor: Colors.green.shade100,
      checkmarkColor: Colors.green,
    );
  }
}
