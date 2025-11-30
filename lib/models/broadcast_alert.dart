import 'package:cloud_firestore/cloud_firestore.dart';

/// Broadcast alert types for targeted messaging
enum AlertType {
  emergency, // Urgent blood requests
  general, // General announcements
  campaign, // Blood donation campaigns
  appreciation, // Thank you messages
}

/// Target audience for broadcast alerts
enum AlertTarget {
  all, // All users
  bloodType, // Specific blood type
  location, // Specific location/district
  activeDopers, // Only available donors
}

/// Broadcast Alert Model
/// Admin/SuperAdmin can send alerts to specific user groups
class BroadcastAlert {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final AlertTarget target;
  final String? targetValue; // e.g., "A+", "Dhaka", etc.
  final String createdBy; // Admin ID
  final String createdByName;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;
  final int viewCount; // How many users viewed
  final List<String> viewedBy; // User IDs who viewed

  const BroadcastAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.target,
    this.targetValue,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    this.expiresAt,
    this.isActive = true,
    this.viewCount = 0,
    this.viewedBy = const [],
  });

  /// Check if alert is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if alert is visible
  bool get isVisible {
    return isActive && !isExpired;
  }

  /// Check if a user should see this alert
  bool shouldShowToUser(Map<String, dynamic> userData) {
    if (!isVisible) return false;

    // Check if user already viewed
    final userId = userData['id'] as String?;
    if (userId != null && viewedBy.contains(userId)) {
      return false; // Don't show again
    }

    switch (target) {
      case AlertTarget.all:
        return true;

      case AlertTarget.bloodType:
        if (targetValue == null) return false;
        final userBloodType = userData['bloodType'] as String?;
        return userBloodType == targetValue;

      case AlertTarget.location:
        if (targetValue == null) return false;
        final userLocation =
            userData['location'] as String? ??
            userData['district'] as String? ??
            userData['address'] as String?;
        return userLocation?.toLowerCase().contains(
              targetValue!.toLowerCase(),
            ) ??
            false;

      case AlertTarget.activeDopers:
        final isAvailable = userData['availableForDonation'] as bool? ?? false;
        final canDonate = userData['isEligibleToDonate'] as bool? ?? false;
        return isAvailable && canDonate;
    }
  }

  factory BroadcastAlert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BroadcastAlert(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: AlertType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => AlertType.general,
      ),
      target: AlertTarget.values.firstWhere(
        (e) => e.toString().split('.').last == data['target'],
        orElse: () => AlertTarget.all,
      ),
      targetValue: data['targetValue'],
      createdBy: data['createdBy'] ?? '',
      createdByName: data['createdByName'] ?? 'Admin',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
      viewCount: data['viewCount'] ?? 0,
      viewedBy: List<String>.from(data['viewedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'target': target.toString().split('.').last,
      'targetValue': targetValue,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isActive': isActive,
      'viewCount': viewCount,
      'viewedBy': viewedBy,
    };
  }

  BroadcastAlert copyWith({
    String? id,
    String? title,
    String? message,
    AlertType? type,
    AlertTarget? target,
    String? targetValue,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isActive,
    int? viewCount,
    List<String>? viewedBy,
  }) {
    return BroadcastAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      target: target ?? this.target,
      targetValue: targetValue ?? this.targetValue,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      viewCount: viewCount ?? this.viewCount,
      viewedBy: viewedBy ?? this.viewedBy,
    );
  }

  /// Get alert color based on type
  static int getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.emergency:
        return 0xFFD32F2F; // Red
      case AlertType.general:
        return 0xFF1976D2; // Blue
      case AlertType.campaign:
        return 0xFF388E3C; // Green
      case AlertType.appreciation:
        return 0xFFF57C00; // Orange
    }
  }

  /// Get alert icon based on type
  static String getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.emergency:
        return '🚨';
      case AlertType.general:
        return 'ℹ️';
      case AlertType.campaign:
        return '📢';
      case AlertType.appreciation:
        return '❤️';
    }
  }

  /// Get target display name
  static String getTargetName(AlertTarget target) {
    switch (target) {
      case AlertTarget.all:
        return 'All Users';
      case AlertTarget.bloodType:
        return 'Blood Type';
      case AlertTarget.location:
        return 'Location';
      case AlertTarget.activeDopers:
        return 'Active Donors';
    }
  }
}
