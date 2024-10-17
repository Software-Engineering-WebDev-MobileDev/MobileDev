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
  final _formKey = GlobalKey<FormState>();

  final TextEditingController recipeNameController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController prepTimeController = TextEditingController();
  final TextEditingController cookTimeController = TextEditingController();
  final TextEditingController servingsController = TextEditingController();

  final List<RecipeIngredient> ingredients = [
    RecipeIngredient(
      recipeIngredientId: '',
      componentId: '',
      ingredientDescription: '',
      quantity: 0.0,
      measurement: '',
    ),
  ];
  final List<String> categories = recipeCatagories;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
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
    if (ingredients.length > 1) {
      setState(() {
        ingredients.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        shape: const RoundedRectangleBorder(),
        title: const Stack(
          children: <Widget>[
            Text(
              'Add Recipe',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Recipe Name Field
                TextFormField(
                  controller: recipeNameController,
                  maxLength: 50,
                  decoration: const InputDecoration(
                    labelText: 'Recipe Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Recipe Name is required';
                    }
                    return null;
                  },
                  buildCounter: (BuildContext context,
                      {required int currentLength,
                      required bool isFocused,
                      required int? maxLength}) {
                    return null; // Don't show character count
                  },
                ),
                const SizedBox(height: 16),
                // Category Field
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
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Category is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Prep Time Field
                TextFormField(
                  controller: prepTimeController,
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Prep Time (minutes)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prep Time is required';
                    } else if (int.tryParse(value) == null) {
                      return 'Prep Time must be an integer';
                    }
                    return null;
                  },
                  buildCounter: (BuildContext context,
                      {required int currentLength,
                      required bool isFocused,
                      required int? maxLength}) {
                    return null; // Don't show the counter
                  },
                ),
                const SizedBox(height: 16),
                // Cook Time Field
                TextFormField(
                  controller: cookTimeController,
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cook Time (minutes)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Cook Time is required';
                    } else if (int.tryParse(value) == null) {
                      return 'Cook Time must be an integer';
                    }
                    return null;
                  },
                  buildCounter: (BuildContext context,
                      {required int currentLength,
                      required bool isFocused,
                      required int? maxLength}) {
                    return null; // Don't show the counter
                  },
                ),
                const SizedBox(height: 16),
                // Servings Field
                TextFormField(
                  controller: servingsController,
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Servings',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Servings are required';
                    } else if (int.tryParse(value) == null) {
                      return 'Servings must be an integer';
                    }
                    return null;
                  },
                  buildCounter: (BuildContext context,
                      {required int currentLength,
                      required bool isFocused,
                      required int? maxLength}) {
                    return null; // Don't show the counter
                  },
                ),
                const SizedBox(height: 16),

                // Instructions Field
                TextFormField(
                  controller: instructionsController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 6, // Increased box size
                  decoration: const InputDecoration(
                    labelText: 'Instructions',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Instructions are required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Ingredients Section
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
                          child: TextFormField(
                            onChanged: (value) =>
                                ingredient.ingredientDescription = value,
                            decoration: InputDecoration(
                              labelText: 'Ingredient ${idx + 1}',
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingredient is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            onChanged: (value) => ingredient.quantity =
                                double.tryParse(value) ?? 0.0,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Quantity is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            onChanged: (value) =>
                                ingredient.measurement = value,
                            decoration: const InputDecoration(
                              labelText: 'Measurement',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Measurement is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (ingredients.length > 1)
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
                    foregroundColor: Colors.white, // White font color
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String recipeName = recipeNameController.text;
                      String instructions = instructionsController.text;
                      String prepTime = prepTimeController.text;
                      String cookTime = cookTimeController.text;
                      String servings = servingsController.text;

                      // Save recipe
                      Map<String, dynamic> response = await ApiService.addRecipe(
                        recipeName: recipeName,
                        ingredients: instructions,
                        prepTime: int.tryParse(prepTime) ?? 0,
                        cookTime: int.tryParse(cookTime) ?? 0,
                        servings: int.tryParse(servings) ?? 1,
                        category: selectedCategory ?? "Bread",
                      );

                      if (response['status'] == 'success') {
                        String recipeId = response['recipeID'];
                        List<String> errors = [];
                        for (var ingredient in ingredients) {
                          Map<String, dynamic> ingredientResponse =
                              await ApiService.addRecipeIngredient(
                            recipeID: recipeId,
                            ingredientDescription:
                                ingredient.ingredientDescription,
                            quantity: ingredient.quantity,
                            unit: ingredient.measurement,
                          );
                          if (ingredientResponse['status'] != 'success') {
                            errors.add(
                                'Failed to add ingredient ${ingredient.ingredientDescription}: ${ingredientResponse['reason']}');
                          }
                        }
                        if (context.mounted) {
                          if (errors.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Recipe and all ingredients added successfully'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Recipe added, but some ingredients failed to add. Check recipe details.'),
                              ),
                            );
                          }
                          Navigator.pop(context);
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Failed to add recipe: ${response['reason']}')));
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.save), // Save icon added
                  label: const Text('Save Recipe'),
                ),
              ],
            ),
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