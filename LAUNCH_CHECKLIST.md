# ✅ Pre-Launch Checklist - Biryani By Flame

## 🚀 System Setup (One-Time)

### Development Environment

- [x] Flutter SDK installed and configured
- [x] Chrome browser installed
- [x] VS Code or preferred IDE set up
- [x] Project dependencies installed (`flutter pub get`)
- [x] Code compiles without errors (`flutter analyze`)

### Hardware Setup

- [ ] Everycom thermal printer available
- [ ] USB or Bluetooth connection tested
- [ ] Printer loaded with thermal paper rolls
- [ ] Backup paper rolls available
- [ ] Laptop/Desktop with adequate screen size (min 13")
- [ ] Reliable power source for event location
- [ ] Backup laptop (optional but recommended)

### Software Testing

- [ ] App runs successfully in Chrome (`flutter run -d chrome`)
- [ ] Test order created and completed
- [ ] Receipt prints correctly (2 copies)
- [ ] Print preview works
- [ ] Database saves orders
- [ ] Search functionality works
- [ ] All menu items display correctly

---

## 📋 Pre-Event Preparation (Day Before)

### System Check

- [ ] Run app to verify it starts correctly
- [ ] Verify all 17 menu items are visible
- [ ] Test creating 3 concurrent orders
- [ ] Test completing an order
- [ ] Test printing a receipt
- [ ] Check GST calculations (spot check 3 items)
- [ ] Verify today's statistics show correctly

### Menu Verification

- [ ] All Non-Veg items (4) display with correct prices
- [ ] All Veg items (4) display with correct prices
- [ ] All Starters (5) display with correct prices
- [ ] All Extras (3) display with correct prices
- [ ] Serving sizes show correctly (Serves 1, Serves 2, Single)
- [ ] Category filters work (Non-Veg, Veg, Starters, Extras)

### Printer Setup

- [ ] Connect printer to laptop via USB or Bluetooth
- [ ] Test print a sample receipt
- [ ] Verify receipt is readable and properly formatted
- [ ] Check paper alignment
- [ ] Load backup paper rolls
- [ ] Test with different item combinations

### Data Management

- [ ] Clear test orders from history (optional)
- [ ] Verify database is functioning
- [ ] Bookmark the app URL (if hosted)
- [ ] Test order search functionality

---

## 👥 Staff Training (Before Event)

### Basic Navigation

- [ ] Show staff the 3 main sections (Menu, Orders, History)
- [ ] Demonstrate switching between tabs
- [ ] Explain the navigation rail
- [ ] Show how to read the statistics in header

### Taking Orders

- [ ] How to create a new order
- [ ] How to browse menu categories
- [ ] How to add items to an order
- [ ] How to adjust quantities
- [ ] How to remove items
- [ ] How to enter customer names
- [ ] How to add notes

### Concurrent Orders

- [ ] How to manage multiple orders
- [ ] How to switch between order tabs
- [ ] How to track which order is which
- [ ] How to close unwanted order tabs

### Completing Orders

- [ ] How to review order totals
- [ ] How to verify GST calculations
- [ ] How to complete and print
- [ ] What to do if printer fails
- [ ] How to use print preview

### Order History

- [ ] How to search for past orders
- [ ] How to view order details
- [ ] How to reprint a receipt
- [ ] How to export as PDF

### Troubleshooting

- [ ] What to do if app crashes (refresh browser)
- [ ] What to do if printer jams (reload paper)
- [ ] What to do if item is out of stock (add note)
- [ ] Who to contact for technical issues

---

## 🎯 Event Day Setup (2 Hours Before)

### Workstation Setup

- [ ] Set up laptop at ordering station
- [ ] Connect to power source
- [ ] Connect printer via USB or Bluetooth
- [ ] Ensure good lighting for screen visibility
- [ ] Position printer within easy reach
- [ ] Have backup paper rolls nearby

### App Launch

- [ ] Open Terminal/Command Prompt
- [ ] Navigate to project folder
- [ ] Run: `flutter run -d chrome`
- [ ] Wait for app to load completely
- [ ] Maximize browser window (F11 for fullscreen)
- [ ] Verify header shows correct date

### System Verification

- [ ] Create a test order
- [ ] Add 2-3 items
- [ ] Complete and print test receipt
- [ ] Verify receipt quality
- [ ] Cancel test order or keep for records
- [ ] Check "Today's Statistics" resets to ₹0

### Staff Readiness

- [ ] Assign staff to ordering station
- [ ] Quick refresher on key operations
- [ ] Ensure staff know emergency contacts
- [ ] Have printed quick reference guide ready
- [ ] Designate backup staff member

---

## ⚡ During Event (Ongoing)

### Every Hour

- [ ] Check printer paper level
- [ ] Verify orders are saving to history
- [ ] Monitor today's statistics
- [ ] Check for any system errors
- [ ] Restart app if performance degrades (rare)

### Peak Times

- [ ] Have multiple orders open (tabs)
- [ ] Process completed orders promptly
- [ ] Keep printer stocked with paper
- [ ] Have backup staff ready if needed

### Common Issues

- [ ] **Printer jam**: Reload paper, restart printer
- [ ] **App slow**: Close unused order tabs
- [ ] **Receipt unclear**: Check printer settings
- [ ] **Wrong item**: Remove and re-add correct item

---

## 🔚 Post-Event (End of Day)

### Data Review

- [ ] Switch to History tab
- [ ] Review all completed orders
- [ ] Note today's total sales from header
- [ ] Note total number of orders
- [ ] Export important orders as PDF (optional)

### Reconciliation

- [ ] Match physical cash/payments with app totals
- [ ] Verify all orders were printed
- [ ] Check for any cancelled orders
- [ ] Note any issues for improvement

### System Shutdown

- [ ] Don't close app immediately (let it save)
- [ ] Allow database to sync (wait 10 seconds)
- [ ] Close browser tab
- [ ] Safely disconnect printer
- [ ] Store printer and paper rolls

### Data Backup (Recommended)

- [ ] Export key orders as PDF
- [ ] Screenshot today's statistics
- [ ] Save browser's local storage (optional)
- [ ] Email PDFs to yourself (if needed)

---

## 🔄 Regular Maintenance

### Weekly

- [ ] Review order history
- [ ] Clear very old orders (>30 days) if needed
- [ ] Check app performance
- [ ] Update menu prices if changed
- [ ] Test printer functionality

### Monthly

- [ ] Review sales trends in history
- [ ] Update any menu items
- [ ] Check for Flutter/dependency updates
- [ ] Clean printer (remove dust)
- [ ] Verify backup systems

---

## 🆘 Emergency Procedures

### App Crashes

1. [ ] Refresh browser (F5 or Cmd+R)
2. [ ] If persists, restart app
3. [ ] Last resort: `flutter clean && flutter pub get && flutter run`
4. [ ] Check browser console (F12) for errors

### Printer Fails

1. [ ] Use "Preview Receipt" button
2. [ ] Save/Export as PDF
3. [ ] Print from regular printer
4. [ ] Switch to backup printer
5. [ ] Write order details manually as fallback

### Data Loss Concerns

1. [ ] All orders saved to local database automatically
2. [ ] Check History tab to verify
3. [ ] Use browser's IndexedDB inspector (F12 > Application > IndexedDB)
4. [ ] Export critical orders as PDF immediately

### Power Outage

1. [ ] Data saved in browser's local storage (persists)
2. [ ] Close app gracefully when power returns
3. [ ] Restart and verify History shows all orders
4. [ ] Continue operations normally

---

## 📞 Support Contacts

### Technical Support

- **Developer**: [Your contact info]
- **IT Support**: [Your IT contact]
- **Printer Support**: [Everycom support]

### Emergency Contacts

- **Backup Staff**: [Phone number]
- **Management**: [Phone number]
- **On-Call Tech**: [Phone number]

---

## 📚 Quick Reference

### Essential Commands

```bash
# Start app
flutter run -d chrome

# If errors occur
flutter clean
flutter pub get
flutter run -d chrome

# Check for issues
flutter analyze
```

### Essential Files

- **Menu Items**: `/lib/data/menu_data.dart`
- **Theme/Colors**: `/lib/theme/app_theme.dart`
- **Receipt Format**: `/lib/services/printing_service.dart`

### Essential Shortcuts

- **New Order**: Click FAB (floating action button)
- **Switch Tabs**: Click on navigation rail
- **Add Item**: Click item card, adjust quantity
- **Complete Order**: Click "Complete & Print" button

---

## ✨ Success Indicators

Your event is running smoothly if:

- ✅ Orders are being created and completed quickly
- ✅ Receipts are printing correctly (2 copies each)
- ✅ Staff can navigate the app confidently
- ✅ Today's statistics are updating correctly
- ✅ No technical issues or crashes
- ✅ Customers are receiving clear, professional receipts
- ✅ Order history is capturing all transactions

---

## 🎉 Ready to Launch!

### Final Pre-Event Checks

- [ ] All items in "System Setup" completed
- [ ] All items in "Pre-Event Preparation" completed
- [ ] Staff trained and confident
- [ ] Test order completed successfully
- [ ] Printer producing quality receipts
- [ ] Backup plans in place
- [ ] Emergency contacts available

**When all boxes are checked, you're ready to start taking orders!**

---

## 📊 Post-Event Report Template

```
Event Name: _______________________
Date: _____________________________
Location: _________________________

STATISTICS:
- Total Sales: ₹_________
- Total Orders: _________
- Average Order: ₹_________
- Peak Hour: _________
- Staff Count: _________

PERFORMANCE:
- Orders Processed: _________
- Receipts Printed: _________
- System Uptime: _________%
- Issues Encountered: _________

NOTES:
_________________________________
_________________________________
_________________________________

IMPROVEMENTS NEEDED:
_________________________________
_________________________________
_________________________________

Prepared by: _____________________
Date: ___________________________
```

---

**Use this checklist before every event to ensure smooth operations!**

_Last Updated: October 11, 2025_
