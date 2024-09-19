class RecipeIngredient {
  String recipeIngredientId;
  String componentId;
  String ingredientId;
  double quantity;
  String measurement;

  RecipeIngredient({
    required this.recipeIngredientId,
    required this.componentId,
    required this.ingredientId,
    required this.quantity,
    required this.measurement,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      recipeIngredientId: json['RecipeIngredientID'] ?? '',
      componentId: json['ComponentID'] ?? '',
      ingredientId: json['IngredientID'] ?? '',
      quantity: json['Quantity']?.toDouble() ?? 0.0,
      measurement: json['Measurement'] ?? '',
    );
  }
}
