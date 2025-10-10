# 📱 User Interface Guide - Visual Walkthrough

## 🎯 App Layout Overview

```
┌─────────────────────────────────────────────────────────────────┐
│  🔥 BIRYANI BY FLAME          [₹2,450] [12 orders today] [🛒 3] │
├───┬─────────────────────────────────────────────────────────────┤
│   │                                                               │
│ 📋│                     MENU SCREEN                              │
│ M │   [🍗 Non-Veg] [🥗 Veg] [🍽️ Starters] [➕ Extras]          │
│ E │                                                               │
│ N │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐                    │
│ U │  │ 🍗   │  │ 🍗   │  │ 🍗   │  │ 🍗   │                    │
│   │  │ Item │  │ Item │  │ Item │  │ Item │                    │
├───┤  │ ₹249 │  │ ₹259 │  │ ₹249 │  │ ₹249 │                    │
│   │  │[Add] │  │[Add] │  │[Add] │  │[Add] │                    │
│ 🛒│  └──────┘  └──────┘  └──────┘  └──────┘                    │
│ O │                                                               │
│ R │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐                    │
│ D │  │ 🥗   │  │ 🥗   │  │ 🥗   │  │ 🥗   │                    │
│ E │  │ Item │  │ Item │  │ Item │  │ Item │                    │
│ R │  │ ₹249 │  │ ₹239 │  │ ₹209 │  │ ₹249 │                    │
│ S │  │[Add] │  │[Add] │  │[Add] │  │[Add] │                    │
├───┤  └──────┘  └──────┘  └──────┘  └──────┘                    │
│   │                                                               │
│ 📜│                                            [➕ New Order]     │
│ H │                                                               │
│ I │                                                               │
│ S │                                                               │
│ T │                                                               │
│ O │                                                               │
│ R │                                                               │
│ Y │                                                               │
└───┴─────────────────────────────────────────────────────────────┘
```

---

## 🎨 Screen Breakdown

### 1. Header Bar (Always Visible)

```
┌─────────────────────────────────────────────────────────────────┐
│  🔥 BIRYANI BY FLAME          [₹2,450] [12 orders today] [🛒 3] │
└─────────────────────────────────────────────────────────────────┘
     Brand Name          Today's Sales  Order Count   Active Orders
```

**Elements:**

- 🔥 **Brand Icon** + Name (Gold on Black)
- 💰 **Today's Sales** (Real-time total)
- 📊 **Order Count** (Completed orders today)
- 🛒 **Active Orders Badge** (Red, shows concurrent order count)

---

### 2. Navigation Rail (Left Side)

```
┌───┐
│ 📋│  MENU
│ M │  (Menu browsing
│ E │   and selection)
│ N │
│ U │
├───┤
│ 🛒│  ORDERS
│ O │  (Active order
│ R │   management)
│ D │
│ E │
│ R │
│ S │
├───┤
│ 📜│  HISTORY
│ H │  (Past orders
│ I │   and search)
│ S │
│ T │
│ O │
│ R │
│ Y │
└───┘
```

**Interaction:**

- Click to switch screens
- Gold highlight on active section
- Icon + Label format

---

## 📋 Menu Screen Details

### Category Tabs

```
┌─────────────────────────────────────────────────────────────────┐
│  [🍗 Non-Veg]  [🥗 Veg]  [🍽️ Starters]  [➕ Extras]            │
└─────────────────────────────────────────────────────────────────┘
   Active: Gold background, Black text
   Inactive: Grey background, Dark grey text
```

### Menu Item Card

```
┌──────────────┐
│  🍗 NON-VEG  │ ← Category badge (colored)
│              │
│ Hyderabadi   │ ← Item name (bold)
│ Chicken Dum  │
│ Biryani with │
│ raita        │
│              │
│ Serves 1:    │ ← Pricing for both sizes
│ ₹249         │   (red, bold)
│ Serves 2:    │
│ ₹448         │
│              │
│  [Add to     │ ← Action button (gold)
│   Order]     │
└──────────────┘
```

### Add to Order Dialog

