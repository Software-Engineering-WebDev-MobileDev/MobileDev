import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class ViewRecordsPage extends StatelessWidget {
  final Ingredient ingredient;

  const ViewRecordsPage({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Records for ${ingredient.name}',
            style: const TextStyle(color: Colors.white)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ingredient.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchRecords(), // Placeholder for fetching records from the database
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No records found'));
                  } else {
                    final records = snapshot.data!;
                    return ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Amount Used: ${record['amountUsed']}'),
                                Text('Recipe Used: ${record['recipeUsed']}'),
                                Text('Date/Time Used: ${record['dateTimeUsed']}'),
                                Text('Amount Started With: ${record['amountStartedWith']}'),
                                Text('Amount Left: ${record['amountLeft']}'),
                                Text('Date/Time Added: ${record['dateTimeAdded']}'),
                                Text('Expiration Date: ${record['expirationDate']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRecords() async {
    // Placeholder for fetching records from the database
    // TODO: Implement database connection and query to get ingredient records

    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    // Placeholder data for records
    return [
      {
        'amountUsed': 5,
        'recipeUsed': 'Recipe 1',
        'dateTimeUsed': '2024-01-01 12:00 PM',
        'amountStartedWith': 5,
        'amountLeft': 5,
        'dateTimeAdded': '2024-01-01 09:00 AM',
        'expirationDate': '2024-01-10'
      },
      {
        'amountUsed': 5,
        'recipeUsed': 'Recipe 2',
        'dateTimeUsed': '2024-01-02 02:00 PM',
        'amountStartedWith': 5,
        'amountLeft': 5,
        'dateTimeAdded': '2024-01-01 09:00 AM',
        'expirationDate': '2024-01-10'
      },
    ];
  }
}