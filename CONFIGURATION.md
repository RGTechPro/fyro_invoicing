# ⚙️ Configuration & Customization Guide

This guide shows you how to customize the Biryani By Flame app for your specific needs.

## 🍽️ Changing Menu Items

**File**: `/lib/data/menu_data.dart`

### Adding a New Item

```dart
MenuItem(
  id: 'nv_special_biryani',           // Unique ID
  name: 'Special Chicken Biryani',     // Display name
  category: MenuCategory.nonVeg,       // Category
  prices: {
    'serves1': 299.0,                  // GST-inclusive price
    'serves2': 548.0,                  // GST-inclusive price
  },
  description: 'Our special recipe',   // Optional description
),
```

### Changing Prices

Find the item and update the prices:

```dart
prices: {
  'serves1': 249.0,  // Change to new price
  'serves2': 448.0,  // Change to new price
},
```

**Remember**: Prices should be **GST-inclusive** (5% GST already included)

### Removing an Item

Simply delete or comment out the entire MenuItem block:

```dart
// MenuItem(
//   id: 'item_to_remove',
//   ...
// ),
```

### Adding a New Category

1. Edit `/lib/models/menu_item.dart`:

```dart
enum MenuCategory {
  nonVeg,
  veg,
  starters,
  extras,
  beverages,  // Add new category
}
```

2. Update category display in `/lib/screens/menu_screen.dart`:

```dart
String _getCategoryName(MenuCategory category) {
  switch (category) {
    // ... existing cases
    case MenuCategory.beverages:
      return '🥤 Beverages';
  }
}
```

## 🎨 Changing Brand Colors

**File**: `/lib/theme/app_theme.dart`

### Primary Colors

```dart
static const Color primaryBlack = Color(0xFF1A1A1A);    // Main color
static const Color secondaryGold = Color(0xFFD4AF37);   // Accent color
static const Color accentRed = Color(0xFFDC143C);       // Highlight color
```

### Change Theme

Replace color hex codes:

```dart
static const Color primaryBlack = Color(0xFF2C3E50);    // New dark blue
static const Color secondaryGold = Color(0xFFF39C12);   // New orange
static const Color accentRed = Color(0xFFE74C3C);       // Keep red
```

## 🖨️ Customizing Receipt Layout

**File**: `/lib/services/printing_service.dart`

### Change Brand Name

```dart
pw.Text(
  'YOUR BRAND NAME',  // Change this
  style: pw.TextStyle(
    fontSize: 18,
    fontWeight: pw.FontWeight.bold,
  ),
),
```

### Add Logo

```dart
// After brand name, add:
pw.Container(
  height: 60,
  child: pw.Image(
    pw.MemoryImage(yourLogoBytes),
  ),
),
```

### Change Receipt Size

```dart
// For 3-inch paper:
format: PdfPageFormat(
  80 * PdfPageFormat.mm,  // Width
  double.infinity,         // Auto height
  marginAll: 8,
)
```

### Add Footer Information

```dart
// Before the closing brackets, add:
pw.SizedBox(height: 8),
pw.Center(
  child: pw.Text(
    'Your Address Line 1',
    style: const pw.TextStyle(fontSize: 8),
  ),
),
pw.Center(
  child: pw.Text(
    'Phone: +91-XXXXXXXXXX',
    style: const pw.TextStyle(fontSize: 8),
  ),
),
```

## 💾 Database Configuration

**File**: `/lib/services/database_service.dart`

### Change Storage Location

```dart
// In init() method:
await Hive.initFlutter('custom_folder_name');
```

### Export Data Function

Add this method to DatabaseService:

```dart
static Future<List<Map<String, dynamic>>> exportAllOrders() async {
  final orders = getAllOrders();
  return orders.map((order) => {
    'orderId': order.orderId,
    'total': order.totalAmount,
    'items': order.items.length,
    'date': order.createdAt.toIso8601String(),
  }).toList();
}
```

## 🔢 Changing GST Rate

If GST rate changes from 5%:

### 1. Update Models

**File**: `/lib/models/menu_item.dart`

```dart
// Change GST rate constant
static const double GST_RATE = 0.05;  // Change to new rate (e.g., 0.12 for 12%)

double getBasePrice(String servingSize) {
  final inclusivePrice = getPrice(servingSize);
  return inclusivePrice / (1 + GST_RATE);  // Updated calculation
}

double getGstAmount(String servingSize) {
  final basePrice = getBasePrice(servingSize);
  return basePrice * GST_RATE;
}
```

