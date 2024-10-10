class Ingredient {
  final String ingredientID;
  final String name;
  final double quantity;
  final String quantityUnit;
  final double shelfLife;
  final String shelfLifeUnit;
  final double reorderAmount;
  final String reorderUnit;

  Ingredient(
      {required this.ingredientID,
      required this.name,
      required this.quantity,
      required this.quantityUnit,
      required this.shelfLife,
      required this.shelfLifeUnit,
      required this.reorderAmount,
      required this.reorderUnit});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
        ingredientID: json['InventoryID'] ?? '',
        name: json['Name'] ?? '',
        quantity: json['Quantity'] ?? 0.0,
        quantityUnit: json['QuantityUnit'] ?? '',
        shelfLife: json['ShelfLife']?.toDouble() ?? 0.0,
        shelfLifeUnit: json['ShelfLifeUnit'] ?? '',
        reorderAmount: json['ReorderAmount'].toDouble() ?? 0.0,
        reorderUnit: json['ReorderUnit'] ?? '');
  }
}
