import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String employeeId; // Who recorded the expense
  final String employeeName; // Who recorded the expense
  final DateTime date;
  final String category; // groceries, utilities, supplies, transport, etc.
  final String itemDescription;
  final double amount;
  final String? vendor; // Shop/vendor name
  final String? paymentMode; // cash, card, upi, etc.
  final String? billNumber; // Optional bill/receipt number
  final String? notes;
  final bool isApproved; // Admin approval status
  final DateTime? approvedDate;
  final String? approvedBy; // Admin who approved

  Expense({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.category,
    required this.itemDescription,
    required this.amount,
    this.vendor,
    this.paymentMode,
    this.billNumber,
    this.notes,
    this.isApproved = false,
    this.approvedDate,
    this.approvedBy,
  });

  // Helper getters
  bool get isPending => !isApproved;

  String get statusText => isApproved ? 'Approved' : 'Pending';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'date': Timestamp.fromDate(date),
      'category': category,
      'itemDescription': itemDescription,
      'amount': amount,
      'vendor': vendor,
      'paymentMode': paymentMode,
      'billNumber': billNumber,
      'notes': notes,
      'isApproved': isApproved,
      'approvedDate':
          approvedDate != null ? Timestamp.fromDate(approvedDate!) : null,
      'approvedBy': approvedBy,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    print('📦 Parsing Expense from map: $map');

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

    DateTime? parseOptionalDateTime(dynamic value, String fieldName) {
      if (value == null) return null;

      try {
        if (value is Timestamp) {
          print('  ✅ $fieldName: Timestamp -> DateTime');
          return value.toDate();
        } else if (value is String) {
          print('  ✅ $fieldName: String -> DateTime');
          return DateTime.parse(value);
        } else {
          print(
              '  ⚠️ $fieldName: Unknown type ${value.runtimeType}, using null');
          return null;
        }
      } catch (e) {
        print('  ❌ Error parsing $fieldName: $e, using null');
        return null;
      }
    }

    return Expense(
      id: map['id'] ?? '',
      employeeId: map['employeeId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      date: parseDateTime(map['date'], 'date'),
      category: map['category'] ?? '',
      itemDescription: map['itemDescription'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      vendor: map['vendor'],
      paymentMode: map['paymentMode'],
      billNumber: map['billNumber'],
      notes: map['notes'],
      isApproved: map['isApproved'] ?? false,
      approvedDate: parseOptionalDateTime(map['approvedDate'], 'approvedDate'),
      approvedBy: map['approvedBy'],
    );
  }

  Expense copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    DateTime? date,
    String? category,
    String? itemDescription,
    double? amount,
    String? vendor,
    String? paymentMode,
    String? billNumber,
    String? notes,
    bool? isApproved,
    DateTime? approvedDate,
    String? approvedBy,
  }) {
    return Expense(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      category: category ?? this.category,
      itemDescription: itemDescription ?? this.itemDescription,
      amount: amount ?? this.amount,
      vendor: vendor ?? this.vendor,
      paymentMode: paymentMode ?? this.paymentMode,
      billNumber: billNumber ?? this.billNumber,
      notes: notes ?? this.notes,
      isApproved: isApproved ?? this.isApproved,
      approvedDate: approvedDate ?? this.approvedDate,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }
}
