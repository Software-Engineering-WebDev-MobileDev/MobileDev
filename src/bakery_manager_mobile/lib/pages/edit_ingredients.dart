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
  String? _shelfLifeUnit; // Changed from controller to variable
  late TextEditingController _reorderAmountController;
  String? _reorderUnit; // Changed from controller to variable

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient.name);
    _shelfLifeController = TextEditingController(text: widget.ingredient.shelfLife.toString());
    _shelfLifeUnit = widget.ingredient.shelfLifeUnit; // Initialize with current unit
    _reorderAmountController = TextEditingController(text: widget.ingredient.reorderAmount.toString());
    _reorderUnit = widget.ingredient.reorderUnit; // Initialize with current unit
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Gather the data from the controllers
      final name = _nameController.text;
      final shelfLife = int.tryParse(_shelfLifeController.text);
      final reorderAmount = double.tryParse(_reorderAmountController.text) ?? 0;

      // Call the update API
      final response = await ApiService.updateInventoryItem(
        inventoryId: widget.ingredient.ingredientID,
        name: name,
        shelfLife: shelfLife,
        shelfLifeUnit: _shelfLifeUnit,
        reorderAmount: reorderAmount,
        reorderUnit: _reorderUnit!,
      );

      // Handle the response
      if (!mounted) return;

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient updated successfully')),
        );
        Navigator.of(context).popUntil(ModalRoute.withName(ingredientPageRoute));
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
        title: const Text('Edit Ingredient', style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
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
              const SizedBox(height: 16),
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the ingredient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Shelf Life Field
              TextFormField(
                controller: _shelfLifeController,
                decoration: const InputDecoration(
                  labelText: 'Shelf Life',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the shelf life';
                  } else if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Shelf Life Unit Dropdown
              DropdownButtonFormField<String>(
                value: _shelfLifeUnit,
                items: const [
                  DropdownMenuItem(value: 'Days', child: Text('Days')),
                  DropdownMenuItem(value: 'Weeks', child: Text('Weeks')),
                  DropdownMenuItem(value: 'Months', child: Text('Months')),
                  DropdownMenuItem(value: 'Years', child: Text('Years')),
                ],
                onChanged: (value) {
                  setState(() {
                    _shelfLifeUnit = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Shelf Life Unit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select the shelf life unit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Reorder Amount Field
              TextFormField(
                controller: _reorderAmountController,
                decoration: const InputDecoration(
                  labelText: 'Reorder Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
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
              const SizedBox(height: 16),
              // Reorder Unit Dropdown
              DropdownButtonFormField<String>(
                value: _reorderUnit,
                items: const [
                  DropdownMenuItem(value: 'g', child: Text('Grams')),
                  DropdownMenuItem(value: 'kg', child: Text('Kilograms')),
                ],
                onChanged: (value) {
                  setState(() {
                    _reorderUnit = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Reorder Unit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select the reorder unit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _saveChanges,
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
