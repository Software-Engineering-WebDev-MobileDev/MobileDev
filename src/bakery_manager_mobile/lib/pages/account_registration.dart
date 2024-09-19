import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  CreateAccountPageState createState() => CreateAccountPageState();
}

// Create account page state
class CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _employeeIDController = TextEditingController();

// Create account function calls the API to create an account
  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      // Get user input from the text controllers
      String firstName = _firstNameController.text;
      String lastName = _lastNameController.text;
      String employeeID = _employeeIDController.text;
      String username = _usernameController.text;
      String password = _passwordController.text;

      Map<String, dynamic> response = await ApiService.createAccount(
        firstName,
        lastName,
        employeeID,
        username,
        password,
      );

      bool accountCreated = response['status'] == 'success';

      if (accountCreated) {
        // Save credentials to SharedPreferences storing the username and password on device
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('password', password);

        // Ensure the widget is still mounted before using BuildContext
        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pop(context);
      } else {
        // Ensure the widget is still mounted before using BuildContext
        if (!mounted) return;

        // Show error message if account creation failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Account creation failed: ${response['reason']}')),
        );
      }
    }
  }

  // Page Content Build Function
  //  add next and done instructions from login
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _employeeIDController,
                  decoration: const InputDecoration(labelText: 'Employee ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Employee ID is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'First Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Last Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _employeeIDController.dispose();
    super.dispose();
  }
}
