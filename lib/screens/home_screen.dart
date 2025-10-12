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
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department, size: isSmallScreen ? 20 : 28),
            SizedBox(width: isSmallScreen ? 4 : 8),
            Text(
              isSmallScreen ? 'BBF' : 'BIRYANI BY FLAME',
              style: TextStyle(fontSize: isSmallScreen ? 16 : 20),
            ),
          ],
        ),
        actions: [
          // Today's stats - hide on very small screens
          if (!isSmallScreen || MediaQuery.of(context).size.width >= 400)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 16,
                vertical: isSmallScreen ? 4 : 8,
              ),
              margin: EdgeInsets.only(right: isSmallScreen ? 4 : 8),
              decoration: BoxDecoration(
                color: AppTheme.darkGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isSmallScreen
                        ? '₹${(todaysSales / 1000).toStringAsFixed(1)}k'
                        : '₹${todaysSales.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: AppTheme.secondaryGold,
                      fontSize: isSmallScreen ? 12 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isSmallScreen)
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
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              margin: EdgeInsets.only(right: isSmallScreen ? 8 : 16),
              decoration: BoxDecoration(
                color: AppTheme.accentRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart,
                      color: Colors.white, size: isSmallScreen ? 16 : 20),
                  SizedBox(width: isSmallScreen ? 4 : 8),
                  Text(
                    '${currentOrders.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: isSmallScreen
          ? _screens[_selectedIndex] // No sidebar on mobile
          : Row(
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
      bottomNavigationBar: isSmallScreen
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: AppTheme.primaryBlack,
              selectedItemColor: AppTheme.secondaryGold,
              unselectedItemColor: AppTheme.mediumGrey,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu),
                  label: 'Menu',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'History',
                ),
              ],
            )
          : null,
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
              label: Text(isSmallScreen ? 'New' : 'New Order'),
            )
          : null,
    );
  }
}
