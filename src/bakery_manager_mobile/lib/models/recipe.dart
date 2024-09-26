// Recipe model for the recipe table in the database
class Recipe {
  final String recipeId;
  final String recipeName;
  final String recipeCategory;
  final String instructions;
  final int scalingFactor;

  Recipe(
      {required this.recipeId,
      required this.recipeName,
      required this.recipeCategory,
      required this.instructions,
      required this.scalingFactor});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeId: json['RecipeID'] ?? '',
      recipeName: json['RecipeName'] ?? '',
      recipeCategory: json['RecipeCategory'] ?? '',
      instructions: json['Instructions'] ?? '',
      scalingFactor: json['ScalingFactor'] ?? 1,
    );
  }
}
