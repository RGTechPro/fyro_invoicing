# 🚀 Quick Start Guide - Biryani By Flame

## Immediate Setup (5 minutes)

### Step 1: Run the App

Open a terminal and run:

```bash
flutter run -d chrome
```

The app will automatically:

- Initialize the local database
- Load the complete menu
- Open in your default browser

### Step 2: Create Your First Order

1. You'll see the **Menu** screen with 4 categories
2. Click the **"New Order"** floating button (bottom right)
3. Browse and click on any item (e.g., "Hyderabadi Chicken Dum Biryani")
4. Select serving size (Serves 1 or Serves 2)
5. Choose quantity
6. Click **"Add to Order"**

### Step 3: Complete the Order

1. Click on the **Orders** tab (second icon in sidebar)
2. Review your order
3. Add customer name (optional)
4. Click **"Complete & Print"**
5. Choose to print or preview the receipt

### Step 4: View History

1. Click on the **History** tab (third icon in sidebar)
2. See your completed order
3. Click to expand and view details
4. Options to reprint or export as PDF

## 🎯 Key Features at a Glance

### Menu Screen

- **4 Categories**: Non-Veg, Veg, Starters, Extras
- **Grid Layout**: Easy visual browsing
- **Price Display**: Shows both serving sizes
- **Quick Add**: One-click to add items

### Orders Screen

- **Multiple Tabs**: Handle 5+ concurrent orders
- **Live Totals**: Real-time GST calculation
- **Quantity Controls**: Easy +/- buttons
- **Customer Info**: Optional name and notes

### History Screen

- **Search**: Find by Order ID or customer name
- **Expandable Cards**: Click to see details
- **Actions**: Reprint, Share PDF, Delete
- **Today's Stats**: Shows in header

## 🖨️ Printer Setup

### For Everycom Thermal Printers

1. Connect printer via **USB** or **Bluetooth**
2. Ensure printer is **ON** with paper loaded
3. In the app, click **"Complete & Print"**
4. Receipt automatically prints 2 copies

### Testing Without Printer

1. Click **"Preview Receipt"** instead
2. View the thermal receipt layout
3. Can save as PDF or print to regular printer

## 📊 Understanding GST

All menu prices are **GST-inclusive**:

```
Example: ₹249 Biryani
- Base Price: ₹237.14
- GST (5%): ₹11.86
- Total: ₹249.00
```

The app automatically:

- ✅ Calculates base price (divides by 1.05)
- ✅ Shows GST amount separately
- ✅ Displays GST-inclusive total
- ✅ Prints compliant receipts

## 🎨 Brand Theme

The app uses **Biryani By Flame** colors:

- **Black** (#1A1A1A) - Primary
- **Gold** (#D4AF37) - Accent
- **Red** (#DC143C) - Highlights

You'll see these colors throughout:

- AppBar (Black with Gold text)
- Buttons (Gold primary, Red for actions)
- Price tags (Red for totals)

## ⚡ Power User Tips

### Creating Multiple Orders Quickly

1. Click **"New Order"** multiple times
2. Each gets a unique ID
3. Switch between tabs at the top
4. Add items to any order from menu

### Searching History

- Type Order ID: `"ABC12345"`
- Type customer name: `"John"`
- Clear search with ✖️ button

### Keyboard Shortcuts

- **Tab**: Switch between fields
- **Enter**: Confirm dialogs
- **Esc**: Cancel dialogs

## 🔄 Daily Operations

### Starting Your Event

1. Open the app in Chrome (full screen)
2. Position on your main screen
3. Connect thermal printer
4. Click **"New Order"** to begin

### During Rush Hours

1. Create multiple orders (one per customer)
2. Use tabs to switch between them
3. Staff can see all active orders
4. Complete orders as ready

### End of Day

1. Review **History** tab
2. Check **Today's Statistics** in header
3. Export important orders as PDF
4. All data saved automatically

## ❓ Common Questions

**Q: Can I modify the menu?**
A: Yes! Edit `/lib/data/menu_data.dart`

**Q: Does it work offline?**
A: Yes! Fully offline after initial load

**Q: Can I add more categories?**
A: Yes! Edit the `MenuCategory` enum

**Q: How do I backup orders?**
A: Use browser's export feature or share PDFs

**Q: Printer not working?**
A: Try "Preview Receipt" first to test PDF generation

## 🆘 Quick Troubleshooting

**App won't start?**

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

**Printer issues?**

1. Check USB/Bluetooth connection
2. Verify printer has paper
3. Try print preview
4. Test with regular printer

**Order not saving?**

- Check browser console (F12)
- Refresh the page
- Clear browser cache if needed

## 📱 Best Practices

✅ **DO:**

- Create new order for each customer
- Review totals before completing
- Add customer names for tracking
- Keep printer stocked with paper

❌ **DON'T:**

- Mix multiple customers in one order
- Delete orders unless absolutely needed
- Close browser during active orders
- Ignore GST calculations

## 🎉 You're Ready!

The app is now running and ready for your event. Start with a test order to familiarize yourself with the workflow.

For detailed documentation, see `BIRYANI_README.md`.

---

**Need help?** Check the full README or contact support.

**Happy Selling! 🔥🍛**
