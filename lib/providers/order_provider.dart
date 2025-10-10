import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/menu_item.dart';
import '../services/database_service.dart';

// Current orders state (for concurrent order management)
class OrdersNotifier extends StateNotifier<Map<String, Order>> {
  OrdersNotifier() : super({});

  // Create a new order
  String createNewOrder() {
    final orderNumber = DatabaseService.getNextOrderNumber();
    final orderId = orderNumber.toString();
    final newOrder = Order.create(
      orderId: orderId,
      items: [],
    );
    state = {...state, orderId: newOrder};
    return orderId;
  }

  // Add item to an order
  void addItem(
      String orderId, MenuItem menuItem, String servingSize, int quantity) {
    final order = state[orderId];
    if (order == null) return;

    final orderItem = OrderItem.fromMenuItem(menuItem, servingSize, quantity);

    // Check if item with same serving size already exists
    final existingItemIndex = order.items.indexWhere(
      (item) =>
          item.menuItemId == menuItem.id && item.servingSize == servingSize,
    );

    List<OrderItem> updatedItems;
    if (existingItemIndex != -1) {
      // Update quantity of existing item
      updatedItems = List.from(order.items);
      final existingItem = updatedItems[existingItemIndex];
      updatedItems[existingItemIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Add new item
      updatedItems = [...order.items, orderItem];
    }

    // Recalculate totals
    final updatedOrder = _recalculateOrder(order.copyWith(items: updatedItems));
    state = {...state, orderId: updatedOrder};
  }

  // Update item quantity
  void updateItemQuantity(String orderId, int itemIndex, int newQuantity) {
    final order = state[orderId];
    if (order == null || itemIndex >= order.items.length) return;

    if (newQuantity <= 0) {
      removeItem(orderId, itemIndex);
      return;
    }

    final updatedItems = List<OrderItem>.from(order.items);
    updatedItems[itemIndex] =
        updatedItems[itemIndex].copyWith(quantity: newQuantity);

    final updatedOrder = _recalculateOrder(order.copyWith(items: updatedItems));
    state = {...state, orderId: updatedOrder};
  }

  // Remove item from order
  void removeItem(String orderId, int itemIndex) {
    final order = state[orderId];
    if (order == null || itemIndex >= order.items.length) return;

    final updatedItems = List<OrderItem>.from(order.items)..removeAt(itemIndex);
    final updatedOrder = _recalculateOrder(order.copyWith(items: updatedItems));
    state = {...state, orderId: updatedOrder};
  }

  // Update customer name
  void updateCustomerName(String orderId, String? customerName) {
    final order = state[orderId];
    if (order == null) return;

    state = {...state, orderId: order.copyWith(customerName: customerName)};
  }

  // Update notes
  void updateNotes(String orderId, String? notes) {
    final order = state[orderId];
    if (order == null) return;

    state = {...state, orderId: order.copyWith(notes: notes)};
  }

  // Complete order and save to database
  Future<void> completeOrder(String orderId) async {
    final order = state[orderId];
    if (order == null || order.items.isEmpty) return;

    final completedOrder = order.copyWith(status: OrderStatus.completed);
    await DatabaseService.saveOrder(completedOrder);

    // Remove from current orders
    final newState = Map<String, Order>.from(state);
    newState.remove(orderId);
    state = newState;
  }

  // Cancel order
  void cancelOrder(String orderId) {
    final newState = Map<String, Order>.from(state);
    newState.remove(orderId);
    state = newState;
  }

  // Recalculate order totals
  Order _recalculateOrder(Order order) {
    double totalBase = 0;
    double totalGst = 0;
    double totalAmount = 0;

    for (final item in order.items) {
      totalBase += item.totalBasePrice;
      totalGst += item.totalGst;
      totalAmount += item.totalPrice;
    }

    return order.copyWith(
      totalAmount: totalAmount,
      totalBaseAmount: totalBase,
      totalGst: totalGst,
    );
  }
}

// Order history notifier
class OrderHistoryNotifier extends StateNotifier<List<Order>> {
  OrderHistoryNotifier() : super([]) {
    loadOrders();
  }

  void loadOrders() {
    state = DatabaseService.getRecentOrders(limit: 100);
  }

  void refresh() {
    loadOrders();
  }

  List<Order> searchOrders(String query) {
    if (query.isEmpty) return state;

    return state.where((order) {
      return order.orderId.toLowerCase().contains(query.toLowerCase()) ||
          (order.customerName?.toLowerCase().contains(query.toLowerCase()) ??
              false);
    }).toList();
  }

  Future<void> deleteOrder(String orderId) async {
    await DatabaseService.deleteOrder(orderId);
    loadOrders();
  }
}

// Providers
final ordersProvider =
    StateNotifierProvider<OrdersNotifier, Map<String, Order>>((ref) {
  return OrdersNotifier();
});

final orderHistoryProvider =
    StateNotifierProvider<OrderHistoryNotifier, List<Order>>((ref) {
  return OrderHistoryNotifier();
});

// Active order ID provider (for UI navigation)
final activeOrderIdProvider = StateProvider<String?>((ref) => null);

// Statistics providers
final todaysSalesProvider = Provider<double>((ref) {
  ref.watch(orderHistoryProvider); // Watch for changes
  return DatabaseService.getTodaysTotalSales();
});

final todaysOrderCountProvider = Provider<int>((ref) {
  ref.watch(orderHistoryProvider); // Watch for changes
  return DatabaseService.getTodaysOrderCount();
});
