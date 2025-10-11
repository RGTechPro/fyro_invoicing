import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../services/thermal_printer_service.dart';
import '../theme/app_theme.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final DateFormat _timeFormat = DateFormat('HH:mm');

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentOrders = ref.watch(ordersProvider);
    final activeOrderId = ref.watch(activeOrderIdProvider);

    if (currentOrders.isEmpty) {
      return _buildEmptyState();
    }

    // Create tab controller if needed
    if (_tabController == null ||
        _tabController!.length != currentOrders.length) {
      _tabController?.dispose();
      _tabController = TabController(
        length: currentOrders.length,
        vsync: this,
        initialIndex:
            activeOrderId != null && currentOrders.containsKey(activeOrderId)
                ? currentOrders.keys.toList().indexOf(activeOrderId)
                : 0,
      );

      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          final orderId = currentOrders.keys.toList()[_tabController!.index];
          ref.read(activeOrderIdProvider.notifier).state = orderId;
        }
      });
    }

    return Column(
      children: [
        // Tabs for multiple orders
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppTheme.primaryBlack,
            unselectedLabelColor: AppTheme.mediumGrey,
            indicatorColor: AppTheme.secondaryGold,
            indicatorWeight: 3,
            tabs: currentOrders.entries.map((entry) {
              final order = entry.value;
              return Tab(
                child: Row(
                  children: [
                    Text('Order #${order.orderId}'),
                    const SizedBox(width: 8),
                    if (order.items.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${order.totalItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => _cancelOrder(order.orderId),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        const Divider(height: 1),

        // Order content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: currentOrders.values.map((order) {
              return _buildOrderView(order);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: AppTheme.mediumGrey.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Active Orders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a new order from the menu to get started',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.mediumGrey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(ordersProvider.notifier).createNewOrder();
            },
            icon: const Icon(Icons.add),
            label: const Text('Create New Order'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderView(Order order) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Row(
      children: [
        // Order items list
        Expanded(
          flex: 3,
          child: order.items.isEmpty
              ? _buildEmptyOrderState(order)
              : _buildItemsList(order),
        ),

        // Vertical divider
        const VerticalDivider(width: 1),

        // Order summary and actions
        Expanded(
          flex: 2,
          child: _buildOrderSummary(order, isMobile),
        ),
      ],
    );
  }

  Widget _buildEmptyOrderState(Order order) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: AppTheme.mediumGrey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No items in this order',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items from the menu',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(Order order) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: order.items.length,
      itemBuilder: (context, index) {
        final item = order.items[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.menuItemName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.getServingSizeDisplay(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${item.pricePerItem.toStringAsFixed(2)} each',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quantity controls
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        ref.read(ordersProvider.notifier).updateItemQuantity(
                              order.orderId,
                              index,
                              item.quantity - 1,
                            );
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: AppTheme.secondaryGold, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        ref.read(ordersProvider.notifier).updateItemQuantity(
                              order.orderId,
                              index,
                              item.quantity + 1,
                            );
                      },
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // Total price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentRed,
                      ),
                    ),
                    const SizedBox(height: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        ref
                            .read(ordersProvider.notifier)
                            .removeItem(order.orderId, index);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(Order order, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Order ID
          Text(
            'Order #${order.orderId}',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
            ),
          ),
          Text(
            _timeFormat.format(order.createdAt),
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: AppTheme.mediumGrey,
            ),
          ),

          SizedBox(height: isMobile ? 16 : 24),

          // Customer name (optional)
          TextField(
            decoration: const InputDecoration(
              labelText: 'Customer Name (Optional)',
              prefixIcon: Icon(Icons.person),
            ),
            onChanged: (value) {
              ref.read(ordersProvider.notifier).updateCustomerName(
                    order.orderId,
                    value.isEmpty ? null : value,
                  );
            },
          ),

          const SizedBox(height: 16),

          // Notes
          TextField(
            decoration: const InputDecoration(
              labelText: 'Notes (Optional)',
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 2,
            onChanged: (value) {
              ref.read(ordersProvider.notifier).updateNotes(
                    order.orderId,
                    value.isEmpty ? null : value,
                  );
            },
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Order summary
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Items count
          _buildSummaryRow('Items', '${order.totalItems}'),
          const SizedBox(height: 8),

          // Subtotal
          _buildSummaryRow(
            'Subtotal',
            '₹${order.totalBaseAmount.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),

          // GST
          _buildSummaryRow(
            'GST (5%)',
            '₹${order.totalGst.toStringAsFixed(2)}',
            color: AppTheme.darkGrey,
          ),
          const SizedBox(height: 16),

          const Divider(thickness: 2),
          const SizedBox(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentRed,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action buttons
          if (order.items.isNotEmpty) ...[
            // Complete and print customer copy
            FilledButton.icon(
              onPressed: () => _completeOrderWithCustomerCopy(order),
              icon: const Icon(Icons.print),
              label: Text(isMobile ? 'Complete & Print' : 'Complete & Print Customer Copy'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            // Print store copy button
            ElevatedButton.icon(
              onPressed: () => _printStoreCopy(order),
              icon: const Icon(Icons.receipt_long),
              label: const Text('Print Store Copy'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            ElevatedButton.icon(
              onPressed: () => _previewReceipt(order),
              icon: const Icon(Icons.visibility),
              label: const Text('Preview Receipt'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            OutlinedButton.icon(
              onPressed: () => _cancelOrder(order.orderId),
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text(
                'Cancel Order',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: color ?? AppTheme.primaryBlack,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? AppTheme.primaryBlack,
          ),
        ),
      ],
    );
  }

  void _completeOrderWithCustomerCopy(Order order) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Order'),
        content: Text(
          'Complete order #${order.orderId} and print customer copy?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete & Print'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Complete order
      await ref.read(ordersProvider.notifier).completeOrder(order.orderId);

      // Refresh history
      ref.read(orderHistoryProvider.notifier).refresh();

      // Print customer copy on thermal printer
      ThermalPrinterService.printReceipt(order, isCustomerCopy: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order completed and customer copy sent to thermal printer!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _printStoreCopy(Order order) async {
    try {
      ThermalPrinterService.printReceipt(order, isCustomerCopy: false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Store copy sent to thermal printer!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _previewReceipt(Order order) async {
    try {
      // Preview customer copy in browser
      ThermalPrinterService.previewReceipt(order, isCustomerCopy: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelOrder(String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text('Are you sure you want to cancel order #$orderId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(ordersProvider.notifier).cancelOrder(orderId);
    }
  }
}
