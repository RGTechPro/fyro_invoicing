import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/employee.dart';
import '../models/attendance.dart';
import '../models/leave.dart';
import '../models/wastage.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';
import 'file_saver.dart' as file_saver;

enum ExportPeriod { daily, weekly, monthly, custom }

class ExcelExportService {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Export orders to Excel with comprehensive analytics
  static Future<void> exportOrders({
    required List<Order> orders,
    required ExportPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (orders.isEmpty) {
      return;
    }

    final excel = Excel.createExcel();

    // Remove default sheet
    excel.delete('Sheet1');

    // Add sheets
    _addSummarySheet(excel, orders, period, startDate, endDate);
    _addOrdersSheet(excel, orders);
    _addItemAnalysisSheet(excel, orders);
    _addCategoryAnalysisSheet(excel, orders);
    _addDailyBreakdownSheet(excel, orders);

    // Generate filename
    final filename = _generateFilename(period, startDate, endDate);

    // Save and download
    final bytes = excel.encode();
    if (bytes != null) {
      _downloadFile(bytes, filename);
    }
  }

  /// Summary Sheet - Overall statistics
  static void _addSummarySheet(
    Excel excel,
    List<Order> orders,
    ExportPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final sheet = excel['Summary'];

    // Title
    _setCellValue(sheet, 'A1', 'BIRYANI BY FLAME - SALES REPORT');
    _mergeCells(sheet, 'A1:D1');
    _styleHeader(sheet, 'A1');

    int row = 3;

    // Period Information
    _setCellValue(sheet, 'A$row', 'Report Period:');
    _setCellValue(sheet, 'B$row', _getPeriodLabel(period, startDate, endDate));
    _styleBold(sheet, 'A$row');
    row += 2;

    // Key Metrics
    final totalOrders = orders.length;
    final completedOrders =
        orders.where((o) => o.status == OrderStatus.completed).length;
    final totalRevenue =
        orders.fold<double>(0, (sum, o) => sum + o.totalAmount);
    final totalBaseRevenue =
        orders.fold<double>(0, (sum, o) => sum + o.totalBaseAmount);
    final totalGST = orders.fold<double>(0, (sum, o) => sum + o.totalGst);
    final totalItems = orders.fold<int>(0, (sum, o) => sum + o.totalItems);
    final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

    _setCellValue(sheet, 'A$row', 'KEY METRICS');
    _styleBold(sheet, 'A$row');
    row++;

    _setCellValue(sheet, 'A$row', 'Total Orders:');
    _setCellValue(sheet, 'B$row', totalOrders);
    row++;

    _setCellValue(sheet, 'A$row', 'Completed Orders:');
    _setCellValue(sheet, 'B$row', completedOrders);
    row++;

    _setCellValue(sheet, 'A$row', 'Total Items Sold:');
    _setCellValue(sheet, 'B$row', totalItems);
    row++;

    _setCellValue(sheet, 'A$row', 'Total Revenue (Inc. GST):');
    _setCellValue(sheet, 'B$row', '₹${totalRevenue.toStringAsFixed(2)}');
    row++;

    _setCellValue(sheet, 'A$row', 'Base Revenue (Exc. GST):');
    _setCellValue(sheet, 'B$row', '₹${totalBaseRevenue.toStringAsFixed(2)}');
    row++;

    _setCellValue(sheet, 'A$row', 'Total GST Collected:');
    _setCellValue(sheet, 'B$row', '₹${totalGST.toStringAsFixed(2)}');
    row++;

    _setCellValue(sheet, 'A$row', 'Average Order Value:');
    _setCellValue(sheet, 'B$row', '₹${avgOrderValue.toStringAsFixed(2)}');
    row += 2;

    // Top selling items
    final itemSales = _calculateItemSales(orders);
    final topItems = itemSales.entries.toList()
      ..sort((a, b) => b.value['quantity'].compareTo(a.value['quantity']));

    _setCellValue(sheet, 'A$row', 'TOP 5 SELLING ITEMS');
    _styleBold(sheet, 'A$row');
    row++;

    _setCellValue(sheet, 'A$row', 'Item');
    _setCellValue(sheet, 'B$row', 'Quantity');
    _setCellValue(sheet, 'C$row', 'Revenue');
    _styleBold(sheet, 'A$row');
    _styleBold(sheet, 'B$row');
    _styleBold(sheet, 'C$row');
    row++;

    for (var i = 0; i < (topItems.length < 5 ? topItems.length : 5); i++) {
      final item = topItems[i];
      _setCellValue(sheet, 'A$row', item.key);
      _setCellValue(sheet, 'B$row', item.value['quantity']);
      _setCellValue(
          sheet, 'C$row', '₹${item.value['revenue'].toStringAsFixed(2)}');
      row++;
    }
  }

  /// Orders Sheet - Detailed order list
  static void _addOrdersSheet(Excel excel, List<Order> orders) {
    final sheet = excel['Orders'];

    // Headers
    final headers = [
      'Order ID',
      'Date & Time',
      'Customer Name',
      'Status',
      'Items Count',
      'Base Amount',
      'GST Amount',
      'Total Amount',
      'Notes'
    ];

    for (var i = 0; i < headers.length; i++) {
      _setCellValue(sheet, '${_getColumnLetter(i)}1', headers[i]);
      _styleBold(sheet, '${_getColumnLetter(i)}1');
    }

    // Data rows
    int row = 2;
    for (final order in orders) {
      _setCellValue(sheet, 'A$row', order.orderId);
      _setCellValue(sheet, 'B$row', _dateTimeFormat.format(order.createdAt));
      _setCellValue(sheet, 'C$row', order.customerName ?? 'Walk-in');
      _setCellValue(sheet, 'D$row', order.getStatusDisplay());
      _setCellValue(sheet, 'E$row', order.totalItems);
      _setCellValue(sheet, 'F$row', order.totalBaseAmount.toStringAsFixed(2));
      _setCellValue(sheet, 'G$row', order.totalGst.toStringAsFixed(2));
      _setCellValue(sheet, 'H$row', order.totalAmount.toStringAsFixed(2));
      _setCellValue(sheet, 'I$row', order.notes ?? '');
      row++;
    }
  }

  /// Item Analysis Sheet - Item-wise breakdown
  static void _addItemAnalysisSheet(Excel excel, List<Order> orders) {
    final sheet = excel['Item Analysis'];

    // Headers
    _setCellValue(sheet, 'A1', 'Item Name');
    _setCellValue(sheet, 'B1', 'Serving Size');
    _setCellValue(sheet, 'C1', 'Quantity Sold');
    _setCellValue(sheet, 'D1', 'Unit Price');
    _setCellValue(sheet, 'E1', 'Total Revenue');
    _setCellValue(sheet, 'F1', 'Base Revenue');
    _setCellValue(sheet, 'G1', 'GST Amount');

    for (var col in ['A', 'B', 'C', 'D', 'E', 'F', 'G']) {
      _styleBold(sheet, '${col}1');
    }

    // Calculate item sales
    final itemSales = <String, Map<String, dynamic>>{};

    for (final order in orders) {
      for (final item in order.items) {
        final key = '${item.menuItemName}|${item.servingSize}';
        if (!itemSales.containsKey(key)) {
          itemSales[key] = {
            'name': item.menuItemName,
            'servingSize': item.servingSize,
            'quantity': 0,
            'unitPrice': item.pricePerItem,
            'totalRevenue': 0.0,
            'baseRevenue': 0.0,
            'gst': 0.0,
          };
        }

        itemSales[key]!['quantity'] += item.quantity;
        itemSales[key]!['totalRevenue'] += item.totalPrice;
        itemSales[key]!['baseRevenue'] += item.totalBasePrice;
        itemSales[key]!['gst'] += item.totalGst;
      }
    }

    // Sort by quantity
    final sortedItems = itemSales.values.toList()
      ..sort((a, b) => b['quantity'].compareTo(a['quantity']));

    // Add data
    int row = 2;
    for (final item in sortedItems) {
      _setCellValue(sheet, 'A$row', item['name']);
      _setCellValue(sheet, 'B$row', item['servingSize']);
      _setCellValue(sheet, 'C$row', item['quantity']);
      _setCellValue(sheet, 'D$row', '₹${item['unitPrice'].toStringAsFixed(2)}');
      _setCellValue(
          sheet, 'E$row', '₹${item['totalRevenue'].toStringAsFixed(2)}');
      _setCellValue(
          sheet, 'F$row', '₹${item['baseRevenue'].toStringAsFixed(2)}');
      _setCellValue(sheet, 'G$row', '₹${item['gst'].toStringAsFixed(2)}');
      row++;
    }

    // Add totals
    row++;
    _setCellValue(sheet, 'A$row', 'TOTAL');
    _styleBold(sheet, 'A$row');
    final totalQty =
        sortedItems.fold<int>(0, (sum, item) => sum + item['quantity'] as int);
    final totalRev =
        sortedItems.fold<double>(0, (sum, item) => sum + item['totalRevenue']);
    final totalBase =
        sortedItems.fold<double>(0, (sum, item) => sum + item['baseRevenue']);
    final totalGst =
        sortedItems.fold<double>(0, (sum, item) => sum + item['gst']);

    _setCellValue(sheet, 'C$row', totalQty);
    _setCellValue(sheet, 'E$row', '₹${totalRev.toStringAsFixed(2)}');
    _setCellValue(sheet, 'F$row', '₹${totalBase.toStringAsFixed(2)}');
    _setCellValue(sheet, 'G$row', '₹${totalGst.toStringAsFixed(2)}');
  }

  /// Category Analysis Sheet - Category-wise breakdown
  static void _addCategoryAnalysisSheet(Excel excel, List<Order> orders) {
    final sheet = excel['Category Analysis'];

    // Headers
    _setCellValue(sheet, 'A1', 'Category');
    _setCellValue(sheet, 'B1', 'Items Sold');
    _setCellValue(sheet, 'C1', 'Total Revenue');
    _setCellValue(sheet, 'D1', 'Base Revenue');
    _setCellValue(sheet, 'E1', 'GST Amount');
    _setCellValue(sheet, 'F1', '% of Total');

    for (var col in ['A', 'B', 'C', 'D', 'E', 'F']) {
      _styleBold(sheet, '${col}1');
    }

    // Calculate category sales
    final categorySales = <String, Map<String, dynamic>>{
      'Non-Veg': {'quantity': 0, 'revenue': 0.0, 'base': 0.0, 'gst': 0.0},
      'Veg': {'quantity': 0, 'revenue': 0.0, 'base': 0.0, 'gst': 0.0},
      'Starters': {'quantity': 0, 'revenue': 0.0, 'base': 0.0, 'gst': 0.0},
      'Extras': {'quantity': 0, 'revenue': 0.0, 'base': 0.0, 'gst': 0.0},
    };

    for (final order in orders) {
      for (final item in order.items) {
        final category = _getCategoryFromItemName(item.menuItemName);
        if (categorySales.containsKey(category)) {
          categorySales[category]!['quantity'] += item.quantity;
          categorySales[category]!['revenue'] += item.totalPrice;
          categorySales[category]!['base'] += item.totalBasePrice;
          categorySales[category]!['gst'] += item.totalGst;
        }
      }
    }

    final totalRevenue = categorySales.values
        .fold<double>(0, (sum, cat) => sum + cat['revenue']);

    // Add data
    int row = 2;
    for (final entry in categorySales.entries) {
      final cat = entry.value;
      final percentage =
          totalRevenue > 0 ? (cat['revenue'] / totalRevenue * 100) : 0;

      _setCellValue(sheet, 'A$row', entry.key);
      _setCellValue(sheet, 'B$row', cat['quantity']);
      _setCellValue(sheet, 'C$row', '₹${cat['revenue'].toStringAsFixed(2)}');
      _setCellValue(sheet, 'D$row', '₹${cat['base'].toStringAsFixed(2)}');
      _setCellValue(sheet, 'E$row', '₹${cat['gst'].toStringAsFixed(2)}');
      _setCellValue(sheet, 'F$row', '${percentage.toStringAsFixed(1)}%');
      row++;
    }

    // Add totals
    row++;
    _setCellValue(sheet, 'A$row', 'TOTAL');
    _styleBold(sheet, 'A$row');
    final totalQty = categorySales.values
        .fold<int>(0, (sum, cat) => sum + cat['quantity'] as int);
    final totalBase =
        categorySales.values.fold<double>(0, (sum, cat) => sum + cat['base']);
    final totalGst =
        categorySales.values.fold<double>(0, (sum, cat) => sum + cat['gst']);

    _setCellValue(sheet, 'B$row', totalQty);
    _setCellValue(sheet, 'C$row', '₹${totalRevenue.toStringAsFixed(2)}');
    _setCellValue(sheet, 'D$row', '₹${totalBase.toStringAsFixed(2)}');
    _setCellValue(sheet, 'E$row', '₹${totalGst.toStringAsFixed(2)}');
    _setCellValue(sheet, 'F$row', '100.0%');
  }

  /// Daily Breakdown Sheet - Day-by-day analysis
  static void _addDailyBreakdownSheet(Excel excel, List<Order> orders) {
    final sheet = excel['Daily Breakdown'];

    // Headers
    _setCellValue(sheet, 'A1', 'Date');
    _setCellValue(sheet, 'B1', 'Orders');
    _setCellValue(sheet, 'C1', 'Items Sold');
    _setCellValue(sheet, 'D1', 'Total Revenue');
    _setCellValue(sheet, 'E1', 'Base Revenue');
    _setCellValue(sheet, 'F1', 'GST Amount');

    for (var col in ['A', 'B', 'C', 'D', 'E', 'F']) {
      _styleBold(sheet, '${col}1');
    }

    // Group by date
    final dailySales = <String, Map<String, dynamic>>{};

    for (final order in orders) {
      final dateKey = _dateFormat.format(order.createdAt);
      if (!dailySales.containsKey(dateKey)) {
        dailySales[dateKey] = {
          'orders': 0,
          'items': 0,
          'revenue': 0.0,
          'base': 0.0,
          'gst': 0.0,
        };
      }

      dailySales[dateKey]!['orders']++;
      dailySales[dateKey]!['items'] += order.totalItems;
      dailySales[dateKey]!['revenue'] += order.totalAmount;
      dailySales[dateKey]!['base'] += order.totalBaseAmount;
      dailySales[dateKey]!['gst'] += order.totalGst;
    }

    // Sort by date
    final sortedDates = dailySales.keys.toList()..sort();

    // Add data
    int row = 2;
    for (final date in sortedDates) {
      final data = dailySales[date]!;
      _setCellValue(sheet, 'A$row', date);
      _setCellValue(sheet, 'B$row', data['orders']);
      _setCellValue(sheet, 'C$row', data['items']);
      _setCellValue(sheet, 'D$row', '₹${data['revenue'].toStringAsFixed(2)}');
      _setCellValue(sheet, 'E$row', '₹${data['base'].toStringAsFixed(2)}');
      _setCellValue(sheet, 'F$row', '₹${data['gst'].toStringAsFixed(2)}');
      row++;
    }

    // Add totals
    if (sortedDates.isNotEmpty) {
      row++;
      _setCellValue(sheet, 'A$row', 'TOTAL');
      _styleBold(sheet, 'A$row');

      final totalOrders = dailySales.values
          .fold<int>(0, (sum, day) => sum + day['orders'] as int);
      final totalItems = dailySales.values
          .fold<int>(0, (sum, day) => sum + day['items'] as int);
      final totalRev =
          dailySales.values.fold<double>(0, (sum, day) => sum + day['revenue']);
      final totalBase =
          dailySales.values.fold<double>(0, (sum, day) => sum + day['base']);
      final totalGst =
          dailySales.values.fold<double>(0, (sum, day) => sum + day['gst']);

      _setCellValue(sheet, 'B$row', totalOrders);
      _setCellValue(sheet, 'C$row', totalItems);
      _setCellValue(sheet, 'D$row', '₹${totalRev.toStringAsFixed(2)}');
      _setCellValue(sheet, 'E$row', '₹${totalBase.toStringAsFixed(2)}');
      _setCellValue(sheet, 'F$row', '₹${totalGst.toStringAsFixed(2)}');
    }
  }

  // Helper methods
  static Map<String, Map<String, dynamic>> _calculateItemSales(
      List<Order> orders) {
    final itemSales = <String, Map<String, dynamic>>{};

    for (final order in orders) {
      for (final item in order.items) {
        if (!itemSales.containsKey(item.menuItemName)) {
          itemSales[item.menuItemName] = {
            'quantity': 0,
            'revenue': 0.0,
          };
        }

        itemSales[item.menuItemName]!['quantity'] += item.quantity;
        itemSales[item.menuItemName]!['revenue'] += item.totalPrice;
      }
    }

    return itemSales;
  }

  static String _getCategoryFromItemName(String itemName) {
    final lower = itemName.toLowerCase();
    if (lower.contains('chicken') ||
        lower.contains('mutton') ||
        lower.contains('egg')) {
      return 'Non-Veg';
    } else if (lower.contains('paneer') ||
        lower.contains('veg') ||
        lower.contains('mushroom') ||
        lower.contains('aloo')) {
      return 'Veg';
    } else if (lower.contains('65') && !lower.contains('biryani')) {
      return 'Starters';
    } else if (lower.contains('gulab') ||
        lower.contains('raita') ||
        lower.contains('onion')) {
      return 'Extras';
    }
    return 'Other';
  }

  static String _getPeriodLabel(
    ExportPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    switch (period) {
      case ExportPeriod.daily:
        return 'Daily (${_dateFormat.format(DateTime.now())})';
      case ExportPeriod.weekly:
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return 'Weekly (${_dateFormat.format(weekStart)} - ${_dateFormat.format(now)})';
      case ExportPeriod.monthly:
        final now = DateTime.now();
        return 'Monthly (${DateFormat('MMMM yyyy').format(now)})';
      case ExportPeriod.custom:
        if (startDate != null && endDate != null) {
          return 'Custom (${_dateFormat.format(startDate)} - ${_dateFormat.format(endDate)})';
        }
        return 'Custom Period';
    }
  }

  static String _generateFilename(
    ExportPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final periodLabel = period.name;
    return 'BiryaniByFlame_${periodLabel}_$timestamp.xlsx';
  }

  static void _setCellValue(Sheet sheet, String cell, dynamic value) {
    sheet.cell(CellIndex.indexByString(cell)).value = value is String
        ? TextCellValue(value)
        : value is int
            ? IntCellValue(value)
            : value is double
                ? DoubleCellValue(value)
                : TextCellValue(value.toString());
  }

  static void _styleBold(Sheet sheet, String cell) {
    final cellObj = sheet.cell(CellIndex.indexByString(cell));
    cellObj.cellStyle = CellStyle(bold: true);
  }

  static void _styleHeader(Sheet sheet, String cell) {
    final cellObj = sheet.cell(CellIndex.indexByString(cell));
    cellObj.cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
    );
  }

