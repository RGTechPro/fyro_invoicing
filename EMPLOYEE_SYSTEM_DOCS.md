# Employee Management System - Feature Documentation

## 🎯 Overview

Complete employee management system integrated with Firebase for **Biryani By Flame (Fyro Foods)**, featuring attendance tracking, leave management, salary management, and a full POS system.

## 👥 User Roles

### 1. **Employee Role**

- Basic access to own data
- Self-service features
- Limited permissions

### 2. **Admin Role**

- Full system access
- Manage all employees
- Approve/reject requests
- Access POS system
- Salary management

## 🔐 Authentication System

### Login System

- **Email/Password based authentication**
- Firebase Authentication backend
- Secure password storage
- Password reset functionality
- Auto-logout on inactivity

### Features:

- ✅ Simple login screen
- ✅ Email and password fields
- ✅ Password visibility toggle
- ✅ Error handling
- ✅ Loading states
- ✅ Responsive design (mobile & web)

## 📱 Employee Dashboard

### Profile Section

- Display employee name
- Show email address
- Display monthly salary
- Profile avatar with initials

### Attendance Management

- **Check-In Button**
  - One-click check-in
  - Records exact time
  - Cannot check in twice
- **Check-Out Button**
  - One-click check-out
  - Calculates total hours worked
  - Shows work duration
- **Today's Status**
  - View check-in time
  - View check-out time
  - Total hours worked
  - Status indicator (Present/Absent)

### Leave Management

- **Leave Balance Card**

  - Total leaves per month: 4 (configurable)
  - Used leaves count
  - Remaining leaves count
  - Color-coded indicators

- **Apply for Leave**
  - Select from date (date picker)
  - Select to date (date picker)
  - Enter reason (text field)
  - Calculates number of days
  - Submit for approval
- **Leave History**
  - List of all applied leaves
  - Status indicators:
    - 🟠 Pending (Orange)
    - 🟢 Approved (Green)
    - 🔴 Rejected (Red)
  - Date range display
  - Reason display

### UI Features

- Layman-friendly interface
- Large buttons for easy tapping
- Clear labels and instructions
- Visual feedback on actions
- Success/error messages
- Responsive layout for mobile and web

## 🎛️ Admin Dashboard

### Navigation

- Sidebar navigation (desktop)
- Bottom navigation (mobile)
- 6 main sections:
  1. Overview
  2. Employees
  3. Attendance
  4. Leaves
  5. Salary
  6. POS

### 1. Overview Tab

- **Statistics Cards**

  - Total employees count
  - Active employees count
  - Pending leave requests
  - Total monthly salary

- **Pending Leave Approvals**
  - List of all pending leaves
  - Employee details
  - Leave duration
  - Quick approve/reject buttons
  - Remaining leaves check

### 2. Employees Tab

- **Employee List**
  - All employees with status
  - Profile avatar
  - Name and email
  - Salary and role
  - Active/Inactive status
- **Add New Employee**
  - Enter name
  - Enter email (login ID)
  - Enter phone number
  - Set password
  - Set monthly salary
  - Assign role (Employee/Admin)
  - Creates Firebase auth account
  - Creates employee record
- **Edit Employee**
  - Update salary
  - Modify total leaves per month
  - Change active status

### 3. Attendance Tab

- **Today's Attendance Overview**
  - Total present count
  - Total absent count
  - Date display
- **Detailed Attendance List**
  - All employees listed
  - Check-in time
  - Check-out time
  - Total hours worked
  - Status indicator (Present/Absent)
  - Color-coded status
- **Features**
  - Real-time updates
  - Filter by date
  - Export capability (future)

### 4. Leaves Tab

- **Pending Approvals Section**
  - Detailed leave requests
  - Employee name and avatar
  - Remaining leaves display
  - Date range (From - To)
  - Number of days
  - Reason for leave
  - Approve button (green)
  - Reject button (red)
- **Leave Validation**
  - Checks remaining leaves
  - Prevents over-approval
  - Shows warnings if insufficient leaves
- **Approved/Rejected Leaves**
  - History of all leaves
  - Filter by status
  - Approved by information
  - Admin notes

### 5. Salary Management Tab

- **Total Monthly Salary Card**
  - Sum of all active employees' salaries
  - Large display
  - Prominent visibility
- **Employee Salary List**
  - Each employee's salary
  - Joining date
  - Leave usage (used/total)
  - Edit salary button
- **Salary Calculation Helper**
  - View attendance days
  - View leave days
  - Calculate pro-rated salary
  - Example: If employee takes 3 leaves, not 4:
    - Working days = 30 - 3 = 27 days
    - Daily salary = Monthly salary / 30
    - Payable = Daily salary × 27
- **Edit Salary Dialog**
  - Update monthly salary
  - Update total leaves per month
  - Save changes

### 6. POS Tab

- **Full POS System Access**
  - Complete menu management
  - Order creation
  - Invoice generation
  - Sales history
  - All existing POS features

## 📊 Data Models

### Employee Model

```dart
- id (String)
- name (String)
- email (String)
- phone (String)
- role (String) // 'admin' or 'employee'
- salary (double)
- joiningDate (DateTime)
- totalLeavesPerMonth (int) // Default: 4
- usedLeaves (int)
- isActive (bool)
- profileImage (String?)
- address (String?)
- emergencyContact (String?)
```

