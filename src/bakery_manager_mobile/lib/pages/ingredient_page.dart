import 'dart:async'; // Import to use Future and Timer
import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:bakery_manager_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class IngredientPage extends StatefulWidget {
  const IngredientPage({super.key});

  @override
  IngredientPageState createState() => IngredientPageState();
}

class IngredientPageState extends State<IngredientPage> {
  late Future<List<Ingredient>> _futureIngredients;
  List<Ingredient> _filteredIngredients = [];

  @override
  void initState() {
    super.initState();
    _futureIngredients =
        _fetchIngredients(); // Fetch ingredients from API initially
  }

  Future<List<Ingredient>> _fetchIngredients() async {
    // Call getInventory function
    final result = await ApiService.getInventory();

    if (result['status'] == 'success') {
      return result['inventory'];
    } else {
      throw Exception(result['reason']);
    }
  }

  void _filterIngredients(String query, List<Ingredient> ingredients) {
    setState(() {
      if (query.isEmpty) {
        _filteredIngredients = ingredients;
      } else {
        _filteredIngredients = ingredients
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
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        centerTitle: true,
        title: Stack(
          children: <Widget>[
            // Stroked text as border.
            Text(
              'Inventory',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 30,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = const Color.fromARGB(255, 140, 72, 27),
              ),
            ),
            // Solid text as fill.
            const Text(
              'Inventory',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 246, 235, 216),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 140, 72, 27)),
          onPressed: () {
            Navigator.pop(context); // Back navigation
          },
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.home, color: Color.fromARGB(255, 140, 72, 27)),
            onPressed: () {
              Navigator.popUntil(
                  context, ModalRoute.withName('/')); // Home navigation
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (query) {
                _futureIngredients.then((ingredients) {
                  _filterIngredients(query, ingredients);
                });
              },
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _filterIngredients('', _filteredIngredients);
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
                    // Populate the filtered ingredients list on the first load
                    if (_filteredIngredients.isEmpty) {
                      _filteredIngredients = snapshot.data!;
                    }
                    return ListView.builder(
                      itemCount: _filteredIngredients.length,
                      itemBuilder: (context, index) {
                        return _IngredientItem(
                            ingredient: _filteredIngredients[index]);
                      },
                    );
                  } else {
                    return const Center(
                        child: Text('No ingredients available'));
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
                // TODO: Implement add ingredient functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Add ingredient functionality not implemented yet')),
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
        //Navigate to ingredient details page.
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
                  '${ingredient.quantity} ${ingredient.quantityUnit}',
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
