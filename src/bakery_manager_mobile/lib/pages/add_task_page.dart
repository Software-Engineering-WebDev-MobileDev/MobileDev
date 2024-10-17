import 'package:bakery_manager_mobile/models/account.dart';
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

  final String status = 'Pending';
  DateTime? assignmentDate;
  DateTime? completionDate;
  String? taskName;

  // Recipe and User lists for dropdowns
  late Future<List<Recipe>> _futureRecipes;
  Recipe? selectedRecipe;

  late Future<List<Account>> _futureUsers;
  Account? selectedUser;

  @override
  void initState() {
    super.initState();
    _futureRecipes = _fetchRecipes();
    _futureUsers = _fetchUsers(); // Initialize the Future to fetch users
  }

  // Fetch recipes function using the provided logic
  Future<List<Recipe>> _fetchRecipes() {
    return ApiService.getRecipes().then((response) {
      if (response['status'] == 'success') {
        List<Recipe> recipes = response['recipes'];
        return recipes;
      } else {
        throw Exception('Failed to fetch recipes: ${response['message'] ?? 'Unknown error'}');
      }
    }).catchError((error) {
      return <Recipe>[]; // Return an empty list on error
    });
  }

  // Fetch users function
  Future<List<Account>> _fetchUsers() {
    return ApiService.getUserList().then((response) {
      if (response['status'] == 'success') {
        List<Account> users = response['content'];
        return users;
      } else {
        throw Exception('Failed to fetch users: ${response['reason'] ?? 'Unknown error'}');
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
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        shape: const RoundedRectangleBorder(),
        title: const Stack(
          children: <Widget>[
            Text(
              'Add Task',
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
      body: FutureBuilder<List<Recipe>>(
        future: _futureRecipes,
        builder: (context, recipeSnapshot) {
          if (recipeSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (recipeSnapshot.hasError) {
            return Center(child: Text('Error: ${recipeSnapshot.error}'));
          } else if (!recipeSnapshot.hasData || recipeSnapshot.data!.isEmpty) {
            return const Center(child: Text('No recipes found'));
          } else {
            return FutureBuilder<List<Account>>(
              future: _futureUsers,
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}'));
                } else if (!userSnapshot.hasData || userSnapshot.data!.isEmpty) {
                  return const Center(child: Text('No users found'));
                } else {
                  return _buildForm(context, recipeSnapshot.data!, userSnapshot.data!);
                }
              },
            );
          }
        },
      ),
    );
  }

  // Build form UI
  Widget _buildForm(BuildContext context, List<Recipe> recipes, List<Account> users) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildDropdownField<Recipe>(
                label: 'Recipe',
                value: selectedRecipe,
                items: recipes,
                itemBuilder: (recipe) => recipe.recipeName,
                onChanged: (value) => setState(() => selectedRecipe = value),
                validator: (value) => value == null ? 'Please select a recipe' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownField<Account>(
                label: 'Assigned Employee',
                value: selectedUser,
                items: users,
                itemBuilder: (user) => '${user.firstName} ${user.lastName} (${user.username})',
                onChanged: (value) => setState(() => selectedUser = value),
                validator: (value) => value == null ? 'Please select an employee' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountToBakeController,
                maxLength: 8, // Limit to 8 characters
                decoration: const InputDecoration(
                  labelText: 'Amount to Bake',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                keyboardType: TextInputType.number,
                buildCounter: (BuildContext context, {required int currentLength, required bool isFocused, required int? maxLength}) {
                  return null; // Don't show the counter
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Amount to bake is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Due Date',
                controller: dueDateController,
                readOnly: true,
                onTap: () => _selectDueDate(context),
                suffixIcon: const Icon(Icons.calendar_today),
                validator: (value) => value == null || value.isEmpty ? 'Please select a due date' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Due Time',
                controller: dueTimeController,
                readOnly: true,
                onTap: () => _selectDueTime(context),
                suffixIcon: const Icon(Icons.access_time),
                validator: (value) => value == null || value.isEmpty ? 'Please select a due time' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add Task',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _submitTask();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill out all fields correctly')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemBuilder,  // Return a String instead of a Widget
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7, // Constrain width to prevent overflow
            child: Text(
              itemBuilder(item),  // Use the itemBuilder to get the text directly
              overflow: TextOverflow.ellipsis,  // Handle long text by truncating it
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  Future<void> _submitTask() async {
    String recipeID = selectedRecipe!.recipeId;
    String employeeId = selectedUser!.employeeId;
    int amountToBake = int.tryParse(amountToBakeController.text) ?? 0;
    DateTime dueDate = DateTime(
      selectedDueDate!.year,
      selectedDueDate!.month,
      selectedDueDate!.day,
      selectedDueTime!.hour,
      selectedDueTime!.minute,
    );
    String formattedDueDate = dueDate.toUtc().toIso8601String();

    try {
      Map<String, dynamic> response = await ApiService.addTask(
        recipeID: recipeID,
        amountToBake: amountToBake,
        assignedEmployeeID: employeeId,
        dueDate: formattedDueDate,
        comments: '',
      );
      if (response['status'] == 'success') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task added successfully')));
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add task: ${response['reason']}')));
        }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add task: $error')));
      }
    }
  }

  @override
  void dispose() {
    amountToBakeController.dispose();
    dueDateController.dispose();
    dueTimeController.dispose();
    super.dispose();
  }
}