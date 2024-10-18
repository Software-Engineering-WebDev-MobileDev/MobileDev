class Ingredient {
  final String ingredientID;
  final String name;
  double quantity; 
  final int shelfLife;
  final String shelfLifeUnit;
  final double reorderAmount;
  final String reorderUnit;
  String quantityUnit;

  Ingredient({
    required this.ingredientID,
    required this.name,
    required this.quantity,
    required this.shelfLife,
    required this.shelfLifeUnit,
    required this.reorderAmount,
    required this.reorderUnit,
    this.quantityUnit = 'g', // Default quantityUnit to 'g'
  }) {
    // Update quantity and quantityUnit if quantity can be converted to kg
    if (quantityUnit == 'g' && quantity >= 1000) {
      quantityUnit = 'kg';
      quantity = (quantity / 1000); // Convert grams to kilograms
    }
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      ingredientID: json['InventoryID'] ?? '',
      name: json['Name'] ?? '',
      quantity: json['Amount'].toDouble() ?? 0,
      shelfLife: json['ShelfLife'] ?? 0,
      shelfLifeUnit: json['ShelfLifeUnit'] ?? '',
      reorderAmount: json['ReorderAmount'].toDouble() ?? 0,
      reorderUnit: json['ReorderUnit'] ?? '',
    );
  }
}
