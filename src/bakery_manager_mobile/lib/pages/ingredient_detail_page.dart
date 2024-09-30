import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class IngredientDetailPage extends StatelessWidget {
  const IngredientDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the Ingredient object passed via the navigation route
    final Ingredient ingredient = ModalRoute.of(context)!.settings.arguments as Ingredient;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingredient: ${ingredient.name}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '• Quantity: ${ingredient.quantity} ${ingredient.quantityUnit}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '• Shelf Life: ${ingredient.shelfLife} ${ingredient.shelfLifeUnit}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '• Ingredient ID: ${ingredient.ingredientID}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
