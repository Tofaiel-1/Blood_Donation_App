import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive.dart';
import '../../models/user.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedBloodType;
  String? _selectedGender;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSubmitting = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bloodRed, Colors.white],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: Responsive.responsivePadding(context),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: Responsive.responsiveIconSize(context),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(height: Responsive.responsiveSpacing(context)),

                    // Logo and title
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: Responsive.responsiveTextSize(
                              context,
                              mobile: 80,
                              tablet: 100,
                              desktop: 120,
                            ),
                            height: Responsive.responsiveTextSize(
                              context,
                              mobile: 80,
                              tablet: 100,
                              desktop: 120,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.bloodtype,
                              color: Colors.white,
                              size: Responsive.responsiveTextSize(
                                context,
                                mobile: 50,
                                tablet: 60,
                                desktop: 70,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: Responsive.responsiveSpacing(context),
                          ),
                          Text(
                            'Create Account',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Responsive.responsiveTextSize(
                                    context,
                                    mobile: 28,
                                    tablet: 32,
                                    desktop: 36,
                                  ),
                                ),
                          ),
                          SizedBox(
                            height: Responsive.responsiveSpacing(context) * 0.5,
                          ),
                          Text(
                            'Join us and start saving lives',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: Responsive.responsiveTextSize(
                                    context,
                                    mobile: 14,
                                    tablet: 16,
                                    desktop: 18,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.responsiveSpacing(context) * 2),

                    // Form fields in card
                    Card(
                      elevation: Responsive.responsiveElevation(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Responsive.responsiveBorderRadius(context) * 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: Responsive.responsiveCardPadding(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              icon: Icons.person_outlined,
                              validator: Validators.validateName,
                            ),
                            SizedBox(
                              height: Responsive.responsiveSpacing(context),
                            ),

                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'Enter your email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                            ),
                            SizedBox(
                              height: Responsive.responsiveSpacing(context),
                            ),

                            _buildTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hint: 'Enter your phone number',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: Validators.validatePhone,
                            ),
                            SizedBox(
                              height: Responsive.responsiveSpacing(context),
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _ageController,
                                    label: 'Age',
                                    hint: 'Age',
                                    icon: Icons.cake_outlined,
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Required';
                                      }
                                      final age = int.tryParse(v);
                                      if (age == null ||
                                          age < 18 ||
                                          age > 100) {
                                        return '18-100';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: Responsive.responsiveSpacing(context),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Gender',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                              fontSize:
                                                  Responsive.responsiveTextSize(
                                                    context,
                                                    mobile: 14,
                                                    tablet: 15,
                                                    desktop: 16,
                                                  ),
                                            ),
                                      ),
                                      SizedBox(
                                        height:
                                            Responsive.responsiveSpacing(
                                              context,
                                            ) *
                                            0.5,
                                      ),
                                      DropdownButtonFormField<String>(
                                        value: _selectedGender,
                                        decoration: InputDecoration(
                                          hintText: 'Select',
                                          prefixIcon: Icon(
                                            Icons.person_outline,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            size: Responsive.responsiveIconSize(
                                              context,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.05),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              Responsive.responsiveBorderRadius(
                                                context,
                                              ),
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        items: ['Male', 'Female', 'Other']
                                            .map(
                                              (g) => DropdownMenuItem(
                                                value: g,
                                                child: Text(g),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (v) =>
                                            setState(() => _selectedGender = v),
                                        validator: (v) =>
                                            v == null ? 'Required' : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Responsive.responsiveSpacing(context),
                            ),

                            _buildTextField(
                              controller: _addressController,
                              label: 'Address',
                              hint: 'Enter your address (e.g. Dhaka)',
                              icon: Icons.location_on_outlined,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            SizedBox(
                              height: Responsive.responsiveSpacing(context),
                            ),

                            // Blood Type Dropdown
                            Text(
                              'Blood Type',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontSize: Responsive.responsiveTextSize(
                                      context,
                                      mobile: 14,
                                      tablet: 15,
                                      desktop: 16,
                                    ),
                                  ),
                            ),
                            SizedBox(
                              height:
                                  Responsive.responsiveSpacing(context) * 0.5,
                            ),
                            DropdownButtonFormField<String>(
                              value: _selectedBloodType,
                              decoration: InputDecoration(
                                hintText: 'Select your blood type',
                                prefixIcon: Icon(
                                  Icons.opacity,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: Responsive.responsiveIconSize(context),
                                ),
                                filled: true,
                                fillColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    Responsive.responsiveBorderRadius(context),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    Responsive.responsiveBorderRadius(context),
                                  ),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    Responsive.responsiveBorderRadius(context),
                                  ),
                                  borderSide: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              items:
                                  [
                                        'A+',
                                        'A-',
                                        'B+',
                                        'B-',
                                        'AB+',
                                        'AB-',
                                        'O+',
                                        'O-',
                                      ]
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedBloodType = value;
                                });
                              },
                              validator: Validators.validateBloodType,
                            ),
                            SizedBox(
                              height: Responsive.responsiveSpacing(context),
                            ),

                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Create a password',
                              icon: Icons.lock_outlined,
                              obscureText: !_isPasswordVisible,
                              validator: Validators.validatePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: Responsive.responsiveIconSize(context),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: Responsive.responsiveSpacing(context),
                            ),

                            _buildTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hint: 'Re-enter your password',
                              icon: Icons.lock_outlined,
                              obscureText: !_isConfirmPasswordVisible,
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: Responsive.responsiveIconSize(context),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height:
                                  Responsive.responsiveSpacing(context) * 1.5,
                            ),

                            // Terms checkbox
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _acceptedTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _acceptedTerms = value ?? false;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _acceptedTerms = !_acceptedTerms;
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top:
                                            Responsive.responsiveSpacing(
                                              context,
                                            ) *
                                            0.75,
                                      ),
                                      child: Text(
                                        'I agree to the Terms of Service and Privacy Policy',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontSize:
                                                  Responsive.responsiveTextSize(
                                                    context,
                                                    mobile: 12,
                                                    tablet: 13,
                                                    desktop: 14,
                                                  ),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.responsiveSpacing(context) * 2),

                    // Sign Up Button
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Responsive.responsiveMaxWidth(context),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: Responsive.responsiveButtonHeight(context),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(
                            Responsive.responsiveBorderRadius(context) * 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.bloodRed.withValues(alpha: 0.4),
                              blurRadius:
                                  Responsive.responsiveElevation(context) * 3,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isSubmitting ? null : _onSignupPressed,
                            borderRadius: BorderRadius.circular(
                              Responsive.responsiveBorderRadius(context) * 2,
                            ),
                            child: Center(
                              child: _isSubmitting
                                  ? SizedBox(
                                      width: Responsive.responsiveIconSize(
                                        context,
                                      ),
                                      height: Responsive.responsiveIconSize(
                                        context,
                                      ),
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Sign Up',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                Responsive.responsiveTextSize(
                                                  context,
                                                  mobile: 16,
                                                  tablet: 18,
                                                  desktop: 20,
                                                ),
                                          ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.responsiveSpacing(context) * 2),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontSize: Responsive.responsiveTextSize(
                                  context,
                                  mobile: 14,
                                  tablet: 15,
                                  desktop: 16,
                                ),
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.responsiveTextSize(
                                context,
                                mobile: 14,
                                tablet: 15,
                                desktop: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: Responsive.responsiveTextSize(
              context,
              mobile: 14,
              tablet: 15,
              desktop: 16,
            ),
          ),
        ),
        SizedBox(height: Responsive.responsiveSpacing(context) * 0.5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: Responsive.responsiveIconSize(context),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                Responsive.responsiveBorderRadius(context),
              ),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                Responsive.responsiveBorderRadius(context),
              ),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                Responsive.responsiveBorderRadius(context),
              ),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Future<void> _onSignupPressed() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Please accept the terms and conditions')),
            ],
          ),
          backgroundColor: AppColors.warningAmber,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Responsive.responsiveBorderRadius(context),
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final age = int.parse(_ageController.text.trim());
    final address = _addressController.text.trim();
    final gender = _selectedGender!;
    final bloodType = _selectedBloodType!;

    final newUser = User(
      email: email,
      name: name,
      bloodType: bloodType,
      phone: phone,
      age: age,
      gender: gender,
      address: address,
    );

    try {
      // Check if Firebase is available
      if (Firebase.apps.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Firebase not configured. Continuing in offline mode.',
            ),
            backgroundColor: AppColors.warningAmber,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                Responsive.responsiveBorderRadius(context),
              ),
            ),
          ),
        );
        // Offline mode - navigate to home with User object (not Map)
        Navigator.pushReplacementNamed(context, '/home', arguments: newUser);
        return;
      }

      // Create user with Firebase Auth
      final authService = AuthService();
      final credential = await authService.registerWithEmail(email, password);

      final uid = credential.user?.uid;
      if (uid == null) {
        await authService.signOut();
        throw Exception('Signup failed: missing user id');
      }

      // Create user profile in Firestore
      await authService.updateUserProfile({
        'email': email,
        'name': name,
        'bloodType': bloodType,
        'phone': phone,
        'age': age,
        'gender': gender,
        'address': address,
        'role': 'user',
        'isDonor': false,
        'emailVerified': false,
        'phoneVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Regular users go to verification, admins skip verification
      // Admin accounts should be created by super admin through dashboard
      Navigator.pushReplacementNamed(
        context,
        '/verification',
        arguments: {
          'email': email,
          'phone': phone,
          'userData': {
            'email': newUser.email,
            'name': newUser.name,
            'bloodType': newUser.bloodType,
            'phone': newUser.phone,
            'age': newUser.age,
            'gender': newUser.gender,
            'address': newUser.address,
            'role': newUser.role.toString().split('.').last,
          },
        },
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Signup failed';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered';
      } else if (e.code == 'weak-password') {
        message = 'Please use a stronger password (min 6 characters)';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else if (e.code == 'operation-not-allowed') {
        message = 'Email/password sign up is not enabled';
      } else if (e.code == 'network-request-failed') {
        message = 'Network error. Check your connection';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppColors.urgentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Responsive.responsiveBorderRadius(context),
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: AppColors.urgentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Responsive.responsiveBorderRadius(context),
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
