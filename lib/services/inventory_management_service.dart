import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Inventory Management Service
/// Track blood stock, expiry dates, and demand forecasting
class InventoryManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final InventoryManagementService _instance =
      InventoryManagementService._internal();
  factory InventoryManagementService() => _instance;
  InventoryManagementService._internal();

  /// Add blood stock
  Future<void> addStock({
    required String organizationId,
    required String bloodType,
    required int units,
    required DateTime collectionDate,
    required DateTime expiryDate,
    required String donorId,
    String? location,
    String? batchNumber,
  }) async {
    await _firestore.collection('bloodInventory').add({
      'organizationId': organizationId,
      'bloodType': bloodType,
      'units': units,
      'availableUnits': units,
      'collectionDate': Timestamp.fromDate(collectionDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'donorId': donorId,
      'location': location ?? 'Main Storage',
      'batchNumber': batchNumber,
      'status': 'available', // available, reserved, used, expired
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update organization inventory stats
    await _updateInventoryStats(organizationId, bloodType);
  }

  /// Update inventory stats
  Future<void> _updateInventoryStats(
    String organizationId,
    String bloodType,
  ) async {
    final snapshot = await _firestore
        .collection('bloodInventory')
        .where('organizationId', isEqualTo: organizationId)
        .where('bloodType', isEqualTo: bloodType)
        .where('status', isEqualTo: 'available')
        .get();

    int totalUnits = 0;
    for (var doc in snapshot.docs) {
      totalUnits += (doc.data()['availableUnits'] ?? 0) as int;
    }

    await _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('inventoryStats')
        .doc(bloodType)
        .set({
          'bloodType': bloodType,
          'totalUnits': totalUnits,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Reserve blood units
  Future<bool> reserveBlood({
    required String organizationId,
    required String bloodType,
    required int units,
    required String requestId,
  }) async {
    // Find available stock (oldest first - FIFO)
    final snapshot = await _firestore
        .collection('bloodInventory')
        .where('organizationId', isEqualTo: organizationId)
        .where('bloodType', isEqualTo: bloodType)
        .where('status', isEqualTo: 'available')
        .orderBy('collectionDate')
        .get();

    int unitsNeeded = units;
    final batch = _firestore.batch();

    for (var doc in snapshot.docs) {
      if (unitsNeeded <= 0) break;

      final data = doc.data();
      final availableUnits = (data['availableUnits'] ?? 0) as int;

      if (availableUnits > 0) {
        final unitsToReserve = availableUnits >= unitsNeeded
            ? unitsNeeded
            : availableUnits;

        batch.update(doc.reference, {
          'availableUnits': availableUnits - unitsToReserve,
          'status': (availableUnits - unitsToReserve) == 0
              ? 'reserved'
              : 'available',
        });

        // Create reservation record
        final reservationRef = _firestore.collection('reservations').doc();
        batch.set(reservationRef, {
          'inventoryId': doc.id,
          'organizationId': organizationId,
          'bloodType': bloodType,
          'units': unitsToReserve,
          'requestId': requestId,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });

        unitsNeeded -= unitsToReserve;
      }
    }

    if (unitsNeeded > 0) {
      return false; // Not enough stock
    }

    await batch.commit();
    await _updateInventoryStats(organizationId, bloodType);
    return true;
  }

  /// Use reserved blood
  Future<void> useBlood({
    required String reservationId,
    required String usedBy,
  }) async {
    final reservationDoc = await _firestore
        .collection('reservations')
        .doc(reservationId)
        .get();
    final data = reservationDoc.data()!;

    await _firestore.collection('reservations').doc(reservationId).update({
      'status': 'used',
      'usedBy': usedBy,
      'usedAt': FieldValue.serverTimestamp(),
    });

    // Update inventory
    await _firestore
        .collection('bloodInventory')
        .doc(data['inventoryId'])
        .update({'status': 'used'});

    await _updateInventoryStats(data['organizationId'], data['bloodType']);
  }

  /// Get stock levels
  Future<Map<String, int>> getStockLevels(String organizationId) async {
    final stockLevels = <String, int>{};
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    for (var bloodType in bloodTypes) {
      final doc = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('inventoryStats')
          .doc(bloodType)
          .get();

      stockLevels[bloodType] = doc.data()?['totalUnits'] ?? 0;
    }

    return stockLevels;
  }

  /// Check expiring stock (within 7 days)
  Future<List<Map<String, dynamic>>> getExpiringStock(
    String organizationId,
  ) async {
    final sevenDaysFromNow = DateTime.now().add(const Duration(days: 7));

    final snapshot = await _firestore
        .collection('bloodInventory')
        .where('organizationId', isEqualTo: organizationId)
        .where('status', isEqualTo: 'available')
        .where('expiryDate', isLessThan: Timestamp.fromDate(sevenDaysFromNow))
        .orderBy('expiryDate')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Mark expired stock
  Future<void> markExpiredStock() async {
    final now = DateTime.now();

    final snapshot = await _firestore
        .collection('bloodInventory')
        .where('status', isEqualTo: 'available')
        .where('expiryDate', isLessThan: Timestamp.fromDate(now))
        .get();

    final batch = _firestore.batch();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'status': 'expired'});
    }

    await batch.commit();
  }

  /// Forecast demand (based on last 30 days)
  Future<Map<String, dynamic>> forecastDemand(String organizationId) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final requestsSnapshot = await _firestore
        .collection('bloodRequests')
        .where('organizationId', isEqualTo: organizationId)
        .where('requestDate', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
        .get();

    final demandByType = <String, int>{};
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    for (var bloodType in bloodTypes) {
      demandByType[bloodType] = 0;
    }

    for (var doc in requestsSnapshot.docs) {
      final bloodType = doc.data()['bloodType'] ?? '';
      final units = doc.data()['units'] ?? 1;
      demandByType[bloodType] = (demandByType[bloodType] ?? 0) + units as int;
    }

    // Calculate weekly forecast
    final weeklyForecast = <String, int>{};
    for (var entry in demandByType.entries) {
      weeklyForecast[entry.key] = ((entry.value / 30) * 7).ceil();
    }

    return {
      'last30Days': demandByType,
      'weeklyForecast': weeklyForecast,
      'totalDemand': demandByType.values.reduce((a, b) => a + b),
    };
  }

  /// Get stock alerts
  Future<List<Map<String, String>>> getStockAlerts(
    String organizationId,
  ) async {
    final alerts = <Map<String, String>>[];
    final stockLevels = await getStockLevels(organizationId);
    final expiringStock = await getExpiringStock(organizationId);
    final forecast = await forecastDemand(organizationId);

    // Low stock alerts
    for (var entry in stockLevels.entries) {
      if (entry.value < 5) {
        alerts.add({
          'type': 'low_stock',
          'severity': 'critical',
          'bloodType': entry.key,
          'message':
              '⚠️ CRITICAL: Only ${entry.value} units of ${entry.key} left!',
        });
      } else if (entry.value < 10) {
        alerts.add({
          'type': 'low_stock',
          'severity': 'warning',
          'bloodType': entry.key,
          'message': '⚡ LOW: ${entry.value} units of ${entry.key} remaining',
        });
      }
    }

    // Expiring stock alerts
    for (var stock in expiringStock) {
      final daysUntilExpiry = (stock['expiryDate'] as Timestamp)
          .toDate()
          .difference(DateTime.now())
          .inDays;

      alerts.add({
        'type': 'expiring',
        'severity': daysUntilExpiry <= 2 ? 'critical' : 'warning',
        'bloodType': stock['bloodType'],
        'message':
            '⏰ ${stock['bloodType']} expiring in $daysUntilExpiry days (${stock['availableUnits']} units)',
      });
    }

    // Demand-based alerts
    final weeklyForecast = forecast['weeklyForecast'] as Map<String, int>;
    for (var entry in weeklyForecast.entries) {
      final currentStock = stockLevels[entry.key] ?? 0;
      final weeklyDemand = entry.value;

      if (currentStock < weeklyDemand) {
        alerts.add({
          'type': 'demand_shortage',
          'severity': 'warning',
          'bloodType': entry.key,
          'message':
              '📊 ${entry.key}: Current stock ($currentStock) below weekly forecast ($weeklyDemand)',
        });
      }
    }

    return alerts;
  }

  /// Get inventory dashboard data
  Future<Map<String, dynamic>> getDashboardData(String organizationId) async {
    final stockLevels = await getStockLevels(organizationId);
    final expiringStock = await getExpiringStock(organizationId);
    final forecast = await forecastDemand(organizationId);
    final alerts = await getStockAlerts(organizationId);

    final totalStock = stockLevels.values.reduce((a, b) => a + b);
    final totalExpiring = expiringStock.fold<int>(
      0,
      (sum, stock) => sum + (stock['availableUnits'] as int),
    );

    return {
      'stockLevels': stockLevels,
      'totalStock': totalStock,
      'expiringUnits': totalExpiring,
      'criticalAlerts': alerts.where((a) => a['severity'] == 'critical').length,
      'warningAlerts': alerts.where((a) => a['severity'] == 'warning').length,
      'forecast': forecast,
      'alerts': alerts,
    };
  }
}
