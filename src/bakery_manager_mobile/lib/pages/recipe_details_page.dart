import 'package:bakery_manager_mobile/models/recipe.dart';
import 'package:flutter/material.dart';


class RecipeDetailPage extends StatelessWidget {
  const RecipeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Recipe recipe = ModalRoute.of(context)?.settings.arguments as Recipe;
    // Use the recipeId to fetch and display recipe details

    return Scaffold(
      appBar: AppBar(title: Text(recipe.recipeName)),
      body: Center(
        child: Column(
          children: [
            Text('Instructions: \n${recipe.instructions}'),
          ],
        ),
      ),
    );
  }
}