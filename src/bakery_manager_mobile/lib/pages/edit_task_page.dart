import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date and time formatting
import '../models/recipe.dart';
import '../models/task.dart'; // Import Task model
import '../models/account.dart'; // Import Account model
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
  Account? selectedAccount; // Variable to store selected Account

  // Recipe list for dropdown
  List<Recipe> _allRecipes = [];

  // Account list for dropdown
  List<Account> _allAccounts = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the Task object passed from the previous screen
    task = ModalRoute.of(context)!.settings.arguments as Task;

    // Prepopulate form fields with task data
    amountToBakeController.text = task!.amountToBake.toString();
    dueDateController.text = DateFormat('yyyy-MM-dd').format(task!.dueDate);
    selectedDueDate = task!.dueDate;
    selectedDueTime = TimeOfDay.fromDateTime(task!.dueDate);
    dueTimeController.text = selectedDueTime!.format(context);
  }

  @override
  void initState() {
    super.initState();
    // Fetch recipes and accounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRecipes();
      _fetchAccounts();
    });
  }

  // Fetch recipes function using the provided logic
  Future<List<Recipe>> _fetchRecipes() {
    return ApiService.getRecipes().then((response) {
      if (response['status'] == 'success') {
        List<Recipe> recipes = response['recipes'];
        setState(() {
          _allRecipes = recipes;

          // Set the selected recipe based on the task
          selectedRecipe = _allRecipes.firstWhere(
              (recipe) => recipe.recipeId == task!.recipeID,
              orElse: () => _allRecipes.first);
        });
        return recipes;
      } else {
        throw Exception(
            'Failed to fetch recipes: ${response['message'] ?? 'Unknown error'}');
      }
    }).catchError((error) {
      return <Recipe>[]; // Return an empty list on error
    });
  }

  // Fetch accounts function
  Future<List<Account>> _fetchAccounts() {
    return ApiService.getUserList().then((response) {
      if (response['status'] == 'success') {
        List<Account> accounts = response['content'];
        setState(() {
          _allAccounts = accounts;

          // Set the selected account based on the task
          selectedAccount = _allAccounts.firstWhere(
            (account) => account.employeeId == task!.employeeID,
            orElse: () => _allAccounts.first,
          );
        });
        return accounts;
      } else {
        throw Exception(
            'Failed to fetch accounts: ${response['message'] ?? 'Unknown error'}');
      }
    }).catchError((error) {
      return <Account>[]; // Return an empty list on error
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
        dueDateController.text =
            DateFormat('yyyy-MM-dd').format(selectedDueDate!);
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

  // Function to call API for updating task
  Future<void> _updateTask() async {
    final String taskId = task!.taskID;
    final String recipeId = selectedRecipe!.recipeId;
    final int amountToBake = int.parse(amountToBakeController.text);
    DateTime combinedDateTime = DateTime(
      selectedDueDate!.year,
      selectedDueDate!.month,
      selectedDueDate!.day,
      selectedDueTime!.hour,
      selectedDueTime!.minute,
    ).toUtc();
    final String assignedEmployeeId = selectedAccount!.employeeId;
    final String status = task!.status;
    String dueDateTimeISO = combinedDateTime.toIso8601String();

    final response = await ApiService.updateTask(
      taskID: taskId,
      recipeID: recipeId,
      amountToBake: amountToBake,
      dueDate: dueDateTimeISO,
      assignedEmployeeID: assignedEmployeeId,
      status: status,
    );

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully')),
      );
      Navigator.popUntil(context, ModalRoute.withName(taskPageRoute));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error updating task: ${response['reason'] ?? 'Unknown error'}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        shape: const RoundedRectangleBorder(),
        title: const Stack(
          children: <Widget>[
            Text(
              'Edit Task',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
        ],
      ),
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
              const Text('Recipe:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
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

              // Assign User dropdown
              const Text('Assign User:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<Account>(
                value: selectedAccount,
                items: _allAccounts.map((account) {
                  return DropdownMenuItem(
                    value: account,
                    child: Text(
                        '${account.firstName} ${account.lastName} (${account.username})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAccount = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  hintText: 'Select User',
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select an user';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Batches to Make:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: amountToBakeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter amount',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
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
              const Text('Due Date:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: dueDateController,
                readOnly: true,
                onTap: () => _selectDueDate(context),
                decoration: const InputDecoration(
                  hintText: 'Select Due Date',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
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
              const Text('Due Time:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: dueTimeController,
                readOnly: true,
                onTap: () => _selectDueTime(context),
                decoration: const InputDecoration(
                  hintText: 'Select Due Time',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
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
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateTask(); // Call the update task function here
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Please fill out all fields correctly')),
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
