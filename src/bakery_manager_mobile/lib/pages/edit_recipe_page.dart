import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:bakery_manager_mobile/models/recipe.dart';
import 'package:bakery_manager_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import '../models/recipe_ingredients.dart';

class EditRecipePage extends StatefulWidget {
  const EditRecipePage({super.key});

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  final TextEditingController recipeNameController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController prepTimeController = TextEditingController();
  final TextEditingController cookTimeController = TextEditingController();
  final TextEditingController servingsController = TextEditingController();
  final List<RecipeIngredient> ingredients = [];

  final List<String> categories = recipeCatagories;
  String? selectedCategory;

  // This flag ensures recipe details are only loaded once
  bool _hasLoadedInitialRecipeData = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRecipeDetails();
  }

  void _loadRecipeDetails() {
    // Ensure that you check if the arguments are available
    final Recipe recipe = ModalRoute.of(context)!.settings.arguments as Recipe;

    if (!_hasLoadedInitialRecipeData) {
      setState(() {
        recipeNameController.text = recipe.recipeName;
        instructionsController.text = recipe.instructions;
        prepTimeController.text = recipe.prepTime.toString();
        cookTimeController.text = recipe.cookTime.toString();
        servingsController.text = recipe.servings.toString();

        // Only set this the first time
        selectedCategory = recipe.category;
        if (!categories.contains(selectedCategory)) {
          selectedCategory = "Other";
        }

        // Mark that the initial recipe data has been loaded
        _hasLoadedInitialRecipeData = true;
      });
      // Load ingredients (make sure to fetch from backend later)
      ingredients.clear();
      for (var ing in []) {
        // TODO: Replace with actual ingredient data from backend
        ingredients.add(RecipeIngredient(
          recipeIngredientId: ing['id'],
          componentId: ing['componentId'],
          ingredientDescription: ing['ingredientDescription'],
          quantity: double.tryParse(ing['quantity'].toString()) ?? 0.0,
          measurement: ing['unit'],
        ));
      }
    }
  }

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
    final Recipe recipe = ModalRoute.of(context)!.settings.arguments as Recipe;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Edit Recipe'),
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 140, 72, 27)),
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
                'Edit Recipe',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text('Name:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              const Text('Category:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              const Text('Prep Time (minutes):',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              const Text('Cook Time (minutes):',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              const Text('Servings:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              const Text('Instructions:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              const Text('Ingredients:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          onChanged: (value) =>
                              ingredient.ingredientDescription = value,
                          decoration: InputDecoration(
                            hintText: 'Ingredient ${idx + 1}',
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (value) => ingredient.quantity =
                              double.tryParse(value) ?? 0.0,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Quantity',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                      if (idx != 0)
                        IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
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
                  String recipeName = recipeNameController.text;
                  String instructions = instructionsController.text;
                  String prepTime = prepTimeController.text;
                  String cookTime = cookTimeController.text;
                  String servings = servingsController.text;
                  String newCategory = selectedCategory ?? "Other";

                  // Update recipe
                  Map<String, dynamic> response = await ApiService.updateRecipe(
                      recipeId: recipe.recipeId,
                      recipeName: recipeName,
                      instructions: instructions,
                      prepTime: double.tryParse(prepTime) ?? 0,
                      cookTime: double.tryParse(cookTime) ?? 0,
                      servings: int.tryParse(servings) ?? 1,
                      category: newCategory,
                      description: "");

                  if (response['status'] == 'success') {
                    List<String> errors = []; //TODO Backend
                    // for (var ingredient in ingredients) {
                    //   Map<String, dynamic> ingredientResponse = await ApiService.updateRecipeIngredient(
                    //     recipeIngredientId: ingredient.recipeIngredientId,
                    //     recipeID: widget.recipeId,
                    //     ingredientDescription: ingredient.ingredientDescription,
                    //     quantity: ingredient.quantity,
                    //     unit: ingredient.measurement,
                    //   );
                    //   if (ingredientResponse['status'] != 'success') {
                    //     errors.add('Failed to update ingredient ${ingredient.ingredientDescription}: ${ingredientResponse['reason']}');
                    //   }
                    // }
                    if (context.mounted) {
                      if (errors.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Recipe and all ingredients updated successfully')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Recipe updated, but some ingredients failed to update.')));
                      }
                      Navigator.pop(context);
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Failed to update recipe: ${response['reason']}')));
                    }
                  }
                },
                child: const Text('Update Recipe'),
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
