import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../assets/constants.dart';
import '../models/recipe.dart';
import '../services/navigator_observer.dart';

class AllRecipesPage extends StatefulWidget {
  const AllRecipesPage({super.key});

  @override
  AllRecipesPageState createState() => AllRecipesPageState();
}


class AllRecipesPageState extends State<AllRecipesPage> {
  late Future<List<Recipe>> _futureRecipes;
  List<Recipe> _filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    _fetchRecipes(); // Lists all recipes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final NavigatorState navigator = Navigator.of(context);
      final MyNavigatorObserver? observer = navigator.widget.observers.firstWhere(
        (observer) => observer is MyNavigatorObserver,
      ) as MyNavigatorObserver?;  
      if (observer != null) {
        observer.onReturned = _fetchRecipes;
      }
    });
  }

  void _fetchRecipes() {
    _futureRecipes = ApiService.getRecipes();
    _futureRecipes.then((recipes) {
      setState(() {
        _filteredRecipes = recipes;
      });
    });
  }

  void _filterRecipes(String query) {
    setState(() {
      if (query.isEmpty) {
        _fetchRecipes();
      } else {
        _filteredRecipes = _filteredRecipes
            .where((recipe) => recipe.recipeName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Recipes',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Back navigation
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/')); // Home navigation
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              onChanged: _filterRecipes, // Search feature
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    // Clear search field
                    _filterRecipes('');
                  },
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List of recipes
            Expanded(
              child: FutureBuilder<List<Recipe>>(
                future: _futureRecipes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No recipes found');
                  } else {
                    return ListView.builder(
                      itemCount: _filteredRecipes.length,
                      itemBuilder: (context, index) {
                        return _RecipeItem(name: _filteredRecipes[index].recipeName);
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Add Recipe Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Navigate to AddRecipePage
                Navigator.pushNamed(context, addRecipePageRoute);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add recipe'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeItem extends StatelessWidget {
  final String name;

  const _RecipeItem({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow under items
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4), // Shadow offset
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: const Color(0xFFFDF1E0),
        elevation: 4, // 3D effect
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
