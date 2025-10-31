import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/excel_export_service.dart';
import '../models/employee.dart';
import '../models/attendance.dart';
import '../models/leave.dart';
import '../models/wastage.dart';
import '../models/expense.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedIndex = 0;

  // Date selection for attendance
  DateTime _selectedAttendanceDate = DateTime.now();

  final List<String> _tabs = [
    'Overview',
    'Employees',
    'Attendance',
    'Leaves',
    'Salary',
    'Wastage',
    'Expenses',
    'POS',
  ];

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.local_fire_department),
            const SizedBox(width: 8),
            Text(isSmallScreen ? 'Admin' : 'Admin Dashboard'),
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
      body: Row(
        children: [
          // Sidebar
          if (!isSmallScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppTheme.darkGrey,
              selectedIconTheme: const IconThemeData(
                color: AppTheme.secondaryGold,
                size: 28,
              ),
              unselectedIconTheme: const IconThemeData(
                color: AppTheme.mediumGrey,
                size: 24,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: AppTheme.secondaryGold,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: AppTheme.mediumGrey,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('Employees'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.access_time),
                  label: Text('Attendance'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.beach_access),
                  label: Text('Leaves'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.payments),
                  label: Text('Salary'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.delete_outline),
                  label: Text('Wastage'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long),
                  label: Text('Expenses'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.point_of_sale),
                  label: Text('POS'),
                ),
              ],
            ),

          // Main content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: isSmallScreen
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              backgroundColor: AppTheme.darkGrey,
              selectedItemColor: AppTheme.secondaryGold,
              unselectedItemColor: AppTheme.mediumGrey,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Overview',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Staff',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.access_time),
                  label: 'Time',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.beach_access),
                  label: 'Leave',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.payments),
                  label: 'Salary',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.delete_outline),
                  label: 'Wastage',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: 'Expense',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.point_of_sale),
                  label: 'POS',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildEmployeesTab();
      case 2:
        return _buildAttendanceTab();
      case 3:
        return _buildLeavesTab();
      case 4:
        return _buildSalaryTab();
      case 5:
        return _buildWastageTab();
      case 6:
        return _buildExpensesTab();
      case 7:
        return const HomeScreen(); // POS system
      default:
        return _buildOverview();
    }
  }

  Widget _buildOverview() {
    return StreamBuilder<List<Employee>>(
      stream: _firestoreService.getEmployees(),
      builder: (context, employeeSnapshot) {
        if (employeeSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final employees = employeeSnapshot.data ?? [];
        final activeEmployees = employees.where((e) => e.isActive).toList();

        return StreamBuilder<List<Leave>>(
          stream: _firestoreService.getPendingLeaves(),
          builder: (context, leaveSnapshot) {
            final pendingLeaves = leaveSnapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats cards
                  GridView.count(
                    crossAxisCount:
                        MediaQuery.of(context).size.width < 600 ? 2 : 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        'Total Employees',
                        employees.length.toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Active Employees',
                        activeEmployees.length.toString(),
                        Icons.person_add,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Pending Leaves',
                        pendingLeaves.length.toString(),
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Total Salary',
                        '₹${activeEmployees.fold<double>(0, (sum, e) => sum + e.salary).toStringAsFixed(0)}',
                        Icons.payments,
                        AppTheme.secondaryGold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Pending leave approvals
                  if (pendingLeaves.isNotEmpty) ...[
                    const Text(
                      'Pending Leave Approvals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingLeaves.length,
                      itemBuilder: (context, index) {
                        final leave = pendingLeaves[index];
                        final employee = employees.firstWhere(
                          (e) => e.id == leave.employeeId,
                          orElse: () => Employee(
                            id: '',
                            name: 'Unknown',
                            email: '',
                            phone: '',
                            role: 'employee',
                            salary: 0,
                            joiningDate: DateTime.now(),
                          ),
                        );

                        return Card(
                          color: AppTheme.darkGrey,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.secondaryGold,
                              child: Text(
                                employee.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.primaryBlack,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              employee.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${DateFormat('dd MMM').format(leave.fromDate)} - ${DateFormat('dd MMM').format(leave.toDate)} (${leave.numberOfDays} days)\n${leave.reason}',
                              style: const TextStyle(color: AppTheme.lightGold),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () =>
                                      _approveLeave(leave, employees),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () => _rejectLeave(leave),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      color: AppTheme.darkGrey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.lightGold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeesTab() {
    return StreamBuilder<List<Employee>>(
      stream: _firestoreService.getEmployees(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final employees = snapshot.data ?? [];

        return Column(
          children: [
            // Header with add button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Employees',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      // Export button for individual employee
                      if (employees.isNotEmpty)
                        PopupMenuButton<Employee>(
                          icon: const Icon(Icons.file_download,
                              color: AppTheme.secondaryGold),
                          tooltip: 'Export Employee Report',
                          onSelected: (employee) async {
                            try {
                              await ExcelExportService.exportEmployeeReport(
                                employee,
                                _firestoreService,
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Employee report exported successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Export failed: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          itemBuilder: (context) => employees.map((employee) {
                            return PopupMenuItem<Employee>(
                              value: employee,
                              child: Text(employee.name),
                            );
                          }).toList(),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _showAddEmployeeDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Employee'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryGold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Employee list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final employee = employees[index];
                  return Card(
                    color: AppTheme.darkGrey,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: employee.isActive
                            ? AppTheme.secondaryGold
                            : AppTheme.mediumGrey,
                        child: Text(
                          employee.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryBlack,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        employee.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${employee.email}\n₹${employee.salary.toStringAsFixed(0)}/month | ${employee.role}',
                        style: const TextStyle(color: AppTheme.lightGold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit,
                            color: AppTheme.secondaryGold),
                        onPressed: () => _showEditEmployeeDialog(employee),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttendanceTab() {
    final selectedDate = DateTime(
      _selectedAttendanceDate.year,
      _selectedAttendanceDate.month,
      _selectedAttendanceDate.day,
    );

    return StreamBuilder<List<Attendance>>(
      stream: _firestoreService.getAllAttendance(
        startDate: selectedDate,
        endDate: selectedDate,
      ),
      builder: (context, attendanceSnapshot) {
        if (attendanceSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<List<Employee>>(
          stream: _firestoreService.getEmployees(),
          builder: (context, employeeSnapshot) {
            if (employeeSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final employees = employeeSnapshot.data ?? [];
            final attendance = attendanceSnapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date selector header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Attendance - ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Date navigation buttons
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedAttendanceDate = _selectedAttendanceDate
                                .subtract(const Duration(days: 1));
                          });
                        },
                        icon:
                            const Icon(Icons.chevron_left, color: Colors.white),
                        tooltip: 'Previous Day',
                      ),

                      // Calendar picker button
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedAttendanceDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: ColorScheme.dark(
                                    primary: AppTheme.secondaryGold,
                                    onPrimary: Colors.black,
                                    surface: AppTheme.darkGrey,
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null) {
                            setState(() {
                              _selectedAttendanceDate = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Select Date'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryGold,
                          foregroundColor: Colors.black,
                        ),
                      ),

                      IconButton(
                        onPressed: _selectedAttendanceDate.isBefore(
                                DateTime.now()
                                    .subtract(const Duration(days: 1)))
                            ? () {
                                setState(() {
                                  _selectedAttendanceDate =
                                      _selectedAttendanceDate
                                          .add(const Duration(days: 1));
                                });
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right,
                            color: Colors.white),
                        tooltip: 'Next Day',
                      ),

                      // Today button
                      if (!_isSameDay(_selectedAttendanceDate, DateTime.now()))
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedAttendanceDate = DateTime.now();
                            });
                          },
                          child: Text(
                            'TODAY',
                            style: TextStyle(color: AppTheme.secondaryGold),
                          ),
                        ),
                    ],
                  ),

                  // Export button row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showAttendanceExportDialog(),
                          icon: const Icon(Icons.download),
                          label: const Text('Export Report'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryGold,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Summary
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Present',
                          attendance
                              .where((a) => a.checkInTime != null)
                              .length
                              .toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Absent',
                          (employees.length - attendance.length).toString(),
                          Icons.cancel,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Attendance list
                  const Text(
                    'Attendance Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final employee = employees[index];
                      final empAttendance = attendance.firstWhere(
                        (a) => a.employeeId == employee.id,
                        orElse: () => Attendance(
                          id: '',
                          employeeId: employee.id,
                          date: selectedDate,
                          status: 'absent',
                        ),
                      );

                      return Card(
                        color: AppTheme.darkGrey,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: empAttendance.status == 'present'
                                ? Colors.green
                                : Colors.red,
                            child: Icon(
                              empAttendance.status == 'present'
                                  ? Icons.check
                                  : Icons.close,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            employee.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            empAttendance.checkInTime != null
                                ? 'In: ${DateFormat('hh:mm a').format(empAttendance.checkInTime!)}${empAttendance.checkOutTime != null ? ' | Out: ${DateFormat('hh:mm a').format(empAttendance.checkOutTime!)}' : ''}'
                                : 'Absent',
                            style: const TextStyle(color: AppTheme.lightGold),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (empAttendance.checkOutTime != null)
                                Text(
                                  '${empAttendance.totalHours.toStringAsFixed(1)}h',
                                  style: const TextStyle(
                                    color: AppTheme.secondaryGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.calendar_month,
                                color: AppTheme.secondaryGold,
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: () => _showEmployeeMonthlyAttendance(employee),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLeavesTab() {
    return StreamBuilder<List<Leave>>(
      stream: _firestoreService.getAllLeaves(),
      builder: (context, leaveSnapshot) {
        if (leaveSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<List<Employee>>(
          stream: _firestoreService.getEmployees(),
          builder: (context, employeeSnapshot) {
            if (employeeSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final employees = employeeSnapshot.data ?? [];
            final leaves = leaveSnapshot.data ?? [];
            final pendingLeaves = leaves.where((l) => l.isPending).toList();
            final approvedLeaves = leaves.where((l) => l.isApproved).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Leave Management',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showGenericExportDialog(
                          'Export Leaves Report',
                          (start, end) => ExcelExportService.exportLeavesReport(
                              start, end, _firestoreService),
                        ),
                        icon: const Icon(Icons.download),
                        label: const Text('Export'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryGold,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pending leaves
                  const Text(
                    'Pending Approvals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (pendingLeaves.isEmpty)
                    const Card(
                      color: AppTheme.darkGrey,
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No pending leave requests',
                            style: TextStyle(color: AppTheme.mediumGrey),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingLeaves.length,
                      itemBuilder: (context, index) {
                        final leave = pendingLeaves[index];
                        final employee = employees.firstWhere(
                          (e) => e.id == leave.employeeId,
                          orElse: () => Employee(
                            id: '',
                            name: 'Unknown',
                            email: '',
                            phone: '',
                            role: 'employee',
                            salary: 0,
                            joiningDate: DateTime.now(),
                          ),
                        );

                        return Card(
                          color: AppTheme.darkGrey,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppTheme.secondaryGold,
                                      child: Text(
                                        employee.name[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: AppTheme.primaryBlack,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            employee.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            'Remaining: ${employee.remainingLeaves}/${employee.totalLeavesPerMonth} leaves',
                                            style: const TextStyle(
                                              color: AppTheme.lightGold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${DateFormat('dd MMM yyyy').format(leave.fromDate)} - ${DateFormat('dd MMM yyyy').format(leave.toDate)}',
                                  style: const TextStyle(
                                    color: AppTheme.secondaryGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Duration: ${leave.numberOfDays} days',
                                  style: const TextStyle(
                                      color: AppTheme.lightGold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Reason: ${leave.reason}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _rejectLeave(leave),
                                      icon: const Icon(Icons.close,
                                          color: Colors.red),
                                      label: const Text(
                                        'Reject',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _approveLeave(leave, employees),
                                      icon: const Icon(Icons.check),
                                      label: const Text('Approve'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSalaryTab() {
    return StreamBuilder<List<Employee>>(
      stream: _firestoreService.getEmployees(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final employees = snapshot.data ?? [];
        final activeEmployees = employees.where((e) => e.isActive).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Salary Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showGenericExportDialog(
                      'Export Salary Report',
                      (start, end) => ExcelExportService.exportSalaryReport(
                          start, end, _firestoreService),
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryGold,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total salary card
              Card(
                color: AppTheme.darkGrey,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'Total Monthly Salary',
                        style: TextStyle(
                          color: AppTheme.lightGold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${activeEmployees.fold<double>(0, (sum, e) => sum + e.salary).toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppTheme.secondaryGold,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Employee salary list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeEmployees.length,
                itemBuilder: (context, index) {
                  final employee = activeEmployees[index];

                  return Card(
                    color: AppTheme.darkGrey,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.secondaryGold,
                        child: Text(
                          employee.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryBlack,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        employee.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Joined: ${DateFormat('dd MMM yyyy').format(employee.joiningDate)}',
                        style: const TextStyle(color: AppTheme.lightGold),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${employee.salary.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppTheme.secondaryGold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${employee.usedLeaves}/${employee.totalLeavesPerMonth} leaves',
                            style: const TextStyle(
                              color: AppTheme.lightGold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _showEditSalaryDialog(employee),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper methods
  Future<void> _approveLeave(Leave leave, List<Employee> employees) async {
    final employee = employees.firstWhere((e) => e.id == leave.employeeId);

    // Check if employee has enough leaves
    if (employee.remainingLeaves < leave.numberOfDays) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot approve: ${employee.name} has only ${employee.remainingLeaves} leaves remaining',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final currentUser = await _authService.getCurrentEmployee();
      await _firestoreService.approveLeave(leave.id, currentUser!.name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Leave approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectLeave(Leave leave) async {
    try {
      final currentUser = await _authService.getCurrentEmployee();
      await _firestoreService.rejectLeave(leave.id, currentUser!.name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddEmployeeDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final salaryController = TextEditingController();
    String role = 'employee';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGrey,
        title: const Text('Add New Employee',
            style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                cursorColor: AppTheme.secondaryGold,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Name',
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
                controller: emailController,
                cursorColor: AppTheme.secondaryGold,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Email',
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
                controller: phoneController,
                cursorColor: AppTheme.secondaryGold,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Phone',
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
                controller: passwordController,
                obscureText: true,
                cursorColor: AppTheme.secondaryGold,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Password',
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
                controller: salaryController,
                keyboardType: TextInputType.number,
                cursorColor: AppTheme.secondaryGold,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Salary (monthly)',
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
              DropdownButtonFormField<String>(
                value: role,
                dropdownColor: AppTheme.darkGrey,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(color: AppTheme.lightGold),
                ),
                items: const [
                  DropdownMenuItem(value: 'employee', child: Text('Employee')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) => role = value!,
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
              try {
                await _authService.createEmployee(
                  name: nameController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                  password: passwordController.text,
                  salary: double.parse(salaryController.text),
                  role: role,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Employee added successfully'),
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
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditEmployeeDialog(Employee employee) {
    final salaryController = TextEditingController(
      text: employee.salary.toString(),
    );
    final leavesController = TextEditingController(
      text: employee.totalLeavesPerMonth.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGrey,
        title: Text(
          'Edit ${employee.name}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: salaryController,
              autofocus: true,
              keyboardType: TextInputType.number,
              cursorColor: AppTheme.secondaryGold,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Monthly Salary',
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
              controller: leavesController,
              keyboardType: TextInputType.number,
              cursorColor: AppTheme.secondaryGold,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Total Leaves per Month',
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.mediumGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestoreService.updateEmployeeSalary(
                  employee.id,
                  double.parse(salaryController.text),
                );
                await _firestoreService.updateTotalLeaves(
                  employee.id,
                  int.parse(leavesController.text),
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Updated successfully'),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditSalaryDialog(Employee employee) {
    _showEditEmployeeDialog(employee);
  }

  // ============ WASTAGE TAB ============
  Widget _buildWastageTab() {
    return StreamBuilder<List<Wastage>>(
      stream: _firestoreService.getWastages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final wastages = snapshot.data ?? [];

        if (wastages.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline,
                    size: 64, color: AppTheme.mediumGrey),
                SizedBox(height: 16),
                Text(
                  'No wastage entries yet',
                  style: TextStyle(
                    color: AppTheme.lightGold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

        // Calculate total wastage value
        double totalValue = 0;
        for (var w in wastages) {
          if (w.estimatedValue != null) {
            totalValue += w.estimatedValue!;
          }
        }

        // Group by reason
        final employeeConsumed =
            wastages.where((w) => w.isEmployeeConsumed).length;
        final otherConsumed = wastages.where((w) => w.isOtherConsumed).length;
        final thrown = wastages.where((w) => w.isThrown).length;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with export button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Wastage Tracking',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showGenericExportDialog(
                      'Export Wastage Report',
                      (start, end) => ExcelExportService.exportWastageReport(
                          start, end, _firestoreService),
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryGold,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: AppTheme.darkGrey,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Total Entries',
                              style: TextStyle(
                                color: AppTheme.lightGold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${wastages.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      color: AppTheme.darkGrey,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Estimated Value',
                              style: TextStyle(
                                color: AppTheme.lightGold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${totalValue.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppTheme.secondaryGold,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.green.shade900,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            const Text(
                              'Employee',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              '$employeeConsumed',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      color: Colors.blue.shade900,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            const Text(
                              'Other',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              '$otherConsumed',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      color: Colors.red.shade900,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            const Text(
                              'Thrown',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              '$thrown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Wastage Entries',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: wastages.length,
                  itemBuilder: (context, index) {
                    final wastage = wastages[index];
                    return Card(
                      color: AppTheme.darkGrey,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: wastage.isEmployeeConsumed
                              ? Colors.green
                              : wastage.isOtherConsumed
                                  ? Colors.blue
                                  : Colors.red,
                          child: Icon(
                            wastage.isEmployeeConsumed
                                ? Icons.person
                                : wastage.isOtherConsumed
                                    ? Icons.people
                                    : Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          wastage.itemName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${wastage.quantity} ${wastage.unit} • ${wastage.displayReason}',
                              style: const TextStyle(color: AppTheme.lightGold),
                            ),
                            Text(
                              'Logged by: ${wastage.employeeName} • ${DateFormat('dd MMM yyyy, hh:mm a').format(wastage.date)}',
                              style: const TextStyle(
                                color: AppTheme.mediumGrey,
                                fontSize: 12,
                              ),
                            ),
                            if (wastage.notes != null)
                              Text(
                                'Note: ${wastage.notes}',
                                style: const TextStyle(
                                  color: AppTheme.lightGold,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (wastage.estimatedValue != null)
                              Text(
                                '₹${wastage.estimatedValue!.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: AppTheme.secondaryGold,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteWastage(wastage.id),
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteWastage(String wastageId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGrey,
        title: const Text('Delete Wastage Entry?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this wastage entry?',
          style: TextStyle(color: AppTheme.lightGold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.mediumGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestoreService.deleteWastage(wastageId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Wastage entry deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  // ============ EXPENSES TAB ============
  Widget _buildExpensesTab() {
    return StreamBuilder<List<Expense>>(
      stream: _firestoreService.getExpenses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final expenses = snapshot.data ?? [];

        if (expenses.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: AppTheme.mediumGrey),
                SizedBox(height: 16),
                Text(
                  'No expense entries yet',
                  style: TextStyle(
                    color: AppTheme.lightGold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

        // Calculate totals
        final pendingExpenses = expenses.where((e) => e.isPending).toList();
        final approvedExpenses = expenses.where((e) => e.isApproved).toList();

        double totalPending = 0;
        for (var e in pendingExpenses) {
          totalPending += e.amount;
        }

        double totalApproved = 0;
        for (var e in approvedExpenses) {
          totalApproved += e.amount;
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with export button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Expense Tracking',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showGenericExportDialog(
                      'Export Expenses Report',
                      (start, end) => ExcelExportService.exportExpensesReport(
                          start, end, _firestoreService),
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryGold,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: AppTheme.darkGrey,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Total Entries',
                              style: TextStyle(
                                color: AppTheme.lightGold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${expenses.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      color: Colors.green.shade900,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Approved',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${totalApproved.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      color: Colors.orange.shade900,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Pending',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${totalPending.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Expense Entries',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Card(
                      color: AppTheme.darkGrey,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              expense.isApproved ? Colors.green : Colors.orange,
                          child: Icon(
                            expense.isApproved
                                ? Icons.check_circle
                                : Icons.pending,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          expense.itemDescription,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${expense.category.toUpperCase()} • ${expense.paymentMode?.toUpperCase() ?? "N/A"}',
                              style: const TextStyle(color: AppTheme.lightGold),
                            ),
                            if (expense.vendor != null)
                              Text(
                                'Vendor: ${expense.vendor}',
                                style: const TextStyle(
                                  color: AppTheme.mediumGrey,
                                  fontSize: 12,
                                ),
                              ),
                            Text(
                              'By: ${expense.employeeName} • ${DateFormat('dd MMM yyyy').format(expense.date)}',
                              style: const TextStyle(
                                color: AppTheme.mediumGrey,
                                fontSize: 12,
                              ),
                            ),
                            if (expense.isApproved &&
                                expense.approvedBy != null)
                              Text(
                                'Approved by: ${expense.approvedBy}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${expense.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: AppTheme.secondaryGold,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    expense.statusText,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: expense.isApproved
                                      ? Colors.green
                                      : Colors.orange,
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            if (expense.isPending)
                              PopupMenuButton(
                                icon: const Icon(Icons.more_vert,
                                    color: Colors.white),
                                color: AppTheme.darkGrey,
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.check, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text('Approve',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    onTap: () => _approveExpense(expense),
                                  ),
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    onTap: () => _deleteExpense(expense.id),
                                  ),
                                ],
                              )
                            else
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteExpense(expense.id),
                                iconSize: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _approveExpense(Expense expense) async {
    try {
      final currentUser = await _authService.getCurrentEmployee();
      await _firestoreService.approveExpense(
        expense.id,
        currentUser?.name ?? 'Admin',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Expense approved'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteExpense(String expenseId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGrey,
        title: const Text('Delete Expense Entry?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this expense entry?',
          style: TextStyle(color: AppTheme.lightGold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.mediumGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestoreService.deleteExpense(expenseId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Expense entry deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  // Export dialog methods
  Future<void> _showAttendanceExportDialog() async {
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGrey,
        title: const Text('Export Attendance Report',
            style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  startDate == null
                      ? 'Start Date'
                      : DateFormat('dd MMM yyyy').format(startDate!),
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.calendar_today,
                    color: AppTheme.secondaryGold),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate ??
                        DateTime.now().subtract(const Duration(days: 30)),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => startDate = picked);
                  }
                },
              ),
              ListTile(
                title: Text(
                  endDate == null
                      ? 'End Date'
                      : DateFormat('dd MMM yyyy').format(endDate!),
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.calendar_today,
                    color: AppTheme.secondaryGold),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: endDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => endDate = picked);
                  }
                },
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
              if (startDate != null && endDate != null) {
                Navigator.pop(context);
                try {
                  await ExcelExportService.exportAttendanceReport(
                    startDate!,
                    endDate!,
                    _firestoreService,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Attendance report exported successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Export failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryGold),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Future<void> _showGenericExportDialog(String title,
      Future<void> Function(DateTime, DateTime) exportFunction) async {
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGrey,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  startDate == null
                      ? 'Start Date'
                      : DateFormat('dd MMM yyyy').format(startDate!),
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.calendar_today,
                    color: AppTheme.secondaryGold),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate ??
                        DateTime.now().subtract(const Duration(days: 30)),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => startDate = picked);
                  }
                },
              ),
              ListTile(
                title: Text(
                  endDate == null
                      ? 'End Date'
                      : DateFormat('dd MMM yyyy').format(endDate!),
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.calendar_today,
                    color: AppTheme.secondaryGold),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: endDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => endDate = picked);
                  }
                },
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
              if (startDate != null && endDate != null) {
                Navigator.pop(context);
                try {
                  await exportFunction(startDate!, endDate!);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report exported successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Export failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryGold),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  // Show employee monthly attendance
  Future<void> _showEmployeeMonthlyAttendance(Employee employee) async {
    DateTime selectedMonth = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.darkGrey,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    '${employee.name} - Attendance',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            content: SizedBox(
              width: 600,
              height: 500,
              child: Column(
                children: [
                  // Month selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            selectedMonth = DateTime(
                              selectedMonth.year,
                              selectedMonth.month - 1,
                            );
                          });
                        },
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(selectedMonth),
                        style: const TextStyle(
                          color: AppTheme.secondaryGold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right,
                            color: Colors.white),
                        onPressed: selectedMonth.month < DateTime.now().month ||
                                selectedMonth.year < DateTime.now().year
                            ? () {
                                setState(() {
                                  selectedMonth = DateTime(
                                    selectedMonth.year,
                                    selectedMonth.month + 1,
                                  );
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Attendance list
                  Expanded(
                    child: FutureBuilder<List<Attendance>>(
                      future: _firestoreService.getAttendanceByDateRange(
                        employee.id,
                        DateTime(selectedMonth.year, selectedMonth.month, 1),
                        DateTime(
                            selectedMonth.year, selectedMonth.month + 1, 0),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        final attendances = snapshot.data ?? [];

                        if (attendances.isEmpty) {
                          return const Center(
                            child: Text(
                              'No attendance records for this month',
                              style: TextStyle(color: AppTheme.lightGold),
                            ),
                          );
                        }

                        // Calculate summary
                        final presentDays =
                            attendances.where((a) => a.isCheckedIn).length;
                        final totalHours = attendances.fold<double>(
                          0,
                          (sum, a) => sum + a.totalHours,
                        );

                        return Column(
                          children: [
                            // Summary cards
                            Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    color: AppTheme.primaryBlack,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          const Text(
                                            'Days Present',
                                            style: TextStyle(
                                              color: AppTheme.lightGold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$presentDays',
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Card(
                                    color: AppTheme.primaryBlack,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          const Text(
                                            'Total Hours',
                                            style: TextStyle(
                                              color: AppTheme.lightGold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            totalHours.toStringAsFixed(1),
                                            style: const TextStyle(
                                              color: AppTheme.secondaryGold,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Attendance list
                            Expanded(
                              child: ListView.builder(
                                itemCount: attendances.length,
                                itemBuilder: (context, index) {
                                  final attendance = attendances[index];
                                  return Card(
                                    color: AppTheme.primaryBlack,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: attendance.isCheckedIn
                                            ? Colors.green
                                            : Colors.red,
                                        child: Text(
                                          '${attendance.date.day}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        DateFormat('EEEE, dd MMM')
                                            .format(attendance.date),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        attendance.checkInTime != null
                                            ? 'In: ${DateFormat('hh:mm a').format(attendance.checkInTime!)}${attendance.checkOutTime != null ? ' | Out: ${DateFormat('hh:mm a').format(attendance.checkOutTime!)}' : ' | Still working'}'
                                            : 'Absent',
                                        style: const TextStyle(
                                            color: AppTheme.lightGold),
                                      ),
                                      trailing: attendance.checkOutTime != null
                                          ? Text(
                                              '${attendance.totalHours.toStringAsFixed(1)}h',
                                              style: const TextStyle(
                                                color: AppTheme.secondaryGold,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            )
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await ExcelExportService.exportEmployeeReport(
                      employee,
                      _firestoreService,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Employee report exported successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Export failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text('Export Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryGold,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
