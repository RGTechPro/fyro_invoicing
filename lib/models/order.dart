import 'order_item.dart';

enum OrderStatus {
  pending,
  completed,
  cancelled,
}

class Order {
  final String orderId;

  final List<OrderItem> items;

  final DateTime createdAt;

  final OrderStatus status;

  final double totalAmount; // GST inclusive

  final double totalBaseAmount; // Excluding GST

  final double totalGst;

  final String? customerName;

  final String? notes;

  Order({
    required this.orderId,
    required this.items,
    required this.createdAt,
    required this.status,
    required this.totalAmount,
    required this.totalBaseAmount,
    required this.totalGst,
    this.customerName,
    this.notes,
  });

  factory Order.create({
    required String orderId,
    required List<OrderItem> items,
    String? customerName,
    String? notes,
  }) {
    double totalBase = 0;
    double totalGst = 0;
    double totalAmount = 0;

    for (final item in items) {
      totalBase += item.totalBasePrice;
      totalGst += item.totalGst;
      totalAmount += item.totalPrice;
    }

    return Order(
      orderId: orderId,
      items: items,
      createdAt: DateTime.now(),
      status: OrderStatus.pending,
      totalAmount: totalAmount,
      totalBaseAmount: totalBase,
      totalGst: totalGst,
      customerName: customerName,
      notes: notes,
    );
  }

  Order copyWith({
    String? orderId,
    List<OrderItem>? items,
    DateTime? createdAt,
    OrderStatus? status,
    double? totalAmount,
    double? totalBaseAmount,
    double? totalGst,
    String? customerName,
    String? notes,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      totalBaseAmount: totalBaseAmount ?? this.totalBaseAmount,
      totalGst: totalGst ?? this.totalGst,
      customerName: customerName ?? this.customerName,
      notes: notes ?? this.notes,
    );
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  String getStatusDisplay() {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
