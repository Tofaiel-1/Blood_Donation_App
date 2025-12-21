import 'package:flutter/material.dart';
import '../../services/advance_booking_service.dart';
import '../../services/payment_service.dart';
import 'booking_success_screen.dart';

class BookingPaymentScreen extends StatefulWidget {
  final String bookingId;
  final double totalAmount;

  const BookingPaymentScreen({
    Key? key,
    required this.bookingId,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<BookingPaymentScreen> createState() => _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends State<BookingPaymentScreen> {
  String _selectedMethod = 'bkash';
  bool _isProcessing = false;
  final _advanceBookingService = AdvanceBookingService();
  final _paymentService = PaymentService();

  final Map<String, Map<String, dynamic>> _paymentMethods = {
    'bkash': {
      'name': 'bKash',
      'icon': 'assets/bkash.png',
      'color': Colors.pink,
      'number': '01XXXXXXXXX',
    },
    'nagad': {
      'name': 'Nagad',
      'icon': 'assets/nagad.png',
      'color': Colors.orange,
      'number': '01XXXXXXXXX',
    },
    'rocket': {
      'name': 'Rocket',
      'icon': 'assets/rocket.png',
      'color': Colors.purple,
      'number': '01XXXXXXXXX',
    },
    'card': {
      'name': 'ক্রেডিট/ডেবিট কার্ড',
      'icon': 'assets/card.png',
      'color': Colors.blue,
      'number': null,
    },
  };

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      // In real implementation, integrate with actual payment gateway
      // For now, simulating payment

      await Future.delayed(const Duration(seconds: 2));

      // Generate mock transaction ID
      final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';

      // Confirm payment in database
      await _advanceBookingService.confirmPayment(
        bookingId: widget.bookingId,
        paymentMethod: _selectedMethod,
        transactionId: transactionId,
      );

      setState(() => _isProcessing = false);

      // Navigate to success screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingSuccessScreen(
              bookingId: widget.bookingId,
              transactionId: transactionId,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('পেমেন্ট ব্যর্থ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('পেমেন্ট'), backgroundColor: Colors.red),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('পেমেন্ট প্রসেস হচ্ছে...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Card
                  _buildAmountCard(),
                  const SizedBox(height: 24),

                  // Payment Methods
                  const Text(
                    'পেমেন্ট মাধ্যম নির্বাচন করুন',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  ...(_paymentMethods.entries.map((entry) {
                    return _buildPaymentMethodCard(entry.key, entry.value);
                  }).toList()),

                  const SizedBox(height: 24),

                  // Instructions
                  if (_selectedMethod != 'card') _buildInstructions(),

                  const SizedBox(height: 24),

                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'পেমেন্ট করুন - ৳${widget.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Security Notice
                  Card(
                    color: Colors.blue.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.security, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'আপনার পেমেন্ট সম্পূর্ণ নিরাপদ এবং এনক্রিপ্টেড',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAmountCard() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'পেমেন্ট পরিমাণ',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '৳${widget.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'বুকিং ID: ${widget.bookingId.substring(0, 8).toUpperCase()}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(String key, Map<String, dynamic> method) {
    final isSelected = _selectedMethod == key;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? method['color'].withOpacity(0.1) : null,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = key),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon/Logo
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: method['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getPaymentIcon(key),
                  color: method['color'],
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),

              // Name and Number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? method['color'] : null,
                      ),
                    ),
                    if (method['number'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        method['number'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Selection Indicator
              Radio<String>(
                value: key,
                groupValue: _selectedMethod,
                onChanged: (value) {
                  if (value != null) setState(() => _selectedMethod = value);
                },
                activeColor: method['color'],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'bkash':
        return Icons.phone_android;
      case 'nagad':
        return Icons.phone_iphone;
      case 'rocket':
        return Icons.rocket_launch;
      case 'card':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  Widget _buildInstructions() {
    final method = _paymentMethods[_selectedMethod]!;

    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.info, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'পেমেন্ট নির্দেশনা',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '১. আপনার ${method['name']} অ্যাপ খুলুন\n'
              '২. "সেন্ড মানি" নির্বাচন করুন\n'
              '৩. নম্বর: ${method['number']}\n'
              '৪. পরিমাণ: ৳${widget.totalAmount.toStringAsFixed(0)}\n'
              '৫. রেফারেন্স: ${widget.bookingId.substring(0, 8).toUpperCase()}\n'
              '৬. পেমেন্ট সম্পূর্ণ করুন\n'
              '৭. নিচের "পেমেন্ট করুন" বাটনে ক্লিক করুন',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
