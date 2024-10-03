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
      body: Center( // Ensure everything is centered on the page
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center items horizontally
            children: [
              // Display Ingredient name, quantity, and shelf life centered
              Text(
                ingredient.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center, // Center text
              ),
              const SizedBox(height: 16),
              Text(
                '• Quantity: ${ingredient.quantity} ${ingredient.quantityUnit}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center, // Center text
              ),
              const SizedBox(height: 8),
              Text(
                '• Shelf Life: ${ingredient.shelfLife} ${ingredient.shelfLifeUnit}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center, // Center text
              ),
              const SizedBox(height: 32), // Add space before the buttons

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // TODO: Implement View Records functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('View Records functionality not implemented yet')),
                  );
                },
                child: const Text('View Records', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 32), // Add space between buttons

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Make the button orange
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // TODO: Implement Edit Stock Levels functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Stock Levels functionality not implemented yet')),
                  );
                },
                child: const Text('Edit Stock Levels', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Make the button orange
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // TODO: Implement Edit Ingredient functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Ingredient functionality not implemented yet')),
                  );
                },
                child: const Text('Edit Ingredient Details', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Make the button orange
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // TODO: Implement Delete Ingredient functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Delete Ingredient functionality not implemented yet')),
                  );
                },
                child: const Text('Delete Ingredient', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
