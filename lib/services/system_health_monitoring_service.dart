import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

/// System Health Monitoring Service
/// Monitor app performance, uptime, errors
class SystemHealthMonitoringService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final SystemHealthMonitoringService _instance =
      SystemHealthMonitoringService._internal();
  factory SystemHealthMonitoringService() => _instance;
  SystemHealthMonitoringService._internal();

  /// Log system metric
  Future<void> logMetric({
    required String metricName,
    required double value,
    Map<String, dynamic>? metadata,
  }) async {
    await _firestore.collection('systemMetrics').add({
      'metricName': metricName,
      'value': value,
      'metadata': metadata ?? {},
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Log error
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    String? userId,
    Map<String, dynamic>? context,
  }) async {
    await _firestore.collection('systemErrors').add({
      'errorType': errorType,
      'errorMessage': errorMessage,
      'stackTrace': stackTrace,
      'userId': userId,
      'context': context ?? {},
      'platform': Platform.operatingSystem,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Record API call
  Future<void> recordApiCall({
    required String endpoint,
    required String method,
    required int statusCode,
    required int responseTime,
    String? userId,
  }) async {
    await _firestore.collection('apiCalls').add({
      'endpoint': endpoint,
      'method': method,
      'statusCode': statusCode,
      'responseTime': responseTime,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Get system health status
  Future<Map<String, dynamic>> getSystemHealth() async {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));

    // Get error count
    final errorsSnapshot = await _firestore
        .collection('systemErrors')
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(last24Hours),
        )
        .get();

    // Get API call stats
    final apiCallsSnapshot = await _firestore
        .collection('apiCalls')
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(last24Hours),
        )
        .get();

    int totalApiCalls = apiCallsSnapshot.docs.length;
    int failedApiCalls = apiCallsSnapshot.docs
        .where((doc) => (doc.data()['statusCode'] ?? 200) >= 400)
        .length;

    double avgResponseTime = 0;
    if (totalApiCalls > 0) {
      int totalResponseTime = apiCallsSnapshot.docs.fold(
        0,
        (sum, doc) => sum + ((doc.data()['responseTime'] ?? 0) as int),
      );
      avgResponseTime = totalResponseTime / totalApiCalls;
    }

    // Calculate uptime (based on successful API calls)
    double uptime = totalApiCalls > 0
        ? ((totalApiCalls - failedApiCalls) / totalApiCalls * 100)
        : 100;

    // Get active users count
    final activeUsersSnapshot = await _firestore
        .collection('users')
        .where(
          'lastSeen',
          isGreaterThanOrEqualTo: Timestamp.fromDate(last24Hours),
        )
        .get();

    return {
      'status': _getHealthStatus(uptime, errorsSnapshot.docs.length),
      'uptime': uptime.toStringAsFixed(2),
      'totalErrors': errorsSnapshot.docs.length,
      'totalApiCalls': totalApiCalls,
      'failedApiCalls': failedApiCalls,
      'avgResponseTime': avgResponseTime.round(),
      'activeUsers24h': activeUsersSnapshot.docs.length,
      'lastChecked': DateTime.now().toIso8601String(),
    };
  }

  String _getHealthStatus(double uptime, int errors) {
    if (uptime >= 99.9 && errors < 10) return 'healthy';
    if (uptime >= 99.0 && errors < 50) return 'warning';
    return 'critical';
  }

  /// Get error breakdown
  Future<Map<String, int>> getErrorBreakdown({int hours = 24}) async {
    final since = DateTime.now().subtract(Duration(hours: hours));

    final errorsSnapshot = await _firestore
        .collection('systemErrors')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .get();

    final errorsByType = <String, int>{};

    for (var doc in errorsSnapshot.docs) {
      final errorType = doc.data()['errorType'] ?? 'unknown';
      errorsByType[errorType] = (errorsByType[errorType] ?? 0) + 1;
    }

    return errorsByType;
  }

  /// Get performance metrics
  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    final last24Hours = DateTime.now().subtract(const Duration(hours: 24));

    final metricsSnapshot = await _firestore
        .collection('systemMetrics')
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(last24Hours),
        )
        .get();

    final metricsByName = <String, List<double>>{};

    for (var doc in metricsSnapshot.docs) {
      final data = doc.data();
      final name = data['metricName'] ?? '';
      final value = (data['value'] ?? 0.0).toDouble();

      metricsByName[name] ??= [];
      metricsByName[name]!.add(value);
    }

    final averages = <String, double>{};
    for (var entry in metricsByName.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      averages[entry.key] = avg;
    }

    return averages;
  }

  /// Get database stats
  Future<Map<String, int>> getDatabaseStats() async {
    final collections = [
      'users',
      'bloodRequests',
      'donations',
      'campaigns',
      'emergencyNetworks',
      'buddies',
      'bloodInventory',
    ];

    final stats = <String, int>{};

    for (var collection in collections) {
      final snapshot = await _firestore.collection(collection).get();
      stats[collection] = snapshot.docs.length;
    }

    stats['totalDocuments'] = stats.values.reduce((a, b) => a + b);

    return stats;
  }

  /// Get alert configuration
  static const Map<String, dynamic> alertThresholds = {
    'errorRate': {'warning': 10, 'critical': 50},
    'apiFailureRate': {
      'warning': 5.0, // percentage
      'critical': 10.0,
    },
    'responseTime': {
      'warning': 1000, // milliseconds
      'critical': 3000,
    },
    'uptime': {
      'warning': 99.0, // percentage
      'critical': 95.0,
    },
  };

  /// Check alerts
  Future<List<Map<String, String>>> checkAlerts() async {
    final alerts = <Map<String, String>>[];
    final health = await getSystemHealth();

    // Check uptime
    final uptime = double.parse(health['uptime']);
    if (uptime < alertThresholds['uptime']['critical']) {
      alerts.add({
        'severity': 'critical',
        'type': 'uptime',
        'message': '🚨 CRITICAL: System uptime is $uptime%',
      });
    } else if (uptime < alertThresholds['uptime']['warning']) {
      alerts.add({
        'severity': 'warning',
        'type': 'uptime',
        'message': '⚠️ WARNING: System uptime is $uptime%',
      });
    }

    // Check error rate
    final errors = health['totalErrors'] as int;
    if (errors >= alertThresholds['errorRate']['critical']) {
      alerts.add({
        'severity': 'critical',
        'type': 'errors',
        'message': '🚨 CRITICAL: $errors errors in last 24 hours',
      });
    } else if (errors >= alertThresholds['errorRate']['warning']) {
      alerts.add({
        'severity': 'warning',
        'type': 'errors',
        'message': '⚠️ WARNING: $errors errors in last 24 hours',
      });
    }

    // Check API failure rate
    final totalCalls = health['totalApiCalls'] as int;
    final failedCalls = health['failedApiCalls'] as int;
    if (totalCalls > 0) {
      final failureRate = (failedCalls / totalCalls * 100);
      if (failureRate >= alertThresholds['apiFailureRate']['critical']) {
        alerts.add({
          'severity': 'critical',
          'type': 'api_failures',
          'message':
              '🚨 CRITICAL: ${failureRate.toStringAsFixed(1)}% API failure rate',
        });
      } else if (failureRate >= alertThresholds['apiFailureRate']['warning']) {
        alerts.add({
          'severity': 'warning',
          'type': 'api_failures',
          'message':
              '⚠️ WARNING: ${failureRate.toStringAsFixed(1)}% API failure rate',
        });
      }
    }

    // Check response time
    final responseTime = health['avgResponseTime'] as int;
    if (responseTime >= alertThresholds['responseTime']['critical']) {
      alerts.add({
        'severity': 'critical',
        'type': 'response_time',
        'message': '🚨 CRITICAL: Avg response time ${responseTime}ms',
      });
    } else if (responseTime >= alertThresholds['responseTime']['warning']) {
      alerts.add({
        'severity': 'warning',
        'type': 'response_time',
        'message': '⚠️ WARNING: Avg response time ${responseTime}ms',
      });
    }

    return alerts;
  }

  /// Get monitoring dashboard data
  Future<Map<String, dynamic>> getMonitoringDashboard() async {
    final health = await getSystemHealth();
    final errors = await getErrorBreakdown();
    final performance = await getPerformanceMetrics();
    final dbStats = await getDatabaseStats();
    final alerts = await checkAlerts();

    return {
      'health': health,
      'errorBreakdown': errors,
      'performance': performance,
      'databaseStats': dbStats,
      'alerts': alerts,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
}
