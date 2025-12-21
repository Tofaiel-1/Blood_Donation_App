import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../models/premium_subscription.dart';
import '../../models/payment_transaction.dart';
import '../../services/payment_service.dart';

class PremiumMembershipScreen extends StatefulWidget {
  const PremiumMembershipScreen({super.key});

  @override
  State<PremiumMembershipScreen> createState() =>
      _PremiumMembershipScreenState();
}

class _PremiumMembershipScreenState extends State<PremiumMembershipScreen> {
  final PaymentService _paymentService = PaymentService();
  SubscriptionPlan _selectedPlan = SubscriptionPlan.monthly;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.bkash;
  final TextEditingController _phoneController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _subscribeToPremium() async {
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

      final result = await _paymentService.processPremiumSubscription(
        userId: userId,
        plan: _selectedPlan,
        paymentMethod: _selectedPaymentMethod,
        phoneNumber: _phoneController.text,
      );

      if (result['success'] == true) {
        // Show success dialog
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
                    'Please complete the payment in your mobile banking app. Your premium membership will be activated once payment is confirmed.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to previous screen
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

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isSelected = _selectedPlan == plan;
    final price = PremiumSubscription.getPlanPrice(plan);
    final name = PremiumSubscription.getPlanName(plan);

    String duration;
    String savings = '';
    switch (plan) {
      case SubscriptionPlan.monthly:
        duration = '1 Month';
        break;
      case SubscriptionPlan.quarterly:
        duration = '3 Months';
        savings = 'Save ৳50';
        break;
      case SubscriptionPlan.yearly:
        duration = '12 Months';
        savings = 'Save ৳300';
        break;
      default:
        duration = '';
    }

    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? Colors.red : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedPlan = plan),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (savings.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    savings,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (savings.isNotEmpty) const SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.red : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '৳${price.toInt()}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              Text(
                duration,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? Colors.red : Colors.grey,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(feature, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Membership'),
        backgroundColor: Colors.red,
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
                  colors: [Colors.red, Colors.redAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.stars, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Become a Premium Member',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get exclusive benefits and help more people',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Premium Features
            const Text(
              'Premium Benefits',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem('⭐ Priority listing in search results'),
            _buildFeatureItem('✅ Verified badge on your profile'),
            _buildFeatureItem('💬 Unlimited messages to donors/recipients'),
            _buildFeatureItem('🚨 Post emergency blood requests'),
            _buildFeatureItem('📊 Advanced donation statistics'),
            _buildFeatureItem('🔔 Priority notifications'),
            _buildFeatureItem('📱 Ad-free experience'),

            const SizedBox(height: 32),

            // Plan Selection
            const Text(
              'Choose Your Plan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
              children: [
                _buildPlanCard(SubscriptionPlan.monthly),
                _buildPlanCard(SubscriptionPlan.quarterly),
                _buildPlanCard(SubscriptionPlan.yearly),
              ],
            ),

            const SizedBox(height: 32),

            // Payment Method
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

            // Subscribe Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _subscribeToPremium,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Subscribe for ৳${PremiumSubscription.getPlanPrice(_selectedPlan).toInt()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Terms
            Text(
              'By subscribing, you agree to our Terms of Service and Privacy Policy. '
              'Subscription will auto-renew unless cancelled.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
      selectedColor: Colors.red.shade100,
      checkmarkColor: Colors.red,
    );
  }
}
