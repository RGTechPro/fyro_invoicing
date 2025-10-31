import 'package:cloud_firestore/cloud_firestore.dart';

class Wastage {
  final String id;
  final String employeeId; // Who recorded the wastage
  final String employeeName; // Who recorded the wastage
  final DateTime date;
  final String itemName;
  final double quantity;
  final String unit; // kg, pcs, liters, etc.
  final String reason; // 'employee_consumed', 'thrown', 'other'
  final String?
      consumedBy; // Employee name who ate (if reason is employee_consumed)
  final String? consumedByOther; // Other person name (if reason is other)
  final String? notes; // Additional notes
  final double? estimatedValue; // Optional: estimated cost

  Wastage({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.reason,
    this.consumedBy,
    this.consumedByOther,
    this.notes,
    this.estimatedValue,
  });

  // Helper getters
  bool get isEmployeeConsumed => reason == 'employee_consumed';
  bool get isThrown => reason == 'thrown';
  bool get isOtherConsumed => reason == 'other';

  String get displayReason {
    switch (reason) {
      case 'employee_consumed':
        return 'Consumed by Employee: ${consumedBy ?? 'Unknown'}';
      case 'thrown':
        return 'Thrown (Kharab/Spoiled)';
      case 'other':
        return 'Consumed by Other: ${consumedByOther ?? 'Unknown'}';
      default:
        return reason;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'date': Timestamp.fromDate(date),
      'itemName': itemName,
      'quantity': quantity,
      'unit': unit,
      'reason': reason,
      'consumedBy': consumedBy,
      'consumedByOther': consumedByOther,
      'notes': notes,
      'estimatedValue': estimatedValue,
    };
  }

  factory Wastage.fromMap(Map<String, dynamic> map) {
    print('📦 Parsing Wastage from map: $map');

    DateTime parseDateTime(dynamic value, String fieldName) {
      if (value == null) return DateTime.now();

      try {
        if (value is Timestamp) {
          print('  ✅ $fieldName: Timestamp -> DateTime');
          return value.toDate();
        } else if (value is String) {
          print('  ✅ $fieldName: String -> DateTime');
          return DateTime.parse(value);
        } else {
          print(
              '  ⚠️ $fieldName: Unknown type ${value.runtimeType}, using now()');
          return DateTime.now();
        }
      } catch (e) {
        print('  ❌ Error parsing $fieldName: $e, using now()');
        return DateTime.now();
      }
    }

    return Wastage(
      id: map['id'] ?? '',
      employeeId: map['employeeId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      date: parseDateTime(map['date'], 'date'),
      itemName: map['itemName'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      unit: map['unit'] ?? '',
      reason: map['reason'] ?? 'thrown',
      consumedBy: map['consumedBy'],
      consumedByOther: map['consumedByOther'],
      notes: map['notes'],
      estimatedValue: map['estimatedValue']?.toDouble(),
    );
  }

  Wastage copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    DateTime? date,
    String? itemName,
    double? quantity,
    String? unit,
    String? reason,
    String? consumedBy,
    String? consumedByOther,
    String? notes,
    double? estimatedValue,
  }) {
    return Wastage(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      reason: reason ?? this.reason,
      consumedBy: consumedBy ?? this.consumedBy,
      consumedByOther: consumedByOther ?? this.consumedByOther,
      notes: notes ?? this.notes,
      estimatedValue: estimatedValue ?? this.estimatedValue,
    );
  }
}
