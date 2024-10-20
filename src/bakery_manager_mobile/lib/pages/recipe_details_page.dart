import 'package:bakery_manager_mobile/models/recipe_ingredients.dart';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../assets/constants.dart';

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({super.key});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late Future<List<RecipeIngredient>> _futureIngredients;

  Future<List<RecipeIngredient>> _fetchIngredients(String recipeId) async {
    final Recipe recipe = ModalRoute.of(context)!.settings.arguments as Recipe;
    final response = await ApiService.getRecipeIngredients(recipeId);
    if (response['status'] == 'success') {
      // Map the ingredients to RecipeIngredient instances
      recipe.ingredients = List<RecipeIngredient>.from(
          response['ingredients'].map((ingredientJson) => RecipeIngredient.fromJson(ingredientJson)));
      return recipe.ingredients!;
    } else {
      throw Exception('Failed to load ingredients: ${response['reason']}');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch ingredients when the dependencies change
    final Recipe recipe = ModalRoute.of(context)!.settings.arguments as Recipe;
    _futureIngredients = _fetchIngredients(recipe.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    final Recipe recipe =
        ModalRoute.of(context)!.settings.arguments as Recipe;
    _futureIngredients = _fetchIngredients(recipe.recipeId);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          recipe.recipeName,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // 2x2 Grid for Recipe Info using Rows and Columns
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _GridItem(
                    title: 'Prep Time:',
                    value: '${recipe.prepTime} minutes',
                  ),
                ),
                Expanded(
                  child: _GridItem(
                    title: 'Category:',
                    value: recipe.category.isNotEmpty
                        ? recipe.category
                        : 'No category',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _GridItem(
                    title: 'Cook Time:',
                    value: '${recipe.cookTime} minutes',
                  ),
                ),
                Expanded(
                  child: _GridItem(
                    title: 'Servings:',
                    value: recipe.servings.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ingredients Section
            const Text(
              'Ingredients:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<RecipeIngredient>>(
              future: _futureIngredients,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No ingredients found for this recipe.');
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: snapshot.data!.map((ingredient) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '${ingredient.inventoryName}: ${ingredient.quantity} ${ingredient.unitOfMeasure}',
                          style: const TextStyle(fontSize: 20),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Instructions Section
            const Text(
              'Instructions:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.instructions.isNotEmpty
                  ? recipe.instructions
                  : 'No instructions provided.',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),

            // Centered Action Buttons
            Center(
              child: Column(
                children: [
                  // Edit Recipe Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 209, 125, 51),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        editRecipePageRoute,
                        arguments: recipe, // Pass the recipe object to edit
                      );
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    label: const Text(
                      '  Edit Recipe  ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16), // Space between the buttons

                  // Delete Recipe Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF800000),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      final confirmed = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Recipe'),
                            content: const Text('Are you sure you want to delete this recipe?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(false); // Cancel
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true); // Confirm
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmed) {
                        try {
                          await ApiService.deleteRecipe(
                              recipeId: recipe.recipeId);
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Failed to delete recipe: $e')),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Delete Recipe',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for Grid Items
class _GridItem extends StatelessWidget {
  final String title;
  final String value;

  const _GridItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center vertically
      crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
