import 'package:bakery_manager_mobile/services/api_service.dart';
import 'package:flutter/material.dart';

class AddIngredientPage extends StatefulWidget {
  const AddIngredientPage({super.key});

  @override
  _AddIngredientPageState createState() => _AddIngredientPageState();
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shelfLifeController = TextEditingController();
  final TextEditingController _shelfLifeUnitController =
      TextEditingController();
  final TextEditingController _reorderAmountController =
      TextEditingController();
  final TextEditingController _reorderUnitController = TextEditingController();

  void _addIngredient() async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final double reorderAmount = double.parse(_reorderAmountController.text);
      final String reorderUnit = _reorderUnitController.text;
      final int? shelfLife = _shelfLifeController.text.isNotEmpty
          ? int.parse(_shelfLifeController.text)
          : null;
      final String? shelfLifeUnit = _shelfLifeUnitController.text.isNotEmpty
          ? _shelfLifeUnitController.text
          : null;

      // Call the function that interacts with the API
      final result = await ApiService.addInventoryItem(
        name: name,
        reorderAmount: reorderAmount,
        reorderUnit: reorderUnit,
        shelfLife: shelfLife,
        shelfLifeUnit: shelfLifeUnit,
      );

      // Check the result and show appropriate message
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient added successfully')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['reason']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Add Ingredient', style: TextStyle(color: Colors.white)),
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the ingredient name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _shelfLifeController,
                decoration: const InputDecoration(labelText: 'Shelf Life'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the shelf life';
                  } else if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _shelfLifeUnitController,
                decoration: const InputDecoration(labelText: 'Shelf Life Unit'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the shelf life unit';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _reorderAmountController,
                decoration: const InputDecoration(labelText: 'Reorder Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the reorder amount';
                  } else if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _reorderUnitController,
                decoration: const InputDecoration(labelText: 'Reorder Unit'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the reorder unit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _addIngredient,
                child: const Text('Add Ingredient',
                    style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
