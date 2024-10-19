import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:bakery_manager_mobile/models/ingredient.dart';
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
  final _formKey = GlobalKey<FormState>();

  final TextEditingController recipeNameController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController prepTimeController = TextEditingController();
  final TextEditingController cookTimeController = TextEditingController();
  final TextEditingController servingsController = TextEditingController();
  final List<RecipeIngredient> ingredients = [];
  List<RecipeIngredient> ingredientsToDelete = [];

  List<Ingredient> inventoryItems = [];
  final List<String> categories = recipeCatagories;
  String? selectedCategory;

  // Flag to ensure recipe details are only loaded once
  bool _hasLoadedInitialRecipeData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRecipeDetails();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    final response = await ApiService.getInventory();
    if (response['status'] == 'success') {
      setState(() {
        inventoryItems = response['inventory'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load inventory: ${response['reason']}'),
      ));
    }
  }

  void _loadRecipeDetails() {
    // Retrieve the recipe data from the passed arguments
    final Recipe recipe = ModalRoute.of(context)!.settings.arguments as Recipe;

    if (!_hasLoadedInitialRecipeData) {
      setState(() {
        recipeNameController.text = recipe.recipeName;
        instructionsController.text = recipe.instructions;
        prepTimeController.text = recipe.prepTime.toString();
        cookTimeController.text = recipe.cookTime.toString();
        servingsController.text = recipe.servings.toString();

        selectedCategory = recipe.category;
        if (!categories.contains(selectedCategory)) {
          selectedCategory = "Other";
        }

        // Mark that the initial recipe data has been loaded
        _hasLoadedInitialRecipeData = true;
      });

      // Load ingredients from the recipe - replace with actual backend data later
      ingredients.clear();
      for (var ing in recipe.ingredients!) {
        ingredients.add(ing);
      }
    }
  }

  void _addIngredientField() {
    setState(() {
      ingredients.add(RecipeIngredient(
        ingredientID: '',
        inventoryName: '',
        quantity: 0.0,
        unitOfMeasure: '',
        inventoryID: '',
      ));
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      if (ingredients[index].ingredientID != "") {
        ingredientsToDelete.add(ingredients[index]);
      }
      ingredients.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Recipe recipe = ModalRoute.of(context)!.settings.arguments as Recipe;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        shape: const RoundedRectangleBorder(),
        title: const Stack(
          children: <Widget>[
            Text(
              'Edit Recipe',
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
                    } else if (value.length > 50) {
                      return 'Recipe Name can\'t exceed 50 characters';
                    }
                    return null;
                  },
                  buildCounter: (BuildContext context,
                      {required int currentLength,
                      required bool isFocused,
                      required int? maxLength}) {
                    // Don't show the character count
                    return null;
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
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: ingredient.inventoryID.isNotEmpty
                                ? ingredient.inventoryID
                                : null,
                            items: inventoryItems.map((inventoryItem) {
                              return DropdownMenuItem(
                                value: inventoryItem.ingredientID,
                                child: Text(inventoryItem.name,
                                    overflow: TextOverflow
                                        .ellipsis, // Prevent overflow
                                    maxLines: 1),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                ingredient.inventoryID = value!;
                                ingredient.inventoryName = inventoryItems
                                    .firstWhere(
                                        (item) => item.ingredientID == value)
                                    .name;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Select Ingredient',
                              border: OutlineInputBorder(
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
                            initialValue: ingredient.quantity > 0
                                ? ingredient.quantity.toString()
                                : '',
                            onChanged: (value) {
                              ingredient.quantity =
                                  double.tryParse(value) ?? 0.0;
                            },
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
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: ingredient.unitOfMeasure.isNotEmpty
                                ? ingredient.unitOfMeasure
                                : null,
                            items: const [
                              DropdownMenuItem(
                                  value: 'g',
                                  child: Text('Grams',
                                      overflow: TextOverflow
                                          .ellipsis, // Prevent overflow
                                      maxLines: 1)),
                              DropdownMenuItem(
                                  value: 'kg',
                                  child: Text('Kilograms',
                                      overflow: TextOverflow
                                          .ellipsis, // Prevent overflow
                                      maxLines: 1)),
                              // Add more units as needed
                            ],
                            onChanged: (value) {
                              setState(() {
                                ingredient.unitOfMeasure =
                                    value!; // Update the unit of measure
                              });
                            },
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
                // Instructions Field (moved under Ingredients and increased in size)
                TextFormField(
                  controller: instructionsController,
                  maxLines: 6, // Increased size
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
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                    foregroundColor: Colors.white, // White font color
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Get the recipe data
                      String recipeName = recipeNameController.text;
                      String instructions = instructionsController.text;
                      String prepTime = prepTimeController.text;
                      String cookTime = cookTimeController.text;
                      String servings = servingsController.text;

                      // Update Recipe API call
                      Map<String, dynamic> recipeResponse =
                          await ApiService.updateRecipe(
                        recipeId: (ModalRoute.of(context)!.settings.arguments
                                as Recipe)
                            .recipeId,
                        recipeName: recipeName,
                        instructions: instructions,
                        prepTime: int.tryParse(prepTime) ?? 0,
                        cookTime: int.tryParse(cookTime) ?? 0,
                        servings: int.tryParse(servings) ?? 1,
                        category: selectedCategory ?? 'Other',
                        description: '',
                      );

                      if (recipeResponse['status'] == 'success') {
                        // If recipe updated successfully, update ingredients
                        bool allIngredientsUpdated = true;

                        // Update ingredients with non-empty ingredient IDs
                        for (var ingredient in ingredients) {
                          if (ingredient.ingredientID.isNotEmpty) {
                            Map<String, dynamic> ingredientResponse =
                                await ApiService.updateIngredient(
                                    ingredient.ingredientID,
                                    ingredient.inventoryID,
                                    ingredient.quantity,
                                    ingredient.unitOfMeasure,
                                    ingredient.inventoryName);
                            if (ingredientResponse['status'] != 'success') {
                              allIngredientsUpdated = false;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Failed to update ingredient: ${ingredientResponse['reason']}')),
                              );
                            }
                          } else {
                            Map<String, dynamic> ingredientResponse =
                                await ApiService.addRecipeIngredient(
                                    recipeId: recipe.recipeId,
                                    quantity: ingredient.quantity,
                                    unitOfMeasure: ingredient.unitOfMeasure,
                                    inventoryId: ingredient.inventoryID);
                            if (ingredientResponse['status'] != 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Failed to add ingredient: ${ingredientResponse['reason']}')),
                              );
                            }
                          }
                        }

                        // Delete items in itemsToDelete list
                        for (var item in ingredientsToDelete) {
                          Map<String, dynamic> deleteResponse =
                              await ApiService.deleteIngredient(
                                  item.ingredientID);

                          if (deleteResponse['status'] != 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to delete ingredient: ${deleteResponse['reason']}')),
                            );
                          }
                        }

                        // Show success message if all operations succeeded
                        if (allIngredientsUpdated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Recipe and ingredients updated successfully!')),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Some ingredients failed to update.')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Failed to update recipe: ${recipeResponse['reason']}')),
                        );
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.update,
                    color: Colors.white,
                  ),
                  label: const Text('Update Recipe'),
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
