import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Smart Donation Scheduler Service
/// Auto-calculate next eligible date, send reminders, calendar integration
class DonationSchedulerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static final DonationSchedulerService _instance =
      DonationSchedulerService._internal();
  factory DonationSchedulerService() => _instance;
  DonationSchedulerService._internal();

  /// Initialize notification system
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings);
  }

  /// Calculate next eligible donation date (120 days from last donation)
  DateTime? calculateNextEligibleDate(DateTime? lastDonationDate) {
    if (lastDonationDate == null) return DateTime.now();
    return lastDonationDate.add(const Duration(days: 120));
  }

  /// Schedule donation reminders
  Future<void> scheduleReminders(
    String userId,
    DateTime nextEligibleDate,
  ) async {
    // Clear existing reminders
    await cancelReminders(userId);

    final now = DateTime.now();

    // 7 days before reminder
    final reminder7Days = nextEligibleDate.subtract(const Duration(days: 7));
    if (reminder7Days.isAfter(now)) {
      await _scheduleNotification(
        id: userId.hashCode + 1,
        title: '🩸 Donation Reminder',
        body: 'You can donate blood in 7 days! Start preparing.',
        scheduledDate: reminder7Days,
      );
    }

    // 3 days before reminder
    final reminder3Days = nextEligibleDate.subtract(const Duration(days: 3));
    if (reminder3Days.isAfter(now)) {
      await _scheduleNotification(
        id: userId.hashCode + 2,
        title: '🩸 Almost Ready!',
        body: 'Only 3 days until you can donate blood again.',
        scheduledDate: reminder3Days,
      );
    }

    // 1 day before reminder
    final reminder1Day = nextEligibleDate.subtract(const Duration(days: 1));
    if (reminder1Day.isAfter(now)) {
      await _scheduleNotification(
        id: userId.hashCode + 3,
        title: '🩸 Tomorrow is the Day!',
        body: 'You can donate blood tomorrow. Save a life!',
        scheduledDate: reminder1Day,
      );
    }

    // Eligible day notification
    if (nextEligibleDate.isAfter(now)) {
      await _scheduleNotification(
        id: userId.hashCode + 4,
        title: '🎉 Ready to Donate!',
        body: 'You are now eligible to donate blood. Book your appointment!',
        scheduledDate: nextEligibleDate,
      );
    }

    // Save to Firestore
    await _firestore.collection('scheduledReminders').doc(userId).set({
      'nextEligibleDate': Timestamp.fromDate(nextEligibleDate),
      'reminders': [
        {'days': 7, 'scheduled': Timestamp.fromDate(reminder7Days)},
        {'days': 3, 'scheduled': Timestamp.fromDate(reminder3Days)},
        {'days': 1, 'scheduled': Timestamp.fromDate(reminder1Day)},
        {'days': 0, 'scheduled': Timestamp.fromDate(nextEligibleDate)},
      ],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Schedule a notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate.toLocal() as dynamic, // Will be converted by plugin
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'donation_reminders',
            'Donation Reminders',
            channelDescription: 'Reminders for blood donation eligibility',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// Cancel all reminders for user
  Future<void> cancelReminders(String userId) async {
    for (int i = 1; i <= 4; i++) {
      await _notifications.cancel(userId.hashCode + i);
    }
  }

  /// Birthday donation campaign
  Future<void> scheduleBirthdayReminder(
    String userId,
    DateTime birthday,
  ) async {
    final thisYearBirthday = DateTime(
      DateTime.now().year,
      birthday.month,
      birthday.day,
    );

    if (thisYearBirthday.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: userId.hashCode + 100,
        title: '🎂 Birthday Special!',
        body: 'Celebrate your birthday by donating blood and saving a life!',
        scheduledDate: thisYearBirthday,
      );
    }
  }

  /// Get user's schedule
  Future<Map<String, dynamic>?> getUserSchedule(String userId) async {
    final doc = await _firestore
        .collection('scheduledReminders')
        .doc(userId)
        .get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  /// Update schedule after donation
  Future<void> updateScheduleAfterDonation(
    String userId,
    DateTime donationDate,
  ) async {
    final nextEligible = calculateNextEligibleDate(donationDate);
    if (nextEligible != null) {
      await scheduleReminders(userId, nextEligible);
    }
  }

  /// Get days until next donation
  int getDaysUntilNextDonation(DateTime? lastDonationDate) {
    if (lastDonationDate == null) return 0;
    final nextEligible = calculateNextEligibleDate(lastDonationDate);
    final diff = nextEligible!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  /// Check if user is eligible now
  bool isEligibleNow(DateTime? lastDonationDate) {
    return getDaysUntilNextDonation(lastDonationDate) == 0;
  }

  /// Export to calendar (iCal format)
  String generateCalendarEvent(String userId, DateTime nextEligibleDate) {
    return '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//PSTU Bloodbank//Donation Reminder//EN
BEGIN:VEVENT
UID:donation-$userId-${nextEligibleDate.millisecondsSinceEpoch}
DTSTAMP:${_formatDateTime(DateTime.now())}
DTSTART:${_formatDateTime(nextEligibleDate)}
SUMMARY:Blood Donation - You're Eligible!
DESCRIPTION:You can donate blood today. Save a life!
STATUS:CONFIRMED
SEQUENCE:0
END:VEVENT
END:VCALENDAR
''';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}T${dt.hour.toString().padLeft(2, '0')}${dt.minute.toString().padLeft(2, '0')}${dt.second.toString().padLeft(2, '0')}Z';
  }

  /// Get reminder statistics
  Future<Map<String, int>> getReminderStats() async {
    final now = DateTime.now();
    final snapshot = await _firestore
        .collection('scheduledReminders')
        .where('nextEligibleDate', isGreaterThan: Timestamp.fromDate(now))
        .get();

    int upcoming7Days = 0;
    int upcoming30Days = 0;
    int eligibleNow = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final nextDate = (data['nextEligibleDate'] as Timestamp).toDate();
      final diff = nextDate.difference(now).inDays;

      if (diff == 0) {
        eligibleNow++;
      } else if (diff <= 7) {
        upcoming7Days++;
      } else if (diff <= 30) {
        upcoming30Days++;
      }
    }

    return {
      'eligibleNow': eligibleNow,
      'upcoming7Days': upcoming7Days,
      'upcoming30Days': upcoming30Days,
      'total': snapshot.docs.length,
    };
  }
}
