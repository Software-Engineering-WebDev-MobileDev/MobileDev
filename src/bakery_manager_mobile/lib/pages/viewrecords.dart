import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import '../models/ingredient.dart';
import '../services/api_service.dart'; // Assume this is where the API call is defined

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
                future: _fetchRecords(ingredient.ingredientID),
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
                        final int changeAmount = record['ChangeAmount'];
                        final String? description = record['Description'];
                        final String? expirationDate = record['ExpirationDate'];
                        final String dateUsed = record['Date'];

                        // Parse and format dates to local time
                        final formattedDateUsed = _formatDateToLocal(dateUsed);
                        final formattedExpirationDate = expirationDate != null
                            ? _formatDateToLocal(expirationDate)
                            : null;

                        return Card(
                          elevation: 4,
                          color: changeAmount < 0
                              ? Colors.red[100]
                              : Colors.green[100], // Set card color
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Amount Used: $changeAmount',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                if (description != null &&
                                    description.isNotEmpty)
                                  Text('Description: $description'),
                                Text('Date/Time Used: $formattedDateUsed'),
                                if (formattedExpirationDate != null)
                                  Text(
                                      'Expiration Date: $formattedExpirationDate'),
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

  Future<List<Map<String, dynamic>>> _fetchRecords(String ingredientId) async {
    // Make an API call to fetch the records for the given ingredient
    final response = await ApiService.fetchIngredientHistory(
      inventoryId: ingredientId,
    );

    if (response['status'] == 'success') {
      return List<Map<String, dynamic>>.from(response['content']);
    } else {
      throw Exception(response['reason'] ?? 'Failed to fetch records');
    }
  }

  // Helper function to format a date string to local time
  String _formatDateToLocal(String dateString) {
    final DateTime parsedDate = DateTime.parse(dateString).toLocal();
    return DateFormat('yyyy-MM-dd hh:mm a')
        .format(parsedDate); // Formatting date to local time
  }
}
