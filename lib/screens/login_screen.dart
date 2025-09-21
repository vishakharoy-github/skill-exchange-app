
import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../utils/animations.dart';  // Import the animations utility
import 'home_screen.dart';  // Import the HomeScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    // Your login logic goes here
    // For now, let's simulate a successful login
    debugPrint('Logging in with ${_emailController.text}');

    // Once login is successful, navigate to the HomeScreen
    Navigator.of(context).push(fadePageTransition(HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomButton(
              onTap: _login,  // Trigger the _login function when the button is pressed
              text: 'Login',
            ),
          ],
        ),
      ),
    );
  }
}
