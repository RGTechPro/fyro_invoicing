# 🔥 Biryani By Flame - Event Ordering System

A powerful Flutter web application designed for **Biryani By Flame** to efficiently manage food orders during events with integrated thermal printing support.

## ✨ Features

### 📋 Order Management

- **Concurrent Orders**: Handle multiple orders simultaneously with tabbed interface
- **Real-time Order Tracking**: Track order status and items in real-time
- **Unique Order IDs**: Auto-generated 8-character order IDs for easy tracking
- **Customer Information**: Optional customer name and order notes

### 🍽️ Menu System

- **Fixed Menu**: Pre-configured menu with GST-inclusive prices (5%)
- **Categories**: Non-Veg, Veg, Starters, and Extras
- **Serving Sizes**: Support for Serves 1, Serves 2, and single items
- **Easy Selection**: Visual menu cards with quick add-to-order functionality

### 🧾 Invoice & Printing

- **Thermal Receipt Printing**: 2-inch (80mm) thermal format optimized for Everycom printers
- **Dual Copies**: Automatically prints customer and store copies
- **GST Breakdown**: Clear display of base price, GST amount, and total
- **Reverse GST Calculation**: Proper GST calculation from inclusive prices
- **Print Preview**: Preview receipts before printing
- **PDF Export**: Share receipts as PDF

### 💾 Data Persistence

- **Local Database**: Hive-based local storage for offline capability
- **Order History**: Complete history of all orders with search functionality
- **Compliance**: All orders saved locally for record-keeping
- **Today's Statistics**: Real-time display of today's sales and order count

### 🎨 User Interface

- **Brand Colors**: Black, Gold, and Red theme matching Biryani By Flame identity
- **Responsive Design**: Optimized for desktop/tablet browsers
- **Navigation Rail**: Easy switching between Menu, Orders, and History
- **Real-time Updates**: Instant UI updates using Riverpod state management

## 📦 Tech Stack

- **Framework**: Flutter Web
- **State Management**: flutter_riverpod
- **Database**: Hive (local NoSQL database)
- **Printing**: printing & pdf packages (Everycom thermal printer compatible)
- **Unique IDs**: uuid package
- **Date/Time**: intl package

## 🍛 Menu Items

### Non-Veg Biryani

1. Hyderabadi Chicken Dum Biryani with raita — ₹249 (Serves 1) / ₹448 (Serves 2)
2. Kolkata Chicken Dum Biryani with raita — ₹259 (Serves 1) / ₹458 (Serves 2)
3. Chicken 65 Biryani with raita — ₹249 (Serves 1) / ₹448 (Serves 2)
4. Boneless Hyderabadi Chicken Dum Biryani with raita — ₹249 (Serves 1) / ₹448 (Serves 2)

### Veg Biryani

1. Paneer 65 Biryani with raita — ₹249 (Serves 1) / ₹448 (Serves 2)
2. Hyderabadi Paneer Dum Biryani with raita — ₹249 (Serves 1) / ₹448 (Serves 2)
3. Mushroom 65 Biryani with raita — ₹239 (Serves 1) / ₹438 (Serves 2)
4. Aloo 65 Biryani with raita — ₹209 (Serves 1) / ₹408 (Serves 2)

### Starters

1. Paneer 65 — ₹179
2. Chicken 65 — ₹209
3. Aloo 65 — ₹129
4. Mushroom 65 — ₹179
5. Soyabean 65 — ₹169

### Extras

1. Gulab Jamun — ₹49
2. Extra Raita — ₹25
3. Onion — ₹10

_All prices are inclusive of 5% GST_

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- A web browser (Chrome, Edge, Safari, or Firefox)
- Everycom thermal printer (optional, for printing)

### Installation

1. **Clone the repository** (or ensure you're in the project directory)

```bash
cd /Users/rishabhgupta/projects/fyro_invoicing
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run the application**

```bash
flutter run -d chrome
```

Or for production build:

```bash
flutter build web
```

## 📱 Usage Guide

### Creating an Order

1. Click the **"New Order"** FAB on the Menu screen
2. Browse menu categories (Non-Veg, Veg, Starters, Extras)
3. Click on items to add them to the order
4. Select serving size and quantity
5. Choose which order to add to (if multiple orders are open)

### Managing Orders

1. Switch to the **Orders** tab
2. Use tabs to navigate between multiple concurrent orders
3. Adjust item quantities using +/- buttons
4. Add customer name and notes (optional)
5. View real-time GST calculation and total

### Completing Orders

1. Review order details
2. Click **"Complete & Print"**
3. Confirm to print 2 thermal receipts (customer + store copy)
4. Order is saved to history

### Viewing History

1. Switch to the **History** tab
2. Search orders by ID or customer name
3. Click on orders to view details
4. Options to reprint, share PDF, or delete

### Printer Setup

- Connect Everycom thermal printer via USB or Bluetooth
- The app uses standard 2-inch (80mm) thermal format
- Receipts automatically print in duplicate

## 🔧 Configuration

### Changing Menu Items

Edit `/lib/data/menu_data.dart` to modify menu items and prices.

### Customizing Theme

Edit `/lib/theme/app_theme.dart` to change colors and styling.

### Receipt Layout

Modify `/lib/services/printing_service.dart` to customize receipt format.

## 📊 GST Calculation

The app correctly handles GST-inclusive pricing:

- **Menu prices are inclusive of 5% GST**
- **Base Price** = Menu Price / 1.05
- **GST Amount** = Base Price × 0.05
- **Total** = Menu Price (already GST-inclusive)

Example:

- Menu Price: ₹249.00
- Base Price: ₹237.14
- GST (5%): ₹11.86
- Total: ₹249.00

## 🗄️ Data Storage

All order data is stored locally using Hive database:

- **Location**: Browser's local storage (IndexedDB)
- **Persistence**: Data persists across sessions
- **Privacy**: All data stays on the local device
- **Backup**: Export orders via PDF sharing

## 🖨️ Printing Details

### Thermal Receipt Format

- **Width**: 80mm (2 inches)
- **Copies**: 2 (Customer + Store)
- **Content**:
  - Brand name and logo
  - Order ID and timestamp
  - Customer name (if provided)
  - Itemized list with quantities
  - Subtotal, GST, and total
  - Notes (if any)
  - Thank you message

### Printer Compatibility

Optimized for **Everycom thermal printers**, but compatible with most ESC/POS thermal printers.

## 🎯 Key Benefits

✅ **Fast Order Processing**: Quick menu selection and checkout
✅ **No Internet Required**: Fully offline-capable
✅ **GST Compliant**: Proper GST calculation and invoice printing
✅ **Multi-Order Support**: Handle rush hours with concurrent orders
✅ **Professional Receipts**: Brand-consistent thermal prints
✅ **Order History**: Complete record of all transactions
✅ **User-Friendly**: Intuitive interface for event staff

## 🛠️ Troubleshooting

### Printer Not Working

- Ensure printer is connected via USB or Bluetooth
- Check printer is turned on and has paper
- Try print preview first to test PDF generation
- Verify printer drivers are installed

### Database Issues

- Clear browser cache if data appears corrupted
- Use browser's developer tools to inspect IndexedDB

### Performance Issues

- Close unused order tabs
- Clear old orders from history periodically

## 📄 License

This project is proprietary software for Biryani By Flame.

## 🤝 Support

For issues or questions, contact the development team.

---

**Built with ❤️ for Biryani By Flame 🔥**
