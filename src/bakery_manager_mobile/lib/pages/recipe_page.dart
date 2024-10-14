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
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  String _currentCategoryFilter = 'All'; // Track current category filter

  // Page Initialization Function
  @override
  void initState() {
    super.initState();
    //    _fetchRecipes(); // Lists all recipes
    _fetchRecipes(); // Fetch recipes initially

    // Adds the observer to the navigator
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final NavigatorState navigator = Navigator.of(context);
      final MyNavigatorObserver? observer =
          navigator.widget.observers.firstWhere(
        (observer) => observer is MyNavigatorObserver,
      ) as MyNavigatorObserver?;
      if (observer != null) {
        observer.onReturned = _fetchRecipes;
      }
    });
  }

  // Fetch recipes function
  void _fetchRecipes() {
    _futureRecipes = ApiService.getRecipes().then((response) {
      if (response['status'] == 'success') {
        List<Recipe> recipes = response['recipes'];
        setState(() {
          _filteredRecipes = recipes;
          _allRecipes = recipes;
        });
        return recipes;
      } else {
        throw Exception(
            'Failed to fetch recipes: ${response['message'] ?? 'Unknown error'}');
      }
    }).catchError((error) {
      return <Recipe>[]; // Return an empty list on error
    });
  }

  // Filter recipes function by search query
  void _filterRecipes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filterByCategory(
            _currentCategoryFilter, _allRecipes); // Restore category filter
      } else {
        _filteredRecipes = _filteredRecipes
            .where((recipe) =>
                recipe.recipeName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Filter by category function
  void _filterByCategory(String category, List<Recipe> recipes) {
    setState(() {
      _currentCategoryFilter = category;
      if (category == 'All') {
        _filteredRecipes = recipes;
      } else {
        _filteredRecipes =
            recipes.where((recipe) => recipe.category == category).toList();
      }
    });
  }

    // Build category filter button
    Widget _buildCategoryFilterButton(String category, List<Recipe> recipes) {
      bool isSelected = _currentCategoryFilter == category;
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color.fromARGB(255, 140, 72, 27) : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          _filterByCategory(category, recipes);
        },
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white, // Text color is white in both cases
          ),
        ),
      );
    }

  // Page Content Build Function
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
              'Home',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white
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

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Horizontal category filter bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryFilterButton('All', _allRecipes),
                  const SizedBox(width: 8),
                  _buildCategoryFilterButton('Bread', _allRecipes),
                  const SizedBox(width: 8),
                  _buildCategoryFilterButton('Muffins', _allRecipes),
                  const SizedBox(width: 8),
                  _buildCategoryFilterButton('Cookies', _allRecipes),
                  const SizedBox(width: 8),
                  _buildCategoryFilterButton('Pastry', _allRecipes),
                  const SizedBox(width: 8),
                  _buildCategoryFilterButton('Cake', _allRecipes),
                  const SizedBox(width: 8),
                  _buildCategoryFilterButton('Pie', _allRecipes),
                  const SizedBox(width: 8),
                  _buildCategoryFilterButton('Cupcakes', _allRecipes),
                  const SizedBox(width: 8),
                  _buildCategoryFilterButton('Dessert', _allRecipes),
                ],
              ),
            ),
            const SizedBox(height: 16),

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
                        return _RecipeItem(recipe: _filteredRecipes[index]);
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
                backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Navigate to AddRecipePage
                Navigator.pushNamed(context, addRecipePageRoute);
              },
              icon: const Icon(
                Icons.add,
                color: Color.fromARGB(255, 246, 235, 216),
              ),
              label: const Text(
                'Add recipe',
                style: TextStyle(
                  color: Color.fromARGB(255, 246, 235, 216),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeItem extends StatelessWidget {
  final Recipe recipe;
  const _RecipeItem({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to the target page when tapped
        Navigator.pushNamed(context, recipeDetailsPageRoute, arguments: recipe);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: const Color.fromARGB(255, 246, 235, 216),
        elevation: 4, // 3D effect
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            recipe.recipeName,
            style: const TextStyle(
              color: Color.fromARGB(255, 209, 125, 51),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}