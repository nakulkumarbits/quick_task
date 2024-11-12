import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _registerUser() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String email = _emailController.text.trim();

    // Validate the input fields and display error message to the user.
    if (username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          'All fields are required!',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red.shade500,
      ));
      return;
    }

    // Validate if password entered correctly by the user else display error to the user.
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          'Password do not match!!',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red.shade500,
      ));
      return;
    }
    final user = ParseUser(username, password, email);
    var response = await user.signUp();

    // Display the message if Sign up is successful.
    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'User registered successfully!',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green.shade500,
        ),
      );

      // Go back to the login screen
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error!.message),
          backgroundColor: Colors.red.shade500,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prepare the AppBar for the Sign up screen.
      appBar: AppBar(
        title: const Text('Sign Up'),
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
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Re-enter Password'),
              obscureText: true,
            ),
            TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 20),
            // Invoke the registerUser method when user clicks the button.
            ElevatedButton(
              onPressed: _registerUser,
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(Colors.deepPurple.shade300)),
              child: const Text(
                'Sign Up',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
