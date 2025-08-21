import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawalRequest {
  final String id;
  final String uid;
  final String upiId;
  final double amount;
  final String status; // pending, approved, rejected
  final DateTime requestDate;
  final DateTime? processedDate;
  final String? remarks;

  WithdrawalRequest({
    required this.id,
    required this.uid,
    required this.upiId,
    required this.amount,
    required this.status,
    required this.requestDate,
    this.processedDate,
    this.remarks,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'upiId': upiId,
      'amount': amount,
      'status': status,
      'requestDate': requestDate.toIso8601String(),
      'processedDate': processedDate?.toIso8601String(),
      'remarks': remarks,
    };
  }

  // Create from Map
  factory WithdrawalRequest.fromMap(Map<String, dynamic> map) {
    return WithdrawalRequest(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      upiId: map['upiId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      requestDate: DateTime.parse(map['requestDate']),
      processedDate: map['processedDate'] != null 
          ? DateTime.parse(map['processedDate'])
          : null,
      remarks: map['remarks'],
    );
  }

  // Create from Firestore DocumentSnapshot
  factory WithdrawalRequest.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return WithdrawalRequest.fromMap({
      'id': snapshot.id,
      ...data,
    });
  }

  // Copy with method
  WithdrawalRequest copyWith({
    String? id,
    String? uid,
    String? upiId,
    double? amount,
    String? status,
    DateTime? requestDate,
    DateTime? processedDate,
    String? remarks,
  }) {
    return WithdrawalRequest(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      upiId: upiId ?? this.upiId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      requestDate: requestDate ?? this.requestDate,
      processedDate: processedDate ?? this.processedDate,
      remarks: remarks ?? this.remarks,
    );
  }
}
