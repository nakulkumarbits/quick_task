import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:quick_task/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Check if username or password is empty and display error message to the user.
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          'Username/Password cannot be empty!',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red.shade500,
      ));
      return;
    }

    final user = ParseUser(username, password, null);
    var response = await user.login();

    // Route to taskList in case of successful login.
    if (response.success) {
      Navigator.pushReplacementNamed(context, '/taskList');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response.error!.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prepare the AppBar for the Login screen.
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username')),
            TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Display the Login button and route to login method when pressed.
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.deepPurple.shade300)),
                  onPressed: _login,
                  child: const Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                // Display the Sign up button and route to Signup screen when pressed.
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.deepPurple.shade300)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
