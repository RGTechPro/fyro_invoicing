enum MenuCategory {
  nonVeg,
  veg,
  starters,
  extras,
}

enum ServingSize {
  serves1,
  serves2,
  single, // For starters and extras
}

class MenuItem {
  final String id;

  final String name;

  final MenuCategory category;

  final Map<String, double> prices; // Key: 'serves1', 'serves2', or 'single'

  final String description;

  MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.prices,
    this.description = '',
  });

  double getPrice(String servingSize) {
    return prices[servingSize] ?? 0.0;
  }

  // Calculate base price (excluding GST)
  double getBasePrice(String servingSize) {
    final inclusivePrice = getPrice(servingSize);
    return inclusivePrice / 1.05; // GST is 5%
  }

  // Calculate GST amount
  double getGstAmount(String servingSize) {
    final basePrice = getBasePrice(servingSize);
    return basePrice * 0.05;
  }

  List<String> getAvailableServingSizes() {
    return prices.keys.toList();
  }

  String getCategoryName() {
    switch (category) {
      case MenuCategory.nonVeg:
        return 'Non-Veg';
      case MenuCategory.veg:
        return 'Veg';
      case MenuCategory.starters:
        return 'Starters';
      case MenuCategory.extras:
        return 'Extras';
    }
  }
}
