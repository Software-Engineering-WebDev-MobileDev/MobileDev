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
  late TextEditingController confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _has8Characters = false;
  bool _hasNumber = false;
  bool _hasSpecialCharacter = false;

  List<Map<String, dynamic>> _emails = [];
  List<Map<String, dynamic>> _phones = [];
  List<TextEditingController> _emailControllers = [];
  List<TextEditingController> _phoneControllers = [];

  final List<String> emailTypes = ['Work', 'Home', 'Other'];
  final List<String> phoneTypes = ['Mobile', 'Home', 'Work', 'Fax'];

  @override
  void initState() {
    super.initState();

    employeeIDController = TextEditingController(text: '12345-ABCDE');
    firstNameController = TextEditingController(text: 'John');
    lastNameController = TextEditingController(text: 'Doe');
    usernameController = TextEditingController(text: 'johndoe');
    passwordController = TextEditingController(text: 'password123');
    confirmPasswordController = TextEditingController();

    _emails = [
      {'address': 'johndoe@example.com', 'type': 'Work', 'primary': true},
      {'address': 'john.doe@home.com', 'type': 'Home', 'primary': false},
    ];
    _phones = [
      {'number': '+1234567890', 'type': 'Mobile', 'primary': true},
      {'number': '+0987654321', 'type': 'Home', 'primary': false},
    ];

    _emailControllers = _emails.map((email) => TextEditingController(text: email['address'])).toList();
    _phoneControllers = _phones.map((phone) => TextEditingController(text: phone['number'])).toList();

    passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    employeeIDController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    passwordController.removeListener(_validatePassword);
    passwordController.dispose();
    confirmPasswordController.dispose();
    for (var controller in _emailControllers) {
      controller.dispose();
    }

    for (var controller in _phoneControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // Function to validate password requirements
  void _validatePassword() {
    String password = passwordController.text;
    setState(() {
      _has8Characters = password.length >= 8;
      _hasNumber = password.contains(RegExp(r'\d'));
      _hasSpecialCharacter = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  // Email validation function
  String? _validateEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (email.isEmpty) {
      return 'Email is required';
    } else if (!emailRegex.hasMatch(email)) {
      return 'Invalid email format.';
    }
    return null;
  }

  // Phone number validation function
  String? _validatePhone(String phone) {
    final phoneRegex = RegExp(r'^\d{10}$'); // Expecting 10 digits
    if (phone.isEmpty) {
      return 'Phone number is required';
    } else if (!phoneRegex.hasMatch(phone)) {
      return 'Phone number must be 10 digits long.';
    }
    return null;
  }

  // Remove email field and handle primary email reassignment
  void _removeEmailField(int index) {
    bool wasPrimary = _emails[index]['primary'];

    setState(() {
      _emails.removeAt(index);
      _emailControllers.removeAt(index).dispose();

      // If the primary email was deleted, make the first email the new primary
      if (wasPrimary && _emails.isNotEmpty) {
        _emails[0]['primary'] = true;
        _emails[0]['type'] = 'Primary';
      }
    });
  }

  // Remove phone field and handle primary phone reassignment
  void _removePhoneField(int index) {
    bool wasPrimary = _phones[index]['primary'];

    setState(() {
      _phones.removeAt(index);
      _phoneControllers.removeAt(index).dispose();

      // If the primary phone was deleted, make the first phone the new primary
      if (wasPrimary && _phones.isNotEmpty) {
        _phones[0]['primary'] = true;
        _phones[0]['type'] = 'Primary';
      }
    });
  }

  Future<void> _saveAccountChanges() async {
    if (_formKey.currentState!.validate()) {
      // Get user input from the text controllers
      String firstName = firstNameController.text;
      String lastName = lastNameController.text;
      String employeeID = employeeIDController.text;
      String username = usernameController.text;
      String password = passwordController.text;

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

// Build emails field with primary dropdown change and updated type list
Column _buildEmailsField() {
  return Column(
    children: _emails.asMap().entries.map((entry) {
      int idx = entry.key;
      var email = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            // Email Text Field
            Expanded(
              child: TextFormField(
                controller: _emailControllers[idx],
                decoration: InputDecoration(
                  hintText: 'Email ${idx + 1}',
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: _validateEmail(_emailControllers[idx].text) == null
                          ? Colors.grey
                          : Colors.red,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
                validator: (value) => _validateEmail(value!),
              ),
            ),
            const SizedBox(width: 8),
            
            // Primary Radio Button
            Radio<bool>(
              value: true,
              groupValue: email['primary'],
              onChanged: (value) {
                setState(() {
                  // Clear all other primary flags
                  for (var em in _emails) {
                    em['primary'] = false;
                    if (em['type'] == 'Primary') {
                      em['type'] = emailTypes[0]; // Set to default type
                    }
                  }
                  email['primary'] = true;
                  email['type'] = 'Primary'; // Set the dropdown value to Primary
                });
              },
            ),
            const Text('Primary'),
            const SizedBox(width: 8),

            // Email Type Dropdown
            DropdownButton<String>(
              value: email['primary'] ? 'Primary' : email['type'],
              onChanged: email['primary']
                  ? null // Disable dropdown when primary is selected
                  : (newValue) {
                      setState(() {
                        email['type'] = newValue!;
                      });
                    },
              items: [
                if (email['primary']) // Show 'Primary' only if selected by radio
                  const DropdownMenuItem(
                    value: 'Primary',
                    child: Text('Primary'),
                  ),
                ...['Personal', 'Home', 'Work', 'Other']
                    .where((type) => type != 'Primary')
                    .map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
              ],
            ),
            const SizedBox(width: 8),

            // Subtract/Remove Button
            if (_emails.length > 1)
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removeEmailField(idx),
              ),
          ],
        ),
      );
    }).toList(),
  );
}

// Build phones field with primary dropdown change
Column _buildPhonesField() {
  return Column(
    children: _phones.asMap().entries.map((entry) {
      int idx = entry.key;
      var phone = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            // Phone Number Field
            Expanded(
              child: TextFormField(
                controller: _phoneControllers[idx],
                decoration: InputDecoration(
                  hintText: 'Phone ${idx + 1}',
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: _validatePhone(_phoneControllers[idx].text) == null
                          ? Colors.grey
                          : Colors.red,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
                validator: (value) => _validatePhone(value!),
              ),
            ),
            const SizedBox(width: 8),

            // Primary Radio Button
            Radio<bool>(
              value: true,
              groupValue: phone['primary'],
              onChanged: (value) {
                setState(() {
                  // Clear all other primary flags
                  for (var ph in _phones) {
                    ph['primary'] = false;
                    if (ph['type'] == 'Primary') {
                      ph['type'] = phoneTypes[0]; // Set to default type
                    }
                  }
                  phone['primary'] = true;
                  phone['type'] = 'Primary'; // Set the dropdown value to Primary
                });
              },
            ),
            const Text('Primary'),
            const SizedBox(width: 8),

            // Phone Type Dropdown
            DropdownButton<String>(
              value: phone['primary'] ? 'Primary' : phone['type'],
              onChanged: phone['primary']
                  ? null // Disable dropdown when primary is selected
                  : (newValue) {
                      setState(() {
                        phone['type'] = newValue!;
                      });
                    },
              items: [
                if (phone['primary']) // Show 'Primary' only if selected by radio
                  const DropdownMenuItem(
                    value: 'Primary',
                    child: Text('Primary'),
                  ),
                ...phoneTypes
                    .where((type) => type != 'Primary')
                    .map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
              ],
            ),
            const SizedBox(width: 8),

            // Subtract/Remove Button
            if (_phones.length > 1)
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removePhoneField(idx),
              ),
          ],
        ),
      );
    }).toList(),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
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
        shape: const RoundedRectangleBorder(),
        title: const Stack(
          children: <Widget>[
            Text(
              'Edit Account',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
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

                // Emails Field
                const Text(
                  'Emails:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildEmailsField(),
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

                // Phone Numbers Field
                const Text(
                  'Phone Numbers:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildPhonesField(),
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