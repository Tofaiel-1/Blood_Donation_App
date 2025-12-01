import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../models/user.dart' as app_user;

class VerificationScreen extends StatefulWidget {
  final String email;
  final String? phone;
  final Map<String, dynamic> userData;

  const VerificationScreen({
    super.key,
    required this.email,
    this.phone,
    required this.userData,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  late TabController _tabController;
  bool _isEmailVerified = false;
  bool _isPhoneVerified = false;
  bool _isLoading = false;
  Timer? _verificationCheckTimer;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  // Email OTP
  final _emailOtpController = TextEditingController();
  String? _emailOtpCode;
  bool _emailOtpSent = false;
  bool _useEmailLink = true; // Toggle between link and OTP

  // Phone verification
  String? _verificationId;
  final _smsCodeController = TextEditingController();
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Don't send verification automatically - let user choose method
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _verificationCheckTimer?.cancel();
    _resendTimer?.cancel();
    _emailOtpController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  void _startVerificationCheck() {
    _verificationCheckTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      await _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      final verified = user?.emailVerified ?? false;

      if (verified && !_isEmailVerified) {
        setState(() => _isEmailVerified = true);
        await _authService.updateUserProfile({'emailVerified': true});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('✅ ইমেইল ভেরিফাই সম্পন্ন!'),
                ],
              ),
              backgroundColor: AppColors.hopeGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // If phone not required or already verified, proceed
        if (widget.phone == null || _isPhoneVerified) {
          _proceedToHome();
        }
      }
    } catch (e) {
      // Silent check, don't show error
    }
  }

  // Generate 6-digit OTP
  String _generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Send Email OTP (instead of link)
  Future<void> _sendEmailOtp() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      if (user.emailVerified) {
        setState(() => _isEmailVerified = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ ইমেইল ইতিমধ্যে ভেরিফাই করা আছে!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }

      // Generate OTP
      _emailOtpCode = _generateOtp();

      // Store OTP in Firestore with expiry (5 minutes)
      await FirebaseFirestore.instance
          .collection('email_verifications')
          .doc(user.uid)
          .set({
            'email': user.email,
            'otp': _emailOtpCode,
            'createdAt': FieldValue.serverTimestamp(),
            'expiresAt': DateTime.now()
                .add(const Duration(minutes: 5))
                .millisecondsSinceEpoch,
            'verified': false,
          });

      // TODO: In production, send this via email service (SendGrid, Mailgun, etc.)
      // For now, we'll show it in debug console
      debugPrint('✅ Email OTP: $_emailOtpCode');
      debugPrint('📧 Send this OTP to: ${user.email}');

      setState(() => _emailOtpSent = true);
      _startResendCountdown(60);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📧 OTP কোড পাঠানো হয়েছে'),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Development only - show OTP
                if (user.email?.contains('test') ?? false) ...[
                  const SizedBox(height: 4),
                  Text(
                    'TEST OTP: $_emailOtpCode',
                    style: const TextStyle(fontSize: 10, color: Colors.yellow),
                  ),
                ],
              ],
            ),
            backgroundColor: AppColors.hopeGreen,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Email OTP error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP পাঠাতে সমস্যা: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'পুনরায়',
              textColor: Colors.white,
              onPressed: _sendEmailOtp,
            ),
          ),
        );
      }
    }
  }

  // Verify Email OTP
  Future<void> _verifyEmailOtp() async {
    if (_emailOtpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে OTP কোড লিখুন'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Get stored OTP from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('email_verifications')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        throw Exception('OTP not found. Please request a new one.');
      }

      final data = doc.data()!;
      final storedOtp = data['otp'] as String;
      final expiresAt = data['expiresAt'] as int;
      final verified = data['verified'] as bool? ?? false;

      // Check if already verified
      if (verified) {
        throw Exception('This OTP has already been used.');
      }

      // Check expiry
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        throw Exception('OTP expired. Please request a new one.');
      }

      // Verify OTP
      if (_emailOtpController.text.trim() != storedOtp) {
        throw Exception('Invalid OTP code.');
      }

      // Mark as verified in Firestore
      await FirebaseFirestore.instance
          .collection('email_verifications')
          .doc(user.uid)
          .update({'verified': true});

      await _authService.updateUserProfile({'emailVerified': true});

      setState(() {
        _isEmailVerified = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('✅ ইমেইল ভেরিফাই সম্পন্ন!'),
              ],
            ),
            backgroundColor: AppColors.hopeGreen,
          ),
        );
      }

      if (widget.phone == null || _isPhoneVerified) {
        _proceedToHome();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ভেরিফিকেশন ব্যর্থ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in. Please login again.');
      }

      debugPrint('🔍 Sending email verification to: ${user.email}');

      if (user.emailVerified) {
        setState(() => _isEmailVerified = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ ইমেইল ইতিমধ্যে ভেরিফাই করা আছে!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }

      await _authService.sendEmailVerification();
      debugPrint('✅ Email verification sent successfully');

      _startResendCountdown(60);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📧 ভেরিফিকেশন লিংক পাঠানো হয়েছে'),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.hopeGreen,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Email verification error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ইমেইল পাঠাতে সমস্যা: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'পুনরায়',
              textColor: Colors.white,
              onPressed: _sendEmailVerification,
            ),
          ),
        );
      }
    }
  }

  Future<void> _sendPhoneVerification() async {
    if (widget.phone == null) return;

    setState(() => _isLoading = true);

    // Format phone number to international format for Bangladesh
    String phoneNumber = widget.phone!.replaceAll(
      RegExp(r'\D'),
      '',
    ); // Remove non-digits

    // Handle different formats
    if (phoneNumber.startsWith('880')) {
      phoneNumber = '+$phoneNumber';
    } else if (phoneNumber.startsWith('0')) {
      phoneNumber = '+880${phoneNumber.substring(1)}';
    } else if (phoneNumber.length == 10) {
      phoneNumber = '+880$phoneNumber';
    } else if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+880$phoneNumber';
    }

    debugPrint('📱 Formatted phone: $phoneNumber');

    try {
      await _authService.verifyPhone(
        phoneNumber: phoneNumber,
        codeSent: (verificationId) {
          debugPrint('✅ SMS code sent! Verification ID: $verificationId');
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _isLoading = false;
          });
          _startResendCountdown(60);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📱 SMS কোড পাঠানো হয়েছে!'),
                    const SizedBox(height: 4),
                    Text(
                      phoneNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.hopeGreen,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        completed: (credential) async {
          debugPrint('✅ Phone auto-verified!');
          setState(() {
            _isPhoneVerified = true;
            _isLoading = false;
          });
          await _authService.updateUserProfile({'phoneVerified': true});

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('✅ ফোন স্বয়ংক্রিয়ভাবে ভেরিফাই হয়েছে!'),
                  ],
                ),
                backgroundColor: AppColors.hopeGreen,
              ),
            );
          }

          if (_isEmailVerified) {
            _proceedToHome();
          }
        },
        failed: (error) {
          debugPrint('❌ Phone verification failed: $error');
          setState(() => _isLoading = false);
          if (mounted) {
            String message = 'ফোন ভেরিফিকেশন ব্যর্থ';

            if (error.contains('quota')) {
              message = 'SMS quota exceeded. Try again later.';
            } else if (error.contains('invalid')) {
              message = 'Invalid phone number format';
            } else if (error.contains('blocked')) {
              message = 'Phone verification temporarily blocked';
            } else {
              message = 'Error: $error';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 6),
                action: SnackBarAction(
                  label: 'পুনরায়',
                  textColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      _codeSent = false;
                      _smsCodeController.clear();
                    });
                  },
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      debugPrint('❌ Phone verification error: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('সমস্যা: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_verificationId == null || _smsCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে OTP কোড লিখুন'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_smsCodeController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP অবশ্যই ৬ ডিজিটের হতে হবে'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint('🔍 Verifying SMS code: ${_smsCodeController.text.trim()}');

      await _authService.confirmSmsCode(
        verificationId: _verificationId!,
        smsCode: _smsCodeController.text.trim(),
      );

      debugPrint('✅ Phone OTP verified successfully!');

      setState(() {
        _isPhoneVerified = true;
        _isLoading = false;
      });

      await _authService.updateUserProfile({'phoneVerified': true});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('✅ ফোন ভেরিফাই সম্পন্ন!'),
              ],
            ),
            backgroundColor: AppColors.hopeGreen,
          ),
        );
      }

      if (_isEmailVerified) {
        _proceedToHome();
      } else {
        // Switch to email tab
        _tabController.animateTo(0);
      }
    } catch (e) {
      debugPrint('❌ SMS verification failed: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        String message = 'ভুল OTP কোড';

        if (e.toString().contains('invalid-verification-code')) {
          message = 'OTP কোডটি সঠিক নয়। আবার চেষ্টা করুন।';
        } else if (e.toString().contains('session-expired')) {
          message = 'OTP মেয়াদ শেষ। নতুন কোড নিন।';
        } else {
          message = 'Error: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _startResendCountdown(int seconds) {
    setState(() => _resendCountdown = seconds);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _proceedToHome() {
    _verificationCheckTimer?.cancel();

    // Convert Map to User object
    final user = app_user.User.fromMap(widget.userData);

    Navigator.pushReplacementNamed(context, '/home', arguments: user);
  }

  void _skipVerification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('সতর্কতা'),
          ],
        ),
        content: const Text(
          'ভেরিফিকেশন ছাড়া আপনার অ্যাকাউন্ট সীমিত থাকবে এবং কিছু ফিচার ব্যবহার করতে পারবেন না।\n\nআপনি কি এগিয়ে যেতে চান?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('না, ভেরিফাই করবো'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedToHome();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('হ্যাঁ, পরে করবো'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Verification'),
        backgroundColor: AppColors.bloodRed,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: _skipVerification,
            icon: const Icon(Icons.skip_next, color: Colors.white),
            label: const Text('Skip', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatusIcon(_isEmailVerified, 'Email'),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value:
                        (_isEmailVerified ? 0.5 : 0) +
                        (_isPhoneVerified ? 0.5 : 0),
                    backgroundColor: Colors.grey[300],
                    color: AppColors.hopeGreen,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusIcon(
                  widget.phone != null ? _isPhoneVerified : true,
                  'Phone',
                ),
              ],
            ),
          ),

          // Tab bar
          if (widget.phone != null)
            TabBar(
              controller: _tabController,
              labelColor: AppColors.bloodRed,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.bloodRed,
              tabs: const [
                Tab(icon: Icon(Icons.email), text: 'Email'),
                Tab(icon: Icon(Icons.phone), text: 'Phone'),
              ],
            ),

          // Tab views
          Expanded(
            child: widget.phone != null
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEmailVerificationTab(),
                      _buildPhoneVerificationTab(),
                    ],
                  )
                : _buildEmailVerificationTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(bool verified, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          verified ? Icons.check_circle : Icons.radio_button_unchecked,
          color: verified ? AppColors.hopeGreen : Colors.grey,
          size: 24,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: verified ? AppColors.hopeGreen : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailVerificationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(
            _isEmailVerified ? Icons.mark_email_read : Icons.mark_email_unread,
            size: 100,
            color: _isEmailVerified ? AppColors.hopeGreen : AppColors.bloodRed,
          ),
          const SizedBox(height: 30),
          Text(
            _isEmailVerified
                ? 'ইমেইল ভেরিফাই সম্পন্ন! ✅'
                : 'ইমেইল ভেরিফিকেশন প্রয়োজন',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: _isEmailVerified
                  ? AppColors.hopeGreen
                  : AppColors.bloodRed,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Toggle between Link and OTP
          if (!_isEmailVerified) ...[
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _useEmailLink = true;
                        _emailOtpSent = false;
                        _emailOtpController.clear();
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _useEmailLink
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _useEmailLink
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.link,
                              color: _useEmailLink
                                  ? AppColors.bloodRed
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Email Link',
                              style: TextStyle(
                                fontWeight: _useEmailLink
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _useEmailLink
                                    ? AppColors.bloodRed
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _useEmailLink = false;
                        _emailOtpSent = false;
                        _emailOtpController.clear();
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_useEmailLink
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: !_useEmailLink
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pin,
                              color: !_useEmailLink
                                  ? AppColors.bloodRed
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'OTP Code',
                              style: TextStyle(
                                fontWeight: !_useEmailLink
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: !_useEmailLink
                                    ? AppColors.bloodRed
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.email, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.email,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  // Email Link Method
                  if (_useEmailLink) ...[
                    const Text(
                      'আমরা আপনার ইমেইলে একটি ভেরিফিকেশন লিংক পাঠিয়েছি।\n\n'
                      '1️⃣ আপনার ইমেইল চেক করুন\n'
                      '2️⃣ ভেরিফিকেশন লিংকে ক্লিক করুন\n'
                      '3️⃣ এই পেজে ফিরে আসুন',
                      style: TextStyle(fontSize: 15, height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    if (!_isEmailVerified) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _resendCountdown > 0
                              ? null
                              : () async {
                                  await _sendEmailVerification();
                                },
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            _resendCountdown > 0
                                ? 'আবার পাঠান ($_resendCountdown সেকেন্ড)'
                                : 'আবার ইমেইল পাঠান',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bloodRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _checkEmailVerification();
                            if (!mounted) return;

                            if (!_isEmailVerified) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'এখনো ভেরিফাই হয়নি। লিংকে ক্লিক করুন।',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('ভেরিফিকেশন চেক করুন'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ]
                  // Email OTP Method
                  else ...[
                    if (!_emailOtpSent) ...[
                      const Text(
                        'আপনার ইমেইলে একটি 6-ডিজিটের OTP কোড পাঠানো হবে।\n\n'
                        '✅ দ্রুত এবং সহজ\n'
                        '✅ কোড টাইপ করুন এবং ভেরিফাই করুন\n'
                        '✅ 5 মিনিটের জন্য বৈধ',
                        style: TextStyle(fontSize: 15, height: 1.6),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _resendCountdown > 0
                              ? null
                              : _sendEmailOtp,
                          icon: const Icon(Icons.send),
                          label: Text(
                            _resendCountdown > 0
                                ? 'পাঠান ($_resendCountdown সেকেন্ড)'
                                : 'OTP কোড পাঠান',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bloodRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'আপনার ইমেইলে পাঠানো 6 ডিজিটের কোড লিখুন:',
                        style: TextStyle(fontSize: 15, height: 1.6),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailOtpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                        decoration: InputDecoration(
                          hintText: '------',
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.bloodRed,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _verifyEmailOtp,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle),
                          label: const Text('ভেরিফাই করুন'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.hopeGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: _resendCountdown > 0
                              ? null
                              : () async {
                                  await _sendEmailOtp();
                                },
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            _resendCountdown > 0
                                ? 'আবার পাঠান ($_resendCountdown সেকেন্ড)'
                                : 'আবার কোড পাঠান',
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ইমেইল না পেলে যা করবেন:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '• Gmail এর Spam/Junk ফোল্ডার চেক করুন\n'
                  '• Promotions/Social ট্যাব দেখুন\n'
                  '• 2-3 মিনিট অপেক্ষা করুন\n'
                  '• ইমেইল ঠিক আছে কিনা নিশ্চিত করুন',
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Open Gmail app or web
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Gmail খুলুন এবং ইনবক্স চেক করুন',
                          ),
                          action: SnackBarAction(label: 'OK', onPressed: () {}),
                        ),
                      );
                    },
                    icon: const Icon(Icons.email, color: Colors.red),
                    label: const Text(
                      'Gmail চেক করুন',
                      style: TextStyle(color: Colors.black87),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneVerificationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(
            _isPhoneVerified ? Icons.phone_enabled : Icons.phone_android,
            size: 100,
            color: _isPhoneVerified ? AppColors.hopeGreen : AppColors.bloodRed,
          ),
          const SizedBox(height: 30),
          Text(
            _isPhoneVerified
                ? 'ফোন ভেরিফাই সম্পন্ন! ✅'
                : 'ফোন নম্বর ভেরিফিকেশন',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: _isPhoneVerified
                  ? AppColors.hopeGreen
                  : AppColors.bloodRed,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(
                        widget.phone ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  if (!_codeSent) ...[
                    const Text(
                      'আপনার ফোন নম্বর ভেরিফাই করতে নিচের বাটনে ক্লিক করুন। আমরা একটি SMS কোড পাঠাবো।',
                      style: TextStyle(fontSize: 15, height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading || _resendCountdown > 0
                            ? null
                            : _sendPhoneVerification,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.sms),
                        label: Text(
                          _resendCountdown > 0
                              ? 'পাঠান ($_resendCountdown সেকেন্ড)'
                              : 'SMS কোড পাঠান',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bloodRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'আপনার ফোনে পাঠানো ৬ ডিজিটের কোড লিখুন:',
                      style: TextStyle(fontSize: 15, height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _smsCodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                      decoration: InputDecoration(
                        hintText: '------',
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.bloodRed,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _verifyOtp,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle),
                        label: const Text('ভেরিফাই করুন'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.hopeGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: _resendCountdown > 0
                            ? null
                            : () {
                                setState(() {
                                  _codeSent = false;
                                  _smsCodeController.clear();
                                });
                              },
                        icon: const Icon(Icons.refresh),
                        label: Text(
                          _resendCountdown > 0
                              ? 'আবার পাঠান ($_resendCountdown সেকেন্ড)'
                              : 'আবার কোড পাঠান',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: Colors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ফোন ভেরিফিকেশন আপনার অ্যাকাউন্ট আরো সুরক্ষিত করে',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
