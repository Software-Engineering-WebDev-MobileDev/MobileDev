import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
// import '../services/api_service.dart';  // Commented out for now

class EditRecipePage extends StatefulWidget {
  const EditRecipePage({super.key});

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  late TextEditingController recipeNameController;
  late TextEditingController instructionsController;
  late Future<List<Map<String, dynamic>>> _futureIngredients;
  late Recipe recipe;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers here to avoid LateInitializationError
    recipeNameController = TextEditingController();
    instructionsController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the passed recipe object from arguments
    final Recipe? passedRecipe = ModalRoute.of(context)?.settings.arguments as Recipe?;
    
    if (passedRecipe != null) {
      recipe = passedRecipe;

      // Initialize the text controllers with the recipe data
      recipeNameController.text = recipe.recipeName;
      instructionsController.text = recipe.instructions;

      // Fetch the ingredients for this recipe (using mock data for now)
      _futureIngredients = _fetchIngredients(recipe.recipeId);
    } else {
      // Handle the case where recipe is not passed (optional)
      print('Error: No recipe passed to EditRecipePage');
      Navigator.pop(context); // Go back if no recipe is found
    }
  }

  @override
  void dispose() {
    // Dispose controllers when done to avoid memory leaks
    recipeNameController.dispose();
    instructionsController.dispose();
    super.dispose();
  }

  // Mock fetch ingredients function (simulated as a future)
  Future<List<Map<String, dynamic>>> _fetchIngredients(String recipeId) async {
    return await Future.delayed(const Duration(seconds: 1), () {
      return [
        {'ingredientID': '1', 'name': 'Flour', 'quantity': 1.0, 'unit': 'kg'},
        {'ingredientID': '2', 'name': 'Sugar', 'quantity': 0.5, 'unit': 'kg'},
        {'ingredientID': '3', 'name': 'Eggs', 'quantity': 12.0, 'unit': 'pieces'},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipe', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                'Ingredients:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // FutureBuilder to load ingredients from mock data or API
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureIngredients,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final ingredients = snapshot.data!;

                    return Column(
                      children: [
                        ...ingredients.asMap().entries.map((entry) {
                          int idx = entry.key;
                          var ingredient = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    onChanged: (value) => ingredient['name'] = value,
                                    controller: TextEditingController(text: ingredient['name']),
                                    decoration: InputDecoration(
                                      hintText: 'Ingredient ${idx + 1} Name',
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    onChanged: (value) => ingredient['quantity'] = double.tryParse(value) ?? 0.0,
                                    keyboardType: TextInputType.number,
                                    controller: TextEditingController(text: ingredient['quantity'].toString()),
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
                                    onChanged: (value) => ingredient['unit'] = value,
                                    controller: TextEditingController(text: ingredient['unit']),
                                    decoration: const InputDecoration(
                                      hintText: 'Unit',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                    ),
                                  ),
                                ),
                                if (idx != 0)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        ingredients.removeAt(idx); // Remove ingredient from the list
                                      });
                                    },
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              ingredients.add({
                                'ingredientID': '',
                                'name': '',
                                'quantity': 0.0,
                                'unit': '',
                              });
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Ingredient'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: Text('No ingredients available'));
                  }
                },
              ),
              const SizedBox(height: 16),
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, recipeDetailsPageRoute, arguments: recipe);
                },
                child: const Text('Update Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}