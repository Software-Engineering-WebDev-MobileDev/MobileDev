import 'package:flutter/material.dart';

class AllRecipesPage extends StatefulWidget {
  const AllRecipesPage({super.key});

  @override
  AllRecipesPageState createState() => AllRecipesPageState();
}

// add safe area

class AllRecipesPageState extends State<AllRecipesPage> {
  final List<String> _recipes = ['Sourdough', 'Baguette', 'Croissant', 'Ciabatta'];
  List<String> _filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    _filteredRecipes = _recipes; // Lists all recipes
  }

  void _filterRecipes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecipes = _recipes;
      } else {
        _filteredRecipes = _recipes
            .where((recipe) => recipe.toLowerCase().contains(query.toLowerCase()))
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
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    // Clear search field
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
              child: ListView.builder(
                itemCount: _filteredRecipes.length,
                itemBuilder: (context, index) {
                  return _RecipeItem(name: _filteredRecipes[index]);
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddRecipePage()),
                );
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
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.5), // Shadow under items
        //     spreadRadius: 2,
        //     blurRadius: 8,
        //     offset: const Offset(0, 4), // Shadow offset
        //   ),
        // ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: const Color.fromARGB(255, 209,126,51),
        elevation: 4, // 3D effect
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            name,
            style: const TextStyle(
              color: Color.fromARGB(255, 246,235,216),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          // child: Stack(
          //   children: [
          //     Text(
          //       name,
          //       style: TextStyle(
          //         fontSize: 16,
          //         foreground: Paint()
          //         ..style = PaintingStyle.stroke
          //         ..strokeWidth = 6
          //         ..color = const Color.fromARGB(255, 140,72,27)
          //       ),
          //     ),
          //     Text(
          //       name,
          //       style: const TextStyle(
          //         color: Color.fromARGB(255, 246,235,216),
          //         fontSize: 16,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ],
          // ), 
        ),
      ),
    );
  }
}

class AddRecipePage extends StatelessWidget {
  const AddRecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add a New Recipe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Recipe Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                //Save recipe
              },
              child: const Text('Save Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
