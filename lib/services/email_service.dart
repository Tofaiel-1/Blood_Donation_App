import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Email Service for sending verification and notification emails
/// Uses Firebase Admin SDK or Cloud Functions to send from custom domain
class EmailService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Super Admin Email (configure this in Firebase Console or .env)
  static const String SUPER_ADMIN_EMAIL = 'admin@blooddonation.com';
  static const String APP_NAME = 'Blood Donation App';

  /// Send email verification with custom template
  Future<bool> sendVerificationEmail({
    required User user,
    String? customMessage,
  }) async {
    try {
      // Get action code settings for custom email
      final actionCodeSettings = ActionCodeSettings(
        // URL to redirect after email verification
        url: 'https://blooddonation.com/verify-email',
        // This must be true for mobile apps
        handleCodeInApp: true,
        // iOS bundle ID
        iOSBundleId: 'com.example.bloodBank1',
        // Android package name
        androidPackageName: 'com.example.blood_bank1',
        // Android install app if not installed
        androidInstallApp: true,
        // Android minimum version
        androidMinimumVersion: '21',
        // Dynamic link domain (optional)
        // dynamicLinkDomain: 'blooddonation.page.link',
      );

      // Send verification email with custom settings
      await user.sendEmailVerification(actionCodeSettings);

      // Log email sent in Firestore for tracking
      await _firestore.collection('emailLogs').add({
        'type': 'verification',
        'to': user.email,
        'userId': user.uid,
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'sent',
        'from': SUPER_ADMIN_EMAIL,
      });

      // Trigger Cloud Function to send custom email (if configured)
      await _triggerCustomEmail(
        to: user.email!,
        subject: 'Verify Your Email - $APP_NAME',
        templateType: 'verification',
        userId: user.uid,
        userName: user.displayName ?? 'User',
      );

      debugPrint('✅ Verification email sent to ${user.email}');
      return true;
    } catch (e) {
      debugPrint('❌ Error sending verification email: $e');
      return false;
    }
  }

  /// Resend verification email
  Future<bool> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      if (user.emailVerified) {
        debugPrint('Email already verified');
        return false;
      }

      return await sendVerificationEmail(user: user);
    } catch (e) {
      debugPrint('Error resending verification email: $e');
      return false;
    }
  }

  /// Trigger custom email via Cloud Function or custom backend
  Future<void> _triggerCustomEmail({
    required String to,
    required String subject,
    required String templateType,
    required String userId,
    String? userName,
  }) async {
    try {
      // Store email request in Firestore
      // Cloud Function will pick this up and send via custom SMTP
      await _firestore.collection('emailQueue').add({
        'to': to,
        'from': {'email': SUPER_ADMIN_EMAIL, 'name': APP_NAME},
        'subject': subject,
        'templateType': templateType,
        'templateData': {
          'userName': userName ?? 'User',
          'userId': userId,
          'appName': APP_NAME,
          'supportEmail': SUPER_ADMIN_EMAIL,
          'year': DateTime.now().year,
        },
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Custom email queued for $to');
    } catch (e) {
      debugPrint('Error queuing custom email: $e');
    }
  }

  /// Send blood request notification email
  Future<void> sendBloodRequestNotification({
    required String donorEmail,
    required String donorName,
    required String patientName,
    required String bloodType,
    required String hospital,
    required String urgency,
  }) async {
    try {
      await _firestore.collection('emailQueue').add({
        'to': donorEmail,
        'from': {'email': SUPER_ADMIN_EMAIL, 'name': APP_NAME},
        'subject': '🩸 Urgent Blood Donation Request - $bloodType',
        'templateType': 'blood_request',
        'templateData': {
          'donorName': donorName,
          'patientName': patientName,
          'bloodType': bloodType,
          'hospital': hospital,
          'urgency': urgency,
          'appName': APP_NAME,
          'supportEmail': SUPER_ADMIN_EMAIL,
        },
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'priority': urgency == 'critical' ? 'high' : 'normal',
      });

      debugPrint('Blood request notification queued for $donorEmail');
    } catch (e) {
      debugPrint('Error sending blood request notification: $e');
    }
  }

  /// Send donation confirmation email
  Future<void> sendDonationConfirmation({
    required String userEmail,
    required String userName,
    required String donationDate,
    required String location,
  }) async {
    try {
      await _firestore.collection('emailQueue').add({
        'to': userEmail,
        'from': {'email': SUPER_ADMIN_EMAIL, 'name': APP_NAME},
        'subject': '🎉 Thank You for Your Blood Donation!',
        'templateType': 'donation_confirmation',
        'templateData': {
          'userName': userName,
          'donationDate': donationDate,
          'location': location,
          'appName': APP_NAME,
          'supportEmail': SUPER_ADMIN_EMAIL,
        },
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Donation confirmation email queued for $userEmail');
    } catch (e) {
      debugPrint('Error sending donation confirmation: $e');
    }
  }

  /// Check email verification status
  Future<bool> checkEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      debugPrint('Error checking email verification: $e');
      return false;
    }
  }

  /// Get email template (for preview)
  String getEmailTemplate(String templateType, Map<String, dynamic> data) {
    switch (templateType) {
      case 'verification':
        return _getVerificationTemplate(data);
      case 'blood_request':
        return _getBloodRequestTemplate(data);
      case 'donation_confirmation':
        return _getDonationConfirmationTemplate(data);
      default:
        return _getDefaultTemplate(data);
    }
  }

  String _getVerificationTemplate(Map<String, dynamic> data) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Verify Your Email</title>
</head>
<body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f5f5f5;">
  <table width="100%" cellpadding="0" cellspacing="0" style="max-width: 600px; margin: 0 auto; background-color: white;">
    <tr>
      <td style="background: linear-gradient(135deg, #D32F2F 0%, #B71C1C 100%); padding: 40px 20px; text-align: center;">
        <h1 style="color: white; margin: 0; font-size: 28px;">🩸 ${data['appName']}</h1>
        <p style="color: white; margin: 10px 0 0; font-size: 16px;">Verify Your Email Address</p>
      </td>
    </tr>
    <tr>
      <td style="padding: 40px 30px;">
        <h2 style="color: #333; margin: 0 0 20px;">Hello ${data['userName']}!</h2>
        <p style="color: #666; font-size: 16px; line-height: 1.6;">
          Welcome to ${data['appName']}! We're excited to have you join our community of life-savers.
        </p>
        <p style="color: #666; font-size: 16px; line-height: 1.6;">
          Please verify your email address by clicking the button below:
        </p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="{{verificationLink}}" style="background-color: #D32F2F; color: white; padding: 15px 40px; text-decoration: none; border-radius: 5px; font-size: 16px; font-weight: bold; display: inline-block;">
            Verify Email Address
          </a>
        </div>
        <p style="color: #999; font-size: 14px; line-height: 1.6;">
          If the button doesn't work, copy and paste this link into your browser:<br>
          <span style="color: #D32F2F; word-break: break-all;">{{verificationLink}}</span>
        </p>
        <p style="color: #999; font-size: 14px; line-height: 1.6; margin-top: 30px;">
          This link will expire in 24 hours. If you didn't create an account, please ignore this email.
        </p>
      </td>
    </tr>
    <tr>
      <td style="background-color: #f9f9f9; padding: 20px 30px; text-align: center; border-top: 1px solid #eee;">
        <p style="color: #999; font-size: 12px; margin: 0;">
          © ${data['year']} ${data['appName']}. All rights reserved.<br>
          Need help? Contact us at <a href="mailto:${data['supportEmail']}" style="color: #D32F2F;">${data['supportEmail']}</a>
        </p>
      </td>
    </tr>
  </table>
</body>
</html>
''';
  }

  String _getBloodRequestTemplate(Map<String, dynamic> data) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Blood Request</title>
</head>
<body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f5f5f5;">
  <table width="100%" cellpadding="0" cellspacing="0" style="max-width: 600px; margin: 0 auto; background-color: white;">
    <tr>
      <td style="background: linear-gradient(135deg, #D32F2F 0%, #B71C1C 100%); padding: 40px 20px; text-align: center;">
        <h1 style="color: white; margin: 0; font-size: 28px;">🚨 Urgent Blood Request</h1>
      </td>
    </tr>
    <tr>
      <td style="padding: 40px 30px;">
        <h2 style="color: #333;">Dear ${data['donorName']},</h2>
        <p style="color: #666; font-size: 16px; line-height: 1.6;">
          A patient urgently needs <strong style="color: #D32F2F;">${data['bloodType']}</strong> blood donation.
        </p>
        <div style="background-color: #fff3f3; border-left: 4px solid #D32F2F; padding: 20px; margin: 20px 0;">
          <p style="margin: 0 0 10px; color: #333;"><strong>Patient:</strong> ${data['patientName']}</p>
          <p style="margin: 0 0 10px; color: #333;"><strong>Hospital:</strong> ${data['hospital']}</p>
          <p style="margin: 0 0 10px; color: #333;"><strong>Blood Type:</strong> ${data['bloodType']}</p>
          <p style="margin: 0; color: #D32F2F;"><strong>Urgency:</strong> ${data['urgency'].toUpperCase()}</p>
        </div>
        <p style="color: #666; font-size: 16px; line-height: 1.6;">
          Your donation can save a life. Please open the app to respond to this request.
        </p>
      </td>
    </tr>
    <tr>
      <td style="background-color: #f9f9f9; padding: 20px 30px; text-align: center;">
        <p style="color: #999; font-size: 12px; margin: 0;">
          © ${DateTime.now().year} ${data['appName']}<br>
          <a href="mailto:${data['supportEmail']}" style="color: #D32F2F;">${data['supportEmail']}</a>
        </p>
      </td>
    </tr>
  </table>
</body>
</html>
''';
  }

  String _getDonationConfirmationTemplate(Map<String, dynamic> data) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Donation Confirmation</title>
</head>
<body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f5f5f5;">
  <table width="100%" cellpadding="0" cellspacing="0" style="max-width: 600px; margin: 0 auto; background-color: white;">
    <tr>
      <td style="background: linear-gradient(135deg, #4CAF50 0%, #388E3C 100%); padding: 40px 20px; text-align: center;">
        <h1 style="color: white; margin: 0; font-size: 28px;">🎉 Thank You!</h1>
      </td>
    </tr>
    <tr>
      <td style="padding: 40px 30px; text-align: center;">
        <h2 style="color: #333;">You're a Hero, ${data['userName']}!</h2>
        <p style="color: #666; font-size: 16px; line-height: 1.6;">
          Thank you for your blood donation on <strong>${data['donationDate']}</strong> at ${data['location']}.
        </p>
        <p style="color: #666; font-size: 18px; line-height: 1.6; margin: 30px 0;">
          <strong style="color: #4CAF50;">You just saved a life! ❤️</strong>
        </p>
      </td>
    </tr>
    <tr>
      <td style="background-color: #f9f9f9; padding: 20px 30px; text-align: center;">
        <p style="color: #999; font-size: 12px; margin: 0;">
          © ${DateTime.now().year} ${data['appName']}
        </p>
      </td>
    </tr>
  </table>
</body>
</html>
''';
  }

  String _getDefaultTemplate(Map<String, dynamic> data) {
    return '''
<!DOCTYPE html>
<html>
<body style="font-family: Arial, sans-serif;">
  <h2>Blood Donation App</h2>
  <p>${data['message'] ?? 'No message provided'}</p>
</body>
</html>
''';
  }
}