```
┌─────────────────────────────────────┐
│  Hyderabadi Chicken Dum Biryani     │
├─────────────────────────────────────┤
│                                     │
│  Select Order:                      │
│  [Order #ABC12345 ▼]                │
│                                     │
│  Serving Size:                      │
│  [Serves 1]  [Serves 2]             │
│     ✓                               │
│                                     │
│  Quantity:                          │
│  [➖]  [ 2 ]  [➕]                  │
│                                     │
│  ─────────────────────              │
│  Price:    ₹249 × 2                 │
│  Total:    ₹498                     │
│                                     │
│     [Cancel]  [Add to Order]        │
└─────────────────────────────────────┘
```

---

## 🛒 Orders Screen Details

### Multiple Order Tabs

```
┌─────────────────────────────────────────────────────────────────┐
│ [Order #ABC12 (5) ✕] [Order #DEF34 (3) ✕] [Order #GHI56 (2) ✕]│
└─────────────────────────────────────────────────────────────────┘
   Active tab (gold underline)
   Badge shows item count
   ✕ button to cancel order
```

### Order View Layout

```
┌─────────────────────────────────┬─────────────────────────────┐
│  ITEMS LIST                     │  ORDER SUMMARY              │
│                                 │                             │
│  ┌───────────────────────────┐ │  Order #ABC12345            │
│  │ Hyderabadi Chicken        │ │  10:30 AM                   │
│  │ Serves 1                  │ │                             │
│  │ ₹249 each                 │ │  Customer Name:             │
│  │                           │ │  [____________]             │
│  │  [➖] [ 2 ] [➕]    ₹498  │ │                             │
│  │                     [🗑️]  │ │  Notes:                     │
│  └───────────────────────────┘ │  [____________]             │
│                                 │  [____________]             │
│  ┌───────────────────────────┐ │                             │
│  │ Chicken 65                │ │  ─────────────────          │
│  │ Single                    │ │  ORDER SUMMARY              │
│  │ ₹209 each                 │ │                             │
│  │                           │ │  Items:         5           │
│  │  [➖] [ 1 ] [➕]    ₹209  │ │  Subtotal:   ₹672.86        │
│  │                     [🗑️]  │ │  GST (5%):    ₹33.64        │
│  └───────────────────────────┘ │  ─────────────────          │
│                                 │  TOTAL:      ₹706.50        │
│                                 │                             │
│                                 │  [🖨️ Complete & Print]     │
│                                 │  [👁️ Preview Receipt]      │
│                                 │  [❌ Cancel Order]          │
└─────────────────────────────────┴─────────────────────────────┘
```

### Empty Order State

```
┌─────────────────────────────────────────┐
│                                         │
│           🛒                            │
│       (large icon)                      │
│                                         │
│      No items in this order             │
│      Add items from the menu            │
│                                         │
└─────────────────────────────────────────┘
```

---

## 📜 History Screen Details

### Search Bar

```
┌─────────────────────────────────────────────────────────────────┐
│  [🔍 Search by order ID or customer name...        ✕]  [🔄]     │
└─────────────────────────────────────────────────────────────────┘
      Search input field                         Clear  Refresh
```

### Order History Card (Collapsed)

```
┌─────────────────────────────────────────────────────────────────┐
│  ✅  Order #ABC12345  [COMPLETED]                      ₹706.50  │
│      15/10/2024 10:30                                 5 items   │
│      Customer: John Doe                                    [⋮]  │
└─────────────────────────────────────────────────────────────────┘
   Status   Order ID      Badge        Date/Time   Total    Menu
   Icon                              Customer Name  Price
```

### Order History Card (Expanded)

```
┌─────────────────────────────────────────────────────────────────┐
│  ✅  Order #ABC12345  [COMPLETED]                      ₹706.50  │
│      15/10/2024 10:30                                 5 items   │
│      Customer: John Doe                                    [⋮]  │
├─────────────────────────────────────────────────────────────────┤
│  Order Items:                                                   │
│                                                                 │
│  Hyderabadi Chicken Dum Biryani                                │
│  Serves 1 × 2                                          ₹498.00  │
│                                                                 │
│  Chicken 65                                                     │
│  Single × 1                                            ₹209.00  │
│                                                                 │
│  ─────────────────────────────────────────────────────          │
│  Subtotal:                                             ₹672.86  │
│  GST (5%):                                              ₹33.64  │
│  ─────────────────────────────────────────────────────          │
│  Total:                                                ₹706.50  │
│                                                                 │
│  Notes: Extra spicy                                             │
└─────────────────────────────────────────────────────────────────┘
```

### Context Menu

