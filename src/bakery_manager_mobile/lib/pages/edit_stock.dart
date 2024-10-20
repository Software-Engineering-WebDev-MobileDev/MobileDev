import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:bakery_manager_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class EditStockPage extends StatefulWidget {
  final Ingredient ingredient;

  const EditStockPage({super.key, required this.ingredient});

  @override
  _EditStockPageState createState() => _EditStockPageState();
}

class _EditStockPageState extends State<EditStockPage> {
  late int _stockAmount;
  final TextEditingController _stockController = TextEditingController();
  String _unit = 'grams'; // Default unit

  @override
  void initState() {
    super.initState();
    _stockAmount = 0;
    _stockController.text = '0';
  }

  void _increaseStock() {
    setState(() {
      _stockAmount++;
      _stockController.text = '$_stockAmount';
    });
  }

  void _decreaseStock() {
    // Convert the stock amount to grams for comparison
    int stockInGrams =
        _unit == 'kilograms' ? _stockAmount * 1000 : _stockAmount;

    double quantityInGrams = widget.ingredient.quantityUnit == 'kg'
        ? widget.ingredient.quantity * 1000
        : widget.ingredient.quantity;

    // Check if the decrease is allowed
    if (stockInGrams > -quantityInGrams) {
      setState(() {
        _stockAmount--;
        _stockController.text = '$_stockAmount';
      });
    } else {
      // Optionally, show a message if trying to decrease beyond the limit
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cannot decrease stock beyond current inventory')),
      );
    }
  }

  void _onTextChanged(String value) {
    final int? newValue = int.tryParse(value);
    if (newValue != null) {
      setState(() {
        _stockAmount = newValue;
      });
    }
  }

  void _saveChanges() async {
    try {
      // Convert the stock amount to grams for submission
      double changeAmount = _unit == 'kilograms'
          ? _stockAmount * 1000.0
          : _stockAmount.toDouble();
      double quantityInGrams = widget.ingredient.quantityUnit == 'kg'
          ? widget.ingredient.quantity * 1000
          : widget.ingredient.quantity;

      // Check if the changeAmount is valid
      if (changeAmount == 0) {
        throw Exception("Stock changes cannot be zero");
      }

      // Check if the changeAmount would cause stock to go negative
      if ((quantityInGrams + changeAmount) < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Cannot adjust stock below zero. Current stock is $quantityInGrams grams.")),
        );
        return;
      }

      final result = await ApiService.inventoryChange(
        changeAmount: changeAmount,
        inventoryId: widget.ingredient.ingredientID,
        description: 'Manual Stock Update',
      );

      if (!mounted) return;
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock updated successfully')),
        );
        Navigator.of(context)
            .popUntil(ModalRoute.withName(ingredientPageRoute));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${result['reason']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Stock',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor:
            const Color.fromARGB(255, 209, 125, 51), // Updated color to match
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Stock Adjustment For ${widget.ingredient.name}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'Enter value to adjust stock',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: _onTextChanged,
            ),
            // Dropdown for unit selection
            DropdownButton<String>(
              value: _unit,
              items: <String>['grams', 'kilograms']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(_capitalizeFirstLetter(value)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _unit = newValue!;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 32),
                  onPressed: _decreaseStock,
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 32),
                  onPressed: _increaseStock,
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                    255, 209, 125, 51), // Updated color to match
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _saveChanges,
              child: const Text('Save Changes',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
