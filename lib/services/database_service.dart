import 'package:hive_flutter/hive_flutter.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/menu_item.dart';

class DatabaseService {
  static const String _ordersBoxName = 'orders';
  static const String _counterBoxName = 'counters';
  static Box<Order>? _ordersBox;
  static Box? _counterBox;

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MenuItemAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(OrderItemAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(OrderAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(OrderStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(MenuCategoryAdapter());
    }

    // Open boxes
    _ordersBox = await Hive.openBox<Order>(_ordersBoxName);
    _counterBox = await Hive.openBox(_counterBoxName);
  }

  // Get next order number
  static int getNextOrderNumber() {
    final currentNumber = _counterBox?.get('lastOrderNumber', defaultValue: 0) as int;
    final nextNumber = currentNumber + 1;
    _counterBox?.put('lastOrderNumber', nextNumber);
    return nextNumber;
  }

  // Reset order counter (use with caution - typically only for new day or testing)
  static Future<void> resetOrderCounter() async {
    await _counterBox?.put('lastOrderNumber', 0);
  }

  // Get current order number without incrementing
  static int getCurrentOrderNumber() {
    return _counterBox?.get('lastOrderNumber', defaultValue: 0) as int;
  }

  // Save an order
  static Future<void> saveOrder(Order order) async {
    await _ordersBox?.put(order.orderId, order);
  }

  // Get order by ID
  static Order? getOrder(String orderId) {
    return _ordersBox?.get(orderId);
  }

  // Get all orders
  static List<Order> getAllOrders() {
    return _ordersBox?.values.toList() ?? [];
  }

  // Get orders by status
  static List<Order> getOrdersByStatus(OrderStatus status) {
    final allOrders = getAllOrders();
    return allOrders.where((order) => order.status == status).toList();
  }

  // Get recent orders (last n orders)
  static List<Order> getRecentOrders({int limit = 50}) {
    final allOrders = getAllOrders();
    allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allOrders.take(limit).toList();
  }

  // Get orders by date range
  static List<Order> getOrdersByDateRange(DateTime start, DateTime end) {
    final allOrders = getAllOrders();
    return allOrders.where((order) {
      return order.createdAt.isAfter(start) && order.createdAt.isBefore(end);
    }).toList();
  }

  // Get today's orders
  static List<Order> getTodaysOrders() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getOrdersByDateRange(startOfDay, endOfDay);
  }

  // Update order
  static Future<void> updateOrder(Order order) async {
    await _ordersBox?.put(order.orderId, order);
  }

  // Delete order
  static Future<void> deleteOrder(String orderId) async {
    await _ordersBox?.delete(orderId);
  }

  // Get total sales for today
  static double getTodaysTotalSales() {
    final todaysOrders = getTodaysOrders();
    return todaysOrders.fold(
      0.0,
      (sum, order) =>
          sum + (order.status == OrderStatus.completed ? order.totalAmount : 0),
    );
  }

  // Get total number of orders for today
  static int getTodaysOrderCount() {
    return getTodaysOrders()
        .where((order) => order.status == OrderStatus.completed)
        .length;
  }

  // Clear all data (use with caution)
  static Future<void> clearAllOrders() async {
    await _ordersBox?.clear();
  }

  // Close database
  static Future<void> close() async {
    await _ordersBox?.close();
  }
}

// Adapter for MenuCategory enum
class MenuCategoryAdapter extends TypeAdapter<MenuCategory> {
  @override
  final int typeId = 4;

  @override
  MenuCategory read(BinaryReader reader) {
    final index = reader.readByte();
    return MenuCategory.values[index];
  }

  @override
  void write(BinaryWriter writer, MenuCategory obj) {
    writer.writeByte(obj.index);
  }
}

// Adapter for MenuItem (since it's not generated)
class MenuItemAdapter extends TypeAdapter<dynamic> {
  @override
  final int typeId = 0;

  @override
  dynamic read(BinaryReader reader) {
    // This is a placeholder - we won't store MenuItem in Hive directly
    return null;
  }

  @override
  void write(BinaryWriter writer, dynamic obj) {
    // This is a placeholder
  }
}

// Adapter for OrderStatus enum
class OrderStatusAdapter extends TypeAdapter<OrderStatus> {
  @override
  final int typeId = 3;

  @override
  OrderStatus read(BinaryReader reader) {
    final index = reader.readByte();
    return OrderStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, OrderStatus obj) {
    writer.writeByte(obj.index);
  }
}

// Note: OrderItemAdapter and OrderAdapter will be generated by build_runner
class OrderItemAdapter extends TypeAdapter<OrderItem> {
  @override
  final int typeId = 1;

  @override
  OrderItem read(BinaryReader reader) {
    return OrderItem(
      menuItemId: reader.readString(),
      menuItemName: reader.readString(),
      servingSize: reader.readString(),
      quantity: reader.readInt(),
      pricePerItem: reader.readDouble(),
      basePrice: reader.readDouble(),
      gstAmount: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, OrderItem obj) {
    writer.writeString(obj.menuItemId);
    writer.writeString(obj.menuItemName);
    writer.writeString(obj.servingSize);
    writer.writeInt(obj.quantity);
    writer.writeDouble(obj.pricePerItem);
    writer.writeDouble(obj.basePrice);
    writer.writeDouble(obj.gstAmount);
  }
}

class OrderAdapter extends TypeAdapter<Order> {
  @override
  final int typeId = 2;

  @override
  Order read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };

    return Order(
      orderId: fields[0] as String,
      items: (fields[1] as List).cast<OrderItem>(),
      createdAt: fields[2] as DateTime,
      status: fields[3] as OrderStatus,
      totalAmount: fields[4] as double,
      totalBaseAmount: fields[5] as double,
      totalGst: fields[6] as double,
      customerName: fields[7] as String?,
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Order obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.orderId)
      ..writeByte(1)
      ..write(obj.items)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.totalAmount)
      ..writeByte(5)
      ..write(obj.totalBaseAmount)
      ..writeByte(6)
      ..write(obj.totalGst)
      ..writeByte(7)
      ..write(obj.customerName)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
