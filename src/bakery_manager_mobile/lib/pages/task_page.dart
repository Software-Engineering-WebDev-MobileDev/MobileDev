import 'dart:async'; // Import to use Future and Timer
import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:bakery_manager_mobile/services/api_service.dart';
import 'package:bakery_manager_mobile/services/navigator_observer.dart';
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
  List<Task> _filteredTasks = [];
  List<Task> _allTasks = [];
  String _currentFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  // Page Initialization Function
  @override
  void initState() {
    super.initState();
    _futureTasks = _fetchTasks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final NavigatorState navigator = Navigator.of(context);
      final MyNavigatorObserver? observer =
          navigator.widget.observers.firstWhere(
        (observer) => observer is MyNavigatorObserver,
      ) as MyNavigatorObserver?;
      if (observer != null) {
        observer.onReturned = () async {
          // Refetch account details when returning from another page
          _futureTasks = _fetchTasks();
          if(mounted) setState(() {}); // Trigger rebuild
        };
      }
    });
  }

  @override
  void didChangeDependencies() {
    
    super.didChangeDependencies();
    _futureTasks = _fetchTasks();
  }

  // Fetch tasks function
  Future<List<Task>> _fetchTasks() async {
    final result = await ApiService.getTasks();

    if (result['status'] == 'success') {
      List<Task> tasks = result['tasks'];

      setState(() {
        _allTasks = tasks;
        _filteredTasks = tasks; // Initially show all tasks
      });

      return tasks;
    } else {
      throw Exception(result['reason']);
    }
  }

  void _filterTasks(String status, {String query = ''}) {
    setState(() {
      _currentFilter = status;
      _filteredTasks = _allTasks.where((task) {
        final matchesStatus = status == 'All' || task.status == status;
        final matchesQuery =
            task.name!.toLowerCase().contains(query.toLowerCase());
        return matchesStatus && matchesQuery; // Filter by both status and query
      }).toList();
    });
  }

  // Build filter button
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

  // Build page content
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: <Widget>[
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
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.home, color: Color.fromARGB(255, 140, 72, 27)),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status filter bar
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
              controller: _searchController,
              onChanged: (query) {
                _filterTasks(_currentFilter, query: query); // Filter by current status and query
              },
              decoration: InputDecoration(
                hintText: 'Search tasks',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterTasks(''); // Clear search field
                  },
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Task List
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
              
                Navigator.pushNamed(context, addTaskPageRoute).then((_) {
                  // Refetch tasks after returning from the add task page
                  setState(() {
                    _futureTasks = _fetchTasks();
                  });
                });
              },
              icon: const Icon(Icons.add,
                  color: Color.fromARGB(255, 246, 235, 216)),
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

// Task Item Widget
// Task Item Widget
class _TaskItem extends StatelessWidget {
  final Task task;
  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, taskDetailsPageRoute, arguments: task);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: const Color.fromARGB(255, 209, 126, 51),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row to include employee ID and task name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${task.name} x${task.amountToBake}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 251, 250, 248),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Employee ID displayed on the top right
                  Text(
                    'Assigned Employee ID: ${task.employeeID}', // Assuming task has employeeID field
                    style: const TextStyle(
                      color: Color.fromARGB(255, 246, 235, 216),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
    );
  }

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
