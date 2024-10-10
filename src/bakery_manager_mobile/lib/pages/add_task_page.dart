import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date and time formatting
import '../models/recipe.dart';
import '../services/api_service.dart'; // Importing ApiService

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => AddTaskPageState();
}

class AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController amountToBakeController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController dueTimeController = TextEditingController();

  DateTime? selectedDueDate;
  TimeOfDay? selectedDueTime;

  final String employeeID = '0';
  final String status = 'Pending';
  DateTime? assignmentDate;
  DateTime? completionDate;
  String? taskName;

  // Recipe list for dropdown
  late Future<List<Recipe>> _futureRecipes;
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  Recipe? selectedRecipe;

  @override
  void initState() {
    super.initState();
    // Initialize the Future to fetch recipes
    _futureRecipes = _fetchRecipes();
  }

  // Fetch recipes function using the provided logic
  Future<List<Recipe>> _fetchRecipes() {
    return ApiService.getRecipes().then((response) {
      if (response['status'] == 'success') {
        List<Recipe> recipes = response['recipes'];
        setState(() {
          _filteredRecipes = recipes;
          _allRecipes = recipes;
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
      body: FutureBuilder<List<Recipe>>(
        future: _futureRecipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recipes found'));
          } else {
            return _buildForm(context, snapshot.data!);
          }
        },
      ),
    );
  }

  // Build form UI
  Widget _buildForm(BuildContext context, List<Recipe> recipes) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Added form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Recipe:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: amountToBakeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: dueDateController,
                readOnly: true,
                onTap: () => _selectDueDate(context),
                decoration: const InputDecoration(
                  hintText: 'Select Due Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: dueTimeController,
                readOnly: true,
                onTap: () => _selectDueTime(context),
                decoration: const InputDecoration(
                  hintText: 'Select Due Time',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
                  backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Prepare data for submission
                    String recipeID = selectedRecipe!.recipeId;
                    int amountToBake = int.tryParse(amountToBakeController.text) ?? 0;
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

                    try {
                      // Simulating API Call for Adding Task (Commented Out)
                      /*
                      Map<String, dynamic> response = await ApiService.addTask(
                        recipeId: recipeID,
                        employeeId: employeeID,
                        amountToBake: amountToBake,
                        status: status,
                        assignmentDate: assignmentDate!,
                        dueDate: dueDate,
                        taskName: taskName!,
                      );

                      if (response['status'] == 'success') {
                        // Task successfully added
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Task added successfully')));

                          // Pop the current page (go back to the previous screen)
                          Navigator.pop(context);
                        }
                      } else {
                        // Show error message if the task creation failed
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed to add task: ${response['reason']}'),
                          ));
                        }
                      }
                      */

                      // Simulate success for now
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Task added successfully')));

                        // Pop the current page (go back to the previous screen)
                        Navigator.pop(context);
                      }
                    } catch (error) {
                      // Show error message if API call fails
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add task: $error')),
                        );
                      }
                    }
                  } else {
                    // Validation failed
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill out all fields correctly')),
                    );
                  }
                },
                child: const Text(
                  'Add Task',
                  style: TextStyle(color: Colors.white), // This line makes the font white
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
    dueTimeController.dispose(); // Dispose the controller
    super.dispose();
  }
}