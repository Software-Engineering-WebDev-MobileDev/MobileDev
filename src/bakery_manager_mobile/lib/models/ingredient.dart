class Ingredient {
  final String ingredientID;
  final String name;
  final int quantity;
  final int shelfLife;
  final String shelfLifeUnit;
  final int reorderAmount;
  final String reorderUnit;

  Ingredient(
      {required this.ingredientID,
      required this.name,
      required this.quantity,
      required this.shelfLife,
      required this.shelfLifeUnit,
      required this.reorderAmount,
      required this.reorderUnit});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
        ingredientID: json['InventoryID'] ?? '',
        name: json['Name'] ?? '',
        quantity: json['Amount'] ?? 0,
        shelfLife: json['ShelfLife'] ?? 0,
        shelfLifeUnit: json['ShelfLifeUnit'] ?? '',
        reorderAmount: json['ReorderAmount'] ?? 0,
        reorderUnit: json['ReorderUnit'] ?? '');
  }
}
