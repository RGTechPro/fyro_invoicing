import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/employee.dart';
import '../models/attendance.dart';
import '../models/leave.dart';
import '../models/wastage.dart';
import '../models/expense.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Retry helper for Firestore operations to handle intermittent errors
  Future<T> _retryOperation<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    int attempts = 0;
    Duration currentDelay = delay;

    while (attempts < maxAttempts) {
      try {
        attempts++;
        return await operation();
      } catch (e) {
        print('⚠️ Firestore operation attempt $attempts failed: $e');

        if (attempts >= maxAttempts) {
          print('❌ Max retry attempts reached for Firestore operation');
          rethrow;
        }

        // Check if it's a Firestore internal error
        if (e.toString().contains('INTERNAL ASSERTION FAILED') ||
            e.toString().contains('FIRESTORE') ||
            e.toString().contains('network')) {
          print(
              '🔄 Retrying Firestore operation in ${currentDelay.inMilliseconds}ms...');
          await Future.delayed(currentDelay);
          currentDelay *= 2; // Exponential backoff
        } else {
          // If it's not a retriable error, don't retry
          rethrow;
        }
      }
    }

    throw Exception('Firestore operation failed after $maxAttempts attempts');
  }

  // ============ EMPLOYEE OPERATIONS ============

  // Get all employees
  Stream<List<Employee>> getEmployees() {
    return _firestore.collection('employees').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Employee.fromMap(doc.data())).toList());
  }

  // Get employee by ID
  Future<Employee?> getEmployee(String id) async {
    return await _retryOperation(() async {
      final doc = await _firestore.collection('employees').doc(id).get();
      if (!doc.exists) return null;
      return Employee.fromMap(doc.data()!);
    });
  }

  // Update employee
  Future<void> updateEmployee(Employee employee) async {
    await _firestore
        .collection('employees')
        .doc(employee.id)
        .update(employee.toMap());
  }

  // Delete employee (soft delete)
  Future<void> deleteEmployee(String id) async {
    await _firestore
        .collection('employees')
        .doc(id)
        .update({'isActive': false});
  }

  // Update employee salary
  Future<void> updateEmployeeSalary(String id, double newSalary) async {
    await _firestore
        .collection('employees')
        .doc(id)
        .update({'salary': newSalary});
  }

  // Update total leaves per month
  Future<void> updateTotalLeaves(String id, int totalLeaves) async {
    await _firestore
        .collection('employees')
        .doc(id)
        .update({'totalLeavesPerMonth': totalLeaves});
  }

  // Reset monthly leaves (call this at the start of each month)
  Future<void> resetMonthlyLeaves() async {
    final employees = await _firestore.collection('employees').get();
    final batch = _firestore.batch();

    for (var doc in employees.docs) {
      batch.update(doc.reference, {'usedLeaves': 0});
    }

    await batch.commit();
  }

  // ============ ATTENDANCE OPERATIONS ============

  // Mark attendance (check-in)
  Future<Attendance> checkIn(String employeeId) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day);

    // Check if already checked in today
    final existing = await _firestore
        .collection('attendance')
        .where('employeeId', isEqualTo: employeeId)
        .where('date', isEqualTo: date.toIso8601String())
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Already checked in today');
    }

    final attendance = Attendance(
      id: id,
      employeeId: employeeId,
      date: date,
      checkInTime: now,
      status: 'present',
    );

    await _firestore.collection('attendance').doc(id).set(attendance.toMap());

    return attendance;
  }

  // Mark check-out
  Future<Attendance> checkOut(String employeeId) async {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day);

    // Find today's attendance
    final snapshot = await _firestore
        .collection('attendance')
        .where('employeeId', isEqualTo: employeeId)
        .where('date', isEqualTo: date.toIso8601String())
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('No check-in found for today');
    }

    final doc = snapshot.docs.first;
    final attendance = Attendance.fromMap(doc.data());

    if (attendance.checkOutTime != null) {
      throw Exception('Already checked out today');
    }

    final updatedAttendance = attendance.copyWith(
      checkOutTime: now,
      totalHours: now.difference(attendance.checkInTime!).inMinutes / 60,
    );

    await _firestore
        .collection('attendance')
        .doc(attendance.id)
        .update(updatedAttendance.toMap());

    return updatedAttendance;
  }

  // Check out by attendance ID (for incomplete previous day attendance)
  Future<Attendance> checkOutById(String attendanceId) async {
    final now = DateTime.now();

    // Get the attendance record
    final doc = await _firestore.collection('attendance').doc(attendanceId).get();
    
    if (!doc.exists) {
      throw Exception('Attendance record not found');
    }

    final attendance = Attendance.fromMap(doc.data()!);

    if (attendance.checkOutTime != null) {
      throw Exception('Already checked out');
    }

    // Calculate hours, handling midnight crossover
    double hours = now.difference(attendance.checkInTime!).inMinutes / 60;
    if (hours < 0) {
      hours += 24;
    }

    final updatedAttendance = attendance.copyWith(
      checkOutTime: now,
      totalHours: hours,
    );

    await _firestore
        .collection('attendance')
        .doc(attendanceId)
        .update(updatedAttendance.toMap());

    return updatedAttendance;
  }

  // Get incomplete attendance (checked in but not checked out)
  Future<Attendance?> getIncompleteAttendance(String employeeId) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('employeeId', isEqualTo: employeeId)
        .where('checkOutTime', isNull: true)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    
    final attendance = Attendance.fromMap(snapshot.docs.first.data());
    
    // Only return if it's from a previous day (not today)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (attendance.date.isBefore(today)) {
      return attendance;
    }
    
    return null;
  }

  // Admin: Add manual attendance record
  Future<void> addManualAttendance({
    required String employeeId,
    required DateTime date,
    required DateTime checkInTime,
    DateTime? checkOutTime,
  }) async {
    final attendanceId = _uuid.v4();

    // Calculate total hours if check-out time is provided
    double? totalHours;
    if (checkOutTime != null) {
      double hours = checkOutTime.difference(checkInTime).inMinutes / 60;
      // Fix negative hours when shift crosses midnight (e.g., 6pm to 2am)
      if (hours < 0) {
        hours += 24; // Add 24 hours for next day
      }
      totalHours = hours;
    }

    final attendance = Attendance(
      id: attendanceId,
      employeeId: employeeId,
      date: DateTime(date.year, date.month, date.day),
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      totalHours: totalHours ?? 0,
      status: 'present',
    );

    await _firestore
        .collection('attendance')
        .doc(attendanceId)
        .set(attendance.toMap());
  }

  // Update existing attendance record
  Future<void> updateAttendance({
    required String attendanceId,
    required DateTime checkInTime,
    DateTime? checkOutTime,
  }) async {
    // Calculate total hours if check-out time is provided
    double? totalHours;
    if (checkOutTime != null) {
      double hours = checkOutTime.difference(checkInTime).inMinutes / 60;
      // Fix negative hours when shift crosses midnight
      if (hours < 0) {
        hours += 24;
      }
      totalHours = hours;
    }

    final updates = <String, dynamic>{
      'checkInTime': checkInTime.toIso8601String(),
      'totalHours': totalHours ?? 0,
    };

    if (checkOutTime != null) {
      updates['checkOutTime'] = checkOutTime.toIso8601String();
    }

    await _firestore.collection('attendance').doc(attendanceId).update(updates);
  }

  // Get today's attendance for employee
  Future<Attendance?> getTodayAttendance(String employeeId) async {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day);

    final snapshot = await _firestore
        .collection('attendance')
        .where('employeeId', isEqualTo: employeeId)
        .where('date', isEqualTo: date.toIso8601String())
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Attendance.fromMap(snapshot.docs.first.data());
  }

  // Get attendance for employee (date range)
  Stream<List<Attendance>> getEmployeeAttendance(
    String employeeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _firestore
        .collection('attendance')
        .where('employeeId', isEqualTo: employeeId);

    if (startDate != null) {
      query = query.where('date',
          isGreaterThanOrEqualTo: startDate.toIso8601String());
    }

    if (endDate != null) {
      query =
          query.where('date', isLessThanOrEqualTo: endDate.toIso8601String());
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Attendance.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Get all attendance records (for admin)
  Stream<List<Attendance>> getAllAttendance({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _firestore.collection('attendance');

    if (startDate != null) {
      query = query.where('date',
          isGreaterThanOrEqualTo: startDate.toIso8601String());
    }

    if (endDate != null) {
      query =
          query.where('date', isLessThanOrEqualTo: endDate.toIso8601String());
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Attendance.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Get attendance by date range (for reports)
  // Note: Fetches all attendance for employee and filters in memory to avoid composite index requirement
  Future<List<Attendance>> getAttendanceByDateRange(
    String employeeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _retryOperation(() async {
      return await _firestore
          .collection('attendance')
          .where('employeeId', isEqualTo: employeeId)
          .get();
    });

    // Filter in memory to avoid needing composite index
    final startDateStr = startDate.toIso8601String();
    final endDateStr = endDate.toIso8601String();

    return snapshot.docs
        .map((doc) => Attendance.fromMap(doc.data()))
        .where((attendance) {
      final dateStr = attendance.date.toIso8601String();
      return dateStr.compareTo(startDateStr) >= 0 &&
          dateStr.compareTo(endDateStr) <= 0;
    }).toList();
  }

  // Get all attendance records for all employees by date range (for reports)
  // Fetches all attendance and filters in memory to avoid composite index
  Future<List<Attendance>> getAllAttendanceByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _retryOperation(() async {
      return await _firestore.collection('attendance').get();
    });

    // Filter in memory to avoid needing composite index
    final startDateStr = startDate.toIso8601String();
    final endDateStr = endDate.toIso8601String();

    return snapshot.docs
        .map((doc) => Attendance.fromMap(doc.data()))
        .where((attendance) {
      final dateStr = attendance.date.toIso8601String();
      return dateStr.compareTo(startDateStr) >= 0 &&
          dateStr.compareTo(endDateStr) <= 0;
    }).toList();
  }

  // Calculate monthly attendance summary
  Future<Map<String, dynamic>> getMonthlyAttendanceSummary(
    String employeeId,
    int month,
    int year,
  ) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final snapshot = await _firestore
        .collection('attendance')
        .where('employeeId', isEqualTo: employeeId)
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();

    int presentDays = 0;
    int absentDays = 0;
    double totalHours = 0;

    for (var doc in snapshot.docs) {
      final attendance = Attendance.fromMap(doc.data());
      if (attendance.status == 'present') {
        presentDays++;
        totalHours += attendance.totalHours;
      } else if (attendance.status == 'absent') {
        absentDays++;
      }
    }

    return {
      'presentDays': presentDays,
      'absentDays': absentDays,
      'totalHours': totalHours,
      'workingDays': endDate.day,
    };
  }

  // ============ LEAVE OPERATIONS ============

  // Apply for leave
  Future<Leave> applyLeave({
    required String employeeId,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    final id = _uuid.v4();

    final leave = Leave(
      id: id,
      employeeId: employeeId,
      fromDate: fromDate,
      toDate: toDate,
      reason: reason,
      status: 'pending',
      appliedDate: DateTime.now(),
    );

    await _firestore.collection('leaves').doc(id).set(leave.toMap());

    return leave;
  }

  // Get employee leaves
  Stream<List<Leave>> getEmployeeLeaves(String employeeId) {
    return _firestore
        .collection('leaves')
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Leave.fromMap(doc.data())).toList());
  }

  // Get pending leaves (for admin)
  Stream<List<Leave>> getPendingLeaves() {
    return _firestore
        .collection('leaves')
        .where('status', isEqualTo: 'pending')
        .orderBy('appliedDate')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Leave.fromMap(doc.data())).toList());
  }

  // Get all leaves (for admin)
  Stream<List<Leave>> getAllLeaves() {
    return _firestore
        .collection('leaves')
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Leave.fromMap(doc.data())).toList());
  }

  // Approve leave
  Future<void> approveLeave(String leaveId, String approvedBy,
      {String? notes}) async {
    final leave = await _firestore.collection('leaves').doc(leaveId).get();
    final leaveData = Leave.fromMap(leave.data()!);

    // Update leave status
    await _firestore.collection('leaves').doc(leaveId).update({
      'status': 'approved',
      'approvedBy': approvedBy,
      'approvedDate': DateTime.now().toIso8601String(),
      'adminNotes': notes,
    });

    // Update employee's used leaves
    final employee = await getEmployee(leaveData.employeeId);
    if (employee != null) {
      await _firestore.collection('employees').doc(employee.id).update({
        'usedLeaves': employee.usedLeaves + leaveData.numberOfDays,
      });
    }
  }

  // Reject leave
  Future<void> rejectLeave(String leaveId, String rejectedBy,
      {String? notes}) async {
    await _firestore.collection('leaves').doc(leaveId).update({
      'status': 'rejected',
      'approvedBy': rejectedBy,
      'approvedDate': DateTime.now().toIso8601String(),
      'adminNotes': notes,
    });
  }

  // Get monthly leave count
  Future<int> getMonthlyLeaveCount(
      String employeeId, int month, int year) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final snapshot = await _firestore
        .collection('leaves')
        .where('employeeId', isEqualTo: employeeId)
        .where('status', isEqualTo: 'approved')
        .where('fromDate', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('fromDate', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();

    int totalDays = 0;
    for (var doc in snapshot.docs) {
      final leave = Leave.fromMap(doc.data());
      totalDays += leave.numberOfDays;
    }

    return totalDays;
  }

  // ============ WASTAGE OPERATIONS ============

  // Add wastage entry
  Future<void> addWastage({
    required String employeeId,
    required String employeeName,
    required DateTime date,
    required String itemName,
    required double quantity,
    required String unit,
    required String reason,
    String? consumedBy,
    String? consumedByOther,
    String? notes,
    double? estimatedValue,
  }) async {
    final wastageId = _uuid.v4();
    final wastage = Wastage(
      id: wastageId,
      employeeId: employeeId,
      employeeName: employeeName,
      date: date,
      itemName: itemName,
      quantity: quantity,
      unit: unit,
      reason: reason,
      consumedBy: consumedBy,
      consumedByOther: consumedByOther,
      notes: notes,
      estimatedValue: estimatedValue,
    );

    await _firestore.collection('wastages').doc(wastageId).set(wastage.toMap());
  }

  // Get all wastages
  Stream<List<Wastage>> getWastages() {
    return _firestore
        .collection('wastages')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Wastage.fromMap(doc.data())).toList());
  }

  // Get wastages by employee
  Stream<List<Wastage>> getWastagesByEmployee(String employeeId) {
    return _firestore
        .collection('wastages')
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Wastage.fromMap(doc.data())).toList());
  }

  // Get wastages by date range
  Future<List<Wastage>> getWastagesByDateRange(
      DateTime startDate, DateTime endDate) async {
    final snapshot = await _firestore
        .collection('wastages')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => Wastage.fromMap(doc.data())).toList();
  }

  // Delete wastage
  Future<void> deleteWastage(String wastageId) async {
    await _firestore.collection('wastages').doc(wastageId).delete();
  }

  // ============ EXPENSE OPERATIONS ============

  // Add expense entry
  Future<void> addExpense({
    required String employeeId,
    required String employeeName,
    required DateTime date,
    required String category,
    required String itemDescription,
    required double amount,
    String? vendor,
    String? paymentMode,
    String? billNumber,
    String? notes,
  }) async {
    final expenseId = _uuid.v4();
    final expense = Expense(
      id: expenseId,
      employeeId: employeeId,
      employeeName: employeeName,
      date: date,
      category: category,
      itemDescription: itemDescription,
      amount: amount,
      vendor: vendor,
      paymentMode: paymentMode,
      billNumber: billNumber,
      notes: notes,
      isApproved: false,
    );

    await _firestore.collection('expenses').doc(expenseId).set(expense.toMap());
  }

  // Get all expenses
  Stream<List<Expense>> getExpenses() {
    return _firestore
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList());
  }

  // Get expenses by employee
  Stream<List<Expense>> getExpensesByEmployee(String employeeId) {
    return _firestore
        .collection('expenses')
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList());
  }

  // Get pending expenses (for admin approval)
  Stream<List<Expense>> getPendingExpenses() {
    return _firestore
        .collection('expenses')
        .where('isApproved', isEqualTo: false)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList());
  }

  // Approve expense
  Future<void> approveExpense(String expenseId, String adminName) async {
    await _firestore.collection('expenses').doc(expenseId).update({
      'isApproved': true,
      'approvedDate': Timestamp.fromDate(DateTime.now()),
      'approvedBy': adminName,
    });
  }

  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(
      DateTime startDate, DateTime endDate) async {
    final snapshot = await _firestore
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList();
  }

  // Get total expenses for a period
  Future<double> getTotalExpenses(DateTime startDate, DateTime endDate) async {
    final expenses = await getExpensesByDateRange(startDate, endDate);
    double total = 0.0;
    for (var expense in expenses) {
      if (expense.isApproved) {
        total += expense.amount;
      }
    }
    return total;
  }

  // Delete expense
  Future<void> deleteExpense(String expenseId) async {
    await _firestore.collection('expenses').doc(expenseId).delete();
  }
}
