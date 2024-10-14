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
  late Future<List<Map<String, dynamic>>> _futureIngredients;

  Future<List<Map<String, dynamic>>> _fetchIngredients(String recipeId) async {
    final response = await ApiService.getRecipeIngredients(recipeId);
    if (response['status'] == 'success') {
      return List<Map<String, dynamic>>.from(response['ingredients']);
    } else {
      throw Exception('Failed to load ingredients');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Recipe recipe = ModalRoute.of(context)!.settings.arguments as Recipe;
    _futureIngredients = _fetchIngredients(recipe.recipeId);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Stack(
          children: <Widget>[
            Text(
              'View Recipe',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
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
            // Recipe Name Section
            const Text(
              'Recipe Name:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.recipeName,
              style: const TextStyle(fontSize: 20), // Increased font size
            ),
            const SizedBox(height: 16),
            // Category Section
            const Text(
              'Category:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.category.isNotEmpty ? recipe.category : 'No category',
              style: const TextStyle(fontSize: 20), // Increased font size
            ),
            const SizedBox(height: 16),
            // Prep Time Section
            const Text(
              'Prep Time:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${recipe.prepTime} minutes',
              style: const TextStyle(fontSize: 20), // Increased font size
            ),
            const SizedBox(height: 16),
            // Cook Time Section
            const Text(
              'Cook Time:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${recipe.cookTime} minutes',
              style: const TextStyle(fontSize: 20), // Increased font size
            ),
            const SizedBox(height: 16),
            // Servings Section
            const Text(
              'Servings:',
              style: TextStyle(fontSize:24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.servings.toString(),
              style: const TextStyle(fontSize: 20), // Increased font size
            ),
            const SizedBox(height: 16),
            // Ingredients Section
            const Text(
              'Ingredients:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureIngredients,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
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
                          '${ingredient['IngredientDescription'] ?? 'Unknown'}: ${ingredient['Quantity'] ?? 'N/A'} ${ingredient['UnitOfMeasure'] ?? ''}',
                          style: const TextStyle(fontSize: 20), // Increased font size
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
              style: const TextStyle(fontSize: 20), // Increased font size
            ),
            const SizedBox(height: 24),
            // Centered Action Buttons
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 209, 125, 51),
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
                      'Edit Recipe',
                      style: TextStyle(
                        color: Colors.white, // White font color
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Space between the buttons
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
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
                            content: const Text(
                                'Are you sure you want to delete this recipe?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false); // Cancel
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
                          await ApiService.deleteRecipe(recipeId: recipe.recipeId);
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to delete recipe: $e')),
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
                      style: TextStyle(
                        color: Colors.white, // White font color
                      ),
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