### 2. Update Receipt Display

**File**: `/lib/services/printing_service.dart`

```dart
pw.Row(
  children: [
    pw.Text('GST (12%):', ...),  // Update percentage display
    // ...
  ],
)
```

## 🆔 Customizing Order ID Format

**File**: `/lib/providers/order_provider.dart`

### Change Length

```dart
final orderId = const Uuid().v4().substring(0, 10).toUpperCase();  // 10 chars
```

### Add Prefix

```dart
final orderId = 'BBF-' + const Uuid().v4().substring(0, 6).toUpperCase();
// Result: BBF-A1B2C3
```

### Sequential Numbers

```dart
// Add counter to OrdersNotifier class
int _orderCounter = 1;

String createNewOrder() {
  final orderId = 'ORD${_orderCounter.toString().padLeft(4, '0')}';
  _orderCounter++;
  // Result: ORD0001, ORD0002, etc.
  // ...
}
```

## 📱 UI Customizations

### Change Grid Columns

**File**: `/lib/screens/menu_screen.dart`

```dart
SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 4,  // Change from 3 to 4 columns
  // ...
)
```

### Modify Card Appearance

```dart
Card(
  elevation: 5,           // Increase shadow
  color: Colors.white,    // Change background
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),  // More rounded
  ),
  // ...
)
```

### Change Navigation Position

**File**: `/lib/screens/home_screen.dart`

```dart
// Change from NavigationRail to BottomNavigationBar
// Replace NavigationRail with:
bottomNavigationBar: NavigationBar(
  selectedIndex: _selectedIndex,
  onDestinationSelected: (index) {
    setState(() => _selectedIndex = index);
  },
  destinations: const [
    NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
    NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Orders'),
    NavigationDestination(icon: Icon(Icons.history), label: 'History'),
  ],
)
```

## 🌐 Localization (Language Support)

### Add Hindi Support

**File**: Create `/lib/l10n/app_hi.dart`

```dart
const Map<String, String> hindiStrings = {
  'menu': 'मेन्यू',
  'orders': 'आर्डर',
  'history': 'इतिहास',
  'new_order': 'नया आर्डर',
  // Add more translations
};
```

## 🔐 Adding Simple Password Protection

**File**: Create `/lib/screens/login_screen.dart`

```dart
class LoginScreen extends StatefulWidget {
  // Add simple PIN entry
  // On success, navigate to HomeScreen
}
```

Update main.dart:

```dart
home: const LoginScreen(),  // Instead of HomeScreen
```

## 📊 Adding Sales Reports

**File**: Create `/lib/screens/reports_screen.dart`

```dart
class ReportsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaysSales = ref.watch(todaysSalesProvider);
    // Display charts, totals, item-wise breakdown
  }
}
```

Add to navigation:

```dart
NavigationRailDestination(
  icon: Icon(Icons.analytics),
  label: Text('Reports'),
),
```

## 🎯 Performance Optimizations

### Limit History Items

**File**: `/lib/services/database_service.dart`

```dart
static List<Order> getRecentOrders({int limit = 100}) {  // Reduce from 100
  // ...
}
```

### Add Pagination to History

```dart
// Add to HistoryScreen
int _page = 0;
static const _pageSize = 20;

List<Order> get displayedOrders {
  final start = _page * _pageSize;
  return filteredOrders.skip(start).take(_pageSize).toList();
}
```

## 🧪 Testing Changes

After making changes:

1. **Hot Reload**: Press `r` in terminal (for UI changes)
2. **Hot Restart**: Press `R` in terminal (for logic changes)
3. **Full Rebuild**:

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

## 📝 Best Practices

✅ **Always backup** before making changes
✅ **Test thoroughly** after modifications
✅ **Keep GST calculations** consistent
✅ **Update documentation** for your changes
✅ **Version control** your customizations

## 🆘 Reverting Changes

If something breaks:

```bash
# Discard all changes
git checkout .

# Or restore specific file
git checkout -- lib/data/menu_data.dart
```

## 📞 Need Help?

For complex customizations:

1. Check Flutter documentation: https://flutter.dev/docs
2. Check Riverpod docs: https://riverpod.dev
3. Search Stack Overflow
4. Contact the development team

---

**Happy Customizing! 🛠️**
