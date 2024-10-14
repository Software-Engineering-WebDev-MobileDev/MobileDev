import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:flutter/material.dart';
//import '../services/api_service.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => MyAccountPageState();
}

class MyAccountPageState extends State<MyAccountPage> {
  late Future<Map<String, dynamic>> _futureAccountDetails;
  bool _obscurePassword = true;
  bool _obscureEmployeeID = true;

  // TODO: replace mock data with real data
  final Map<String, dynamic> _accountPlaceholder = {
    'FirstName': 'John', 
    'LastName': 'Doe',
    'EmployeeID': '12345',
    'RoleID': 'Manager',
    'Username': 'johndoe',
    'Password': 'password123',
    'Emails': ['johndoe@example.com', 'john.doe@home.com'], 
    'PhoneNumbers': ['+1234567890', '+0987654321'],
  };

  // Fetch account details from the API
  Future<Map<String, dynamic>> _fetchAccountDetails() async {
    try {
      /*
      final response = await ApiService.getAccount(userID);
      if (response['status'] == 'success') {
        return response['accountDetails'];
      } else {
        debugPrint('Error: ${response['reason']}');
        throw Exception('Failed to load account details: ${response['reason']}');
      }
      */
      
      return _accountPlaceholder;
    } catch (error) {
      debugPrint('Fetch account error: $error');
      return _accountPlaceholder;
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
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        shape: const RoundedRectangleBorder(),
        title: const Stack(
          children: <Widget>[
            Text(
              'Account Details',
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureAccountDetails,
        builder: (context, snapshot) {
          final account = snapshot.data ?? _accountPlaceholder;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // First Name
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 18, color: Colors.black),
                            children: [
                              const TextSpan(
                                  text: 'First Name: ',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: account['FirstName'] ?? ''),
                            ],
                          ),
                        ),
                      ),

                      // Last Name
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 18, color: Colors.black),
                            children: [
                              const TextSpan(
                                  text: 'Last Name: ',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: account['LastName'] ?? ''),
                            ],
                          ),
                        ),
                      ),

                      // Employee ID
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.black),
                                  children: [
                                    const TextSpan(
                                        text: 'Employee ID: ',
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: _obscureEmployeeID ? '••••••••' : account['EmployeeID'] ?? ''),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _obscureEmployeeID
                                    ? Icons.visibility_off
                                    : Icons.visibility,
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

                      // Username
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 18, color: Colors.black),
                            children: [
                              const TextSpan(
                                  text: 'Username: ',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: account['Username'] ?? ''),
                            ],
                          ),
                        ),
                      ),

                      // Password
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.black),
                                  children: [
                                    const TextSpan(
                                        text: 'Password: ',
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: _obscurePassword ? '••••••••' : account['Password'] ?? ''),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
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

                      // Emails
                      const Text(
                        'Emails:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (account['Emails'] as List<dynamic>).cast<String>().map((email) {
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

                      // Phone Numbers
                      const Text(
                        'Phone Numbers:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (account['PhoneNumbers'] as List<dynamic>).cast<String>().map((phone) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '• $phone',
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // Buttons at the bottom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  children: [
                    ElevatedButton.icon(
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
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}