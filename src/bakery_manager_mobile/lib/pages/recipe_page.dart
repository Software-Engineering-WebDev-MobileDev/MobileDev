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
        //matched the theme of tha app bar to that of the home screen
        title: Stack(
          children: <Widget>[
            // Stroked text as border.
            Text(
              'All Recipes',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 30,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = const Color.fromARGB(255, 140,72,27),
              ),
            ),
            // Solid text as fill.
            const Text(
              'All Recipes',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 246,235,216),
              ),
            ),
          ],
        ),
        //center the title
        centerTitle: true,
        //changed the background color
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        //changed the color for both icons in the app bar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 140,72,27)),
          onPressed: () {
            Navigator.pop(context); // Back navigation
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Color.fromARGB(255, 140,72,27)),
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
            // changed the color scheme of the button and the icon/text in the button as well
            // Add Recipe Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 209, 125, 51),
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
              icon: const Icon(
                Icons.add,
                color: Color.fromARGB(255, 246,235,216),
              ),
              label: const Text(
                'Add recipe',
                style: TextStyle(
                  color: Color.fromARGB(255, 246,235,216),
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
      child: Container(
        decoration: const BoxDecoration(
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
              recipe.recipeName,
              style: const TextStyle(
                color: Color.fromARGB(255, 246,235,216),
              fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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