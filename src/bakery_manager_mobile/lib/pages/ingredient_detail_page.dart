import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class IngredientDetailPage extends StatefulWidget {
  const IngredientDetailPage({super.key});

  @override
  IngredientDetailPageState createState() => IngredientDetailPageState();
}

class IngredientDetailPageState extends State<IngredientDetailPage> {
  late TextEditingController _quantityController;
  late TextEditingController _shelfLifeController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with empty values; these will be updated in build()
    _quantityController = TextEditingController();
    _shelfLifeController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _shelfLifeController.dispose();
    super.dispose();
  }

  Future<void> _saveIngredientDetails(Ingredient updatedIngredient) async {
    // Placeholder function for saving ingredient details to the database.
  }

  void _saveChanges(Ingredient ingredient) async {
    // Create a new Ingredient object with updated values
    Ingredient updatedIngredient = Ingredient(
      ingredientID: ingredient.ingredientID,
      name: ingredient.name,
      quantity: double.tryParse(_quantityController.text) ?? ingredient.quantity,
      quantityUnit: ingredient.quantityUnit,
      shelfLife: double.tryParse(_shelfLifeController.text) ?? ingredient.shelfLife,
      shelfLifeUnit: ingredient.shelfLifeUnit,
    );

    // Save updated ingredient details to the database
    await _saveIngredientDetails(updatedIngredient);

    // Ensure the widget is still mounted before calling Navigator
    if (mounted) {
      Navigator.pop(context, updatedIngredient);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the Ingredient object passed via the navigation route
    final Ingredient ingredient = ModalRoute.of(context)!.settings.arguments as Ingredient;

    // Pre-fill text controllers with current ingredient values
    _quantityController.text = ingredient.quantity.toString();
    _shelfLifeController.text = ingredient.shelfLife.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Ingredient', style: TextStyle(color: Colors.white)),
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
                'Edit Ingredient: ${ingredient.name}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity (${ingredient.quantityUnit})',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shelfLifeController,
                decoration: InputDecoration(
                  labelText: 'Shelf Life (${ingredient.shelfLifeUnit})',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  _saveChanges(ingredient);
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

