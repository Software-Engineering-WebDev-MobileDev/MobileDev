import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:bakery_manager_mobile/services/api_service.dart';
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
  late TextEditingController _shelfLifeController;
  late TextEditingController _shelfLifeUnitController;
  late TextEditingController _reorderAmountController;
  late TextEditingController _reorderUnitController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient.name);
    _shelfLifeController = TextEditingController(text: widget.ingredient.shelfLife.toString());
    _shelfLifeUnitController = TextEditingController(text: widget.ingredient.shelfLifeUnit);
    _reorderAmountController = TextEditingController(text: widget.ingredient.reorderAmount.toString());
    _reorderUnitController = TextEditingController(text: widget.ingredient.reorderUnit);
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Gather the data from the controllers
      final name = _nameController.text;
      final shelfLife = _shelfLifeController.text.isNotEmpty ? _shelfLifeController.text : null;
      final shelfLifeUnit = _shelfLifeUnitController.text.isNotEmpty ? _shelfLifeUnitController.text : null;
      final reorderAmount = int.tryParse(_reorderAmountController.text) ?? 0;
      final reorderUnit = _reorderUnitController.text;

      // Call the update API
      final response = await ApiService.updateInventoryItem(
        inventoryId: widget.ingredient.ingredientID,
        name: name,
        shelfLife: shelfLife,
        shelfLifeUnit: shelfLifeUnit,
        reorderAmount: reorderAmount,
        reorderUnit: reorderUnit,
      );

      // Handle the response
      if(!mounted) return;
      
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient updated successfully')),
        );
        Navigator.of(context).popUntil(ModalRoute.withName(ingredientPageRoute)); // Close the page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response['reason']}')),
        );
      }
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
                  } else if (int.tryParse(value) == null) {
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
