# Admin Wastage and Expense Tracking - Feature Summary

## Overview

The admin dashboard now has two new tabs to view and manage all wastage and expense entries submitted by employees.

## New Admin Dashboard Tabs

### 🗑️ 6. Wastage Tab

#### Features

- **Real-time view** of all wastage entries from all employees
- **Summary cards** showing:
  - Total wastage entries
  - Total estimated value (₹)
  - Count by reason (Employee Consumed, Other Consumed, Thrown)

#### Wastage Entry Display

Each entry shows:

- Item name and icon based on reason
- Quantity and unit
- Full reason (who consumed or if thrown)
- Employee who logged it
- Date and time logged
- Notes (if any)
- Estimated value (if provided)
- Delete button

#### Color-coded by Reason

- 🟢 **Green**: Employee consumed
- 🔵 **Blue**: Other person consumed
- 🔴 **Red**: Thrown (Kharab/Spoiled)

#### Admin Actions

- ❌ **Delete** any wastage entry
- View complete history with all details

---

### 💰 7. Expenses Tab

#### Features

- **Real-time view** of all expense entries from all employees
- **Summary cards** showing:
  - Total expense entries
  - Total approved amount (₹) - in green
  - Total pending amount (₹) - in orange

#### Expense Entry Display

Each entry shows:

- Item description
- Category and payment mode
- Vendor name (if provided)
- Amount in ₹
- Employee who submitted it
- Date submitted
- Status chip (Approved/Pending)
- Approval details (who approved and when)

#### Color-coded by Status

- 🟢 **Green**: Approved
- 🟠 **Orange**: Pending approval

#### Admin Actions

For **Pending** expenses:

- ✅ **Approve** - Marks expense as approved and adds admin name
- ❌ **Delete** - Removes the expense entry

For **Approved** expenses:

- ❌ **Delete** - Removes the expense entry (with confirmation)

---

## Navigation Updates

### Desktop View (Side Navigation Rail)

```
1. Overview
2. Employees
3. Attendance
4. Leaves
5. Salary
6. Wastage     ← NEW
7. Expenses    ← NEW
8. POS
```

### Mobile View (Bottom Navigation Bar)

```
Overview | Staff | Time | Leave | Salary | Wastage | Expense | POS
```

---

## Approval Workflow

### Wastage

- ✅ No approval needed
- Logged immediately
- Admin can only delete

### Expenses

- ⏳ Submitted as "Pending"
- 👨‍💼 Admin reviews and approves
- ✅ Only approved expenses count in totals
- 📊 Tracks who approved and when

---

## Statistics and Insights

### Wastage Tab Shows:

- Total number of wastage entries
- Sum of estimated values
- Breakdown by reason:
  - Employee consumed (green)
  - Other consumed (blue)
  - Thrown/Kharab (red)

### Expenses Tab Shows:

- Total number of expense entries
- Total approved amount (green card)
- Total pending amount (orange card)
- Pending vs Approved count

---

## Backend Integration

### Firestore Collections Used

1. **`wastages`** collection

   - Real-time stream of all entries
   - Ordered by date (newest first)

2. **`expenses`** collection
   - Real-time stream of all entries
   - Ordered by date (newest first)
   - Tracks approval status

### Methods Called

```dart
// Wastage
_firestoreService.getWastages() // Stream
_firestoreService.deleteWastage(id)

// Expenses
_firestoreService.getExpenses() // Stream
_firestoreService.approveExpense(id, adminName)
_firestoreService.deleteExpense(id)
```

---

## UI/UX Features

### Responsive Design

- ✅ Works on desktop (navigation rail)
- ✅ Works on mobile (bottom navigation)
- ✅ Cards adjust to screen size

### Visual Indicators

- Color-coded status chips
- Icons matching entry type
- Clear typography hierarchy
- Dark theme with gold accents

### User Feedback

- ✅ Success messages (green)
- ❌ Error messages (red)
- ⏳ Loading indicators
- ⚠️ Confirmation dialogs for delete/approve

---

## Complete Admin Workflow

### For Wastage Management:

1. Click **Wastage** tab
2. View all wastage entries with summaries
3. Review item details, reasons, and values
4. Delete incorrect entries if needed

### For Expense Management:

1. Click **Expenses** tab
2. View all expense entries
3. See pending (orange) and approved (green) expenses
4. For pending expenses:
   - Click three-dot menu
   - Select **Approve** ✅ or **Delete** ❌
5. Track total approved vs pending amounts
6. Monitor spending by category and employee

---

## Benefits for Admin

### Financial Control

- Full visibility into all expenses
- Approval workflow prevents unauthorized spending
- Track estimated wastage costs
- Monitor spending patterns

### Operational Insights

- Identify high-wastage items
- See which employees log most entries
- Track consumption patterns
- Analyze spending by category

### Accountability

- Know who logged each entry
- Track when expenses were approved
- Maintain audit trail
- Delete incorrect entries

### Real-time Monitoring

- Instant updates when employees add entries
- No manual refresh needed
- Always see current totals
- Get notifications via snackbars

---

## Testing Checklist for Admin

- [ ] Can see Wastage tab in navigation
- [ ] Can see Expenses tab in navigation
- [ ] Wastage summary cards display correctly
- [ ] Expense summary cards display correctly
- [ ] Can view all wastage entries from all employees
- [ ] Can view all expense entries from all employees
- [ ] Can delete wastage entries
- [ ] Can approve pending expenses
- [ ] Can delete expense entries
- [ ] Confirmation dialogs work
- [ ] Success/error messages appear
- [ ] Color coding is correct
- [ ] Mobile view works properly
- [ ] Real-time updates work (add entry as employee, see in admin)

---

## Future Enhancements

### Analytics Dashboard

- Monthly/weekly reports
- Charts and graphs
- Category-wise breakdown
- Employee-wise analysis
- Wastage trends over time
- Budget tracking

### Export Features

- Export to Excel/PDF
- Date range filters
- Category filters
- Employee filters

### Notifications

- Alert when expense submitted
- Weekly wastage summaries
- Budget limit warnings
- Email/SMS notifications

### Advanced Features

- Photo upload for receipts
- Receipt OCR scanning
- Budget limits per category
- Auto-approval rules
- Bulk actions
- Search and filters
