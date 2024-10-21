class RecipeIngredient {
  String ingredientID;
  String inventoryID;
  String inventoryName;
  double quantity;
  String unitOfMeasure;

  RecipeIngredient({
    required this.ingredientID,
    required this.inventoryName,
    required this.quantity,
    required this.unitOfMeasure,
    required this.inventoryID
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      ingredientID: json['ingredientId'],
      inventoryName: json['inventoryName'],
      quantity: json['quantity'].toDouble(),
      unitOfMeasure: json['unit'],
      inventoryID: json['inventoryId']
    );
  }
}