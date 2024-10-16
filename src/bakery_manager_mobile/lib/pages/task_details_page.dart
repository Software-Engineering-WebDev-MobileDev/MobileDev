import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../assets/constants.dart';
import 'package:intl/intl.dart'; // For date formatting

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
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                      const TextSpan(text: 'Task Name: '),
                      TextSpan(
                        text: task.name ?? 'N/A',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),

              // Amount to Bake (moved below Task Name)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                      const TextSpan(text: 'Amount to Bake: '),
                      TextSpan(
                        text: '${task.amountToBake}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),

              // Task Status
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                      const TextSpan(text: 'Status: '),
                      TextSpan(
                        text: task.status,
                        style: TextStyle(
                          fontSize: 20,
                          color: _getStatusColor(task.status),
                          fontWeight: FontWeight.bold, // Making status bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Assigned Employee
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                      const TextSpan(text: 'Assigned Employee: '),
                      TextSpan(
                        text: task.employeeID,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
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
                    style: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                      const TextSpan(text: 'Due Date: '),
                      TextSpan(
                        text: _formatDate(task.dueDate.toLocal()),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),

              // Assigned Date
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                      const TextSpan(text: 'Assigned on: '),
                      TextSpan(
                        text: _formatDate(task.assignmentDate.toLocal()),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
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

              const SizedBox(height: 48), // Increased space before Edit Task button

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
                        label: const Text('   Mark In Progress   ', style: TextStyle(color: Colors.white)),
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
                        label: const Text('   Mark Completed   ', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 16), // Space between the buttons

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
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
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Undo Status Change',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],

                    if (task.status == 'Completed')
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
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
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Undo Status Change',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    const SizedBox(height: 64),

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
                        '  Edit Task  ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

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