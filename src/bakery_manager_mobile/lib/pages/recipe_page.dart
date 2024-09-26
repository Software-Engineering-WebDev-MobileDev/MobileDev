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
  String _currentCategoryFilter = 'All'; // Track current category filter

  // Page Initialization Function
  @override
  void initState() {
    super.initState();
    //    _fetchRecipes(); // Lists all recipes
    _futureRecipes = _fetchRecipes(); // Fetch recipes initially

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

  // // Fetch recipes function
  // void _fetchRecipes() {
  //   _futureRecipes = ApiService.getRecipes().then((response) {
  //     if (response['status'] == 'success') {
  //       List<Recipe> recipes = response['recipes'];
  //       setState(() {
  //         _filteredRecipes = recipes;
  //       });
  //       return recipes;
  //     } else {
  //       throw Exception(
  //           'Failed to fetch recipes: ${response['message'] ?? 'Unknown error'}');
  //     }
  //   }).catchError((error) {
  //     return <Recipe>[]; // Return an empty list on error
  //   });
  // }

  // Simulate an asynchronous operation to fetch recipes
  Future<List<Recipe>> _fetchRecipes() async {
    return await Future.delayed(const Duration(seconds: 1), () {
      List<Recipe> recipes = [
        Recipe(
          recipeId: '1',
          recipeName: 'Banana Bread',
          recipeCategory: 'Bread',
          instructions: 'Mix bananas, flour, sugar, and bake for 60 minutes.',
          scalingFactor: 1,
        ),
        Recipe(
          recipeId: '2',
          recipeName: 'Blueberry Muffins',
          recipeCategory: 'Muffins',
          instructions: 'Fold blueberries into the batter and bake for 25 minutes.',
          scalingFactor: 1,
        ),
        Recipe(
          recipeId: '3',
          recipeName: 'Chocolate Chip Cookies',
          recipeCategory: 'Cookies',
          instructions: 'Mix cookie dough with chocolate chips and bake for 15 minutes.',
          scalingFactor: 1,
        ),
        Recipe(
          recipeId: '4',
          recipeName: 'Cinnamon Rolls',
          recipeCategory: 'Pastry',
          instructions: 'Roll dough with cinnamon filling, bake, and top with icing.',
          scalingFactor: 1,
        ),
        Recipe(
          recipeId: '5',
          recipeName: 'Lemon Drizzle Cake',
          recipeCategory: 'Cake',
          instructions: 'Bake lemon-flavored cake and drizzle with lemon syrup.',
          scalingFactor: 1,
        ),
        Recipe(
          recipeId: '6',
          recipeName: 'Apple Pie',
          recipeCategory: 'Pie',
          instructions: 'Fill pie crust with apples and bake for 50 minutes.',
          scalingFactor: 1,
        ),
        Recipe(
          recipeId: '7',
          recipeName: 'Sourdough Bread',
          recipeCategory: 'Bread',
          instructions: 'Mix sourdough starter, flour, and water, then bake.',
          scalingFactor: 1,
        ),
        Recipe(
          recipeId: '8',
          recipeName: 'Pumpkin Spice Cupcakes',
          recipeCategory: 'Cupcakes',
          instructions: 'Mix pumpkin spice batter and bake for 20 minutes.',
          scalingFactor: 1,
        ),
        Recipe(
          recipeId: '9',
          recipeName: 'Brownies',
          recipeCategory: 'Dessert',
          instructions: 'Mix chocolate batter and bake for 30 minutes.',
          scalingFactor: 1,
        ),
        Recipe(
          recipeId: '10',
          recipeName: 'Croissants',
          recipeCategory: 'Pastry',
          instructions: 'Layer butter and dough, roll, and bake for 20 minutes.',
          scalingFactor: 1,
        ),
      ];
      // Before calling setState, ensure the widget is still mounted
      if (mounted) {
        setState(() {
          _filteredRecipes = recipes;
        });
      }
      return recipes;
    });
  }

  // Filter recipes function
  void _filterRecipes(String query) {
    setState(() {
      if (query.isEmpty) {
        _fetchRecipes();
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
        _filteredRecipes = recipes
            .where((recipe) => recipe.recipeCategory == category)
            .toList();
      }
    });
  }

  // Build category filter button
  Widget _buildCategoryFilterButton(String category, List<Recipe> recipes) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _currentCategoryFilter == category ? Colors.orange : Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () {
        _filterByCategory(category, recipes);
      },
      child: Text(category),
    );
  }

  // Page Content Build Function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Recipes', style: TextStyle(color: Colors.white)),
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
            // Horizontal category filter bar
            FutureBuilder<List<Recipe>>(
              future: _futureRecipes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No recipes found');
                } else {
                  final recipes = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryFilterButton('All', recipes),
                        const SizedBox(width: 8),
                        _buildCategoryFilterButton('Bread', recipes),
                        const SizedBox(width: 8),
                        _buildCategoryFilterButton('Muffins', recipes),
                        const SizedBox(width: 8),
                        _buildCategoryFilterButton('Cookies', recipes),
                        const SizedBox(width: 8),
                        _buildCategoryFilterButton('Pastry', recipes),
                        const SizedBox(width: 8),
                        _buildCategoryFilterButton('Cake', recipes),
                        const SizedBox(width: 8),
                        _buildCategoryFilterButton('Pie', recipes),
                        const SizedBox(width: 8),
                        _buildCategoryFilterButton('Cupcakes', recipes),
                        const SizedBox(width: 8),
                        _buildCategoryFilterButton('Dessert', recipes),
                      ],
                    ),
                  );
                }
              },
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
                        return _RecipeItem(
                          recipe: _filteredRecipes[index],);
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
  final Recipe recipe;
  const _RecipeItem({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to the target page when tapped
        Navigator.pushNamed(context, recipeDetailsPageRoute, arguments: recipe);
      },
      child: Container(
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
              recipe.recipeName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}