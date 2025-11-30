import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current stock for all blood types
  Stream<Map<String, int>> getBloodStock() {
    return _firestore.collection('inventory').snapshots().map((snapshot) {
      final stock = <String, int>{};
      for (var doc in snapshot.docs) {
        stock[doc.id] = doc.data()['count'] ?? 0;
      }
      // Ensure all blood types are present
      final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
      for (var type in bloodTypes) {
        if (!stock.containsKey(type)) {
          stock[type] = 0;
        }
      }
      return stock;
    });
  }

  // Update stock (Add/Remove)
  Future<void> updateStock({
    required String bloodType,
    required int quantity,
    required String reason, // 'donation', 'usage', 'expired', 'transfer'
    String? notes,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final docRef = _firestore.collection('inventory').doc(bloodType);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      int currentCount = 0;
      if (snapshot.exists) {
        currentCount = snapshot.data()?['count'] ?? 0;
      }

      int newCount = currentCount + quantity;
      if (newCount < 0) throw Exception('Insufficient stock');

      transaction.set(docRef, {
        'count': newCount,
        'lastUpdated': FieldValue.serverTimestamp(),
        'updatedBy': currentUser.uid,
      }, SetOptions(merge: true));

      // Log the transaction
      transaction.set(_firestore.collection('inventory_logs').doc(), {
        'bloodType': bloodType,
        'quantity': quantity,
        'reason': reason,
        'notes': notes,
        'performedBy': currentUser.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'previousCount': currentCount,
        'newCount': newCount,
      });
    });
  }

  // Get low stock alerts (threshold < 5 units)
  Stream<List<String>> getLowStockAlerts() {
    return getBloodStock().map((stock) {
      final lowStock = <String>[];
      stock.forEach((type, quantity) {
        if (quantity < 5) {
          lowStock.add(type);
        }
      });
      return lowStock;
    });
  }
}
