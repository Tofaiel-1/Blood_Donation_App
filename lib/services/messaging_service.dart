import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class MessagingService {
  final FirebaseMessaging _fm = FirebaseMessaging.instance;

  Future<void> init() async {
    await _fm.requestPermission();
    if (!kIsWeb) {
      final token = await _fm.getToken();
      debugPrint('FCM token: $token');
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message: ${message.notification?.title}');
    });
  }

  Future<void> subscribeToEmergencies() => _fm.subscribeToTopic('emergencies');
  Future<void> unsubscribeFromEmergencies() =>
      _fm.unsubscribeFromTopic('emergencies');
}
