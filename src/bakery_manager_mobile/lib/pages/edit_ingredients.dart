import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class EditIngredientPage extends StatefulWidget {
  final Ingredient ingredient;

  const EditIngredientPage({super.key, required this.ingredient});

  @override
  _EditIngredientPageState createState() => _EditIngredientPageState();
}

class _EditIngredientPageState extends State<EditIngredientPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _quantityUnitController;
  late TextEditingController _shelfLifeController;
  late TextEditingController _shelfLifeUnitController;
  late TextEditingController _reorderAmountController;
  late TextEditingController _reorderUnitController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient.name);
    _quantityController = TextEditingController(text: widget.ingredient.quantity.toString());
    _shelfLifeController = TextEditingController(text: widget.ingredient.shelfLife.toString());
    _shelfLifeUnitController = TextEditingController(text: widget.ingredient.shelfLifeUnit);
    _reorderAmountController = TextEditingController(text: widget.ingredient.reorderAmount.toString());
    _reorderUnitController = TextEditingController(text: widget.ingredient.reorderUnit);
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // TODO: Add logic to connect to the database and update the ingredient
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingredient updated successfully')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Ingredient', style: TextStyle(color: Colors.white)),
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
                onPressed: _saveChanges,
                child: const Text('Save Changes', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}