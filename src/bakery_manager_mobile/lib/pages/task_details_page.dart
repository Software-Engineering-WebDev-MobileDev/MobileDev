import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/account.dart';
import '../services/api_service.dart';
import '../assets/constants.dart';
import '../models/recipe.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:async'; // Import to use Future and Timer

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({super.key});

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Task task;
  String? employeeName;
  String? recipeName;
  Recipe? selectedRecipe; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the Task object passed from the previous screen
    task = ModalRoute.of(context)!.settings.arguments as Task;
    _fetchAndSetEmployeeName(); // Fetch the employee's name
    _fetchAndSetRecipeName(); // Fetch and set the recipe name
  }

  Future<void> _fetchAndSetEmployeeName() async {
    List<Account> users = await _fetchUsers();
    Account? matchedEmployee = users.firstWhere(
      (user) => user.employeeId == task.employeeID,
      orElse: () => Account(
        employeeId: 'Unknown',
        firstName: 'Unknown',
        lastName: '',
        username: 'Unknown',
        role: 'Unknown',
      ),
    );
    if (mounted) {
      setState(() {
        employeeName = '${matchedEmployee.firstName} ${matchedEmployee.lastName}'; // Set employee name
      });
    }
  }

  Future<void> _fetchAndSetRecipeName() async {
    List<Recipe> recipes = await _fetchRecipes();
    Recipe? matchedRecipe = recipes.firstWhere(
      (recipe) => recipe.recipeId == task.recipeID,
      orElse: () => Recipe(
        recipeId: 'Unknown',
        recipeName: 'Unknown Recipe',
        instructions: '',
        description: '',
        category: '',
        servings: 0,
        cookTime: 0,
        prepTime: 0,
      ),
    );
    if (mounted) {
      setState(() {
        recipeName = matchedRecipe.recipeName;
        selectedRecipe = matchedRecipe;
      });
    }
  }

  // Fetch recipes function
  Future<List<Recipe>> _fetchRecipes() {
    return ApiService.getRecipes().then((response) {
      if (response['status'] == 'success') {
        List<Recipe> recipes = response['recipes'];
        return recipes;
      } else {
        throw Exception('Failed to fetch recipes: ${response['message'] ?? 'Unknown error'}');
      }
    }).catchError((error) {
      return <Recipe>[]; 
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

  // Function to update task status and provide an undo button
  Future<void> _updateTaskStatus(String newStatus) async {
    final result = await ApiService.completeTask(taskID: task.taskID, taskStatus: newStatus);

    if (result['status'] == 'success') {
      setState(() {
        task = Task(
          taskID: task.taskID,
          recipeID: task.recipeID,
          amountToBake: task.amountToBake,
          assignmentDate: task.assignmentDate,
          completionDate: DateTime.now(),
          employeeID: task.employeeID,
          name: task.name,
          status: newStatus,
          dueDate: task.dueDate,
        );
      });
    } else {
      // Handle error
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Task marked as Complete'),
    ));
  }

  // Function to reverse task status (go back one step)
  void _undoTaskStatus() async {
    String oldStatus;
    if (task.status == "Completed") {
      oldStatus = "In Progress";
    } else {
      oldStatus = "Pending";
    }
    final response = await ApiService.updateTask(
      taskID: task.taskID,
      recipeID: task.recipeID,
      amountToBake: task.amountToBake,
      dueDate: task.dueDate.toIso8601String(),
      assignedEmployeeID: task.employeeID,
      status: oldStatus,
    );

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully')),
      );
      setState(() {
        task = Task(
          taskID: task.taskID,
          recipeID: task.recipeID,
          amountToBake: task.amountToBake,
          assignmentDate: task.assignmentDate,
          completionDate: null,
          employeeID: task.employeeID,
          name: task.name,
          status: oldStatus,
          dueDate: task.dueDate,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error updating task: ${response['reason'] ?? 'Unknown error'}',
          ),
        ),
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
        title: const Text(
          'Task Details',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Task Name
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Task Name:',
                      style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      task.name ?? 'N/A',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),

              // Amount to Bake
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount to Bake:',
                      style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${task.amountToBake}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),

              // Task Status
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      task.status,
                      style: TextStyle(
                        fontSize: 20,
                        color: _getStatusColor(task.status),
                        fontWeight: FontWeight.bold, // Making status bold
                      ),
                    ),
                  ],
                ),
              ),

              // Assigned Employee
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assigned Employee:',
                      style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      employeeName != null
                          ? '$employeeName (${task.employeeID})'  // Show FirstName LastName (EmployeeID)
                          : task.employeeID,  // Fallback to EmployeeID if name is unavailable
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),

              // Due Date
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Due Date:',
                      style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatDate(task.dueDate.toLocal()),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),

              // Assigned Date
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assigned on:',
                      style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatDate(task.assignmentDate.toLocal()),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),

              if (task.status == 'Completed')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                      children: [
                        const TextSpan(text: 'Completed on: '),
                        TextSpan(
                          text: _formatDate(task.completionDate?.toLocal()),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Link to Recipe Button
              if (recipeName != null)
                Center(
                  child: SizedBox(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          recipeDetailsPageRoute, // The route for the recipe details page
                          arguments: selectedRecipe,  // Pass the recipe object as an argument
                        );
                      },
                      icon: const Icon(Icons.link, color: Colors.white), // Link icon
                      label: const Text(
                        '  Link to Recipe  ', // Display "Link to Recipe" on the button
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 52),

              Center(
                child: Column(
                  children: [
                    if (task.status == 'Pending')
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _updateTaskStatus('In Progress');
                        },
                        icon: const Icon(Icons.work, color: Colors.white), // Icon for "In Progress"
                        label: const Text('Mark In Progress', style: TextStyle(color: Colors.white)),
                      ),

                    if (task.status == 'In Progress') ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _updateTaskStatus('Completed');
                        },
                        icon: const Icon(Icons.check, color: Colors.white), // Checkmark for "Completed"
                        label: const Text('Mark Completed', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 16),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 246, 235, 216),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _undoTaskStatus();
                        },
                        icon: const Icon(
                          Icons.undo,
                          color: Colors.black,
                        ),
                        label: const Text(
                          '    Undo Status    ',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],

                    if (task.status == 'Completed')
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 246, 235, 216),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _undoTaskStatus();
                        },
                        icon: const Icon(
                          Icons.undo,
                          color: Colors.black,
                        ),
                        label: const Text(
                          '    Undo Status   ',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    const SizedBox(height: 52),

                    // Edit and Delete Buttons side by side
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly spaced buttons
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              editTaskPageRoute,
                              arguments: task,
                            );
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white, 
                          ),
                          label: const Text(
                            '     Edit Task  ',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF800000),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final confirmed = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete Task'),
                                  content: const Text('Are you sure you want to delete this task?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false); // User cancels deletion
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true); // User confirms deletion
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmed) {
                              try {
                                await ApiService.deleteTask(task.taskID);
                                Navigator.pop(context); // Navigate back after deletion
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to delete task: $e')),
                                );
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Delete Task',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }
    return DateFormat('MM/dd/yyyy hh:mm a').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFF44336); // Red for Pending
      case 'In Progress':
        return const Color(0xFF2196F3); // Blue for In Progress
      case 'Completed':
        return const Color(0xFF4CAF50); // Green for Completed
      default:
        return Colors.black;
    }
  }
}