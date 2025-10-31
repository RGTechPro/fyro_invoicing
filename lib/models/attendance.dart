class Attendance {
  final String id;
  final String employeeId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double totalHours;
  final String status; // 'present', 'absent', 'half-day', 'leave'
  final String? notes;

  Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.totalHours = 0,
    required this.status,
    this.notes,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'totalHours': totalHours,
      'status': status,
      'notes': notes,
    };
  }

  // Create from Firestore Map
  factory Attendance.fromMap(Map<String, dynamic> map) {
    // Helper function to parse DateTime from Timestamp or String
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.parse(value);
      return (value as dynamic).toDate(); // Firebase Timestamp
    }

    return Attendance(
      id: map['id'] ?? '',
      employeeId: map['employeeId'] ?? '',
      date: parseDateTime(map['date']) ?? DateTime.now(),
      checkInTime: parseDateTime(map['checkInTime']),
      checkOutTime: parseDateTime(map['checkOutTime']),
      totalHours: (map['totalHours'] ?? 0).toDouble(),
      status: map['status'] ?? 'absent',
      notes: map['notes'],
    );
  }

  // Copy with method for updates
  Attendance copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    double? totalHours,
    String? status,
    String? notes,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      totalHours: totalHours ?? this.totalHours,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  // Check if checked in
  bool get isCheckedIn => checkInTime != null && checkOutTime == null;

  // Check if checked out
  bool get isCheckedOut => checkInTime != null && checkOutTime != null;

  // Calculate hours worked
  double calculateHours() {
    if (checkInTime != null && checkOutTime != null) {
      return checkOutTime!.difference(checkInTime!).inMinutes / 60;
    }
    return 0;
  }
}
