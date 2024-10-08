import 'package:flutter/material.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController employeeIDController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  bool _obscurePassword = true;
  List<Map<String, dynamic>> _emails = [];
  List<Map<String, dynamic>> _phones = [];
  List<TextEditingController> _emailControllers = [];
  List<TextEditingController> _phoneControllers = [];

  final List<String> emailTypes = ['Work', 'Home', 'Other'];
  final List<String> phoneTypes = ['Mobile', 'Home', 'Work', 'Fax'];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with mock data (replace with API data in the future)
    employeeIDController = TextEditingController(text: '12345-ABCDE');
    firstNameController = TextEditingController(text: 'John');
    lastNameController = TextEditingController(text: 'Doe');
    usernameController = TextEditingController(text: 'johndoe');
    passwordController = TextEditingController(text: 'password123');

    // Mock email and phone data (replace with API data in the future)
    _emails = [
      {'address': 'johndoe@example.com', 'type': 'Work', 'primary': true},
      {'address': 'john.doe@home.com', 'type': 'Home', 'primary': false},
    ];
    _phones = [
      {'number': '+1234567890', 'type': 'Mobile', 'primary': true},
      {'number': '+0987654321', 'type': 'Home', 'primary': false},
    ];

    // Create controllers for emails and phones
    _emailControllers = _emails.map((email) => TextEditingController(text: email['address'])).toList();
    _phoneControllers = _phones.map((phone) => TextEditingController(text: phone['number'])).toList();
  }

  @override
  void dispose() {
    // Dispose all controllers
    employeeIDController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();

    for (var controller in _emailControllers) {
      controller.dispose();
    }

    for (var controller in _phoneControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _saveAccountChanges() async {
    if (_formKey.currentState!.validate()) {
      // Get user input from the text controllers
      String firstName = firstNameController.text;
      String lastName = lastNameController.text;
      String employeeID = employeeIDController.text;
      String username = usernameController.text;
      String password = passwordController.text;

      // Mock API call (Replace with actual API call to update account details)
      Map<String, dynamic> response = await Future.delayed(const Duration(seconds: 2), () {
        return {'status': 'success'};
      });

      bool accountUpdated = response['status'] == 'success';

      if (accountUpdated) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account updated successfully!')),
        );
        Navigator.pop(context); // Go back after success
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account update failed: ${response['reason']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Account', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // EmployeeID Field
                TextFormField(
                  controller: employeeIDController,
                  decoration: const InputDecoration(
                    labelText: 'Employee ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Employee ID is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // FirstName Field
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'First Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // LastName Field
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Last Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Username Field
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field with Eye Toggle
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Emails Section with types and primary toggle
                const Text(
                  'Emails:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Column(
                  children: _emails.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var email = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emailControllers[idx],
                              decoration: InputDecoration(
                                hintText: 'Email ${idx + 1}',
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          DropdownButton<String>(
                            value: email['type'],
                            onChanged: (newValue) {
                              setState(() {
                                email['type'] = newValue!;
                              });
                            },
                            items: emailTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                          ),
                          Radio<bool>(
                            value: true,
                            groupValue: email['primary'],
                            onChanged: (value) {
                              setState(() {
                                for (var em in _emails) {
                                  em['primary'] = false;
                                }
                                email['primary'] = true;
                              });
                            },
                          ),
                          const Text('Primary'),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _emails.add({'address': '', 'type': 'Work', 'primary': false});
                      _emailControllers.add(TextEditingController(text: ''));
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Email'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                const SizedBox(height: 16),

                // Phone Numbers Section with types and primary toggle
                const Text(
                  'Phone Numbers:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Column(
                  children: _phones.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var phone = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneControllers[idx],
                              decoration: InputDecoration(
                                hintText: 'Phone ${idx + 1}',
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Phone number is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          DropdownButton<String>(
                            value: phone['type'],
                            onChanged: (newValue) {
                              setState(() {
                                phone['type'] = newValue!;
                              });
                            },
                            items: phoneTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                          ),
                          Radio<bool>(
                            value: true,
                            groupValue: phone['primary'],
                            onChanged: (value) {
                              setState(() {
                                for (var ph in _phones) {
                                  ph['primary'] = false;
                                }
                                phone['primary'] = true;
                              });
                            },
                          ),
                          const Text('Primary'),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _phones.add({'number': '', 'type': 'Mobile', 'primary': false});
                      _phoneControllers.add(TextEditingController(text: ''));
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Phone'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                const SizedBox(height: 32),

                // Update Account Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _saveAccountChanges, // Call the save function
                  child: const Text('Update Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}