import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date and time formatting
import '../models/recipe.dart';
import '../models/task.dart'; // Import Task model
import '../services/api_service.dart'; // Import API service

class EditTaskPage extends StatefulWidget {
  const EditTaskPage({super.key});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController amountToBakeController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController dueTimeController = TextEditingController();

  DateTime? selectedDueDate;
  TimeOfDay? selectedDueTime;

  Task? task; // Variable to store the Task object
  Recipe? selectedRecipe;

  // Recipe list for dropdown
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];

  @override
  void initState() {
    super.initState();

    // Fetch recipes and simulate fetching the task object
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRecipes();

      // Prepopulate with hard-coded task data
      Task fakeTask = Task(
        taskID: '123',
        recipeID: '1', // This should match one of the recipeIDs in _allRecipes
        amountToBake: 10,
        assignmentDate: DateTime.now().subtract(const Duration(days: 1)),
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: 'Pending',
        employeeID: 'emp001',
        name: 'Bake Chocolate Cake',
      );

      setState(() {
        task = fakeTask;
        amountToBakeController.text = task!.amountToBake.toString();
        dueDateController.text = DateFormat('yyyy-MM-dd').format(task!.dueDate);
        selectedDueDate = task!.dueDate;
        selectedDueTime = TimeOfDay.fromDateTime(task!.dueDate);
        dueTimeController.text = selectedDueTime!.format(context);
      });
    });
  }

  // Fetch recipes function using the provided logic
  Future<List<Recipe>> _fetchRecipes() {
    return ApiService.getRecipes().then((response) {
      if (response['status'] == 'success') {
        List<Recipe> recipes = response['recipes'];
        setState(() {
          _filteredRecipes = recipes;
          _allRecipes = recipes;

          // Update selected recipe if task exists and matches
          if (task != null) {
            selectedRecipe = recipes.firstWhere(
              (recipe) => recipe.recipeId == task!.recipeID,
              orElse: () => recipes.first,
            );
          }
        });
        return recipes;
      } else {
        throw Exception(
            'Failed to fetch recipes: ${response['message'] ?? 'Unknown error'}');
      }
    }).catchError((error) {
      print('Error fetching recipes: $error');
      return <Recipe>[]; // Return an empty list on error
    });
  }

  // Function to show date picker
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (pickedDate != null && pickedDate != selectedDueDate) {
      setState(() {
        selectedDueDate = pickedDate;
        dueDateController.text = DateFormat('yyyy-MM-dd').format(selectedDueDate!);
      });
    }
  }

  // Function to show time picker
  Future<void> _selectDueTime(BuildContext context) async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedDueTime ?? now,
    );
    if (pickedTime != null && pickedTime != selectedDueTime) {
      setState(() {
        selectedDueTime = pickedTime;
        dueTimeController.text = pickedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: <Widget>[
            // Stroked text as border.
            Text(
              'Edit Task',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 30,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = const Color.fromARGB(255, 140, 72, 27),
              ),
            ),
            // Solid text as fill.
            const Text(
              'Edit Task',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 248, 248, 248),
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 140, 72, 27)),
          onPressed: () {
            Navigator.pop(context); // Back navigation
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Color.fromARGB(255, 140, 72, 27)),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/')); // Home navigation
            },
          ),
        ],
      ),
      body: task == null
          ? const Center(child: CircularProgressIndicator()) // Display a loader while task is being fetched
          : _buildForm(context),
    );
  }

  // Build form UI
  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Recipe:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<Recipe>(
                value: selectedRecipe,
                items: _allRecipes.map((recipe) {
                  return DropdownMenuItem(
                    value: recipe,
                    child: Text(recipe.recipeName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRecipe = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  hintText: 'Select Recipe',
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a recipe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Batches to Make:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: amountToBakeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter amount',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount to bake';
                  }
                  int? amount = int.tryParse(value);
                  if (amount == null) {
                    return 'Please enter a valid integer amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Due Date:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: dueDateController,
                readOnly: true,
                onTap: () => _selectDueDate(context),
                decoration: const InputDecoration(
                  hintText: 'Select Due Date',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a due date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Due Time:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: dueTimeController,
                readOnly: true,
                onTap: () => _selectDueTime(context),
                decoration: const InputDecoration(
                  hintText: 'Select Due Time',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  suffixIcon: Icon(Icons.access_time),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a due time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Show a success message with fake data
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task updated successfully')),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill out all fields correctly')),
                    );
                  }
                },
                child: const Text(
                  'Update Task',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountToBakeController.dispose();
    dueDateController.dispose();
    dueTimeController.dispose();
    super.dispose();
  }
}