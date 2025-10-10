import '../models/menu_item.dart';

class MenuData {
  static final List<MenuItem> allItems = [
    // Non-Veg Items
    MenuItem(
      id: 'nv_hyderabadi_chicken',
      name: 'Hyderabadi Chicken Dum Biryani with raita',
      category: MenuCategory.nonVeg,
      prices: {
        'serves1': 249.0,
        'serves2': 448.0,
      },
      description:
          'Aromatic Hyderabadi style chicken dum biryani served with cooling raita',
    ),
    MenuItem(
      id: 'nv_kolkata_chicken',
      name: 'Kolkata Chicken Dum Biryani with raita',
      category: MenuCategory.nonVeg,
      prices: {
        'serves1': 259.0,
        'serves2': 458.0,
      },
      description: 'Traditional Kolkata style chicken dum biryani with raita',
    ),
    MenuItem(
      id: 'nv_chicken_65_biryani',
      name: 'Chicken 65 Biryani with raita',
      category: MenuCategory.nonVeg,
      prices: {
        'serves1': 249.0,
        'serves2': 448.0,
      },
      description: 'Spicy chicken 65 biryani served with raita',
    ),
    MenuItem(
      id: 'nv_boneless_hyderabadi',
      name: 'Boneless Hyderabadi Chicken Dum Biryani with raita',
      category: MenuCategory.nonVeg,
      prices: {
        'serves1': 249.0,
        'serves2': 448.0,
      },
      description: 'Boneless chicken Hyderabadi dum biryani with raita',
    ),

    // Veg Items
    MenuItem(
      id: 'v_paneer_65_biryani',
      name: 'Paneer 65 Biryani with raita',
      category: MenuCategory.veg,
      prices: {
        'serves1': 249.0,
        'serves2': 448.0,
      },
      description: 'Delicious paneer 65 biryani with raita',
    ),
    MenuItem(
      id: 'v_hyderabadi_paneer',
      name: 'Hyderabadi Paneer Dum Biryani with raita',
      category: MenuCategory.veg,
      prices: {
        'serves1': 249.0,
        'serves2': 448.0,
      },
      description: 'Hyderabadi style paneer dum biryani with raita',
    ),
    MenuItem(
      id: 'v_mushroom_65_biryani',
      name: 'Mushroom 65 Biryani with raita',
      category: MenuCategory.veg,
      prices: {
        'serves1': 239.0,
        'serves2': 438.0,
      },
      description: 'Tasty mushroom 65 biryani with raita',
    ),
    MenuItem(
      id: 'v_aloo_65_biryani',
      name: 'Aloo 65 Biryani with raita',
      category: MenuCategory.veg,
      prices: {
        'serves1': 209.0,
        'serves2': 408.0,
      },
      description: 'Flavorful aloo 65 biryani with raita',
    ),

    // Starters
    MenuItem(
      id: 's_paneer_65',
      name: 'Paneer 65',
      category: MenuCategory.starters,
      prices: {
        'single': 179.0,
      },
      description: 'Crispy and spicy paneer 65',
    ),
    MenuItem(
      id: 's_chicken_65',
      name: 'Chicken 65',
      category: MenuCategory.starters,
      prices: {
        'single': 209.0,
      },
      description: 'Classic spicy chicken 65',
    ),
    MenuItem(
      id: 's_aloo_65',
      name: 'Aloo 65',
      category: MenuCategory.starters,
      prices: {
        'single': 129.0,
      },
      description: 'Crispy potato starter',
    ),
    MenuItem(
      id: 's_mushroom_65',
      name: 'Mushroom 65',
      category: MenuCategory.starters,
      prices: {
        'single': 179.0,
      },
      description: 'Spicy mushroom 65',
    ),
    MenuItem(
      id: 's_soyabean_65',
      name: 'Soyabean 65',
      category: MenuCategory.starters,
      prices: {
        'single': 169.0,
      },
      description: 'Healthy and tasty soyabean 65',
    ),

    // Extras
    MenuItem(
      id: 'e_gulab_jamun',
      name: 'Gulab Jamun',
      category: MenuCategory.extras,
      prices: {
        'single': 49.0,
      },
      description: 'Sweet gulab jamun',
    ),
    MenuItem(
      id: 'e_extra_raita',
      name: 'Extra Raita',
      category: MenuCategory.extras,
      prices: {
        'single': 25.0,
      },
      description: 'Additional raita portion',
    ),
    MenuItem(
      id: 'e_onion',
      name: 'Onion',
      category: MenuCategory.extras,
      prices: {
        'single': 10.0,
      },
      description: 'Fresh sliced onions',
    ),
  ];

  static List<MenuItem> getItemsByCategory(MenuCategory category) {
    return allItems.where((item) => item.category == category).toList();
  }

  static MenuItem? getItemById(String id) {
    try {
      return allItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<MenuCategory> get categories => MenuCategory.values;
}
