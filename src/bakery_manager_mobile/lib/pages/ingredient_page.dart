import 'dart:async'; // Import to use Future and Timer
import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:bakery_manager_mobile/services/api_service.dart';
import 'package:bakery_manager_mobile/services/navigator_observer.dart';
import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import 'package:bakery_manager_mobile/pages/add_ingredients.dart';

class IngredientPage extends StatefulWidget {
  const IngredientPage({super.key});

  @override
  IngredientPageState createState() => IngredientPageState();
}

class IngredientPageState extends State<IngredientPage> {
  late Future<List<Ingredient>> _futureIngredients;
  List<Ingredient> _filteredIngredients = [];
  MyNavigatorObserver? _observer;

  @override
  void initState() {
    super.initState();
    _futureIngredients = _fetchIngredients();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final NavigatorState navigator = Navigator.of(context);
      final MyNavigatorObserver? observer =
          _observer = navigator.widget.observers.firstWhere(
        (observer) => observer is MyNavigatorObserver,
      ) as MyNavigatorObserver?;
      if (observer != null) {
        observer.onReturned = () async {
          // Refetch account details when returning from another page
          if (mounted) {
            setState(() {
              _futureIngredients = _fetchIngredients();
            });
          } // Trigger rebuild
        };
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _futureIngredients = _fetchIngredients();
  }

  @override
  void dispose() {
    if (_observer != null) {
      _observer!.onReturned = null; // Remove the callback to avoid memory leaks
    }
    super.dispose();
  }

  Future<List<Ingredient>> _fetchIngredients() async {
    // Call getInventory function
    final result = await ApiService.getInventory();

    if (result['status'] == 'success') {
      _filteredIngredients = await result['inventory'];
      return result['inventory'];
    } else {
      debugPrint("Failed");
      return [];
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
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 125, 51), // Matching the recipe page color
        shape: const RoundedRectangleBorder(),
        title: const Text(
          'All Ingredients',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white),
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
                backgroundColor: const Color.fromARGB(255, 209, 125, 51), // Match button color
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // TODO: Implement add ingredient functionality
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddIngredientPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Color.fromARGB(255, 246, 235, 216),),
              label: const Text(
                'Add ingredient',
                style: TextStyle(color: Colors.white), // Match text color
              ),
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
        // Navigate to ingredient details page.
        Navigator.pushNamed(context, ingredientDetailsPageRoute,
            arguments: ingredient);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: const Color.fromARGB(255, 246, 235, 216), // Match card color
        elevation: 4, // 3D effect
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ingredient.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 140, 72, 27), // Match text color
                  ),
                  overflow: TextOverflow.ellipsis, // Handle long text
                ),
              ),
              const SizedBox(width: 8), // Add spacing between text and quantity
              Text(
                '${ingredient.quantity}${ingredient.quantityUnit}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 140, 72, 27), // Match text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
