import 'dart:async'; // Import to use Future and Timer
import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:bakery_manager_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  TaskPageState createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  // Simulate an asynchronous operation that fetches tasks
  Future<List<Task>> _fetchTasks() async {
  // Call getTasks function
  final result = await ApiService.getTasks();

  if (result['status'] == 'success') {
  List<Task> tasks = result['tasks']; // Assuming this returns a List<Task>

    // Iterate through tasks and fetch recipe names
    for (var task in tasks) {
      final recipeNameResult = await ApiService.getRecipeName(task.recipeID);
      if (recipeNameResult['status'] == 'success') {
        task.name = recipeNameResult['recipeName']; // Store the recipe name in the task
      } else {
        task.name = 'Unknown Recipe'; // Handle errors by setting a default name
      }
    }
    return tasks;
  } else {
    throw Exception(result['reason']); // Throw an exception with the error reason
  }
}

  late Future<List<Task>> _futureTasks;
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  String _currentFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _futureTasks = _fetchTasks(); // Fetch tasks initially
    _futureTasks.then((tasks) {
      setState(() {
        _allTasks = tasks;
        _filterTasks();
      });
    });
  }

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

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _filterTasks();
  }

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
            // Search Bar
            TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _onSearchChanged('');
                  },
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: _futureTasks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (_filteredTasks.isNotEmpty) {
                    return ListView.builder(
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        return _TaskItem(task: _filteredTasks[index]);
                      },
                    );
                  } else {
                    return const Center(child: Text('No tasks available'));
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 32),
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

  Widget _buildFilterButton(String status) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _currentFilter == status
            ? Colors.orange
            : Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () {
        _currentFilter = status;
        _filterTasks();
      },
      child: Text(status),
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
        // Navigate to task details page
        Navigator.pushNamed(context, taskDetailsPageRoute, arguments: task);
      },
      child: Container(
        // Uncomment the decoration below if you want to add a shadow effect
        // decoration: const BoxDecoration(
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.grey.withOpacity(0.5),
        //       spreadRadius: 2,
        //       blurRadius: 8,
        //       offset: Offset(0, 4),
        //     ),
        //   ],
        // ),
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
                    color: Color.fromARGB(255, 246, 235, 216),
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
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  // Function to format due date
  String _formatDate(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}