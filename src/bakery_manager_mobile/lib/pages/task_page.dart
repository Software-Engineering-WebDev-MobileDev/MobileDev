import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  TaskPageState createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  // TODO: Add tasks from database
  final List<Task> _tasks = [
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
  Task(
    taskID: '2',
    recipeID: '102',
    amountToBake: 5,
    assignmentDate: DateTime.now().subtract(const Duration(days: 1)),
    completionDate: DateTime.now().add(const Duration(hours: 1)),
    employeeID: 'E002',
    name: 'Chocolate Cake',
    status: 'In Progress',
    dueDate: DateTime.now().add(const Duration(hours: 1)),
  ),
  Task(
    taskID: '3',
    recipeID: '103',
    amountToBake: 20,
    assignmentDate: DateTime.now().subtract(const Duration(days: 2)),
    completionDate: DateTime.now().subtract(const Duration(hours: 1)),
    employeeID: 'E003',
    name: 'Vanilla Cupcakes',
    status: 'Completed',
    dueDate: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  Task(
    taskID: '4',
    recipeID: '104',
    amountToBake: 8,
    assignmentDate: DateTime.now().subtract(const Duration(days: 1)),
    completionDate: DateTime.now().add(const Duration(hours: 3)),
    employeeID: 'E004',
    name: 'Scones',
    status: 'Pending',
    dueDate: DateTime.now().add(const Duration(hours: 3)),
  ),
];

  List<Task> _filteredTasks = [];
  String _currentFilter = 'All';

  @override
  void initState() {
    super.initState();
    _filteredTasks = _tasks;
  }

  void _filterTasks(String filter) {
    setState(() {
      _currentFilter = filter;
      if (filter == 'All') {
        _filteredTasks = _tasks;
      } else {
        _filteredTasks = _tasks.where((task) => task.status == filter).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tasks', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                  return _TaskItem(task: _filteredTasks[index]);
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
              onPressed: () {
                // TODO: Implement add task functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add task functionality not implemented yet')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add task'),
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
      onPressed: () => _filterTasks(filter),
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
        // TODO: Implement navigation to task details page
        Navigator.pushNamed(context, taskDetailsPageRoute, arguments: task);
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
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
