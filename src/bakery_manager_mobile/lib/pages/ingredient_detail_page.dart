import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import 'package:bakery_manager_mobile/pages/edit_ingredients.dart';
import 'package:bakery_manager_mobile/pages/edit_stock.dart';
import 'package:bakery_manager_mobile/pages/viewrecords.dart';

class IngredientDetailPage extends StatelessWidget {
  const IngredientDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the Ingredient object passed via the navigation route
    final Ingredient ingredient =
        ModalRoute.of(context)!.settings.arguments as Ingredient;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Details',
            style: TextStyle(color: Colors.white)),
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
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center items horizontally
            children: [
              // Display Ingredient name, quantity, and shelf life centered
              Text(
                ingredient.name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center, // Center text
              ),
              const SizedBox(height: 16),
              Text(
                '• Quantity: ${ingredient.quantity} g',
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

              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ViewRecordsPage(ingredient: ingredient),
                          ),
                        );
                      },
                      child: const Text('View Records',
                          style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(
                        height:
                            16), // Add space between buttons// Add space between buttons

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange, // Make the button orange
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditStockPage(ingredient: ingredient),
                          ),
                        );
                      },
                      child: const Text('Edit Stock Levels',
                          style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange, // Make the button orange
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditIngredientPage(ingredient: ingredient),
                          ),
                        );
                      },
                      child: const Text('Edit Ingredient Details',
                          style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange, // Make the button orange
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Implement Delete Ingredient functionality
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Ingredient'),
                              content: const Text(
                                  'Are you sure you want to delete this ingredient?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Delete'),
                                  onPressed: () {
                                    // TODO: Implement delete functionality here
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Ingredient deleted')),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Delete Ingredient',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
