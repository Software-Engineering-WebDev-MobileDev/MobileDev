import 'package:bakery_manager_mobile/services/api_service.dart';
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

    // Check if quantity is below the reorder amount
    bool isLowStock = ingredient.quantity < ingredient.reorderAmount;
    // Check if quantity is within caution range (20% of reorder amount)
    bool isCautionStock =
        ingredient.quantity <= (1.2 * ingredient.reorderAmount);

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
              const SizedBox(height: 16),

              // Display low stock warning if quantity is less than reorder amount
              if (isLowStock)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'Warning: Stock is low! Order more ${ingredient.name}.',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

              // Display caution message if quantity is close to reorder amount
              if (isCautionStock && !isLowStock)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Caution: Stock is getting low! \nOrder more ${ingredient.name} soon.',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16), // Add space before the buttons

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
                        // Show dialog to confirm deletion
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
                                  onPressed: () async {
                                    // Fetch the history records for this ingredient
                                    final historyResponse =
                                        await ApiService.fetchIngredientHistory(
                                            inventoryId:
                                                ingredient.ingredientID);

                                    if (historyResponse['status'] ==
                                        'success') {
                                      // Iterate through the history records and delete each one
                                      for (var record
                                          in historyResponse['content']) {
                                        final deleteResponse = await ApiService
                                            .deleteInventoryHistory(
                                          histId: record[
                                              'HistID'], // Use the appropriate field for history ID
                                        );

                                        if (deleteResponse['status'] !=
                                            'success') {
                                          // Handle the error as needed (you may want to log or show an error message)
                                        }
                                      }

                                      // Now delete the ingredient itself
                                      final deleteIngredientResponse =
                                          await ApiService.deleteInventoryItem(
                                        inventoryId: ingredient.ingredientID,
                                      );

                                      if (deleteIngredientResponse['status'] ==
                                          'success') {
                                        Navigator.of(context).pop(); // Close the dialog
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Ingredient and its history deleted')),
                                        );
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Failed to delete ingredient: ${deleteIngredientResponse['reason']}')),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to fetch history: ${historyResponse['reason']}')),
                                      );
                                    }
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
