import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date and time formatting
import '../models/recipe.dart';
import '../models/task.dart';
// import 'package:bakery_manager_mobile/services/api_service.dart'; // Importing ApiService (commented out)

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => AddTaskPageState();
}

class AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>(); // Added form key

  // Controllers for form fields
  final TextEditingController amountToBakeController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController dueTimeController = TextEditingController();

  DateTime? selectedDueDate;
  TimeOfDay? selectedDueTime;

  // EmployeeID is '0'
  final String employeeID = '0';

  // Status is 'Pending'
  final String status = 'Pending';

  // AssignmentDate is set when the form is submitted
  DateTime? assignmentDate;

  // CompletionDate is null
  DateTime? completionDate;

  // Name of the task (recipe name)
  String? taskName;

  // List of recipes to populate the dropdown
  List<Recipe> recipes = [];
  Recipe? selectedRecipe;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  // Fetch recipes using the original API call
  void _fetchRecipes() async {
    // Uncomment the code below when API is operational
    /*
    Map<String, dynamic> response = await ApiService.getRecipes();
    if (response['status'] == 'success') {
      List<Recipe> fetchedRecipes = response['recipes'];
      setState(() {
        recipes = fetchedRecipes;
      });
    } else {
      // Handle error or show a message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch recipes: ${response['message'] ?? 'Unknown error'}')),
        );
      }
    }
    */

    // Simulated fetching recipes with mock data
    await Future.delayed(const Duration(seconds: 1));
    List<Recipe> fetchedRecipes = [
      Recipe(
        recipeId: '101',
        recipeName: 'Banana Bread',
        category: 'Bread',
        instructions: 'Mix ingredients and bake.',
        prepTime: 15,
        cookTime: 60,
        servings: 8,
        description: '',
      ),
      Recipe(
        recipeId: '102',
        recipeName: 'Chocolate Cake',
        category: 'Cake',
        instructions: 'Mix ingredients and bake.',
        prepTime: 20,
        cookTime: 45,
        servings: 12,
        description: '',
      ),
      // Add more mock recipes as needed
    ];
    setState(() {
      recipes = fetchedRecipes;
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

  // Build method to construct the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Stack(
          children: <Widget>[
            // Stroked text as border
            Text(
              'Add Task',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 30,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = const Color.fromARGB(255, 140, 72, 27),
              ),
            ),
            // Solid text as fill
            const Text(
              'Add Task',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 246, 235, 216),
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 140, 72, 27)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: recipes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey, // Added form key
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Recipe:',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Recipe>(
                        value: selectedRecipe,
                        items: recipes.map((recipe) {
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
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                          ),
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
                      const Text(
                        'Batches to Make:',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: amountToBakeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter amount',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                          ),
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
                      const Text(
                        'Due Date:',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: dueDateController,
                        readOnly: true,
                        onTap: () => _selectDueDate(context),
                        decoration: const InputDecoration(
                          hintText: 'Select Due Date',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                          ),
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
                      const Text(
                        'Due Time:',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: dueTimeController,
                        readOnly: true,
                        onTap: () => _selectDueTime(context),
                        decoration: const InputDecoration(
                          hintText: 'Select Due Time',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                          ),
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
                          backgroundColor:
                              const Color.fromARGB(255, 209, 125, 51),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Prepare data
                            String recipeID = selectedRecipe!.recipeId;
                            int amountToBake =
                                int.tryParse(amountToBakeController.text) ?? 0;
                            DateTime dueDate = DateTime(
                              selectedDueDate!.year,
                              selectedDueDate!.month,
                              selectedDueDate!.day,
                              selectedDueTime!.hour,
                              selectedDueTime!.minute,
                            );
                            assignmentDate = DateTime.now();
                            taskName = selectedRecipe!.recipeName;
                            completionDate = null;

                            // Uncomment the code below when API is operational
                            /*
                            Map<String, dynamic> response = await ApiService.addTask(
                              recipeID: recipeID,
                              amountToBake: amountToBake,
                              assignmentDate: assignmentDate!,
                              dueDate: dueDate,
                              employeeID: employeeID,
                              status: status,
                              // Include other required fields as needed
                            );

                            if (response['status'] == 'success') {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Task added successfully')),
                                );
                                Navigator.pop(context);
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Failed to add task: ${response['reason']}')),
                                );
                              }
                            }
                            */

                            // Simulate adding a task
                            await Future.delayed(const Duration(seconds: 1));

                            // Simulate success
                            bool success = true;

                            if (success) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Task added successfully')),
                                );
                                Navigator.pop(context);
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Failed to add task')),
                                );
                              }
                            }
                          } else {
                            // Validation failed
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please fill out all fields correctly')),
                            );
                          }
                        },
                        child: const Text('Add Task'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    amountToBakeController.dispose();
    dueDateController.dispose();
    dueTimeController.dispose(); // Dispose the controller
    super.dispose();
  }
}