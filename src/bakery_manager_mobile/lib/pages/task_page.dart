import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  TaskPageState createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  Future<void> _initializeDatabase() async {
    // Placeholder for initializing your database connection
      }

  Future<void> _fetchTasksFromDb() async {
    // Placeholder for fetching tasks from your database
    // Update the `_tasks` and `_filteredTasks` list after fetching

    // Replace the with your own fetch logic
    setState(() {
      _tasks = [
        Task(
          taskID: '1',
          recipeID: '101',
          amountToBake: 10,
          assignmentDate: DateTime.now().subtract(const Duration(days: 1)),
          completionDate: DateTime.now().add(const Duration(hours: 2)),
          employeeID: 'E001',
          name: 'Banana Bread',
          status: 'Pending',
          dueDate: DateTime.now().add(const Duration(hours: 2)),
        ),
      ];
      _filterTasks(_currentFilter);
    });
  }

  Future<void> _insertTaskIntoDb(Task task) async {
    // Placeholder for inserting a task into your database
    // Once added to your database, call `_fetchTasksFromDb()` to update the UI
    await _fetchTasksFromDb();
  }

  Future<void> _deleteTaskFromDb(String taskId) async {
    // Placeholder for deleting a task from your database
    // Once deleted, call `_fetchTasksFromDb()` to update the UI
    await _fetchTasksFromDb();
  }

  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  String _currentFilter = 'All';

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _fetchTasksFromDb();
  }

  void _filterTasks(String status) {
    setState(() {
      _currentFilter = status;
      if (status == 'All') {
        _filteredTasks = _tasks;
      } else {
        _filteredTasks = _tasks.where((task) => task.status == status).toList();
      }
    });
  }

  void _showAddTaskDialog() {
    final nameController = TextEditingController();
    final amountToBakeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Task Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountToBakeController,
                  decoration: const InputDecoration(
                    labelText: 'Amount to Bake',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    amountToBakeController.text.isNotEmpty) {
                  final newTask = Task(
                    taskID: DateTime.now().millisecondsSinceEpoch.toString(),
                    recipeID: '105', // Example recipe ID
                    amountToBake: int.parse(amountToBakeController.text),
                    assignmentDate: DateTime.now(),
                    completionDate: DateTime.now().add(const Duration(days: 1)),
                    employeeID: 'E001', // Example employee ID
                    name: nameController.text,
                    status: 'Pending',
                    dueDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  _insertTaskIntoDb(newTask);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Horizontal filter bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('All'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Pending'),
                  const SizedBox(width: 8),
                  _buildFilterButton('In Progress'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Completed'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredTasks.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(_filteredTasks[index].taskID),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      _deleteTaskFromDb(_filteredTasks[index].taskID);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: _TaskItem(task: _filteredTasks[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _showAddTaskDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String filter) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _currentFilter == filter ? Colors.orange : Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () {
        _filterTasks(filter);
      },
      child: Text(filter),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final Task task;
  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected task: ${task.name}')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: const Color(0xFFFDF1E0),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status: ${task.status}',
                      style: TextStyle(
                        color: _getStatusColor(task.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Due: ${_formatDate(task.dueDate)}',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
