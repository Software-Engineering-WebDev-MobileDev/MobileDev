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

  @override
  void initState() {
    super.initState();
    _stockAmount = widget.ingredient.quantity.toInt();
    _stockController.text = '$_stockAmount';
  }

  void _increaseStock() {
    setState(() {
      _stockAmount++;
      _stockController.text = '$_stockAmount';
    });
  }

  void _decreaseStock() {
    if (_stockAmount > 0) {
      setState(() {
        _stockAmount--;
        _stockController.text = '$_stockAmount';
      });
    }
  }

  void _onTextChanged(String value) {
    final int? newValue = int.tryParse(value);
    if (newValue != null && newValue >= 0) {
      setState(() {
        _stockAmount = newValue;
      });
    }
  }

  void _saveChanges() {
    // TODO: Add logic to connect to the database and update the stock amount
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stock updated successfully')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Stock', style: TextStyle(color: Colors.white)),
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Current Stock for ${widget.ingredient.name}',
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
            // Removed the number under the text box
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
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _saveChanges,
              child: const Text('Save Changes', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
