import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:bakery_manager_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import '../models/recipe_ingredients.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final TextEditingController recipeNameController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController prepTimeController = TextEditingController();  // New field
  final TextEditingController cookTimeController = TextEditingController();  // New field
  final TextEditingController servingsController = TextEditingController();  // New field
  final List<RecipeIngredient> ingredients = [];

  final List<String> categories = recipeCatagories;
  String? selectedCategory;

  void _addIngredientField() {
    setState(() {
      ingredients.add(RecipeIngredient(
        recipeIngredientId: '',
        componentId: '',
        ingredientDescription: '',
        quantity: 0.0,
        measurement: '',
      ));
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Stack(
          children: <Widget>[
            // Stroked text as border.
            Text(
              'The Rolling Scones',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 30,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = const Color.fromARGB(255, 140,72,27),
              ),
            ),
            // Solid text as fill.
            const Text(
              'The Rolling Scones',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 246,235,216),
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 140,72,27)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add a New Recipe',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Name:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: recipeNameController,
                decoration: const InputDecoration(
                  hintText: 'Recipe Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Category:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  hintText: 'Select Category',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Prep Time (minutes):',  // Label for prep time
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: prepTimeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Prep Time',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cook Time (minutes):',  // Label for cook time
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: cookTimeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Cook Time',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Servings:',  // Label for servings
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: servingsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Number of Servings',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Instructions:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: instructionsController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Recipe Instructions',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ingredients:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...ingredients.asMap().entries.map((entry) {
                int idx = entry.key;
                var ingredient = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) => ingredient.ingredientDescription = value,
                          decoration: InputDecoration(
                            hintText: 'Ingredient ID ${idx + 1}',
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (value) => ingredient.quantity = double.tryParse(value) ?? 0.0,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Quantity',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (value) => ingredient.measurement = value,
                          decoration: const InputDecoration(
                            hintText: 'Measurement',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                      if (idx != 0)
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeIngredientField(idx),
                        ),
                    ],
                  ),
                );
              }),
              ElevatedButton.icon(
                onPressed: _addIngredientField,
                icon: const Icon(Icons.add),
                label: const Text('Add Ingredient'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  // Functionality to handle form submission here (without API calls)
                  String recipeName = recipeNameController.text;
                  String instructions = instructionsController.text;
                  String prepTime = prepTimeController.text;
                  String cookTime = cookTimeController.text;
                  String servings = servingsController.text;

                  // Save recipe
                  Map<String, dynamic> response = await ApiService.addRecipe(
                    recipeName: recipeName,
                    ingredients: instructions,
                    prepTime: double.tryParse(prepTime) ?? 0,
                    cookTime: double.tryParse(cookTime) ?? 0,
                    servings: int.tryParse(servings) ?? 1,
                    category: selectedCategory ?? "Bread"
                  );
                  
                  if (response['status'] == 'success') {
                    String recipeId = response['recipeID'];
                    List<String> errors = [];
                    for (var ingredient in ingredients) {
                      Map<String, dynamic> ingredientResponse = await ApiService.addRecipeIngredient(
                        recipeID: recipeId,
                        ingredientDescription: ingredient.ingredientDescription,
                        quantity: ingredient.quantity,
                        unit: ingredient.measurement,
                      );
                      if (ingredientResponse['status'] != 'success') {
                        errors.add('Failed to add ingredient ${ingredient.ingredientDescription}: ${ingredientResponse['reason']}');
                      }
                    }
                    if (context.mounted) {
                      if (errors.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Recipe and all ingredients added successfully')));
                      } else {
                        // Show error if ingredients failed to add
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Recipe added, but some ingredients failed to add. Check recipe details.')));
                      }
                      // Pop context even if ingredients failed to add
                      Navigator.pop(context);
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Failed to add recipe: ${response['reason']}')));
                      // Do not exit if recipe addition fails
                    }
                  }
                },
                child: const Text('Save Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    recipeNameController.dispose();
    instructionsController.dispose();
    prepTimeController.dispose();
    cookTimeController.dispose();
    servingsController.dispose();
    super.dispose();
  }
}