  static void _mergeCells(Sheet sheet, String range) {
    sheet.merge(CellIndex.indexByString(range.split(':')[0]),
        CellIndex.indexByString(range.split(':')[1]));
  }

  static String _getColumnLetter(int index) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (index < 26) {
      return letters[index];
    }
    return letters[index ~/ 26 - 1] + letters[index % 26];
  }

  static Future<void> _downloadFile(List<int> bytes, String filename) async {
    await file_saver.saveFile(bytes, filename);
  }

  // ============ NEW EMPLOYEE MANAGEMENT EXPORTS ============

  /// Export complete employee report with all details
  static Future<void> exportEmployeeReport(
      Employee employee, FirestoreService firestoreService) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    final sheet = excel['Employee_${employee.name}'];

    int row = 1;

    // Header
    _setCellValue(sheet, 'A$row', 'EMPLOYEE COMPREHENSIVE REPORT');
    _styleHeader(sheet, 'A$row');
    sheet.cell(CellIndex.indexByString('A$row')).cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
      backgroundColorHex: ExcelColor.fromHexString('#D4AF37'),
    );
    row += 2;

    // Personal Info
    _setCellValue(sheet, 'A$row', 'PERSONAL INFORMATION');
    _styleBold(sheet, 'A$row');
    row++;

    _setCellValue(sheet, 'A$row', 'Name:');
    _setCellValue(sheet, 'B$row', employee.name);
    row++;

    _setCellValue(sheet, 'A$row', 'Email:');
    _setCellValue(sheet, 'B$row', employee.email);
    row++;

    _setCellValue(sheet, 'A$row', 'Phone:');
    _setCellValue(sheet, 'B$row', employee.phone);
    row++;

    _setCellValue(sheet, 'A$row', 'Role:');
    _setCellValue(sheet, 'B$row', employee.role);
    row++;

    _setCellValue(sheet, 'A$row', 'Joining Date:');
    _setCellValue(sheet, 'B$row', _dateFormat.format(employee.joiningDate));
    row++;

    _setCellValue(sheet, 'A$row', 'Status:');
    _setCellValue(sheet, 'B$row', employee.isActive ? 'Active' : 'Inactive');
    row += 2;

    // Salary Info
    _setCellValue(sheet, 'A$row', 'SALARY INFORMATION');
    _styleBold(sheet, 'A$row');
    row++;

    _setCellValue(sheet, 'A$row', 'Monthly Salary:');
    _setCellValue(sheet, 'B$row', '₹${employee.salary.toStringAsFixed(2)}');
    row++;

    _setCellValue(sheet, 'A$row', 'Per Day Salary:');
    _setCellValue(
        sheet, 'B$row', '₹${(employee.salary / 30).toStringAsFixed(2)}');
    row += 2;

    // Leave Info
    _setCellValue(sheet, 'A$row', 'LEAVE INFORMATION');
    _styleBold(sheet, 'A$row');
    row++;

    _setCellValue(sheet, 'A$row', 'Total Leaves/Month:');
    _setCellValue(sheet, 'B$row', employee.totalLeavesPerMonth);
    row++;

    _setCellValue(sheet, 'A$row', 'Used Leaves:');
    _setCellValue(sheet, 'B$row', employee.usedLeaves);
    row++;

    _setCellValue(sheet, 'A$row', 'Remaining Leaves:');
    _setCellValue(sheet, 'B$row', employee.remainingLeaves);

    final filename =
        'Employee_${employee.name}_Complete_Report_${DateFormat('ddMMMyyyy').format(DateTime.now())}.xlsx';
    final bytes = excel.encode();
    if (bytes != null) {
      _downloadFile(bytes, filename);
    }
  }

  /// Export attendance report for date range
  static Future<void> exportAttendanceReport(
    DateTime startDate,
    DateTime endDate,
    FirestoreService firestoreService,
  ) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    final sheet = excel['Attendance_Report'];

    int row = 1;

    // Header
    _setCellValue(sheet, 'A$row', 'Date');
    _setCellValue(sheet, 'B$row', 'Employee Name');
    _setCellValue(sheet, 'C$row', 'Check In');
    _setCellValue(sheet, 'D$row', 'Check Out');
    _setCellValue(sheet, 'E$row', 'Total Hours');
    _setCellValue(sheet, 'F$row', 'Status');

    // Style header
    for (int i = 0; i < 6; i++) {
      final col = String.fromCharCode(65 + i); // A, B, C, D, E, F
      _styleBold(sheet, '$col$row');
      sheet.cell(CellIndex.indexByString('$col$row')).cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#D4AF37'),
      );
    }
    row++;

    // Get all employees
    final employees = await firestoreService.getEmployees().first;

    // Fetch attendance data
    for (var employee in employees) {
      final attendances = await firestoreService.getAttendanceByDateRange(
        employee.id,
        startDate,
        endDate,
      );

      for (var attendance in attendances) {
        _setCellValue(sheet, 'A$row', _dateFormat.format(attendance.date));
        _setCellValue(sheet, 'B$row', employee.name);
        _setCellValue(
            sheet,
            'C$row',
            attendance.checkInTime != null
                ? DateFormat('hh:mm a').format(attendance.checkInTime!)
                : 'N/A');
        _setCellValue(
            sheet,
            'D$row',
            attendance.checkOutTime != null
                ? DateFormat('hh:mm a').format(attendance.checkOutTime!)
                : 'N/A');
        _setCellValue(sheet, 'E$row', attendance.totalHours.toStringAsFixed(2));
        _setCellValue(
            sheet,
            'F$row',
            attendance.isCheckedOut
                ? 'Complete'
                : attendance.isCheckedIn
                    ? 'In Progress'
                    : 'Not Checked In');
        row++;
      }
    }

    final filename =
        'Attendance_Report_${_dateFormat.format(startDate)}_to_${_dateFormat.format(endDate)}.xlsx';
    final bytes = excel.encode();
    if (bytes != null) {
      _downloadFile(bytes, filename);
    }
  }

  /// Export leaves report
  static Future<void> exportLeavesReport(
    DateTime startDate,
    DateTime endDate,
    FirestoreService firestoreService,
  ) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    final sheet = excel['Leaves_Report'];

    int row = 1;

    // Header
    _setCellValue(sheet, 'A$row', 'Employee Name');
    _setCellValue(sheet, 'B$row', 'From Date');
    _setCellValue(sheet, 'C$row', 'To Date');
    _setCellValue(sheet, 'D$row', 'Days');
    _setCellValue(sheet, 'E$row', 'Reason');
    _setCellValue(sheet, 'F$row', 'Status');
    _setCellValue(sheet, 'G$row', 'Applied Date');
    _setCellValue(sheet, 'H$row', 'Approved By');

    // Style header
    for (int i = 0; i < 8; i++) {
      final col = String.fromCharCode(65 + i);
      _styleBold(sheet, '$col$row');
      sheet.cell(CellIndex.indexByString('$col$row')).cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#D4AF37'),
      );
    }
    row++;

    final employees = await firestoreService.getEmployees().first;

    for (var employee in employees) {
      final leaves =
          await firestoreService.getEmployeeLeaves(employee.id).first;

      for (var leave in leaves) {
        if (leave.fromDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            leave.fromDate.isBefore(endDate.add(const Duration(days: 1)))) {
          _setCellValue(sheet, 'A$row', employee.name);
          _setCellValue(sheet, 'B$row', _dateFormat.format(leave.fromDate));
          _setCellValue(sheet, 'C$row', _dateFormat.format(leave.toDate));
          _setCellValue(sheet, 'D$row', leave.numberOfDays);
          _setCellValue(sheet, 'E$row', leave.reason);
          _setCellValue(sheet, 'F$row', leave.status);
          _setCellValue(sheet, 'G$row', _dateFormat.format(leave.appliedDate));
          _setCellValue(sheet, 'H$row', leave.approvedBy ?? 'N/A');
          row++;
        }
      }
    }

    final filename =
        'Leaves_Report_${_dateFormat.format(startDate)}_to_${_dateFormat.format(endDate)}.xlsx';
    final bytes = excel.encode();
    if (bytes != null) {
      _downloadFile(bytes, filename);
    }
  }

  /// Export wastage report
  static Future<void> exportWastageReport(
    DateTime startDate,
    DateTime endDate,
    FirestoreService firestoreService,
  ) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    final sheet = excel['Wastage_Report'];

    int row = 1;

    // Header
    _setCellValue(sheet, 'A$row', 'Date');
    _setCellValue(sheet, 'B$row', 'Item Name');
    _setCellValue(sheet, 'C$row', 'Quantity');
    _setCellValue(sheet, 'D$row', 'Unit');
    _setCellValue(sheet, 'E$row', 'Reason');
    _setCellValue(sheet, 'F$row', 'Consumed By');
    _setCellValue(sheet, 'G$row', 'Logged By');
    _setCellValue(sheet, 'H$row', 'Estimated Value');
    _setCellValue(sheet, 'I$row', 'Notes');

    // Style header
    for (int i = 0; i < 9; i++) {
      final col = String.fromCharCode(65 + i);
      _styleBold(sheet, '$col$row');
      sheet.cell(CellIndex.indexByString('$col$row')).cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#D4AF37'),
      );
    }
    row++;

    final wastages =
        await firestoreService.getWastagesByDateRange(startDate, endDate);
    double totalValue = 0;

    for (var wastage in wastages) {
      _setCellValue(sheet, 'A$row', _dateFormat.format(wastage.date));
      _setCellValue(sheet, 'B$row', wastage.itemName);
      _setCellValue(sheet, 'C$row', wastage.quantity);
      _setCellValue(sheet, 'D$row', wastage.unit);
      _setCellValue(sheet, 'E$row', wastage.displayReason);
      _setCellValue(sheet, 'F$row',
          wastage.consumedBy ?? wastage.consumedByOther ?? 'N/A');
      _setCellValue(sheet, 'G$row', wastage.employeeName);
      _setCellValue(
          sheet,
          'H$row',
          wastage.estimatedValue != null
              ? '₹${wastage.estimatedValue!.toStringAsFixed(2)}'
              : 'N/A');
      _setCellValue(sheet, 'I$row', wastage.notes ?? '');
      row++;

      if (wastage.estimatedValue != null) {
        totalValue += wastage.estimatedValue!;
      }
    }

    row++;
    _setCellValue(sheet, 'G$row', 'TOTAL:');
    _styleBold(sheet, 'G$row');
    _setCellValue(sheet, 'H$row', '₹${totalValue.toStringAsFixed(2)}');
    _styleBold(sheet, 'H$row');

    final filename =
        'Wastage_Report_${_dateFormat.format(startDate)}_to_${_dateFormat.format(endDate)}.xlsx';
    final bytes = excel.encode();
    if (bytes != null) {
      _downloadFile(bytes, filename);
    }
  }

  /// Export expenses report
  static Future<void> exportExpensesReport(
    DateTime startDate,
    DateTime endDate,
    FirestoreService firestoreService,
  ) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    final sheet = excel['Expenses_Report'];

    int row = 1;

    // Header
    _setCellValue(sheet, 'A$row', 'Date');
    _setCellValue(sheet, 'B$row', 'Category');
    _setCellValue(sheet, 'C$row', 'Description');
    _setCellValue(sheet, 'D$row', 'Amount');
    _setCellValue(sheet, 'E$row', 'Vendor');
    _setCellValue(sheet, 'F$row', 'Payment Mode');
    _setCellValue(sheet, 'G$row', 'Bill Number');
    _setCellValue(sheet, 'H$row', 'Submitted By');
    _setCellValue(sheet, 'I$row', 'Status');
    _setCellValue(sheet, 'J$row', 'Approved By');

    // Style header
    for (int i = 0; i < 10; i++) {
      final col = String.fromCharCode(65 + i);
      _styleBold(sheet, '$col$row');
      sheet.cell(CellIndex.indexByString('$col$row')).cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#D4AF37'),
      );
    }
    row++;

    final expenses =
        await firestoreService.getExpensesByDateRange(startDate, endDate);
    double totalApproved = 0;
    double totalPending = 0;

    for (var expense in expenses) {
      _setCellValue(sheet, 'A$row', _dateFormat.format(expense.date));
      _setCellValue(sheet, 'B$row', expense.category);
      _setCellValue(sheet, 'C$row', expense.itemDescription);
      _setCellValue(sheet, 'D$row', '₹${expense.amount.toStringAsFixed(2)}');
      _setCellValue(sheet, 'E$row', expense.vendor ?? 'N/A');
      _setCellValue(sheet, 'F$row', expense.paymentMode ?? 'N/A');
      _setCellValue(sheet, 'G$row', expense.billNumber ?? 'N/A');
      _setCellValue(sheet, 'H$row', expense.employeeName);
      _setCellValue(sheet, 'I$row', expense.statusText);
      _setCellValue(sheet, 'J$row', expense.approvedBy ?? 'N/A');
      row++;

      if (expense.isApproved) {
        totalApproved += expense.amount;
      } else {
        totalPending += expense.amount;
      }
    }

    row++;
    _setCellValue(sheet, 'C$row', 'Total Approved:');
    _styleBold(sheet, 'C$row');
    _setCellValue(sheet, 'D$row', '₹${totalApproved.toStringAsFixed(2)}');
    _styleBold(sheet, 'D$row');

    row++;
    _setCellValue(sheet, 'C$row', 'Total Pending:');
    _styleBold(sheet, 'C$row');
    _setCellValue(sheet, 'D$row', '₹${totalPending.toStringAsFixed(2)}');
    _styleBold(sheet, 'D$row');

    row++;
    _setCellValue(sheet, 'C$row', 'Grand Total:');
    _styleBold(sheet, 'C$row');
    _setCellValue(sheet, 'D$row',
        '₹${(totalApproved + totalPending).toStringAsFixed(2)}');
    _styleBold(sheet, 'D$row');

    final filename =
        'Expenses_Report_${_dateFormat.format(startDate)}_to_${_dateFormat.format(endDate)}.xlsx';
    final bytes = excel.encode();
    if (bytes != null) {
      _downloadFile(bytes, filename);
    }
  }

  /// Export salary report
  static Future<void> exportSalaryReport(
    DateTime startDate,
    DateTime endDate,
    FirestoreService firestoreService,
  ) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    final sheet = excel['Salary_Report'];

    int row = 1;

    // Header
    _setCellValue(sheet, 'A$row', 'Employee Name');
    _setCellValue(sheet, 'B$row', 'Role');
    _setCellValue(sheet, 'C$row', 'Monthly Salary');
    _setCellValue(sheet, 'D$row', 'Days Worked');
    _setCellValue(sheet, 'E$row', 'Leaves Taken');
    _setCellValue(sheet, 'F$row', 'Per Day Salary');
    _setCellValue(sheet, 'G$row', 'Calculated Salary');
    _setCellValue(sheet, 'H$row', 'Phone');
    _setCellValue(sheet, 'I$row', 'Email');

    // Style header
    for (int i = 0; i < 9; i++) {
      final col = String.fromCharCode(65 + i);
      _styleBold(sheet, '$col$row');
      sheet.cell(CellIndex.indexByString('$col$row')).cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#D4AF37'),
      );
    }
    row++;

    final employees = await firestoreService.getEmployees().first;
    double totalSalary = 0;

    for (var employee in employees) {
      if (!employee.isActive) continue;

      final attendances = await firestoreService.getAttendanceByDateRange(
        employee.id,
        startDate,
        endDate,
      );

      final leaves =
          await firestoreService.getEmployeeLeaves(employee.id).first;
      int leavesTaken = 0;
      for (var leave in leaves) {
        if (leave.isApproved &&
            leave.fromDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            leave.fromDate.isBefore(endDate.add(const Duration(days: 1)))) {
          leavesTaken += leave.numberOfDays;
        }
      }

      double perDaySalary = employee.salary / 30;
      double calculatedSalary =
          perDaySalary * (attendances.length + leavesTaken);

      _setCellValue(sheet, 'A$row', employee.name);
      _setCellValue(sheet, 'B$row', employee.role);
      _setCellValue(sheet, 'C$row', '₹${employee.salary.toStringAsFixed(2)}');
      _setCellValue(sheet, 'D$row', attendances.length);
      _setCellValue(sheet, 'E$row', leavesTaken);
      _setCellValue(sheet, 'F$row', '₹${perDaySalary.toStringAsFixed(2)}');
      _setCellValue(sheet, 'G$row', '₹${calculatedSalary.toStringAsFixed(2)}');
      _setCellValue(sheet, 'H$row', employee.phone);
      _setCellValue(sheet, 'I$row', employee.email);
      row++;

      totalSalary += calculatedSalary;
    }

    row++;
    _setCellValue(sheet, 'F$row', 'TOTAL PAYROLL:');
    _styleBold(sheet, 'F$row');
    _setCellValue(sheet, 'G$row', '₹${totalSalary.toStringAsFixed(2)}');
    _styleBold(sheet, 'G$row');

    final filename =
        'Salary_Report_${_dateFormat.format(startDate)}_to_${_dateFormat.format(endDate)}.xlsx';
    final bytes = excel.encode();
    if (bytes != null) {
      _downloadFile(bytes, filename);
    }
  }
}
