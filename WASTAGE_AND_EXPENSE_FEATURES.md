# New Features Added - Wastage and Expense Tracking

## Overview

Two new features have been added to the employee management system to track wastage and expenses.

## 1. Wastage Tracking 🗑️

### Purpose

Track food wastage with three categories:

- **Employee Consumed**: When an employee eats the food
- **Consumed by Other**: When someone else (non-employee) consumes the food
- **Thrown (Kharab/Spoiled)**: When food is thrown away due to spoilage

### Features

- Record item name, quantity, and unit
- Select reason for wastage
- For employee consumption: Select from dropdown of all employees
- For other consumption: Enter person's name manually
- For thrown items: Add notes about why it was spoiled
- Optional estimated value in rupees
- Optional notes field
- Automatically records who logged the entry and timestamp

### How to Use (Employee Dashboard)

1. Click the **"Add Wastage"** button (orange button)
2. Fill in:
   - Item Name (e.g., "Chicken Biryani")
   - Quantity and Unit (e.g., "2 kg" or "5 pcs")
   - Reason for wastage
   - Based on reason:
     - If employee consumed: Select employee from dropdown
     - If other consumed: Enter person's name
     - If thrown: No additional field needed
   - Estimated Value (optional)
   - Notes (optional)
3. Click **Submit**

### Data Model

```dart
Wastage {
  id: String
  employeeId: String (who recorded it)
  employeeName: String (who recorded it)
  date: DateTime
  itemName: String
  quantity: double
  unit: String (kg, pcs, liters, etc.)
  reason: String ('employee_consumed', 'other', 'thrown')
  consumedBy: String? (employee name)
  consumedByOther: String? (other person name)
  notes: String?
  estimatedValue: double?
}
```

### Firestore Collection

- Collection: `wastages`
- Indexed by: date (descending)
- Can be queried by: employeeId, date range

## 2. Expense Tracking 💰

### Purpose

Track daily expenses for purchases and operational costs with admin approval workflow.

### Features

- Multiple categories: Groceries, Utilities, Supplies, Transport, Maintenance, Other
- Record item description and amount
- Track vendor/shop name
- Multiple payment modes: Cash, Card, UPI, Online Transfer
- Optional bill/receipt number
- Optional notes
- Requires admin approval before being counted
- Automatically records who logged the entry and timestamp

### How to Use (Employee Dashboard)

1. Click the **"Add Expense"** button (purple button)
2. Fill in:
   - Category (dropdown)
   - Item Description (e.g., "Bought rice and spices")
   - Amount in ₹
   - Vendor/Shop Name (optional)
   - Payment Mode (dropdown)
   - Bill/Receipt Number (optional)
   - Notes (optional)
3. Click **Submit**
4. Expense will be marked as "Pending" until admin approves

### Data Model

```dart
Expense {
  id: String
  employeeId: String (who recorded it)
  employeeName: String (who recorded it)
  date: DateTime
  category: String
  itemDescription: String
  amount: double
  vendor: String?
  paymentMode: String ('cash', 'card', 'upi', 'online')
  billNumber: String?
  notes: String?
  isApproved: bool (default: false)
  approvedDate: DateTime?
  approvedBy: String? (admin name)
}
```

### Firestore Collection

- Collection: `expenses`
- Indexed by: date (descending)
- Can be queried by: employeeId, isApproved status, date range

### Admin Features

Admin can:

- View all wastage entries with filters
- View all expense entries
- Approve/reject expense entries
- View total approved expenses for a period
- Export reports

## UI Changes

### Employee Dashboard

New section added with two buttons:

```
┌─────────────────────────────────┐
│  🗑️ Add Wastage  │  💰 Add Expense │
└─────────────────────────────────┘
```

Both buttons open dialogs with proper form validation and styling matching the app theme (gold/black).

## Backend Integration

### FirestoreService Methods

#### Wastage Methods

```dart
// Add wastage entry
Future<void> addWastage({...})

// Get all wastages (stream)
Stream<List<Wastage>> getWastages()

// Get wastages by employee
Stream<List<Wastage>> getWastagesByEmployee(String employeeId)

// Get wastages by date range
Future<List<Wastage>> getWastagesByDateRange(DateTime startDate, DateTime endDate)

// Delete wastage
Future<void> deleteWastage(String wastageId)
```

#### Expense Methods

```dart
// Add expense entry
Future<void> addExpense({...})

// Get all expenses (stream)
Stream<List<Expense>> getExpenses()

// Get expenses by employee
Stream<List<Expense>> getExpensesByEmployee(String employeeId)

// Get pending expenses for approval
Stream<List<Expense>> getPendingExpenses()

// Approve expense (admin only)
Future<void> approveExpense(String expenseId, String adminName)

// Get expenses by date range
Future<List<Expense>> getExpensesByDateRange(DateTime startDate, DateTime endDate)

// Get total approved expenses for a period
Future<double> getTotalExpenses(DateTime startDate, DateTime endDate)

// Delete expense
Future<void> deleteExpense(String expenseId)
```

## Benefits

### For Employees

- Quick and easy logging of wastage
- Simple expense recording with proper categorization
- Mobile-friendly interface
- No complex forms

### For Admins

- Complete visibility into wastage patterns
- Track where food is going
- Expense approval workflow ensures accountability
- Can analyze spending patterns by category
- Can identify high-wastage items
- Better inventory and cost management

## Security

- All entries are linked to the employee who created them
- Expenses require admin approval before being counted in totals
- Firestore security rules should restrict:
  - Employees can only create and view their own entries
  - Admins can view/approve/delete all entries
  - Only authenticated users can access the collections

## Future Enhancements

- Photo upload for bills/receipts
- Wastage analytics dashboard
- Expense reports (daily/weekly/monthly)
- Budget alerts
- Category-wise spending analysis
- Employee-wise wastage reports
- Integration with inventory management
- WhatsApp/email notifications for approvals

## Testing Checklist

- [ ] Employee can add wastage entry
- [ ] Employee can select other employees from dropdown
- [ ] Employee can add expense entry
- [ ] All fields validate properly
- [ ] Entries appear in Firestore
- [ ] Timestamps are recorded correctly
- [ ] Admin can view all entries
- [ ] Admin can approve expenses
- [ ] Total calculations work correctly
- [ ] UI is responsive on mobile and web
