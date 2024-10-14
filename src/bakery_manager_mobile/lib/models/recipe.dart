// Recipe model for the recipe table in the database
class Recipe {
  final String recipeId;
  final String recipeName;
  final String description;
  final String instructions;
  final String category;
  final int servings;
  final int prepTime;
  final int cookTime;

  Recipe(
      {required this.recipeId,
      required this.recipeName,
      required this.instructions,
      required this.description,
      required this.category,
      required this.servings,
      required this.cookTime,
      required this.prepTime});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
        recipeId: json['RecipeID'] ?? '',
        recipeName: json['RecipeName'] ?? '',
        instructions: json['Instructions'] ?? '',
        description: json['Description'] ?? '',
        category: json['Category'],
        servings: json['Servings'] ?? 1,
        cookTime: json['CookTime'] ?? 1,
        prepTime: json['PrepTime'] ?? 1);
  }
}
