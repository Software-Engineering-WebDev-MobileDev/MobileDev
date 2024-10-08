import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  CreateAccountPageState createState() => CreateAccountPageState();
}

class CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController employeeIDController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _emailType = 'Work'; // Single email type
  String _phoneType = 'Mobile'; // Single phone type

  // Password requirement indicators
  bool _has8Characters = false;
  bool _hasNumber = false;
  bool _hasSpecialCharacter = false;

  @override
  void initState() {
    super.initState();

    // Add listener to password controller
    passwordController.addListener(_validatePassword);
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

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      // Get user input from the text controllers
      String firstName = firstNameController.text.trim();
      String lastName = lastNameController.text.trim();
      String employeeID = employeeIDController.text.trim();
      String username = usernameController.text.trim();
      String password = passwordController.text.trim();
      String email = emailController.text.trim();
      String phoneNumber = phoneController.text.trim();

      try {
        // Step 1: Attempt to create account
        Map<String, dynamic> accountResponse = await ApiService.createAccount(
          firstName,
          lastName,
          employeeID,
          username,
          password,
        );

        if (accountResponse['status'] == 'success') {
          // Step 2: Add email using session ID from account creation response
          Map<String, dynamic> emailResponse = await ApiService.addUserEmail(
            sessionID: '',
            emailAddress: email,
            emailType: _emailType, // Email type selected from dropdown
          );

          if (emailResponse['status'] == 'success') {
            // Step 3: Commented out the phone number addition logic
            
            /*
            Map<String, dynamic> phoneResponse = await ApiService.addPhoneNumber(
              phoneNumber,
              employeeID,  // Use employeeID from the created account
              _phoneType,  // Phone type selected from dropdown
            );

            // Debugging: Check phone number addition response
            print("Phone number addition response: $phoneResponse");

            if (phoneResponse['status'] == 'success') {
            */

            // Step 4: All succeeded, save credentials and show success message
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('username', username);
            await prefs.setString('password', password);

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account created successfully!')),
            );
            Navigator.pop(context); // Go back after success
            /*
            } else {
              // Phone addition failed
              print("Phone addition failed: ${phoneResponse['reason']}");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add phone number: ${phoneResponse['reason']}')),
              );
            }
            */

          } else {
            // Handle email addition failure
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${emailResponse['reason']}')),
            );
          }
        } else {
          // Account creation failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account creation failed: ${accountResponse['reason']}')),
          );
        }
      } catch (e) {
        // Handle any unexpected errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } else {
      // Form validation failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields correctly')),
      );
    }
  }

  @override
  void dispose() {
    // Remove listener and dispose controllers
    passwordController.removeListener(_validatePassword);
    employeeIDController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose(); // Dispose confirm password controller
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
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
                          if (!_has8Characters) {
                            return 'Password must be at least 8 characters';
                          }
                          if (!_hasNumber) {
                            return 'Password must contain at least one number';
                          }
                          if (!_hasSpecialCharacter) {
                            return 'Password must contain at least one special character';
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
                const SizedBox(height: 8),

                // Password Requirements
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _has8Characters ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: _has8Characters ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('At least 8 characters'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _hasNumber ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: _hasNumber ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('Contains a number'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _hasSpecialCharacter ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: _hasSpecialCharacter ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('Contains a special character'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Confirm Password Field with Eye Toggle
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Email Section
                const Text(
                  'Email:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 140,
                      child: TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _emailType,
                        onChanged: (newValue) {
                          setState(() {
                            _emailType = newValue!;
                          });
                        },
                        items: ['Personal', 'Work', 'Other'].map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Phone Number Section
                const Text(
                  'Phone Number:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 140,
                      child: TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number is required';
                          }
                          if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Phone number must be 10 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _phoneType,
                        onChanged: (newValue) {
                          setState(() {
                            _phoneType = newValue!;
                          });
                        },
                        items: ['Mobile', 'Home', 'Work', 'Fax'].map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
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
                  onPressed: _createAccount, // Call the create account function
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