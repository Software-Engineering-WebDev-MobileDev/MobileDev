class Ingredient {
  final String ingredientID;
  final String name;
  final double quantity;
  final String quantityUnit;
  final double shelfLife;
  final String shelfLifeUnit;

  Ingredient({required this.ingredientID, required this.name, required this.quantity, required this.quantityUnit, required this.shelfLife, required this.shelfLifeUnit});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      ingredientID: json['IngredientID'] ?? '',
      name: json['Name'] ?? '',
      quantity: json['Quantity'] ?? 0,
      quantityUnit: json['QuantityUnit'] ?? '',
      shelfLife: json['ShelfLife'] ?? 0,
      shelfLifeUnit: json['ShelfLifeUnit'] ?? ''  
    );
  }
}