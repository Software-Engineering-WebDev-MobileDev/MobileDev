class RecipeIngredient {
  String recipeIngredientId;
  String componentId;
  String ingredientDescription;
  double quantity;
  String measurement;

  RecipeIngredient({
    required this.recipeIngredientId,
    required this.componentId,
    required this.ingredientDescription,
    required this.quantity,
    required this.measurement,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      recipeIngredientId: json['RecipeIngredientID'] ?? '',
      componentId: json['ComponentID'] ?? '',
      ingredientDescription: json['IngredientDescription'] ?? '',
      quantity: json['Quantity']?.toDouble() ?? 0.0,
      measurement: json['Measurement'] ?? '',
    );
  }
}
