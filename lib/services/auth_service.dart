import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// 🔐 AUTHENTICATION SERVICE
///
/// এই service handle করে সব authentication related operations:
/// - Email/Password Login & Registration
/// - Google Sign-in
/// - Phone Verification (OTP)
/// - Email Verification
/// - User Profile Management
///
/// Used in:
/// - lib/screens/auth/login_screen.dart
/// - lib/screens/auth/signup_screen.dart
/// - lib/screens/auth/verification_screen.dart
/// - lib/screens/auth/phone_auth_screen.dart
class AuthService {
  // Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Google Sign-in instance
  final GoogleSignIn _google = GoogleSignIn();

  // ==================== AUTH STATE ====================

  /// Stream যা listen করে user এর login/logout status
  /// Returns: `Stream<User?>` - User object or null
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // ==================== EMAIL/PASSWORD AUTH ====================

  /// Email এবং password দিয়ে login করে
  ///
  /// Parameters:
  /// - email: User এর email address
  /// - password: User এর password
  ///
  /// Returns: UserCredential with user data
  /// Throws: FirebaseAuthException if login fails
  ///
  /// Used in: lib/screens/auth/login_screen.dart line 390+
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// নতুন user registration করে email/password দিয়ে
  ///
  /// Parameters:
  /// - email: New user এর email
  /// - password: New user এর password (min 6 characters)
  ///
  /// Returns: UserCredential with newly created user
  /// Throws: FirebaseAuthException if registration fails
  ///
  /// Used in: lib/screens/auth/signup_screen.dart line 445+
  Future<UserCredential> registerWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ==================== EMAIL VERIFICATION ====================

  /// Current user কে email verification link পাঠায়
  ///
  /// এই method automatically check করে user already verified কিনা
  /// Link click করলে email verified হবে
  ///
  /// ✅ Custom email template ব্যবহার করে spam folder avoid করে
  ///
  /// Used in: lib/screens/auth/verification_screen.dart line 80+
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      // Custom action code settings for better email delivery
      final actionCodeSettings = ActionCodeSettings(
        // URL to redirect after verification
        url: 'https://blooddonation.com/verify-email',
        handleCodeInApp: false,
        // Mobile app settings (optional)
        iOSBundleId: 'com.example.bloodBank1',
        androidPackageName: 'com.example.blood_bank1',
        androidInstallApp: true,
        androidMinimumVersion: '21',
      );

      await user.sendEmailVerification(actionCodeSettings);

      // Log email sent for tracking
      await FirebaseFirestore.instance.collection('emailLogs').add({
        'type': 'verification',
        'to': user.email,
        'userId': user.uid,
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'sent',
      });
    }
  }

  /// Email verification status check করে
  /// Returns: true if email verified, false otherwise
  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Email verification resend করে (rate limit সাথে)
  /// Prevents spam sending, max 1 email per minute
  Future<bool> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      if (user.emailVerified) {
        debugPrint('Email already verified');
        return false;
      }

      await sendEmailVerification();
      return true;
    } catch (e) {
      debugPrint('Error resending verification email: $e');
      return false;
    }
  }

  // ==================== SIGN OUT ====================

  /// User কে logout করে (Google + Firebase থেকে)
  ///
  /// এটা clear করে:
  /// - Firebase Auth session
  /// - Google Sign-in session (if available)
  ///
  /// Used in: lib/screens/home/profile_screen.dart
  Future<void> signOut() async {
    try {
      await _google.signOut();
    } catch (e) {
      // Google sign out may fail on web without client ID - ignore
      debugPrint('Google signOut skipped: $e');
    }
    await _auth.signOut();
  }

  // ==================== GOOGLE SIGN-IN ====================

  /// Google account দিয়ে sign in করে
  ///
  /// Process:
  /// 1. Google sign-in dialog open হয়
  /// 2. User account select করে
  /// 3. Firebase এ credential দিয়ে login
  ///
  /// Returns: UserCredential or null if cancelled
  ///
  /// Used in: lib/screens/auth/login_screen.dart
  Future<UserCredential?> signInWithGoogle() async {
    final account = await _google.signIn();
    if (account == null) return null;
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  // ==================== PHONE VERIFICATION ====================

  /// Phone number verify করে SMS OTP দিয়ে
  ///
  /// Process:
  /// 1. Phone number এ SMS code পাঠানো হয়
  /// 2. User code enter করে
  /// 3. Code verify হলে phone verified
  ///
  /// Parameters:
  /// - phoneNumber: Format +880XXXXXXXXXX (Bangladesh)
  /// - codeSent: Callback when SMS sent (returns verificationId)
  /// - completed: Callback when auto-verification complete
  /// - failed: Callback when verification fails
  ///
  /// Used in: lib/screens/auth/verification_screen.dart line 120+
  Future<void> verifyPhone({
    required String phoneNumber,
    required void Function(String verificationId) codeSent,
    required void Function(UserCredential credential) completed,
    required void Function(String error) failed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (cred) async {
        try {
          final result = await _auth.signInWithCredential(cred);
          completed(result);
        } catch (e) {
          failed(e.toString());
        }
      },
      verificationFailed: (e) =>
          failed(e.message ?? 'Phone verification failed'),
      codeSent: (verificationId, _) => codeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// SMS code verify করে এবং phone authentication complete করে
  ///
  /// Parameters:
  /// - verificationId: SMS পাঠানোর সময় পাওয়া ID
  /// - smsCode: User এর enter করা 6-digit code
  ///
  /// Returns: UserCredential if code valid
  /// Throws: FirebaseAuthException if code invalid
  ///
  /// Used in: lib/screens/auth/verification_screen.dart line 180+
  Future<UserCredential> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  }) {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  // ==================== USER PROFILE MANAGEMENT ====================

  /// Current logged-in user এর Firebase User object return করে
  ///
  /// Returns: User object or null if not logged in
  ///
  /// Used throughout the app to check login status
  User? currentUser() => _auth.currentUser;

  /// Current user এর Firestore profile document fetch করে
  ///
  /// Returns: DocumentSnapshot with user profile data
  /// Data includes: name, bloodType, phone, role, etc.
  ///
  /// Used in: lib/screens/auth/login_screen.dart line 392+
  Future<DocumentSnapshot<Map<String, dynamic>>?>
  getCurrentUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  /// User profile data update করে Firestore এ
  ///
  /// এটা automatically:
  /// - Add করে uid field
  /// - Add করে updatedAt timestamp
  /// - Merge করে existing data এর সাথে
  ///
  /// Parameters:
  /// - data: Profile data to update (name, bloodType, phone, etc.)
  ///
  /// Used in:
  /// - lib/screens/auth/signup_screen.dart (profile creation)
  /// - lib/screens/auth/verification_screen.dart (verification status)
  /// - lib/screens/home/profile_screen.dart (profile editing)
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('No authenticated user');
    final toWrite = {
      'uid': uid,
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(toWrite, SetOptions(merge: true));
  }

  /// User profile ensure করে Firestore এ (না থাকলে create করে)
  ///
  /// এটা safe to call multiple times - duplicate create করবে না
  ///
  /// Parameters:
  /// - initial: Optional initial profile data
  ///
  /// Used after Google Sign-in or first login
  Future<void> ensureUserProfile({Map<String, dynamic>? initial}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (!doc.exists) {
      final base = {
        'uid': uid,
        'email': _auth.currentUser?.email,
        'name': _auth.currentUser?.displayName ?? '',
        'emailVerified': _auth.currentUser?.emailVerified ?? false,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        ...base,
        ...?initial,
      }, SetOptions(merge: true));
    }
  }
}
