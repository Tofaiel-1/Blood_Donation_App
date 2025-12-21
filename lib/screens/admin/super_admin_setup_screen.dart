import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Super Admin Setup Screen
/// Use this ONCE to create the super admin account in Firebase
/// After creating, you can remove this file or disable the route
class SuperAdminSetupScreen extends StatefulWidget {
  const SuperAdminSetupScreen({super.key});

  @override
  State<SuperAdminSetupScreen> createState() => _SuperAdminSetupScreenState();
}

class _SuperAdminSetupScreenState extends State<SuperAdminSetupScreen> {
  bool _isCreating = false;
  String _message = '';
  bool _isSuccess = false;

  Future<void> _createSuperAdmin() async {
    setState(() {
      _isCreating = true;
      _message = 'Creating super admin account...';
    });

    try {
      // Super Admin credentials
      const email = 'mdtofaielhussaintota@gmail.com';
      const password = 'super123';
      const name = 'Super Admin';

      // Step 1: Create Firebase Auth account
      // If email already exists, skip creation and mark success
      UserCredential? userCredential;
      try {
        userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Try to sign in to get UID
          userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
        } else {
          rethrow;
        }
      }

      final uid = userCredential.user!.uid;

      // Step 2: Create Firestore user document
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'role': 'superAdmin',
        'bloodType': 'N/A',
        'phone': null,
        'isActive': true,
        'emailVerified': true, // Super admin doesn't need verification
        'phoneVerified': true, // Super admin doesn't need phone verification
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Step 3: Sign out (so user can login normally)
      await FirebaseAuth.instance.signOut();

      setState(() {
        _isCreating = false;
        _isSuccess = true;
        _message = '''
✅ Super Admin Created Successfully!

Email: mdtofaielhussaintota@gmail.com
Password: super123

You can now login with these credentials.
        ''';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isCreating = false;
        _isSuccess = false;
        _message = '❌ Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _isCreating = false;
        _isSuccess = false;
        _message = '❌ Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Setup'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isSuccess ? Icons.check_circle : Icons.admin_panel_settings,
                size: 80,
                color: _isSuccess ? Colors.green : Colors.red[700],
              ),
              const SizedBox(height: 32),
              Text(
                'Super Admin Setup',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_message.isEmpty)
                const Text(
                  'Click the button below to create the super admin account in Firebase.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isSuccess ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isSuccess ? Colors.green : Colors.orange,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _message,
                    style: TextStyle(
                      fontSize: 14,
                      color: _isSuccess
                          ? Colors.green[900]
                          : Colors.orange[900],
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              if (!_isSuccess)
                ElevatedButton.icon(
                  onPressed: _isCreating ? null : _createSuperAdmin,
                  icon: _isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.create),
                  label: Text(
                    _isCreating ? 'Creating...' : 'Create Super Admin',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Go to Login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
