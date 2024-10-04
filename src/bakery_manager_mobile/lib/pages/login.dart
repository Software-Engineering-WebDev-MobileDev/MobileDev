import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../assets/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateButton);
    _passwordController.addListener(_updateButton);
    _savedCredentials();
  }

  void _updateButton() {
    setState(() {
      _isButtonDisabled =
          _usernameController.text.isEmpty || _passwordController.text.isEmpty;
    });
  }

  Future<void> _savedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('remember_me') ?? false;
    if (rememberMe) {
      String? savedUsername = prefs.getString('username');
      String? savedPassword = prefs.getString('password');
      if (savedUsername != null && savedPassword != null) {
        _usernameController.text = savedUsername;
        _passwordController.text = savedPassword;
        setState(() {
          _rememberMe = rememberMe;
        });
      }
    }
  }

  // Save credentials to SharedPreferences
  Future<void> _saveCredentials(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('username', username);
      await prefs.setString('password', password);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('username');
      await prefs.remove('password');
      await prefs.setBool('remember_me', false);
    }
  }

  // Login function
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String enteredUsername = _usernameController.text;
      String enteredPassword = _passwordController.text;

      // Call the API to log in
      final response = await ApiService.login(enteredUsername, enteredPassword);

      if (response['status'] == 'success') {
        // Save credentials if 'Remember Me' is checked
        await _saveCredentials(enteredUsername, enteredPassword);

        if (!mounted) return;

        // Navigate to the home page and show success message
        Navigator.pushReplacementNamed(context, homePageRoute);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful')),
        );
      } else {
        if (mounted) {
          // Show error message if login failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['reason'] ?? 'Login failed')),
          );
        }
      }
    }
  }

  // Page Content Build Function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10)
          ),
        ),
        title: Stack(
          children: <Widget>[
            // Stroked text as border.
            Text(
              'The Rolling Scones',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 30,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = const Color.fromARGB(255, 140,72,27),
              ),
            ),
            // Solid text as fill.
            const Text(
              'The Rolling Scones',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 246,235,216),
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Sign In',
                    style: TextStyle(
                      fontFamily: 'Troops Display',
                      fontSize: 30,
                      color: Color.fromARGB(255, 209,126,51),
                    ),
                  ),
                  const SizedBox(height: 75),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: _usernameController,
                            decoration:
                                const InputDecoration(labelText: 'Username'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: _passwordController,
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _login(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value!;
                                });
                              },
                            ),
                            const Text('Remember Me'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: _isButtonDisabled ? null : _login,
                            child: const Text('Login'),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (mounted) {
                              Navigator.pushNamed(context, registrationPageRoute);
                            }
                          },
                          child: const Text('Create an account'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}