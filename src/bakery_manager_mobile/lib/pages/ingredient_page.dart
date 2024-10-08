import 'dart:async'; // Import to use Future and Timer
import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class IngredientPage extends StatefulWidget {
  const IngredientPage({super.key});

  @override
  IngredientPageState createState() => IngredientPageState();
}

class IngredientPageState extends State<IngredientPage> {
  // Simulate an asynchronous operation that fetches ingredients to mock API return.
  Future<List<Ingredient>> _fetchIngredients() async {
    // Simulate network delay
    return await Future.delayed(const Duration(seconds: 1), () {
      return [
        Ingredient(
            ingredientID: "12345",
            name: 'Flour',
            quantity: 5.0,
            quantityUnit: 'kg',
            shelfLife: 10.0,
            shelfLifeUnit: "Weeks"),
        Ingredient(
            ingredientID: "12346",
            name: 'Sugar',
            quantity: 3.0,
            quantityUnit: 'kg',
            shelfLife: 10.0,
            shelfLifeUnit: "Weeks"),
        Ingredient(
            ingredientID: "12347",
            name: 'Eggs',
            quantity: 24.0,
            quantityUnit: 'kg',
            shelfLife: 10.0,
            shelfLifeUnit: "Weeks"),
        Ingredient(
            ingredientID: "12348",
            name: 'Milk',
            quantity: 2.5,
            quantityUnit: 'kg',
            shelfLife: 10.0,
            shelfLifeUnit: "Weeks"),
      ];
    });
  }

  late Future<List<Ingredient>> _futureIngredients;
  List<Ingredient> _ingredients = [];
  List<Ingredient> _filteredIngredients = [];

  // Controllers for adding new ingredient
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _quantityUnitController = TextEditingController();
  final TextEditingController _shelfLifeController = TextEditingController();
  final TextEditingController _shelfLifeUnitController =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureIngredients = _fetchIngredients(); // Fetch ingredients initially
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _quantityUnitController.dispose();
    _shelfLifeController.dispose();
    _shelfLifeUnitController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterIngredients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredIngredients = _ingredients;
      } else {
        _filteredIngredients = _ingredients
            .where((ingredient) =>
                ingredient.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showAddIngredientDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Ingredient'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _quantityUnitController,
                  decoration: const InputDecoration(labelText: 'Quantity Unit'),
                ),
                TextField(
                  controller: _shelfLifeController,
                  decoration: const InputDecoration(labelText: 'Shelf Life'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _shelfLifeUnitController,
                  decoration:
                      const InputDecoration(labelText: 'Shelf Life Unit'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _nameController.clear();
                _quantityController.clear();
                _quantityUnitController.clear();
                _shelfLifeController.clear();
                _shelfLifeUnitController.clear();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                // Validate input and add new ingredient
                String name = _nameController.text.trim();
                double? quantity =
                    double.tryParse(_quantityController.text.trim());
                String quantityUnit = _quantityUnitController.text.trim();
                double? shelfLife =
                    double.tryParse(_shelfLifeController.text.trim());
                String shelfLifeUnit = _shelfLifeUnitController.text.trim();

                if (name.isEmpty ||
                    quantity == null ||
                    quantityUnit.isEmpty ||
                    shelfLife == null ||
                    shelfLifeUnit.isEmpty) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill all fields correctly')),
                  );
                } else {
                  // Create new ingredient
                  Ingredient newIngredient = Ingredient(
                    ingredientID:
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    quantity: quantity,
                    quantityUnit: quantityUnit,
                    shelfLife: shelfLife,
                    shelfLifeUnit: shelfLifeUnit,
                  );
                  setState(() {
                    _ingredients.add(newIngredient);
                    _filterIngredients(_searchController.text);
                  });
                  Navigator.of(context).pop();
                  // Clear the text fields
                  _nameController.clear();
                  _quantityController.clear();
                  _quantityUnitController.clear();
                  _shelfLifeController.clear();
                  _shelfLifeUnitController.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteIngredient(Ingredient ingredient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete ${ingredient.name}?'),
          content: const Text('Are you sure you want to delete this ingredient?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  _ingredients.remove(ingredient);
                  _filterIngredients(_searchController.text);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${ingredient.name} has been deleted')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Inventory',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (query) {
                _filterIngredients(query);
              },
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterIngredients('');
                  },
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Ingredient>>(
                future: _futureIngredients,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    // Populate the ingredients list on the first load
                    if (_ingredients.isEmpty) {
                      _ingredients = snapshot.data!;
                      _filteredIngredients = _ingredients;
                    }
                    return ListView.builder(
                      itemCount: _filteredIngredients.length,
                      itemBuilder: (context, index) {
                        return _IngredientItem(
                          ingredient: _filteredIngredients[index],
                          onDelete: () {
                            _deleteIngredient(_filteredIngredients[index]);
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No ingredients available'));
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                _showAddIngredientDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add ingredient'),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientItem extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onDelete;

  const _IngredientItem({
    required this.ingredient,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to ingredient details page.
        Navigator.pushNamed(context, ingredientDetailsPageRoute,
            arguments: ingredient);
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: const Color(0xFFFDF1E0),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            title: Text(
              ingredient.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${ingredient.quantity} ${ingredient.quantityUnit}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ),
        ),
      ),
    );
  }
}
