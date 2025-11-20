import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:blood_bank/utils/validators.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen>
    with SingleTickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adminInviteCodeController = TextEditingController();

  String? _bloodType;
  bool _isLoading = false;

  static const _adminInviteCode = 'ORGADMIN2025'; // simple opt-in to org admin

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();

    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _adminInviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Account'),
          backgroundColor: Colors.red[700],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Sign In'),
              Tab(text: 'Register'),
            ],
          ),
        ),
        body: TabBarView(
          children: Firebase.apps.isEmpty
              ? [
                  // If Firebase not configured show simple offline messages
                  _buildOfflinePlaceholder(context, 'Sign In'),
                  _buildOfflinePlaceholder(context, 'Register'),
                ]
              : [_buildLoginTab(context), _buildRegisterTab(context)],
        ),
      ),
    );
  }

  Widget _buildOfflinePlaceholder(BuildContext context, String mode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text(
              'Firebase not configured. $mode is not available in offline mode.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
              child: const Text('Continue Offline'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            TextFormField(
              controller: _loginEmailController,
              decoration: _inputDecoration('Email', Icons.email),
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _loginPasswordController,
              decoration: _inputDecoration('Password', Icons.lock),
              obscureText: true,
              validator: Validators.validatePassword,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onLoginPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isLoading ? null : _onResendVerification,
              child: const Text('Resend verification email'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Full Name', Icons.person),
              validator: Validators.validateName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: _inputDecoration('Email', Icons.email),
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: _inputDecoration('Phone', Icons.phone),
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _bloodType,
              items: const [
                'A+',
                'A-',
                'B+',
                'B-',
                'AB+',
                'AB-',
                'O+',
                'O-',
              ].map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              decoration: _inputDecoration('Blood Type', Icons.bloodtype),
              onChanged: (v) => setState(() => _bloodType = v),
              validator: Validators.validateBloodType,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: _inputDecoration('Password', Icons.lock),
              obscureText: true,
              validator: Validators.validatePassword,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: _inputDecoration(
                'Confirm Password',
                Icons.lock_outline,
              ),
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirm your password';
                if (v != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _adminInviteCodeController,
              decoration: _inputDecoration(
                'Admin Invite Code (optional)',
                Icons.admin_panel_settings,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onRegisterPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create Account'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We will send you a verification email. Please verify before logging in.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      );

  Future<void> _onRegisterPressed() async {
    if (!_registerFormKey.currentState!.validate()) return;
    if (_bloodType == null) return;

    setState(() => _isLoading = true);
    try {
      // If Firebase is not configured, fall back to offline mock flow
      if (Firebase.apps.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Firebase not configured. Creating a local demo account.',
              ),
            ),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
        return;
      }

      final auth = FirebaseAuth.instance;
      final db = FirebaseFirestore.instance;

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set display name
      await cred.user?.updateDisplayName(_nameController.text.trim());

      // Send email verification
      await cred.user?.sendEmailVerification();

      // Determine role
      final role = _adminInviteCodeController.text.trim() == _adminInviteCode
          ? 'orgAdmin'
          : 'user';

      // Create Firestore profile
      await db.collection('users').doc(cred.user!.uid).set({
        'email': email,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'bloodType': _bloodType,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Audit log: signup
      await _writeAuditLog(
        action: 'signup',
        uid: cred.user!.uid,
        email: email,
        role: role,
        status: 'success',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created. Please verify your email.'),
          ),
        );
      }
    } catch (e) {
      await _writeAuditLog(
        action: 'signup',
        uid: null,
        email: _emailController.text.trim(),
        role: 'unknown',
        status: 'error',
        error: e.toString(),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign up failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onLoginPressed() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Offline fallback
      if (Firebase.apps.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Firebase not configured. Continuing offline.'),
            ),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
        return;
      }

      final auth = FirebaseAuth.instance;
      final db = FirebaseFirestore.instance;

      final email = _loginEmailController.text.trim();
      final password = _loginPasswordController.text.trim();

      final cred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Require email verification
      if (!(cred.user?.emailVerified ?? false)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please verify your email before logging in.'),
            ),
          );
        }
        return;
      }

      // Ensure profile exists and get role
      final userDoc = await db.collection('users').doc(cred.user!.uid).get();
      String role = 'user';
      if (!userDoc.exists) {
        await db.collection('users').doc(cred.user!.uid).set({
          'email': email,
          'name': cred.user?.displayName ?? '',
          'phone': '',
          'bloodType': 'N/A',
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        role = (userDoc.data()!['role'] as String?)?.trim() ?? 'user';
      }

      await _writeAuditLog(
        action: 'login',
        uid: cred.user!.uid,
        email: email,
        role: role,
        status: 'success',
      );

      if (mounted) {
        // Navigate based on role
        if (role == 'superAdmin') {
          Navigator.pushReplacementNamed(context, '/super-admin');
        } else if (role == 'orgAdmin') {
          Navigator.pushReplacementNamed(context, '/org-admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      await _writeAuditLog(
        action: 'login',
        uid: null,
        email: _loginEmailController.text.trim(),
        role: 'unknown',
        status: 'error',
        error: e.toString(),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onResendVerification() async {
    try {
      if (Firebase.apps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Firebase not configured. Cannot resend verification.',
            ),
          ),
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in first to resend verification.'),
          ),
        );
        return;
      }
      await user.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send verification: $e')),
        );
      }
    }
  }

  Future<void> _writeAuditLog({
    required String action,
    required String? uid,
    required String email,
    required String role,
    required String status,
    String? error,
  }) async {
    try {
      final db = FirebaseFirestore.instance;
      await db.collection('auditLogs').add({
        'action': action,
        'uid': uid,
        'email': email,
        'role': role,
        'status': status,
        'error': error,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Swallow audit errors to not block auth flow
    }
  }
}
