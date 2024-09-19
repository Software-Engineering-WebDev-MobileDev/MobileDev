import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bakery_manager_mobile/assets/constants.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  MyAccountPageState createState() => MyAccountPageState();
}

class MyAccountPageState extends State<MyAccountPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadAccountDetails();
  }

  Future<void> _loadAccountDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _firstNameController.text = prefs.getString('first_name') ?? '';
      _lastNameController.text = prefs.getString('last_name') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
    });
  }

  Future<void> _saveAccountDetails() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('first_name', _firstNameController.text);
      await prefs.setString('last_name', _lastNameController.text);
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('password', _passwordController.text);

      if (!mounted) return;
      setState(() {
        _isEditing = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account details updated successfully')),
      );
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, loginPageRoute);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account Details',
          style: TextStyle(color: Colors.white),
        ),
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
              Navigator.popUntil(context, ModalRoute.withName('/')); // Home navigation
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: SingleChildScrollView(
            child: _buildAccountDetails(),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Welcome, John Doe!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 209, 126, 51),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: 300,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      icon: Icons.person,
                      enabled: _isEditing,
                    ),
                    const Divider(),
                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      icon: Icons.person_outline,
                      enabled: _isEditing,
                    ),
                    const Divider(),
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Username',
                      icon: Icons.account_circle,
                      enabled: _isEditing,
                    ),
                    const Divider(),
                    _buildPasswordField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock,
                      enabled: _isEditing,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 150,
          child: _isEditing
              ? ElevatedButton(
                  onPressed: _saveAccountDetails,
                  child: const Text('Save'),
                )
              : ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  child: const Text('Edit'),
                ),
        ),
        const SizedBox(height: 10),
        if (!_isEditing)
          SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        icon: Icon(icon),
      ),
      validator: (value) {
        if (enabled && (value == null || value.isEmpty)) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        icon: Icon(icon),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: enabled ? onToggleVisibility : null,
        ),
      ),
      validator: (value) {
        if (enabled && (value == null || value.isEmpty)) {
          return 'Please enter your $label';
        }
        if (enabled && value!.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
    );
  }
}
