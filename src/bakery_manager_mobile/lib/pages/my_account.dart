import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:flutter/material.dart';
import '../pages/edit_account.dart';
import '../services/api_service.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => MyAccountPageState();
}

class MyAccountPageState extends State<MyAccountPage> {
  late Future<Map<String, dynamic>> _futureAccountDetails;
  bool _obscurePassword = true;
  bool _obscureEmployeeID = true;

  // Fetch account details from the API
  Future<Map<String, dynamic>> _fetchAccountDetails() async {
    var userID = "12345"; // Use the actual user ID here
    try {
      final response = await ApiService.getAccount(userID);

      if (response['status'] == 'success') {
        return response['accountDetails'];
      } else {
        // Log the error message or response
        debugPrint('Error: ${response['reason']}');
        throw Exception('Failed to load account details: ${response['reason']}');
      }
    } catch (error) {
      // Print out the error for more detailed analysis
      debugPrint('Fetch account error: $error');
      throw Exception('Failed to load account details');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureAccountDetails = _fetchAccountDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _futureAccountDetails,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return const Text('No account details found.');
              } else {
                final account = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // First Name
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'First Name: ${account['FirstName']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),

                    // Last Name
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Last Name: ${account['LastName']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),

                    // Employee ID with eye toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Employee ID: ${_obscureEmployeeID ? '••••••••' : account['EmployeeID']}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _obscureEmployeeID ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureEmployeeID = !_obscureEmployeeID;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Role
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Role: ${account['RoleID']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),

                    // Username
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Username: ${account['Username']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),

                    // Password with eye toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Password: ${_obscurePassword ? '••••••••' : account['Password']}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Emails Section
                    const Text(
                      'Emails:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (account['Emails'] as List<String>).map((email) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '• $email',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Phone Numbers Section
                    const Text(
                      'Phone Numbers:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (account['PhoneNumbers'] as List<String>).map((phone) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '• $phone',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, editAccountPageRoute);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Account'),
                      ),
                    ),

                    // Log Out Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Log Out'),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}