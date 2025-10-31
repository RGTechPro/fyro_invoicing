import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'menu_screen.dart';
import 'orders_screen.dart';

/// Split view screen with menu on left and orders on right
/// Only used on desktop/tablet (>= 900px width)
class MenuOrdersScreen extends ConsumerWidget {
  const MenuOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    // For mobile (< 900px), this shouldn't be used
    // But as fallback, show just the menu
    if (screenWidth < 900) {
      return const MenuScreen();
    }

    return Row(
      children: [
        // Left side: Menu (60% width)
        Expanded(
          flex: 6,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: const MenuScreen(),
          ),
        ),

        // Right side: Orders (40% width)
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.grey[50],
            child: const OrdersScreen(),
          ),
        ),
      ],
    );
  }
}
