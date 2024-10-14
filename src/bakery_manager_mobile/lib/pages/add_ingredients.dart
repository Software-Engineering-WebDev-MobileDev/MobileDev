import 'package:flutter/material.dart';

class AddIngredientPage extends StatefulWidget {
  const AddIngredientPage({super.key});

  @override
  _AddIngredientPageState createState() => _AddIngredientPageState();
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _quantityUnitController = TextEditingController();
  final TextEditingController _shelfLifeController = TextEditingController();
  final TextEditingController _shelfLifeUnitController = TextEditingController();
  final TextEditingController _reorderAmountController = TextEditingController();
  final TextEditingController _reorderUnitController = TextEditingController();

  void _addIngredient() {
    if (_formKey.currentState!.validate()) {
      // TODO: Add logic to connect to the database and add the ingredient
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingredient added successfully')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Ingredient', style: TextStyle(color: Colors.white)),
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
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  } else if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityUnitController,
                decoration: const InputDecoration(labelText: 'Quantity Unit'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity unit';
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
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _addIngredient,
                child: const Text('Add Ingredient', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}