import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:bakery_manager_mobile/services/api_service.dart';
import 'package:bakery_manager_mobile/services/session_manager.dart';
import 'package:flutter/material.dart';
import '../services/navigator_observer.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => MyAccountPageState();
}

class MyAccountPageState extends State<MyAccountPage> {
  late Future<Map<String, dynamic>> _futureAccountDetails;
  MyNavigatorObserver? _observer;

  // Fetch account details from the API
  Future<Map<String, dynamic>> _fetchAccountDetails() async {
    final response = await ApiService.getUserInfo();

    if (response['status'] == 'success') {
      return response['content'];
    } else {
      debugPrint('Error: ${response['reason']}');
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    _futureAccountDetails = _fetchAccountDetails();
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
              _futureAccountDetails = _fetchAccountDetails();
            });
          } // Trigger rebuild
        };
      }
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false (cancel)
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true (confirm)
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      bool success = await ApiService.logout();
      if (success) {
        // Clear session token from SessionManager
        await SessionManager().clearSession();
        // Navigate to the login page
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // Show an error message if logout fails
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout failed. Please try again.')),
        );
      }
    }
  }

  @override
  void dispose() {
    if (_observer != null) {
      _observer!.onReturned = null; // Remove the callback to avoid memory leaks
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        title: const Stack(
          children: <Widget>[
            Text(
              'Account Details',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureAccountDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final account = snapshot.data ?? {};

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      const Text(
                        'First Name:',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        account['FirstName'] ?? '',
                        style: const TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Last Name:',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        account['LastName'] ?? '',
                        style: const TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Employee ID:',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        account['EmployeeID'] ?? '',
                        style: const TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Username:',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        account['Username'] ?? '',
                        style: const TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 16),

                      // Emails Section
                      const Text(
                        'Emails:',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (account['Emails'] as List<dynamic>? ?? []).map((email) {
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  email['EmailAddress'] ?? '',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              Text(
                                _capitalizeFirstLetter(email['EmailTypeID'] ?? 'other'),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Phone Numbers Section
                      const Text(
                        'Phone Numbers:',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (account['PhoneNumbers'] as List<dynamic>? ?? []).map((phone) {
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  phone['PhoneNumber'] ?? '',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              Text(
                                _capitalizeFirstLetter(phone['PhoneTypeID'] ?? 'mobile'),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 64),

                      // Action Buttons
                      Center(
                        child: Column(
                          children: [
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
                                Navigator.pushNamed(context, editAccountPageRoute);
                              },
                              icon: const Icon(Icons.edit, color: Colors.white),
                              label: const Text(
                                'Edit Contact Info',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _handleLogout(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF800000), // Maroon color
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.logout, color: Colors.white),
                              label: const Text(
                                '        Log Out        ',
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
            ],
          );
        },
      ),
    );
  }

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }
}