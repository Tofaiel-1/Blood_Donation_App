import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus { pending, approved, fulfilled, cancelled }

enum UrgencyLevel { normal, urgent, critical }

class BloodRequest {
  final String id;
  final String bloodType;
  final String hospitalName;
  final String location;
  final String contactPhone;
  final String patientName;
  final int unitsNeeded;
  final UrgencyLevel urgency;
  final RequestStatus status;
  final String requestedBy; // User ID
  final String requestedByName;
  final DateTime requestDate;
  final DateTime? fulfilledDate;
  final String? notes;
  final String? assignedAdminId;

  BloodRequest({
    required this.id,
    required this.bloodType,
    required this.hospitalName,
    required this.location,
    required this.contactPhone,
    required this.patientName,
    required this.unitsNeeded,
    required this.urgency,
    required this.status,
    required this.requestedBy,
    required this.requestedByName,
    required this.requestDate,
    this.fulfilledDate,
    this.notes,
    this.assignedAdminId,
  });

  factory BloodRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BloodRequest(
      id: doc.id,
      bloodType: data['bloodType'] ?? '',
      hospitalName: data['hospitalName'] ?? '',
      location: data['location'] ?? '',
      contactPhone: data['contactPhone'] ?? '',
      patientName: data['patientName'] ?? '',
      unitsNeeded: data['unitsNeeded'] ?? 1,
      urgency: _parseUrgency(data['urgency']),
      status: _parseStatus(data['status']),
      requestedBy: data['requestedBy'] ?? '',
      requestedByName: data['requestedByName'] ?? '',
      requestDate:
          (data['requestDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fulfilledDate: (data['fulfilledDate'] as Timestamp?)?.toDate(),
      notes: data['notes'],
      assignedAdminId: data['assignedAdminId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bloodType': bloodType,
      'hospitalName': hospitalName,
      'location': location,
      'contactPhone': contactPhone,
      'patientName': patientName,
      'unitsNeeded': unitsNeeded,
      'urgency': urgency.name,
      'status': status.name,
      'requestedBy': requestedBy,
      'requestedByName': requestedByName,
      'requestDate': Timestamp.fromDate(requestDate),
      'fulfilledDate': fulfilledDate != null
          ? Timestamp.fromDate(fulfilledDate!)
          : null,
      'notes': notes,
      'assignedAdminId': assignedAdminId,
    };
  }

  static UrgencyLevel _parseUrgency(String? urgency) {
    switch (urgency) {
      case 'critical':
        return UrgencyLevel.critical;
      case 'urgent':
        return UrgencyLevel.urgent;
      default:
        return UrgencyLevel.normal;
    }
  }

  static RequestStatus _parseStatus(String? status) {
    switch (status) {
      case 'approved':
        return RequestStatus.approved;
      case 'fulfilled':
        return RequestStatus.fulfilled;
      case 'cancelled':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.pending;
    }
  }

  BloodRequest copyWith({
    RequestStatus? status,
    DateTime? fulfilledDate,
    String? assignedAdminId,
  }) {
    return BloodRequest(
      id: id,
      bloodType: bloodType,
      hospitalName: hospitalName,
      location: location,
      contactPhone: contactPhone,
      patientName: patientName,
      unitsNeeded: unitsNeeded,
      urgency: urgency,
      status: status ?? this.status,
      requestedBy: requestedBy,
      requestedByName: requestedByName,
      requestDate: requestDate,
      fulfilledDate: fulfilledDate ?? this.fulfilledDate,
      notes: notes,
      assignedAdminId: assignedAdminId ?? this.assignedAdminId,
    );
  }
}
