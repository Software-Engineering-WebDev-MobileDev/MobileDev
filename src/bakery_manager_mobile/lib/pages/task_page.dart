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
  MyNavigatorObserver? _observer;

  // Page Initialization Function
  @override
  void initState() {
    super.initState();
    _futureTasks = _fetchTasks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final NavigatorState navigator = Navigator.of(context);
      final MyNavigatorObserver? observer =
        _observer = navigator.widget.observers.firstWhere(
        (observer) => observer is MyNavigatorObserver,
      ) as MyNavigatorObserver?;
      if (observer != null) {
        observer.onReturned = () async {
          // Refetch account details when returning from another page
          if (mounted) {
            setState(() {
              _futureTasks = _fetchTasks();
            });
          } // Trigger rebuild
        };
      }
    });
  }


  @override
  void dispose() {
    _searchController.dispose();
    if (_observer != null) {
      _observer!.onReturned = null; // Remove the callback to avoid memory leaks
    }
    super.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to grab recipes')));
      return [];
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
    bool isSelected = _currentFilter == filter;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _currentFilter == filter ? const Color.fromARGB(255, 140, 72, 27): Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () {
        _filterTasks(filter);
      },
      child: Text(
        filter,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white,
        ),
        ),
      //child: Text(filter),
    );
  }

  // Build page content
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
              'All Tasks',
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
                _filterTasks(_currentFilter,
                    query: query); // Filter by current status and query
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
                    //return const Center(child: CircularProgressIndicator());
                    return const SizedBox(height: 16);
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
        color: const Color.fromARGB(255, 246, 235, 216),
        elevation: 4, // 3D effect
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task name, amount to bake, and assigned employee in one row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${task.name} x${task.amountToBake}', // Task and amount
                      style: const TextStyle(
                        color: Color.fromARGB(255, 140, 72, 27),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Employee ID and Assigned Employee text to the right
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assigned Employee:', // Static text
                        style: TextStyle(
                          color: Color.fromARGB(255, 140, 72, 27),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        task.employeeID, // Display Employee ID
                        style: const TextStyle(
                          color: Color.fromARGB(255, 140, 72, 27),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Status and due date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status: ${task.status}', // Display Task Status
                    style: TextStyle(
                      color: _getStatusColor(task.status), // Status color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    // Format the due date with AM/PM
                    'Due: ${DateFormat('MM/dd hh:mm a').format(task.dueDate)}', // e.g., 08/12 02:45 PM
                    style: const TextStyle(
                      color: Color.fromARGB(255, 140, 72, 27),
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