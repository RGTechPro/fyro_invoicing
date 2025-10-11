import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/menu_data.dart';
import '../models/menu_item.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  MenuCategory _selectedCategory = MenuCategory.nonVeg;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category selector
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MenuCategory.values.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(
                      _getCategoryName(category),
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.primaryBlack
                            : AppTheme.darkGrey,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                    selectedColor: AppTheme.secondaryGold,
                    backgroundColor: AppTheme.lightGrey,
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.secondaryGold
                          : AppTheme.mediumGrey,
                      width: 2,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const Divider(height: 1),

        // Menu items grid
        Expanded(
          child: _buildMenuGrid(),
        ),
      ],
    );
  }

  Widget _buildMenuGrid() {
    final items = MenuData.getItemsByCategory(_selectedCategory);

    if (items.isEmpty) {
      return const Center(
        child: Text('No items in this category'),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 1 : (screenWidth < 1024 ? 2 : 3);
    final childAspectRatio = screenWidth < 600 ? 2.5 : 0.85;

    return GridView.builder(
      padding: EdgeInsets.all(screenWidth < 600 ? 8 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: screenWidth < 600 ? 8 : 16,
        mainAxisSpacing: screenWidth < 600 ? 8 : 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildMenuItemCard(items[index]);
      },
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isVeg = item.category == MenuCategory.veg;
    final firstPrice = item.prices.values.first;
    
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () => _showAddToOrderDialog(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 8 : 12),
          child: isMobile
              ? Row( // Horizontal layout for mobile
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isVeg
                            ? Colors.green.withOpacity(0.1)
                            : AppTheme.accentRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isVeg ? Icons.eco : Icons.local_fire_department,
                        color: isVeg ? Colors.green : AppTheme.accentRed,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (item.description.isNotEmpty) ...[
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            '₹${firstPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add button
                    IconButton(
                      onPressed: () => _showAddToOrderDialog(item),
                      icon: const Icon(Icons.add_circle),
                      color: AppTheme.secondaryGold,
                      iconSize: 32,
                    ),
                  ],
                )
              : Column( // Vertical layout for desktop/tablet
                  crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(item.category),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.getCategoryName(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Item name
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 8),

              // Prices
              if (item.prices.length == 1) ...[
                Text(
                  '₹${item.prices.values.first.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentRed,
                  ),
                ),
              ] else ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Serves 1: ',
                          style: TextStyle(fontSize: 11),
                        ),
                        Text(
                          '₹${item.getPrice('serves1').toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentRed,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Serves 2: ',
                          style: TextStyle(fontSize: 11),
                        ),
                        Text(
                          '₹${item.getPrice('serves2').toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentRed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 8),

              // Add button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showAddToOrderDialog(item),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Add to Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddToOrderDialog(MenuItem item) {
    final currentOrders = ref.read(ordersProvider);

    if (currentOrders.isEmpty) {
      // No active order, create one first
      _showCreateOrderDialog(item);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddToOrderDialog(
        menuItem: item,
        currentOrders: currentOrders,
      ),
    );
  }

  void _showCreateOrderDialog(MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Order?'),
        content: const Text(
            'You need to create a new order first. Would you like to create one now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final orderId =
                  ref.read(ordersProvider.notifier).createNewOrder();
              ref.read(activeOrderIdProvider.notifier).state = orderId;
              Navigator.pop(context);
              _showAddToOrderDialog(item);
            },
            child: const Text('Create Order'),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(MenuCategory category) {
    switch (category) {
      case MenuCategory.nonVeg:
        return '🍗 Non-Veg';
      case MenuCategory.veg:
        return '🥗 Veg';
      case MenuCategory.starters:
        return '🍽️ Starters';
      case MenuCategory.extras:
        return '➕ Extras';
    }
  }

  Color _getCategoryColor(MenuCategory category) {
    switch (category) {
      case MenuCategory.nonVeg:
        return AppTheme.accentRed;
      case MenuCategory.veg:
        return Colors.green;
      case MenuCategory.starters:
        return Colors.orange;
      case MenuCategory.extras:
        return Colors.blue;
    }
  }
}

// Dialog for adding item to order
class AddToOrderDialog extends ConsumerStatefulWidget {
  final MenuItem menuItem;
  final Map<String, dynamic> currentOrders;

  const AddToOrderDialog({
    super.key,
    required this.menuItem,
    required this.currentOrders,
  });

  @override
  ConsumerState<AddToOrderDialog> createState() => _AddToOrderDialogState();
}

class _AddToOrderDialogState extends ConsumerState<AddToOrderDialog> {
  String? _selectedOrderId;
  String _selectedServingSize = 'serves1';
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedOrderId =
        ref.read(activeOrderIdProvider) ?? widget.currentOrders.keys.first;
    _selectedServingSize = widget.menuItem.getAvailableServingSizes().first;
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.menuItem.getPrice(_selectedServingSize);
    final totalPrice = price * _quantity;

    return AlertDialog(
      title: Text(widget.menuItem.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select order
            const Text(
              'Select Order:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedOrderId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: widget.currentOrders.keys.map((orderId) {
                return DropdownMenuItem(
                  value: orderId,
                  child: Text('Order #$orderId'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedOrderId = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Select serving size (if applicable)
            if (widget.menuItem.getAvailableServingSizes().length > 1) ...[
              const Text(
                'Serving Size:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    widget.menuItem.getAvailableServingSizes().map((size) {
                  final isSelected = _selectedServingSize == size;
                  return ChoiceChip(
                    label: Text(
                      size == 'serves1' ? 'Serves 1' : 'Serves 2',
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedServingSize = size;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Quantity selector
            const Text(
              'Quantity:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed:
                      _quantity > 1 ? () => setState(() => _quantity--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 32,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.secondaryGold, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 32,
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Price summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Price:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '₹${price.toStringAsFixed(2)} × $_quantity',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addToOrder,
          child: const Text('Add to Order'),
        ),
      ],
    );
  }

  void _addToOrder() {
    if (_selectedOrderId == null) return;

    ref.read(ordersProvider.notifier).addItem(
          _selectedOrderId!,
          widget.menuItem,
          _selectedServingSize,
          _quantity,
        );

    Navigator.pop(context);

    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${widget.menuItem.name} to order'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.secondaryGold,
      ),
    );
  }
}
