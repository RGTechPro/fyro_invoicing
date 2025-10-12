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
      imagePath: 'images/Hyderbadi chicken dum biryani.jpg',
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
      imagePath: 'images/Kolkata chicken dum biryani.jpg',
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
      imagePath: 'images/chicken 65 biryani.jpg',
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
      imagePath: 'images/Boneless Hyderabadi chicken dum biryani.jpg',
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
      imagePath: 'images/paneer 65 biryani.jpg',
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
      imagePath: 'images/Hyderbadi paneer dum biryani.jpg',
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
      imagePath: 'images/mushroom 65 biryani.jpg',
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
      imagePath: 'images/aloo 65 biryani.jpg',
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
      imagePath: 'images/paneer 65.jpg',
    ),
    MenuItem(
      id: 's_chicken_65',
      name: 'Chicken 65',
      category: MenuCategory.starters,
      prices: {
        'single': 209.0,
      },
      description: 'Classic spicy chicken 65',
      imagePath: 'images/chicken 65.jpg',
    ),
    MenuItem(
      id: 's_aloo_65',
      name: 'Aloo 65',
      category: MenuCategory.starters,
      prices: {
        'single': 129.0,
      },
      description: 'Crispy potato starter',
      imagePath: 'images/aloo 65.jpg',
    ),
    MenuItem(
      id: 's_mushroom_65',
      name: 'Mushroom 65',
      category: MenuCategory.starters,
      prices: {
        'single': 179.0,
      },
      description: 'Spicy mushroom 65',
      imagePath: 'images/mushroom 65.jpg',
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
      imagePath: 'images/gulab jamun.jpg',
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
