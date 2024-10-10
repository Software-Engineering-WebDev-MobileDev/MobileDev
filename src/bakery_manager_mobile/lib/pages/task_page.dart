import 'dart:async'; // Import to use Future and Timer
import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:bakery_manager_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  TaskPageState createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  late Future<List<Task>> _futureTasks;
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  String _currentFilter = 'All';
  String _searchQuery = '';

  // Page Initialization Function
  @override
  void initState() {
    super.initState();
    _futureTasks = _fetchTasks();
  }

  // Fetch tasks function (corrected)
  Future<List<Task>> _fetchTasks() async {
    try {
      var response = await ApiService.getTasks();
      if (response['status'] == 'success') {
        List<Task> tasks = response['tasks'];
        setState(() {
          _filteredTasks = tasks;
          _allTasks = tasks;
        });
        return tasks;
      } else {
        throw Exception(
            'Failed to fetch tasks: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (error) {
      // Handle error appropriately
      print('Error fetching tasks: $error');
      return [];
    }
  }

  // Filtering tasks based on status and search query
  void _filterTasks() {
    setState(() {
      List<Task> tasks = _allTasks;
      if (_currentFilter != 'All') {
        tasks = tasks.where((task) => task.status == _currentFilter).toList();
      }
      if (_searchQuery.isNotEmpty) {
        tasks = tasks
            .where((task) =>
                (task.name ?? '')
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
            .toList();
      }
      _filteredTasks = tasks;
    });
  }

  // Filter by status function
  void _filterByStatus(String status) {
    setState(() {
      _currentFilter = status;
      _filterTasks();
    });
  }

  // Build status filter button
  Widget _buildStatusFilterButton(String status) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _currentFilter == status ? Colors.orange : Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () {
        _filterByStatus(status);
      },
      child: Text(status),
    );
  }

  // Page Content Build Function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: <Widget>[
            // Stroked text as border.
            Text(
              'Daily Tasks',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 30,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = const Color.fromARGB(255, 140, 72, 27),
              ),
            ),
            // Solid text as fill.
            const Text(
              'Daily Tasks',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 246, 235, 216),
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 140, 72, 27)),
          onPressed: () {
            Navigator.pop(context); // Back navigation
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home,
                color: Color.fromARGB(255, 140, 72, 27)),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/')); // Home navigation
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Horizontal status filter bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusFilterButton('All'),
                  const SizedBox(width: 8),
                  _buildStatusFilterButton('Pending'),
                  const SizedBox(width: 8),
                  _buildStatusFilterButton('In Progress'),
                  const SizedBox(width: 8),
                  _buildStatusFilterButton('Completed'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            TextField(
              onChanged: (value) {
                _searchQuery = value;
                _filterTasks();
              }, // Search feature
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchQuery = '';
                    _filterTasks();
                  },
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List of tasks
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: _futureTasks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (_filteredTasks.isEmpty) {
                    return const Text('No tasks found');
                  } else {
                    return ListView.builder(
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        return _TaskItem(task: _filteredTasks[index]);
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Add Task Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Navigate to AddTaskPage
                Navigator.pushNamed(context, addTaskPageRoute);
              },
              icon: const Icon(
                Icons.add,
                color: Color.fromARGB(255, 246, 235, 216),
              ),
              label: const Text(
                'Add Task',
                style: TextStyle(
                  color: Color.fromARGB(255, 246, 235, 216),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Task Item Widget for the List of Tasks
class _TaskItem extends StatelessWidget {
  final Task task;
  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to the task details page when tapped
        Navigator.pushNamed(context, taskDetailsPageRoute, arguments: task);
      },
      child: Container(
        decoration: const BoxDecoration(),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: const Color.fromARGB(255, 209, 126, 51),
          elevation: 4, // 3D effect
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name!,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 251, 250, 248),
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
                      'Due: ${DateFormat('MM/dd HH:mm').format(task.dueDate)}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 246, 235, 216),
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

  // Function to get color based on task status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color.fromARGB(255, 233, 255, 66);
      case 'In Progress':
        return const Color.fromARGB(255, 77, 255, 255);
      case 'Completed':
        return const Color.fromARGB(255, 75, 253, 102);
      default:
        return Colors.black;
    }
  }
}