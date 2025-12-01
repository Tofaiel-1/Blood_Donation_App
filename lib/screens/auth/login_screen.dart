import 'package:flutter/material.dart';
import '../../utils/responsive.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.responsiveMaxWidth(context),
              ),
              child: Center(
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
                                width: Responsive.isMobile(context) ? 70 : 90,
                                height: Responsive.isMobile(context) ? 70 : 90,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.bloodtype,
                                  color: Colors.white,
                                  size: Responsive.isMobile(context) ? 40 : 50,
                                ),
                              ),
                              SizedBox(
                                height: Responsive.responsiveSpacing(context),
                              ),
                              Text(
                                'Welcome Back',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: Responsive.responsiveTextSize(
                                        context,
                                        mobile: 24.0,
                                        tablet: 28.0,
                                        desktop: 32.0,
                                      ),
                                    ),
                              ),
                              SizedBox(
                                height:
                                    Responsive.responsiveSpacing(context) * 0.4,
                              ),
                              Text(
                                'Log in to continue saving lives',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: Responsive.responsiveTextSize(
                                        context,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Responsive.responsiveSpacing(context) * 2.5,
                        ),

                        // Form fields in card
                        Card(
                          elevation: Responsive.responsiveElevation(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              Responsive.responsiveBorderRadius(context) + 4,
                            ),
                          ),
                          child: Padding(
                            padding: Responsive.responsiveCardPadding(context),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email Field
                                Text(
                                  'Email',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        fontSize: Responsive.responsiveTextSize(
                                          context,
                                        ),
                                      ),
                                ),
                                SizedBox(
                                  height:
                                      Responsive.responsiveSpacing(context) *
                                      0.4,
                                ),
                                TextFormField(
                                  controller: _emailController,
                                  style: TextStyle(
                                    fontSize: Responsive.responsiveTextSize(
                                      context,
                                    ),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your email',
                                    hintStyle: TextStyle(
                                      fontSize: Responsive.responsiveTextSize(
                                        context,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
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
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Responsive.responsiveBorderRadius(
                                          context,
                                        ),
                                      ),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Responsive.responsiveBorderRadius(
                                          context,
                                        ),
                                      ),
                                      borderSide: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: Validators.validateEmail,
                                ),
                                SizedBox(
                                  height: Responsive.responsiveSpacing(context),
                                ),

                                // Password Field
                                Text(
                                  'Password',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        fontSize: Responsive.responsiveTextSize(
                                          context,
                                        ),
                                      ),
                                ),
                                SizedBox(
                                  height:
                                      Responsive.responsiveSpacing(context) *
                                      0.4,
                                ),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  style: TextStyle(
                                    fontSize: Responsive.responsiveTextSize(
                                      context,
                                    ),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    hintStyle: TextStyle(
                                      fontSize: Responsive.responsiveTextSize(
                                        context,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outlined,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      size: Responsive.responsiveIconSize(
                                        context,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        size: Responsive.responsiveIconSize(
                                          context,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
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
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Responsive.responsiveBorderRadius(
                                          context,
                                        ),
                                      ),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Responsive.responsiveBorderRadius(
                                          context,
                                        ),
                                      ),
                                      borderSide: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: Validators.validatePassword,
                                ),
                                SizedBox(
                                  height:
                                      Responsive.responsiveSpacing(context) *
                                      0.6,
                                ),

                                // Forgot Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: Responsive.responsiveTextSize(
                                          context,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Responsive.responsiveSpacing(context) * 2,
                        ),

                        // Login Button
                        Container(
                          width: double.infinity,
                          height: Responsive.responsiveButtonHeight(context),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              Responsive.responsiveBorderRadius(context) * 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.bloodRed.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: Responsive.responsiveElevation(
                                  context,
                                ),
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isLoading ? null : _handleLogin,
                              borderRadius: BorderRadius.circular(
                                Responsive.responsiveBorderRadius(context) *
                                    2.5,
                              ),
                              child: Center(
                                child: _isLoading
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
                                        'Log In',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  Responsive.responsiveTextSize(
                                                    context,
                                                    mobile: 18.0,
                                                    tablet: 20.0,
                                                    desktop: 22.0,
                                                  ),
                                            ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Responsive.responsiveSpacing(context) * 1.5,
                        ),

                        // Alternative login options
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.responsiveSpacing(
                                  context,
                                ),
                              ),
                              child: Text(
                                'Or continue with',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontSize: Responsive.responsiveTextSize(
                                        context,
                                      ),
                                    ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.responsiveSpacing(context) * 1.5,
                        ),

                        // Phone auth button
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/phone-auth');
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(
                              double.infinity,
                              Responsive.responsiveButtonHeight(context),
                            ),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Responsive.responsiveBorderRadius(context) *
                                    2.5,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone,
                                color: Theme.of(context).colorScheme.primary,
                                size: Responsive.responsiveIconSize(context),
                              ),
                              SizedBox(
                                width:
                                    Responsive.responsiveSpacing(context) * 0.6,
                              ),
                              Text(
                                'Phone Number',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontSize: Responsive.responsiveTextSize(
                                        context,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Responsive.responsiveSpacing(context) * 2,
                        ),

                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontSize: Responsive.responsiveTextSize(
                                      context,
                                    ),
                                  ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/signup',
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Responsive.responsiveTextSize(
                                    context,
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
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        // Try Firebase authentication
        final authService = AuthService();

        // Attempt Firebase login
        final credential = await authService.signInWithEmail(email, password);

        if (!mounted) return;

        // Fetch user profile from Firestore
        final profile = await authService.getCurrentUserProfile();
        final data = profile?.data();

        // Check verification status
        final emailVerified = credential.user?.emailVerified ?? false;
        final phoneVerified = data?['phoneVerified'] ?? false;

        if (!emailVerified && !phoneVerified) {
          // Neither verified - go to verification screen
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/verification',
              arguments: {'email': email, 'fromSignup': false},
            );
          }
          return;
        }

        // Check user role and navigate accordingly
        final role = data?['role']?.toString().toLowerCase() ?? '';

        // Debug: Print role information
        debugPrint('🔍 Login Debug:');
        debugPrint('   Email: $email');
        debugPrint('   Role from Firestore: ${data?['role']}');
        debugPrint('   Role (lowercase): $role');
        debugPrint('   Email Verified: $emailVerified');
        debugPrint('   Phone Verified: $phoneVerified');

        if (!mounted) return;

        if (role == 'superadmin' || role == 'admin') {
          debugPrint('   ✅ Navigating to Super Admin Dashboard');
          // Super Admin - go to super admin dashboard
          Navigator.pushReplacementNamed(context, '/super-admin');
        } else if (role == 'orgadmin') {
          debugPrint('   ✅ Navigating to Org Admin Dashboard');
          // Organization Admin - go to org admin dashboard
          Navigator.pushReplacementNamed(context, '/org-admin');
        } else {
          debugPrint('   ✅ Navigating to Home (Regular User)');
          // Regular user - go to main app
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        if (!mounted) return;

        String errorMessage = 'Login failed. Please try again.';
        if (e.toString().contains('user-not-found')) {
          errorMessage = 'No account found with this email.';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Incorrect password.';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Invalid email address.';
        } else if (e.toString().contains('user-disabled')) {
          errorMessage = 'This account has been disabled.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
