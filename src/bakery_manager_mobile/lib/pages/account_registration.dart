import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  CreateAccountPageState createState() => CreateAccountPageState();
}

class CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController employeeIDController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  bool _obscurePassword = true;

  // Focus nodes for tracking focus
  final FocusNode employeeIDFocus = FocusNode();
  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();
  final FocusNode usernameFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();

  // Error display tracking for each field
  bool _showEmployeeIDError = false;
  bool _showFirstNameError = false;
  bool _showLastNameError = false;
  bool _showUsernameError = false;
  bool _showPasswordError = false;
  bool _showEmailError = false;
  bool _showPhoneError = false;

  // Password validation tracking
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _hasMinLength = false;

  String _emailType = 'Work';
  String _phoneType = 'Mobile';

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    employeeIDController = TextEditingController();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();

    // Add listeners to validate fields when focus is lost
    _setupFocusListeners();

    // Add listener for password validation
    passwordController.addListener(_validatePassword);
  }

  // Setup focus listeners for all fields
  void _setupFocusListeners() {
    employeeIDFocus.addListener(() {
      if (!employeeIDFocus.hasFocus) {
        setState(() {
          _showEmployeeIDError = true;
        });
      }
    });
    firstNameFocus.addListener(() {
      if (!firstNameFocus.hasFocus) {
        setState(() {
          _showFirstNameError = true;
        });
      }
    });
    lastNameFocus.addListener(() {
      if (!lastNameFocus.hasFocus) {
        setState(() {
          _showLastNameError = true;
        });
      }
    });
    usernameFocus.addListener(() {
      if (!usernameFocus.hasFocus) {
        setState(() {
          _showUsernameError = true;
        });
      }
    });
    passwordFocus.addListener(() {
      if (!passwordFocus.hasFocus) {
        setState(() {
          _showPasswordError = true;
        });
      }
    });
    emailFocus.addListener(() {
      if (!emailFocus.hasFocus) {
        setState(() {
          _showEmailError = true;
        });
      }
    });
    phoneFocus.addListener(() {
      if (!phoneFocus.hasFocus) {
        setState(() {
          _showPhoneError = true;
        });
      }
    });
  }

  // Password validation method with dynamic requirements
  void _validatePassword() {
    String password = passwordController.text;

    setState(() {
      _hasMinLength = password.length >= 8;
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#\$&*~]'));
    });
  }

  String? _validatePasswordMessage(String? value) {
    if (_showPasswordError) {
      if (value == null || value.isEmpty) {
        return 'Password is required';
      } else if (!_hasMinLength || !_hasNumber || !_hasSpecialChar) {
        return null; // Dynamic errors are shown below the field
      }
    }
    return null;
  }

  // Email validation method (checks if contains '@')
  String? _validateEmail(String? value) {
    if (_showEmailError) {
      if (value == null || value.isEmpty) {
        return 'Email is required';
      } else if (!value.contains('@')) {
        return 'Please enter a valid email (must contain @)';
      }
    }
    return null;
  }

  // Phone number validation method
  String? _validatePhoneNumber(String? value) {
    final phonePattern = RegExp(r'^\d{10}$');
    if (_showPhoneError) {
      if (value == null || value.isEmpty) {
        return 'Phone number is required';
      } else if (!phonePattern.hasMatch(value)) {
        return 'Phone number must be 10 digits';
      }
    }
    return null;
  }

  String? _validateEmployeeID(String? value) {
    if (_showEmployeeIDError && (value == null || value.isEmpty)) {
      return 'Employee ID is required';
    }
    return null;
  }

  String? _validateFirstName(String? value) {
    if (_showFirstNameError && (value == null || value.isEmpty)) {
      return 'First Name is required';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (_showLastNameError && (value == null || value.isEmpty)) {
      return 'Last Name is required';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (_showUsernameError && (value == null || value.isEmpty)) {
      return 'Username is required';
    }
    return null;
  }

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      // Get user input from the text controllers
      String firstName = firstNameController.text;
      String lastName = lastNameController.text;
      String employeeID = employeeIDController.text;
      String username = usernameController.text;
      String password = passwordController.text;

      // Create account using the API (without email and phone)
      Map<String, dynamic> response = await ApiService.createAccount(
        firstName,
        lastName,
        employeeID,
        username,
        password,
      );

      bool accountCreated = response['status'] == 'success';

      if (accountCreated) {
        // Save credentials to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('password', password);

        // Navigate back after success
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pop(context); // Go back after success
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account creation failed: ${response['reason']}')),
        );
      }
    }
  }

  @override
  void dispose() {
    employeeIDController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    phoneController.dispose();
    employeeIDFocus.dispose();
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    usernameFocus.dispose();
    passwordFocus.dispose();
    emailFocus.dispose();
    phoneFocus.dispose();
    super.dispose();
  }

  Widget _buildDynamicPasswordErrors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _hasMinLength ? "• At least 8 characters" : "• Must have at least 8 characters",
          style: TextStyle(color: _hasMinLength ? Colors.green : Colors.red),
        ),
        Text(
          _hasNumber ? "• At least one number" : "• Must have at least one number",
          style: TextStyle(color: _hasNumber ? Colors.green : Colors.red),
        ),
        Text(
          _hasSpecialChar ? "• At least one special character" : "• Must have at least one special character",
          style: TextStyle(color: _hasSpecialChar ? Colors.green : Colors.red),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account', style: TextStyle(color: Colors.white)),
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
                  focusNode: employeeIDFocus,
                  decoration: const InputDecoration(
                    labelText: 'Employee ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: _validateEmployeeID,
                ),
                const SizedBox(height: 16),

                // FirstName Field
                TextFormField(
                  controller: firstNameController,
                  focusNode: firstNameFocus,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: _validateFirstName,
                ),
                const SizedBox(height: 16),

                // LastName Field
                TextFormField(
                  controller: lastNameController,
                  focusNode: lastNameFocus,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: _validateLastName,
                ),
                const SizedBox(height: 16),

                // Username Field
                TextFormField(
                  controller: usernameController,
                  focusNode: usernameFocus,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: _validateUsername,
                ),
                const SizedBox(height: 16),

                // Password Field with Eye Toggle
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: passwordController,
                        focusNode: passwordFocus,
                        obscureText: _obscurePassword,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        validator: _validatePasswordMessage,
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
                const SizedBox(height: 8),
                _buildDynamicPasswordErrors(),
                const SizedBox(height: 16),

                // Email Field
                const Text(
                  'Email:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: emailController,
                        focusNode: emailFocus,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        validator: _validateEmail,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _emailType,
                      onChanged: (newValue) {
                        setState(() {
                          _emailType = newValue!;
                        });
                      },
                      items: ['Work', 'Home', 'Other'].map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Phone Number Field
                const Text(
                  'Phone Number:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: phoneController,
                        focusNode: phoneFocus,
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        validator: _validatePhoneNumber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _phoneType,
                      onChanged: (newValue) {
                        setState(() {
                          _phoneType = newValue!;
                        });
                      },
                      items: ['Mobile', 'Home', 'Work'].map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Create Account Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _createAccount,
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}