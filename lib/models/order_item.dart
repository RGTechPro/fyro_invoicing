import 'menu_item.dart';

class OrderItem {
  final String menuItemId;

  final String menuItemName;

  final String servingSize;

  final int quantity;

  final double pricePerItem; // GST inclusive

  final double basePrice; // Excluding GST

  final double gstAmount;

  OrderItem({
    required this.menuItemId,
    required this.menuItemName,
    required this.servingSize,
    required this.quantity,
    required this.pricePerItem,
    required this.basePrice,
    required this.gstAmount,
  });

  factory OrderItem.fromMenuItem(
    MenuItem menuItem,
    String servingSize,
    int quantity,
  ) {
    final price = menuItem.getPrice(servingSize);
    final base = menuItem.getBasePrice(servingSize);
    final gst = menuItem.getGstAmount(servingSize);

    return OrderItem(
      menuItemId: menuItem.id,
      menuItemName: menuItem.name,
      servingSize: servingSize,
      quantity: quantity,
      pricePerItem: price,
      basePrice: base,
      gstAmount: gst,
    );
  }

  double get totalPrice => pricePerItem * quantity;
  double get totalBasePrice => basePrice * quantity;
  double get totalGst => gstAmount * quantity;

  String getServingSizeDisplay() {
    switch (servingSize) {
      case 'serves1':
        return 'Serves 1';
      case 'serves2':
        return 'Serves 2';
      case 'single':
        return 'Single';
      default:
        return servingSize;
    }
  }

  OrderItem copyWith({
    String? menuItemId,
    String? menuItemName,
    String? servingSize,
    int? quantity,
    double? pricePerItem,
    double? basePrice,
    double? gstAmount,
  }) {
    return OrderItem(
      menuItemId: menuItemId ?? this.menuItemId,
      menuItemName: menuItemName ?? this.menuItemName,
      servingSize: servingSize ?? this.servingSize,
      quantity: quantity ?? this.quantity,
      pricePerItem: pricePerItem ?? this.pricePerItem,
      basePrice: basePrice ?? this.basePrice,
      gstAmount: gstAmount ?? this.gstAmount,
    );
  }
}