```
┌──────────────────┐
│ 🖨️ Reprint Receipt │
│ 📤 Share PDF       │
│ 🗑️ Delete          │
└──────────────────┘
```

---

## 🧾 Thermal Receipt Layout

```
        BIRYANI BY FLAME
    🔥 Flame-Cooked Perfection 🔥

─────────────────────────────────

    --- CUSTOMER COPY ---

Order ID: ABC12345
Date: 15/10/2024 10:30
Customer: John Doe

─────────────────────────────────

Item                    Qty  Amount
─────────────────────────────────

Hyderabadi Chicken
Dum Biryani with raita
Serves 1                 2  ₹498.00

Chicken 65
Single                   1  ₹209.00

─────────────────────────────────
Subtotal:                  ₹672.86
GST (5%):                   ₹33.64
─────────────────────────────────
TOTAL:                     ₹706.50
─────────────────────────────────

    Thank you for your order!
         Visit us again!

Notes: Extra spicy

  All prices are inclusive of GST
```

---

## 🎨 Color Scheme Guide

### Primary Colors

```
┌──────────┐  ┌──────────┐  ┌──────────┐
│  BLACK   │  │   GOLD   │  │   RED    │
│ #1A1A1A  │  │ #D4AF37  │  │ #DC143C  │
└──────────┘  └──────────┘  └──────────┘
  Headers      Buttons       Prices
  Sidebar      Selected      Alerts
  Text         Highlights    Actions
```

### Usage Examples

**Black (#1A1A1A):**

- App header background
- Navigation rail
- Primary text
- Order IDs

**Gold (#D4AF37):**

- Active tabs
- Primary buttons
- Selected items
- Brand accents
- Icon highlights

**Red (#DC143C):**

- Price displays
- Active order badge
- Action buttons
- Category badges (Non-Veg)

---

## 📱 Responsive Breakpoints

### Desktop (> 1200px)

- 3-column menu grid
- Full sidebar navigation
- Side-by-side order view

### Tablet (768px - 1200px)

- 2-column menu grid
- Compact sidebar
- Adjusted spacing

### Mobile (< 768px)

- Not optimized (Web app for desktop/tablet use)
- Recommend tablet minimum

---

## ⌨️ Keyboard Navigation

```
TAB         - Navigate between fields
ENTER       - Confirm/Submit
ESC         - Cancel/Close
SPACE       - Select/Toggle
↑↓          - Scroll lists
```

---

## 🔔 Notification Patterns

### Success (Green)

```
┌────────────────────────────────┐
│ ✅ Added Chicken Biryani to    │
│    order                        │
└────────────────────────────────┘
```

### Error (Red)

```
┌────────────────────────────────┐
│ ❌ Error printing: No printer   │
│    found                        │
└────────────────────────────────┘
```

### Info (Gold)

```
┌────────────────────────────────┐
│ ℹ️ Order deleted                │
└────────────────────────────────┘
```

---

## 🎯 User Flow Examples

### Flow 1: Quick Order

```
Menu Screen → Click "New Order" → Select Items →
Add to Order → Switch to Orders Tab →
Enter Customer Name → Complete & Print →
Receipt Printed (2 copies)
```

### Flow 2: Multiple Orders

```
Menu Screen → Create Order 1 → Add Items →
Create Order 2 → Add Items → Create Order 3 →
Add Items → Switch between tabs →
Complete each when ready
```

### Flow 3: Order History Search

```
History Tab → Type Order ID → View Details →
Click Reprint → Receipt Reprints
```

---

## 💡 Visual Cues

### Item Status

- ✅ **Green**: Completed
- 🟠 **Orange**: Pending
- ❌ **Red**: Cancelled

### Interactive Elements

- 🖱️ **Hover**: Slight elevation
- 👆 **Click**: Gold highlight
- 🔄 **Loading**: Spinner

### Required Fields

- **Bold label**: Required
- _Italic label_: Optional

---

## 📊 Dashboard Stats Display

```
┌─────────────────────────────────────┐
│         TODAY'S STATISTICS          │
├─────────────────────────────────────┤
│  💰 Total Sales:    ₹12,450         │
│  📦 Orders:         42              │
│  ⏱️ Avg Order:     ₹296             │
│  🛒 Active:        3                │
└─────────────────────────────────────┘
```

---

**This visual guide helps staff quickly understand the interface layout and navigation patterns!**

---

_Last Updated: October 11, 2025_
