class Leave {
  final String id;
  final String employeeId;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime appliedDate;
  final String? adminNotes;
  final String? approvedBy;
  final DateTime? approvedDate;

  Leave({
    required this.id,
    required this.employeeId,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    required this.appliedDate,
    this.adminNotes,
    this.approvedBy,
    this.approvedDate,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
      'reason': reason,
      'status': status,
      'appliedDate': appliedDate.toIso8601String(),
      'adminNotes': adminNotes,
      'approvedBy': approvedBy,
      'approvedDate': approvedDate?.toIso8601String(),
    };
  }

  // Create from Firestore Map
  factory Leave.fromMap(Map<String, dynamic> map) {
    // Helper function to parse DateTime from Timestamp or String
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.parse(value);
      return (value as dynamic).toDate(); // Firebase Timestamp
    }

    return Leave(
      id: map['id'] ?? '',
      employeeId: map['employeeId'] ?? '',
      fromDate: parseDateTime(map['fromDate']) ?? DateTime.now(),
      toDate: parseDateTime(map['toDate']) ?? DateTime.now(),
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'pending',
      appliedDate: parseDateTime(map['appliedDate']) ?? DateTime.now(),
      adminNotes: map['adminNotes'],
      approvedBy: map['approvedBy'],
      approvedDate: parseDateTime(map['approvedDate']),
    );
  }

  // Copy with method for updates
  Leave copyWith({
    String? id,
    String? employeeId,
    DateTime? fromDate,
    DateTime? toDate,
    String? reason,
    String? status,
    DateTime? appliedDate,
    String? adminNotes,
    String? approvedBy,
    DateTime? approvedDate,
  }) {
    return Leave(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      adminNotes: adminNotes ?? this.adminNotes,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedDate: approvedDate ?? this.approvedDate,
    );
  }

  // Calculate number of days
  int get numberOfDays {
    return toDate.difference(fromDate).inDays + 1;
  }

  // Check if pending
  bool get isPending => status == 'pending';

  // Check if approved
  bool get isApproved => status == 'approved';

  // Check if rejected
  bool get isRejected => status == 'rejected';
}
