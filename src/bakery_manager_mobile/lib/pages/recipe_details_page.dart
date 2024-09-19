import 'package:bakery_manager_mobile/models/recipe.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({super.key});

  @override
  State<RecipeDetailPage> createState() => RecipeDetailPageState();
}

class RecipeDetailPageState extends State<RecipeDetailPage> {
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
        title: const Text('View Recipe', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recipe: ${recipe.recipeName}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ingredients:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureIngredients,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('No ingredients found for this recipe.'),
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: snapshot.data!.map((ingredient) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '• ${ingredient['IngredientDescription'] ?? 'Unknown'}: ${ingredient['Quantity'] ?? 'N/A'} ${ingredient['UnitOfMeasure'] ?? ''}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Instructions:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                recipe.instructions.isNotEmpty ? recipe.instructions : 'No instructions provided.',
                style: const TextStyle(fontSize: 16)
              ),
            ],
          ),
        ),
      ),
    );
  }
}