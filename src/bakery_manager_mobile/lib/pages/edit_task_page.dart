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
  void initState() {
    super.initState();
    // Fetch recipes and accounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      task = ModalRoute.of(context)!.settings.arguments as Task;
      amountToBakeController.text = task!.amountToBake.toString();
      dueDateController.text = DateFormat('yyyy-MM-dd').format(task!.dueDate);
      selectedDueDate = task!.dueDate;
      selectedDueTime = TimeOfDay.fromDateTime(task!.dueDate);
      dueTimeController.text = selectedDueTime!.format(context);
      _fetchRecipes();
      _fetchAccounts();
    });
  }

  // Fetch recipes function
  Future<void> _fetchRecipes() async {
    try {
      final response = await ApiService.getRecipes();
      if (response['status'] == 'success') {
        setState(() {
          _allRecipes = response['recipes'];
          selectedRecipe = _allRecipes.firstWhere(
              (recipe) => recipe.recipeId == task!.recipeID,
              orElse: () => _allRecipes.first);
        });
      }
    } catch (error) {
      return;
    }
  }

  Future<void> _fetchAccounts() async {
    try {
      final response = await ApiService.getUserList();
      if (response['status'] == 'success') {
        setState(() {
          _allAccounts = response['content'];
          if (_allAccounts.isNotEmpty) {
            // Find the matched account, otherwise select the first one
            selectedAccount = _allAccounts.firstWhere(
              (account) => account.employeeId == task!.employeeID,
              orElse: () => _allAccounts.first,
            );
          }
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch employees: $error')),
      );
    }
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
    if (pickedDate != null) {
      setState(() {
        selectedDueDate = pickedDate;
        dueDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
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
    if (pickedTime != null) {
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
    final DateTime combinedDateTime = DateTime(
      selectedDueDate!.year,
      selectedDueDate!.month,
      selectedDueDate!.day,
      selectedDueTime!.hour,
      selectedDueTime!.minute,
    ).toUtc();
    final String assignedEmployeeId = selectedAccount!.employeeId;
    final String status = task!.status;
    final String dueDateTimeISO = combinedDateTime.toIso8601String();

    try {
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
          SnackBar(content: Text('Failed to update task: ${response['reason']}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
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
      body: task == null
          ? const Center(
              child:
                  CircularProgressIndicator()) // Display a loader while task is being fetched
          : _buildForm(context),
    );
  }

  // Updated _buildForm with onChanged logic for the employee dropdown
  Widget _buildForm(BuildContext context) {
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
                label: 'Select Recipe',
                value: selectedRecipe,
                items: _allRecipes,
                itemBuilder: (recipe) => recipe.recipeName,
                onChanged: (value) => setState(() => selectedRecipe = value),
                validator: (value) => value == null ? 'Please select a recipe' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownField<Account>(
                label: 'Select Employee',
                value: selectedAccount,
                items: _allAccounts,
                itemBuilder: (account) => '${account.firstName} ${account.lastName} (${account.username})',
                onChanged: (value) => setState(() => selectedAccount = value), // Ensure it updates state
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
                icon: const Icon(Icons.update, color: Colors.white),
                label: const Text(
                  'Update Task',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateTask();  // This will now include the updated employee data
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
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
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