# 🚀 Quick Setup & Daily Operations Guide

## ⚡ First-Time Setup (Do Once)

### 1. Install Dependencies

```bash
cd /Users/rishabhgupta/projects/fyro_invoicing
flutter pub get
```

### 2. Setup Firebase

```bash
# Install Firebase CLI
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# Login
firebase login

# Configure project
flutterfire configure
```

### 3. Create Firebase Project

1. Go to https://console.firebase.google.com/
2. Create project: "biryani-by-flame"
3. Enable Authentication > Email/Password
4. Enable Firestore Database
5. Create first admin user (see FIREBASE_SETUP.md)

### 4. Run the App

```bash
# For development
flutter run

# For web
flutter run -d chrome

# For Android
flutter run -d android

# For iOS
flutter run -d ios
```

---

## 👤 Daily Operations for Employees

### Morning Check-In

1. Open app
2. Login with email & password
3. Click **"CHECK IN"** button
4. ✓ Confirmed!

### Evening Check-Out

1. Open app (if not already open)
2. Click **"CHECK OUT"** button
3. See total hours worked
4. ✓ Done for the day!

### Applying for Leave

1. Login to app
2. Click **"Apply"** button in Leave Balance card
3. Select **From Date**
4. Select **To Date**
5. Enter **Reason**
6. Click **"Submit"**
7. Wait for admin approval (will show as "PENDING")

### Checking Leave Balance

- Dashboard shows:
  - **Total**: 4 leaves per month
  - **Used**: Leaves already taken
  - **Remaining**: Leaves available

---

## 👨‍💼 Daily Operations for Admin

### Morning Routine

#### 1. Check Today's Attendance

```
Admin Dashboard → Attendance Tab
```

- See who has checked in
- See who is absent
- Total present/absent count

#### 2. Review Pending Leaves

```
Admin Dashboard → Overview Tab
OR
Admin Dashboard → Leaves Tab
```

- See all pending leave requests
- Check employee's remaining leaves
- Approve ✓ or Reject ✗

### Adding New Employee

```
Admin Dashboard → Employees Tab → Add Employee Button
```

Fill in:

- **Name**: Employee full name
- **Email**: username@company.com (they'll use this to login)
- **Phone**: 10-digit number
- **Password**: Temporary password (they should change it)
- **Salary**: Monthly salary in ₹
- **Role**: Employee or Admin

Click **"Add"** ✓

### Approving a Leave

```
Admin Dashboard → Leaves Tab → Pending Approvals
```

For each request:

1. Check employee name
2. Check remaining leaves (must have enough)
3. Check dates and reason
4. Click **Approve** (green ✓) OR **Reject** (red ✗)

**Important**: System automatically:

- Deducts leaves from balance
- Updates employee's used leaves
- Notifies the employee

### Managing Salaries

```
Admin Dashboard → Salary Tab
```

#### View Total Salary

- See total monthly salary for all employees

#### Edit Individual Salary

1. Click on employee card
2. Update **Monthly Salary**
3. Update **Total Leaves per Month** (if needed)
4. Click **Save**

#### Calculate Pro-rated Salary (Manual)

```
Example: Employee on ₹30,000/month takes 3 leaves

Daily Rate = 30,000 ÷ 30 = ₹1,000/day
Working Days = 30 - 3 = 27 days
Payable = 1,000 × 27 = ₹27,000
```

### Accessing POS System

```
Admin Dashboard → POS Tab
```

- Full billing system
- Menu management
- Order history
- Everything from the main POS

---

## 🔧 Common Tasks

### Reset Password (Employee Forgot)

**Option 1**: Admin creates new password

1. Go to Firebase Console
2. Authentication → Users
3. Find user → Reset password
4. Send reset email

**Option 2**: Delete and recreate

1. Admin Dashboard → Employees
2. Remove old account
3. Create new account with same details

### Edit Employee Details

```
Admin Dashboard → Employees Tab → Click Edit Icon
```

- Update salary
- Change total leaves
- Deactivate employee (instead of delete)

### View Attendance History

```
Admin Dashboard → Attendance Tab
```

- Today's attendance by default
- Filter by date (future feature)
- Export reports (future feature)

### Monthly Leave Reset

Currently manual (future: automatic)

1. Go to Firebase Console
2. Firestore → employees collection
3. For each employee, set `usedLeaves: 0`

OR create a script (ask admin for help)

---

## 📱 Quick Troubleshoots

### Can't Login?

- Check email spelling
- Check CAPS LOCK
- Try "Forgot Password"
- Contact admin

### Can't Check-In?

- Already checked in? (Check screen)
- Internet connection ok?
- Try refresh/restart app

### Can't Apply Leave?

- Insufficient balance?
- Already have pending request?
- Internet connection ok?

### Leave Not Approved Yet?

- Leaves need admin approval
- Check with admin
- Status shows "PENDING"

### Wrong Salary Shown?

- Contact admin to update
- Admin can edit in system

---

## 🆘 Emergency Contacts

### For Employees

**Issue**: Login, attendance, leave problems
**Contact**: Admin / Manager

### For Admin

**Issue**: System errors, Firebase issues
**Contact**: Tech support / Developer

---

## 💡 Best Practices

### For Employees ✓

- Check in immediately upon arrival
- Check out when leaving
- Apply for leaves in advance (3-4 days)
- Keep profile updated
- Report issues immediately

### For Admin ✓

- Review leaves within 24 hours
- Monitor daily attendance
- Keep salary records updated
- Regular backups (Firebase auto-backs up)
- Monthly leave resets
- Review employee data monthly

### Security ✓

- Don't share passwords
- Logout when leaving
- Use strong passwords
- Change default passwords
- Report suspicious activity

---

## 📊 Monthly Checklist (Admin)

### Start of Month

- [ ] Reset all employees' `usedLeaves` to 0
- [ ] Review previous month's attendance
- [ ] Process previous month's salaries
- [ ] Clear pending leave requests

### Mid-Month

- [ ] Monitor attendance patterns
- [ ] Check leave balances
- [ ] Address any issues

### End of Month

- [ ] Generate attendance summary
- [ ] Calculate final salaries
- [ ] Process payments
- [ ] Review next month's leave requests

---

## 🎯 Pro Tips

### Employees

- Check in even if you're late (records actual time)
- Apply leaves early to get approval
- Check remaining leaves before applying
- Keep app updated

### Admin

- Approve leaves same day if possible
- Check attendance at end of day
- Keep employee records current
- Regular system checks
- Train new employees properly

---

## 📞 Support

### Firebase Console

- URL: https://console.firebase.google.com/
- Project: biryani-by-flame
- Access: Admin only

### App URL (Web)

- Development: http://localhost:5000
- Production: [Your domain]

### Documentation

- Setup: `FIREBASE_SETUP.md`
- Features: `EMPLOYEE_SYSTEM_DOCS.md`
- This guide: `QUICK_OPERATIONS_GUIDE.md`

---

**Last Updated**: October 31, 2025
**Version**: 1.0.0
**Status**: ✅ Ready for Production
