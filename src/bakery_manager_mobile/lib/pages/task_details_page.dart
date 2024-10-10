import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart'; // Assuming this contains API service for status updates
import '../assets/constants.dart'; // Assuming this contains the route constants

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({super.key});

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Task task;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the Task object passed from the previous screen
    task = ModalRoute.of(context)!.settings.arguments as Task;
  }

  // Function to display feedback message and navigate back to the task page
  void _showMessageAndNavigate(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));

    // Navigate back to the task page after the message is shown
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Pop the detail page
    });
  }

  // Function to update task status and provide an undo button
  Future<void> _updateTaskStatus(String newStatus, String undoStatus) async {
    try {
      // Assuming an API call to update the task status
      // await ApiService.updateTaskStatus(task.taskID, newStatus);

      setState(() {
        task = Task(
          taskID: task.taskID,
          recipeID: task.recipeID,
          amountToBake: task.amountToBake,
          assignmentDate: task.assignmentDate,
          completionDate: task.completionDate,
          employeeID: task.employeeID,
          name: task.name,
          status: newStatus,
          dueDate: task.dueDate,
        );
      });

      // Show a message with an Undo option
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Task marked as $newStatus'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _updateTaskStatus(undoStatus, newStatus); // Undo status change
          },
        ),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.name ?? 'Task Details', style: const TextStyle(color: Colors.white)),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Task Name
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    children: [
                      const TextSpan(
                        text: 'Task Name: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: task.name ?? 'N/A'),
                    ],
                  ),
                ),
              ),

              // Task Status
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    children: [
                      const TextSpan(
                        text: 'Status: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: task.status ?? 'N/A',
                        style: TextStyle(
                          color: _getStatusColor(task.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Due Date
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    children: [
                      const TextSpan(
                        text: 'Due Date: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: _formatDate(task.dueDate)),
                    ],
                  ),
                ),
              ),

              // Amount to Bake
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    children: [
                      const TextSpan(
                        text: 'Amount to Bake: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: task.amountToBake != null ? '${task.amountToBake}' : 'N/A'),
                    ],
                  ),
                ),
              ),

              // Assigned Date
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    children: [
                      const TextSpan(
                        text: 'Assigned on: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: _formatDate(task.assignmentDate)),
                    ],
                  ),
                ),
              ),

              // Completion Date (if applicable)
              if (task.status == 'Completed')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      children: [
                        const TextSpan(
                          text: 'Completed on: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: _formatDate(task.completionDate)),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Center the action buttons
              Center(
                child: Column(
                  children: [
                    // Conditional button based on task status
                    if (task.status == 'Pending')
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _updateTaskStatus('In Progress', 'Pending'); // Change status to 'In Progress'
                        },
                        child: const Text('Mark In Progress', style: TextStyle(color: Colors.white)),
                      ),

                    if (task.status == 'In Progress')
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _updateTaskStatus('Completed', 'In Progress'); // Change status to 'Completed'
                        },
                        child: const Text('Mark Completed', style: TextStyle(color: Colors.white)),
                      ),

                    const SizedBox(height: 16), // Space between the buttons

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // Navigate to the EditTaskPage, passing the Task object as an argument
                        Navigator.pushNamed(
                          context,
                          editTaskPageRoute,
                          arguments: task, // Pass the Task object directly
                        );
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Color.fromARGB(255, 246, 235, 216),
                      ),
                      label: const Text(
                        'Edit Task',
                        style: TextStyle(
                          color: Color.fromARGB(255, 246, 235, 216),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16), // Space between the buttons

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
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
                              content: const Text(
                                  'Are you sure you want to delete this task?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(false); // User cancels deletion
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(true); // User confirms deletion
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmed) {
                          // Call API to delete task and handle success/failure
                          try {
                            // await ApiService.deleteTask(task.taskID ?? '');
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Utility function to format date
  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Utility function to get color based on task status
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.black;
    }
  }
}