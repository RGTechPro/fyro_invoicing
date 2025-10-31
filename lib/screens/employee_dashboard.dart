import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/employee.dart';
import '../models/attendance.dart';
import '../models/leave.dart';
import '../models/wastage.dart';
import '../models/expense.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'package:intl/intl.dart';

class EmployeeDashboard extends ConsumerStatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  ConsumerState<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends ConsumerState<EmployeeDashboard> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  Employee? _currentEmployee;
  Attendance? _todayAttendance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    try {
      final employee = await _authService.getCurrentEmployee();
      if (employee != null) {
        final attendance =
            await _firestoreService.getTodayAttendance(employee.id);
        setState(() {
          _currentEmployee = employee;
          _todayAttendance = attendance;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCheckIn() async {
    if (_currentEmployee == null) return;

    try {
      final attendance = await _firestoreService.checkIn(_currentEmployee!.id);
      setState(() => _todayAttendance = attendance);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Checked in successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleCheckOut() async {
    if (_currentEmployee == null) return;

    try {
      final attendance = await _firestoreService.checkOut(_currentEmployee!.id);
      setState(() => _todayAttendance = attendance);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Checked out successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _showLeaveApplicationDialog() {
    final fromDateController = TextEditingController();
    final toDateController = TextEditingController();
    final reasonController = TextEditingController();
    DateTime? fromDate;
    DateTime? toDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGrey,
        title: const Text('Apply for Leave',
            style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // From date
              TextFormField(
                controller: fromDateController,
                readOnly: true,
                autofocus: true,
                cursorColor: AppTheme.secondaryGold,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'From Date',
                  labelStyle: TextStyle(color: AppTheme.lightGold),
                  suffixIcon:
                      Icon(Icons.calendar_today, color: AppTheme.lightGold),
                  filled: true,
                  fillColor: AppTheme.primaryBlack,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.mediumGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppTheme.secondaryGold, width: 2),
                  ),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) {
                    fromDate = date;
                    fromDateController.text =
                        DateFormat('dd MMM yyyy').format(date);
                  }
                },
              ),
              const SizedBox(height: 16),

              // To date
              TextFormField(
                controller: toDateController,
                readOnly: true,
                cursorColor: AppTheme.secondaryGold,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'To Date',
                  labelStyle: TextStyle(color: AppTheme.lightGold),
                  suffixIcon:
                      Icon(Icons.calendar_today, color: AppTheme.lightGold),
                  filled: true,
                  fillColor: AppTheme.primaryBlack,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.mediumGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppTheme.secondaryGold, width: 2),
                  ),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: fromDate ?? DateTime.now(),
                    firstDate: fromDate ?? DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) {
                    toDate = date;
                    toDateController.text =
                        DateFormat('dd MMM yyyy').format(date);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Reason
              TextFormField(
                controller: reasonController,
                cursorColor: AppTheme.secondaryGold,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  labelStyle: TextStyle(color: AppTheme.lightGold),
                  filled: true,
                  fillColor: AppTheme.primaryBlack,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.mediumGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppTheme.secondaryGold, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.mediumGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (fromDate == null ||
                  toDate == null ||
                  reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              try {
                await _firestoreService.applyLeave(
                  employeeId: _currentEmployee!.id,
                  fromDate: fromDate!,
                  toDate: toDate!,
                  reason: reasonController.text,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Leave applied successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryGold,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.primaryBlack,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentEmployee == null) {
      return const LoginScreen();
    }

    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.local_fire_department),
            const SizedBox(width: 8),
            Text(isSmallScreen ? 'BBF' : 'BIRYANI BY FLAME'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Card(
              color: AppTheme.darkGrey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: isSmallScreen ? 30 : 40,
                      backgroundColor: AppTheme.secondaryGold,
                      child: Text(
                        _currentEmployee!.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlack,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${_currentEmployee!.name}!',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _currentEmployee!.email,
                            style: const TextStyle(
                              color: AppTheme.lightGold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Salary: ₹${_currentEmployee!.salary.toStringAsFixed(0)}/month',
                            style: const TextStyle(
                              color: AppTheme.secondaryGold,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Attendance card
            Card(
              color: AppTheme.darkGrey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📅 Today\'s Attendance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_todayAttendance == null)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _handleCheckIn,
                          icon: const Icon(Icons.login),
                          label: const Text('CHECK IN'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      )
                    else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Check In',
                                style: TextStyle(color: AppTheme.lightGold),
                              ),
                              Text(
                                DateFormat('hh:mm a')
                                    .format(_todayAttendance!.checkInTime!),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (_todayAttendance!.checkOutTime != null)
                            Column(
                              children: [
                                const Text(
                                  'Check Out',
                                  style: TextStyle(color: AppTheme.lightGold),
                                ),
                                Text(
                                  DateFormat('hh:mm a')
                                      .format(_todayAttendance!.checkOutTime!),
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_todayAttendance!.checkOutTime == null)
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _handleCheckOut,
                            icon: const Icon(Icons.logout),
                            label: const Text('CHECK OUT'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                        )
                      else
                        Center(
                          child: Text(
                            'Total Hours: ${_todayAttendance!.totalHours.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppTheme.secondaryGold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Leave summary card
            Card(
              color: AppTheme.darkGrey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🏖️ Leave Balance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _showLeaveApplicationDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Apply'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryGold,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Total',
                          _currentEmployee!.totalLeavesPerMonth.toString(),
                          Colors.blue,
                        ),
                        _buildStatItem(
                          'Used',
                          _currentEmployee!.usedLeaves.toString(),
                          Colors.red,
                        ),
                        _buildStatItem(
                          'Remaining',
                          _currentEmployee!.remainingLeaves.toString(),
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showAddWastageDialog,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Add Wastage'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showAddExpenseDialog,
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Add Expense'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Leave history
            const Text(
              'Leave History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            StreamBuilder<List<Leave>>(
              stream: _firestoreService.getEmployeeLeaves(_currentEmployee!.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Card(
                    color: AppTheme.darkGrey,
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No leave applications yet',
                          style: TextStyle(color: AppTheme.mediumGrey),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final leave = snapshot.data![index];
                    return Card(
                      color: AppTheme.darkGrey,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          '${DateFormat('dd MMM').format(leave.fromDate)} - ${DateFormat('dd MMM yyyy').format(leave.toDate)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          leave.reason,
                          style: const TextStyle(color: AppTheme.lightGold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Chip(
                          label: Text(
                            leave.status.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: leave.isPending
                              ? Colors.orange
                              : leave.isApproved
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWastageDialog() {
    final itemNameController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController(text: 'kg');
    final consumedByController = TextEditingController();
    final otherPersonController = TextEditingController();
    final notesController = TextEditingController();
    final estimatedValueController = TextEditingController();
    String reason = 'employee_consumed';

    // Get list of all employees for dropdown
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkGrey,
          title: const Text('Add Wastage Entry',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: itemNameController,
                  autofocus: true,
                  cursorColor: AppTheme.secondaryGold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    labelStyle: TextStyle(color: AppTheme.lightGold),
                    filled: true,
                    fillColor: AppTheme.primaryBlack,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.mediumGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppTheme.secondaryGold, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        cursorColor: AppTheme.secondaryGold,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          labelStyle: TextStyle(color: AppTheme.lightGold),
                          filled: true,
                          fillColor: AppTheme.primaryBlack,
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.mediumGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppTheme.secondaryGold, width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        cursorColor: AppTheme.secondaryGold,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          labelStyle: TextStyle(color: AppTheme.lightGold),
                          hintText: 'kg, pcs',
                          hintStyle: TextStyle(color: AppTheme.mediumGrey),
                          filled: true,
                          fillColor: AppTheme.primaryBlack,
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.mediumGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppTheme.secondaryGold, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: reason,
                  dropdownColor: AppTheme.darkGrey,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Reason for Wastage',
                    labelStyle: TextStyle(color: AppTheme.lightGold),
                    filled: true,
                    fillColor: AppTheme.primaryBlack,
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'employee_consumed',
                      child: Text('Consumed by Employee'),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text('Consumed by Other'),
                    ),
                    DropdownMenuItem(
                      value: 'thrown',
                      child: Text('Thrown (Kharab/Spoiled)'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() => reason = value!);
                  },
                ),
                const SizedBox(height: 16),
                if (reason == 'employee_consumed')
                  StreamBuilder<List<Employee>>(
                    stream: _firestoreService.getEmployees(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      return DropdownButtonFormField<String>(
                        dropdownColor: AppTheme.darkGrey,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Employee Who Consumed',
                          labelStyle: TextStyle(color: AppTheme.lightGold),
                          filled: true,
                          fillColor: AppTheme.primaryBlack,
                          border: OutlineInputBorder(),
                        ),
                        items: snapshot.data!
                            .map((emp) => DropdownMenuItem(
                                  value: emp.name,
                                  child: Text(emp.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          consumedByController.text = value ?? '';
                        },
                      );
                    },
                  ),
                if (reason == 'other')
                  TextField(
                    controller: otherPersonController,
                    cursorColor: AppTheme.secondaryGold,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      labelText: 'Person Name',
                      labelStyle: TextStyle(color: AppTheme.lightGold),
                      filled: true,
                      fillColor: AppTheme.primaryBlack,
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.mediumGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppTheme.secondaryGold, width: 2),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: estimatedValueController,
                  keyboardType: TextInputType.number,
                  cursorColor: AppTheme.secondaryGold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'Estimated Value (₹) - Optional',
                    labelStyle: TextStyle(color: AppTheme.lightGold),
                    prefixText: '₹',
                    prefixStyle: TextStyle(color: Colors.white, fontSize: 16),
                    filled: true,
                    fillColor: AppTheme.primaryBlack,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.mediumGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppTheme.secondaryGold, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  cursorColor: AppTheme.secondaryGold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    labelStyle: TextStyle(color: AppTheme.lightGold),
                    filled: true,
                    fillColor: AppTheme.primaryBlack,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.mediumGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppTheme.secondaryGold, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.mediumGrey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (itemNameController.text.isEmpty ||
                    quantityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill required fields')),
                  );
                  return;
                }

                if (reason == 'employee_consumed' &&
                    consumedByController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select employee')),
                  );
                  return;
                }

                if (reason == 'other' && otherPersonController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter person name')),
                  );
                  return;
                }

                try {
                  await _firestoreService.addWastage(
                    employeeId: _currentEmployee!.id,
                    employeeName: _currentEmployee!.name,
                    date: DateTime.now(),
                    itemName: itemNameController.text,
                    quantity: double.parse(quantityController.text),
                    unit: unitController.text,
                    reason: reason,
                    consumedBy: reason == 'employee_consumed'
                        ? consumedByController.text
                        : null,
                    consumedByOther:
                        reason == 'other' ? otherPersonController.text : null,
                    notes: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                    estimatedValue: estimatedValueController.text.isEmpty
                        ? null
                        : double.parse(estimatedValueController.text),
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Wastage entry added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryGold,
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExpenseDialog() {
    final itemDescController = TextEditingController();
    final amountController = TextEditingController();
    final vendorController = TextEditingController();
    final billNumberController = TextEditingController();
    final notesController = TextEditingController();
    String category = 'groceries';
    String paymentMode = 'cash';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkGrey,
          title: const Text('Add Expense Entry',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: AppTheme.darkGrey,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: AppTheme.lightGold),
                    filled: true,
                    fillColor: AppTheme.primaryBlack,
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'groceries', child: Text('Groceries')),
                    DropdownMenuItem(
                        value: 'utilities', child: Text('Utilities')),
                    DropdownMenuItem(
                        value: 'supplies', child: Text('Supplies')),
                    DropdownMenuItem(
                        value: 'transport', child: Text('Transport')),
                    DropdownMenuItem(
                        value: 'maintenance', child: Text('Maintenance')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => category = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: itemDescController,
                  autofocus: true,
                  cursorColor: AppTheme.secondaryGold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'Item Description',
                    labelStyle: TextStyle(color: AppTheme.lightGold),
                    filled: true,
                    fillColor: AppTheme.primaryBlack,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.mediumGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppTheme.secondaryGold, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  cursorColor: AppTheme.secondaryGold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(color: AppTheme.lightGold),
                    prefixText: '₹',
                    prefixStyle: TextStyle(color: Colors.white, fontSize: 16),
                    filled: true,
                    fillColor: AppTheme.primaryBlack,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.mediumGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppTheme.secondaryGold, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: vendorController,
                  cursorColor: AppTheme.secondaryGold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'Vendor/Shop Name (Optional)',
                    labelStyle: TextStyle(color: AppTheme.lightGold),
                    filled: true,
                    fillColor: AppTheme.primaryBlack,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.mediumGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppTheme.secondaryGold, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: paymentMode,
                  dropdownColor: AppTheme.darkGrey,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Payment Mode',
                    labelStyle: TextStyle(color: AppTheme.lightGold),
                    filled: true,
                    fillColor: AppTheme.primaryBlack,
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'card', child: Text('Card')),
                    DropdownMenuItem(value: 'upi', child: Text('UPI')),
                    DropdownMenuItem(
                        value: 'online', child: Text('Online Transfer')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => paymentMode = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: billNumberController,
                  cursorColor: AppTheme.secondaryGold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'Bill/Receipt Number (Optional)',
                    labelStyle: TextStyle(color: AppTheme.lightGold),
                    filled: true,
                    fillColor: AppTheme.primaryBlack,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.mediumGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppTheme.secondaryGold, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  cursorColor: AppTheme.secondaryGold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    labelStyle: TextStyle(color: AppTheme.lightGold),
                    filled: true,
                    fillColor: AppTheme.primaryBlack,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.mediumGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppTheme.secondaryGold, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.mediumGrey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (itemDescController.text.isEmpty ||
                    amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill required fields')),
                  );
                  return;
                }

                try {
                  await _firestoreService.addExpense(
                    employeeId: _currentEmployee!.id,
                    employeeName: _currentEmployee!.name,
                    date: DateTime.now(),
                    category: category,
                    itemDescription: itemDescController.text,
                    amount: double.parse(amountController.text),
                    vendor: vendorController.text.isEmpty
                        ? null
                        : vendorController.text,
                    paymentMode: paymentMode,
                    billNumber: billNumberController.text.isEmpty
                        ? null
                        : billNumberController.text,
                    notes: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            '✓ Expense added successfully! (Pending approval)'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryGold,
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.lightGold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
