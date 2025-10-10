import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import 'menu_screen.dart';
import 'orders_screen.dart';
import 'history_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    MenuScreen(),
    OrdersScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentOrders = ref.watch(ordersProvider);
    final todaysSales = ref.watch(todaysSalesProvider);
    final todaysOrderCount = ref.watch(todaysOrderCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department, size: 28),
            const SizedBox(width: 8),
            const Text('BIRYANI BY FLAME'),
          ],
        ),
        actions: [
          // Today's stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppTheme.darkGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${todaysSales.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppTheme.secondaryGold,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$todaysOrderCount orders today',
                  style: const TextStyle(
                    color: AppTheme.lightGold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // Active orders badge
          if (currentOrders.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppTheme.accentRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${currentOrders.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppTheme.primaryBlack,
            selectedIconTheme: const IconThemeData(
              color: AppTheme.secondaryGold,
              size: 32,
            ),
            unselectedIconTheme: const IconThemeData(
              color: AppTheme.mediumGrey,
              size: 28,
            ),
            selectedLabelTextStyle: const TextStyle(
              color: AppTheme.secondaryGold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: AppTheme.mediumGrey,
              fontSize: 12,
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.restaurant_menu),
                label: Text('Menu'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_cart),
                label: Text('Orders'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                label: Text('History'),
              ),
            ],
          ),

          // Vertical divider
          const VerticalDivider(thickness: 1, width: 1),

          // Main content area
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                // Create new order and switch to orders screen
                final orderId =
                    ref.read(ordersProvider.notifier).createNewOrder();
                ref.read(activeOrderIdProvider.notifier).state = orderId;
                setState(() {
                  _selectedIndex = 1;
                });
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('New Order'),
            )
          : null,
    );
  }
}
