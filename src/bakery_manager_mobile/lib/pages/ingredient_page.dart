import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class IngredientPage extends StatefulWidget {
  const IngredientPage({super.key});

  @override
  IngredientPageState createState() => IngredientPageState();
}

class IngredientPageState extends State<IngredientPage> {
  // TODO: Replace with actual ingredient data from the database

  final List<Ingredient> _ingredients = [
    Ingredient(name: 'Flour', quantity: 5.0, unit: 'kg'),
    Ingredient(name: 'Sugar', quantity: 3.0, unit: 'kg'),
    Ingredient(name: 'Eggs', quantity: 24, unit: 'pcs'),
    Ingredient(name: 'Milk', quantity: 2.5, unit: 'L'),
  ];

  List<Ingredient> _filteredIngredients = [];

  @override
  void initState() {
    super.initState();
    _filteredIngredients = _ingredients;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Inventory', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: _filterIngredients,
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
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
              child: ListView.builder(
                itemCount: _filteredIngredients.length,
                itemBuilder: (context, index) {
                  return _IngredientItem(ingredient: _filteredIngredients[index]);
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // TODO: Implement add ingredient functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add ingredient functionality not implemented yet')),
                );
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
  const _IngredientItem({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Implement navigation to ingredient details page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ingredient.name} details page not implemented yet')),
        );
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ingredient.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${ingredient.quantity} ${ingredient.unit}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