### Attendance Model

```dart
- id (String)
- employeeId (String)
- date (DateTime)
- checkInTime (DateTime?)
- checkOutTime (DateTime?)
- totalHours (double)
- status (String) // 'present', 'absent', 'half-day', 'leave'
- notes (String?)
```

### Leave Model

```dart
- id (String)
- employeeId (String)
- fromDate (DateTime)
- toDate (DateTime)
- reason (String)
- status (String) // 'pending', 'approved', 'rejected'
- appliedDate (DateTime)
- adminNotes (String?)
- approvedBy (String?)
- approvedDate (DateTime?)
```

## 🔄 Business Logic

### Leave Rules

1. **Maximum 4 leaves per month** (configurable per employee)
2. Resets every month (manual reset or automated)
3. Cannot apply if insufficient balance
4. Requires admin approval
5. Deducts from balance only after approval

### Attendance Rules

1. One check-in per day
2. Must check-in before check-out
3. Cannot modify past attendance (admin only)
4. Automatic absent marking (future feature)
5. Half-day logic (future feature)

### Salary Calculation

1. **Monthly Salary**: Base salary per month
2. **Working Days**: Typically 30 days
3. **Daily Rate**: Monthly Salary ÷ 30
4. **Leaves Deduction**:
   - If takes 3 leaves (1 unused): No deduction for unused leave
   - If takes 4 leaves (all used): Full month
   - If takes more than 4: Deduct extra days
5. **Formula**:
   ```
   Working Days = 30 - Approved Leaves
   Daily Salary = Monthly Salary / 30
   Payable Salary = Daily Salary × Working Days
   ```

## 🎨 UI/UX Features

### Responsive Design

- ✅ Mobile-first approach
- ✅ Tablet optimization
- ✅ Desktop layout
- ✅ Adaptive components
- ✅ Touch-friendly buttons
- ✅ Large tap targets

### Color Scheme

- **Primary Black**: #1a1a1a
- **Dark Grey**: #2a2a2a
- **Medium Grey**: #666666
- **Light Gold**: #d4af37
- **Secondary Gold**: #ffd700
- **Accent Red**: #ff4444
- **Success Green**: #4caf50
- **Warning Orange**: #ff9800

### User-Friendly Elements

- Large, clear buttons
- Visual feedback (colors, animations)
- Success/error notifications
- Loading indicators
- Confirmation dialogs
- Intuitive icons
- Simple language
- Minimal text entry
- Date pickers (no manual typing)
- Dropdown menus (no typing)

### Accessibility

- High contrast colors
- Large text options
- Clear icon meanings
- Error messages
- Help tooltips
- Logical flow

## 📱 Platform Support

### Mobile (Android & iOS)

- Native look and feel
- Touch gestures
- Native date pickers
- Push notifications (future)
- Biometric login (future)

### Web

- Full browser support
- Responsive layout
- Desktop optimizations
- Keyboard shortcuts (future)
- Printable views

## 🔒 Security Features

### Authentication

- Secure password hashing (Firebase)
- Session management
- Auto-logout
- Password reset via email
- Role-based access control

### Authorization

- Employee: Own data only
- Admin: All data access
- Firestore security rules
- Backend validation

### Data Protection

- Encrypted connections (HTTPS)
- Secure API calls
- Input validation
- SQL injection prevention
- XSS protection

## 🚀 Future Enhancements

### Phase 1 (Immediate)

- [ ] Automated monthly leave reset
- [ ] Automatic absent marking (end of day)
- [ ] Attendance reports (PDF)
- [ ] Salary slip generation

### Phase 2 (Short-term)

- [ ] Push notifications
- [ ] Biometric check-in
- [ ] GPS-based check-in
- [ ] Half-day leave option
- [ ] Overtime tracking
- [ ] Holiday calendar

### Phase 3 (Long-term)

- [ ] Mobile app (native)
- [ ] Shift management
- [ ] Performance reviews
- [ ] Document management
- [ ] Employee chat
- [ ] Payroll integration

## 📞 Support & Maintenance

### Admin Responsibilities

1. Create employee accounts
2. Approve/reject leaves
3. Monitor attendance
4. Process salaries
5. Update employee data
6. Handle exceptions

### Employee Responsibilities

1. Daily check-in/check-out
2. Apply for leaves in advance
3. Update profile information
4. Report issues to admin

## 🎓 Training Guide

### For Employees (15 minutes)

1. How to log in
2. How to check-in/check-out
3. How to apply for leave
4. How to view leave balance
5. Understanding the dashboard

### For Admins (30 minutes)

1. System overview
2. Adding employees
3. Approving leaves
4. Monitoring attendance
5. Managing salaries
6. Using POS system
7. Best practices

## 📝 Quick Start Checklist

- [ ] Set up Firebase project
- [ ] Run `flutterfire configure`
- [ ] Enable Authentication
- [ ] Enable Firestore
- [ ] Create first admin user
- [ ] Test login
- [ ] Add test employee
- [ ] Test employee dashboard
- [ ] Test admin dashboard
- [ ] Test attendance flow
- [ ] Test leave flow
- [ ] Review and adjust

---

**System Status**: ✅ Ready for Firebase setup and deployment
**Documentation**: ✅ Complete
**Code Quality**: ✅ Production-ready
**Testing**: ⏳ Pending Firebase configuration
