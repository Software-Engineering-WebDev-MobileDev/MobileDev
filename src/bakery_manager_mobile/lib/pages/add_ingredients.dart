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
  final TextEditingController _reorderAmountController = TextEditingController();

  String? _shelfLifeUnit; // Changed from controller to variable
  String? _reorderUnit;    // Changed from controller to variable

  void _addIngredient() async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final double reorderAmount = double.parse(_reorderAmountController.text);
      final int? shelfLife = _shelfLifeController.text.isNotEmpty
          ? int.parse(_shelfLifeController.text)
          : null;

      // Call the function that interacts with the API
      final result = await ApiService.addInventoryItem(
        name: name,
        reorderAmount: reorderAmount,
        reorderUnit: _reorderUnit!, 
        shelfLife: shelfLife,
        shelfLifeUnit: _shelfLifeUnit,
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
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        title: const Text(
          'Add Ingredient',
          style: TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  onPressed: _addIngredient,
                  child: const Text(
                    'Add Ingredient',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
