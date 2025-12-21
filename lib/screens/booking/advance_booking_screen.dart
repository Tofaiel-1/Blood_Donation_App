import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/advance_booking.dart';
import '../../services/advance_booking_service.dart';
import '../../utils/bangladesh_locations.dart';
import 'booking_payment_screen.dart';

class AdvanceBookingScreen extends StatefulWidget {
  const AdvanceBookingScreen({Key? key}) : super(key: key);

  @override
  State<AdvanceBookingScreen> createState() => _AdvanceBookingScreenState();
}

class _AdvanceBookingScreenState extends State<AdvanceBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _advanceBookingService = AdvanceBookingService();

  // Controllers
  final _patientNameController = TextEditingController();
  final _patientAgeController = TextEditingController();
  final _patientConditionController = TextEditingController();
  final _hospitalNameController = TextEditingController();
  final _hospitalAddressController = TextEditingController();
  final _specialInstructionsController = TextEditingController();

  // Form values
  String? _selectedBloodGroup;
  String? _selectedGender;
  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedUpazila;
  int _unitsRequired = 1;
  DateTime? _requiredDate;
  BookingPriority _priority = BookingPriority.standard;

  bool _isLoading = false;

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
  final List<String> _genders = ['পুরুষ', 'মহিলা', 'অন্যান্য'];

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientAgeController.dispose();
    _patientConditionController.dispose();
    _hospitalNameController.dispose();
    _hospitalAddressController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  // Calculate total price
  double _calculateTotalPrice() {
    final bookingAmount =
        AdvanceBookingService.BASE_PRICE_PER_UNIT * _unitsRequired;
    final priorityCharge = _requiredDate != null
        ? AdvanceBloodBooking.calculatePriorityCharge(_priority, _requiredDate!)
        : 0.0;
    final platformFee =
        bookingAmount * AdvanceBookingService.PLATFORM_FEE_PERCENTAGE;
    return bookingAmount + priorityCharge + platformFee;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _requiredDate = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_requiredDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে তারিখ নির্বাচন করুন')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bookingId = await _advanceBookingService.createBooking(
        patientName: _patientNameController.text.trim(),
        patientAge: _patientAgeController.text.trim(),
        patientGender: _selectedGender!,
        patientBloodGroup: _selectedBloodGroup!,
        patientCondition: _patientConditionController.text.trim(),
        hospitalName: _hospitalNameController.text.trim(),
        hospitalAddress: _hospitalAddressController.text.trim(),
        division: _selectedDivision!,
        district: _selectedDistrict!,
        upazila: _selectedUpazila!,
        unitsRequired: _unitsRequired,
        requiredDate: _requiredDate!,
        priority: _priority,
        specialInstructions: _specialInstructionsController.text.trim().isEmpty
            ? null
            : _specialInstructionsController.text.trim(),
      );

      setState(() => _isLoading = false);

      // Navigate to payment screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingPaymentScreen(
              bookingId: bookingId,
              totalAmount: _calculateTotalPrice(),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ত্রুটি: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('অগ্রিম ব্লাড বুকিং'),
        backgroundColor: Colors.red,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    _buildInfoCard(),
                    const SizedBox(height: 24),

                    // Patient Information
                    _buildSectionTitle('রোগীর তথ্য'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _patientNameController,
                      label: 'রোগীর নাম',
                      icon: Icons.person,
                      validator: (v) => v?.isEmpty ?? true ? 'নাম লিখুন' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _patientAgeController,
                            label: 'বয়স',
                            icon: Icons.cake,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v?.isEmpty ?? true ? 'বয়স লিখুন' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            value: _selectedGender,
                            label: 'লিঙ্গ',
                            items: _genders,
                            onChanged: (v) =>
                                setState(() => _selectedGender = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      value: _selectedBloodGroup,
                      label: 'রক্তের গ্রুপ',
                      items: _bloodGroups,
                      onChanged: (v) => setState(() => _selectedBloodGroup = v),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _patientConditionController,
                      label: 'রোগের বিবরণ / কেন রক্ত প্রয়োজন',
                      icon: Icons.medical_services,
                      maxLines: 3,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'বিবরণ লিখুন' : null,
                    ),
                    const SizedBox(height: 24),

                    // Hospital Information
                    _buildSectionTitle('হাসপাতালের তথ্য'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _hospitalNameController,
                      label: 'হাসপাতালের নাম',
                      icon: Icons.local_hospital,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'হাসপাতালের নাম লিখুন' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _hospitalAddressController,
                      label: 'হাসপাতালের ঠিকানা',
                      icon: Icons.location_on,
                      maxLines: 2,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'ঠিকানা লিখুন' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      value: _selectedDivision,
                      label: 'বিভাগ',
                      items: BangladeshLocations.divisions,
                      onChanged: (v) => setState(() {
                        _selectedDivision = v;
                        _selectedDistrict = null;
                        _selectedUpazila = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedDivision != null)
                      _buildDropdown(
                        value: _selectedDistrict,
                        label: 'জেলা',
                        items: BangladeshLocations.getDistricts(
                          _selectedDivision!,
                        ),
                        onChanged: (v) => setState(() {
                          _selectedDistrict = v;
                          _selectedUpazila = null;
                        }),
                      ),
                    if (_selectedDistrict != null) const SizedBox(height: 12),
                    if (_selectedDistrict != null)
                      _buildDropdown(
                        value: _selectedUpazila,
                        label: 'উপজেলা',
                        items: BangladeshLocations.getUpazilas(
                          _selectedDivision!,
                          _selectedDistrict!,
                        ),
                        onChanged: (v) => setState(() => _selectedUpazila = v),
                      ),
                    const SizedBox(height: 24),

                    // Booking Details
                    _buildSectionTitle('বুকিং বিবরণ'),
                    const SizedBox(height: 12),
                    _buildUnitsSelector(),
                    const SizedBox(height: 12),
                    _buildDateSelector(),
                    const SizedBox(height: 12),
                    _buildPrioritySelector(),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _specialInstructionsController,
                      label: 'বিশেষ নির্দেশনা (ঐচ্ছিক)',
                      icon: Icons.note,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Price Breakdown
                    _buildPriceCard(),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'পেমেন্ট করুন',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'অগ্রিম বুকিং সেবা',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '✓ আপনার প্রয়োজনীয় তারিখের আগে থেকে ব্লাড বুক করুন\n'
              '✓ আমরা আপনার জন্য ডোনার খুঁজে দেব\n'
              '✓ নিশ্চিত সেবা গ্যারান্টি\n'
              '✓ ২৪/৭ সাপোর্ট',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? '$label নির্বাচন করুন' : null,
    );
  }

  Widget _buildUnitsSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'রক্তের ব্যাগ সংখ্যা',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (index) {
                final units = index + 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text('$units'),
                      selected: _unitsRequired == units,
                      onSelected: (selected) {
                        if (selected) setState(() => _unitsRequired = units);
                      },
                      selectedColor: Colors.red,
                      labelStyle: TextStyle(
                        color: _unitsRequired == units
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: InkWell(
        onTap: _selectDate,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'কবে রক্ত প্রয়োজন',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _requiredDate == null
                          ? 'তারিখ নির্বাচন করুন'
                          : DateFormat(
                              'dd MMM yyyy',
                              'bn',
                            ).format(_requiredDate!),
                      style: TextStyle(
                        color: _requiredDate == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'জরুরী মাত্রা',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...BookingPriority.values.map((priority) {
              String title, subtitle;
              double charge = _requiredDate != null
                  ? AdvanceBloodBooking.calculatePriorityCharge(
                      priority,
                      _requiredDate!,
                    )
                  : 0;

              switch (priority) {
                case BookingPriority.standard:
                  title = 'সাধারণ';
                  subtitle = 'কোনো অতিরিক্ত চার্জ নেই';
                  break;
                case BookingPriority.urgent:
                  title = 'জরুরী (৭ দিনের মধ্যে)';
                  subtitle = 'অতিরিক্ত ৳${charge.toStringAsFixed(0)}';
                  break;
                case BookingPriority.critical:
                  title = 'অতি জরুরী (২৪-৪৮ ঘন্টা)';
                  subtitle = 'অতিরিক্ত ৳${charge.toStringAsFixed(0)}';
                  break;
              }

              return RadioListTile<BookingPriority>(
                value: priority,
                groupValue: _priority,
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value);
                },
                title: Text(title),
                subtitle: Text(subtitle),
                activeColor: Colors.red,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard() {
    final bookingAmount =
        AdvanceBookingService.BASE_PRICE_PER_UNIT * _unitsRequired;
    final priorityCharge = _requiredDate != null
        ? AdvanceBloodBooking.calculatePriorityCharge(_priority, _requiredDate!)
        : 0.0;
    final platformFee =
        bookingAmount * AdvanceBookingService.PLATFORM_FEE_PERCENTAGE;
    final total = bookingAmount + priorityCharge + platformFee;

    return Card(
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPriceRow(
              'বুকিং মূল্য',
              '৳${bookingAmount.toStringAsFixed(0)}',
            ),
            if (priorityCharge > 0) ...[
              const Divider(),
              _buildPriceRow(
                'জরুরী চার্জ',
                '৳${priorityCharge.toStringAsFixed(0)}',
                color: Colors.orange,
              ),
            ],
            const Divider(),
            _buildPriceRow(
              'সেবা চার্জ (১৫%)',
              '৳${platformFee.toStringAsFixed(0)}',
              color: Colors.grey,
            ),
            const Divider(thickness: 2),
            _buildPriceRow(
              'মোট মূল্য',
              '৳${total.toStringAsFixed(0)}',
              isBold: true,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
