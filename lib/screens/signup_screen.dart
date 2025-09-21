import '../utils/animations.dart';
import 'skill_screen.dart';  // adjust path if SkillScreen is in another folder like '../screens/skill_screen.dart'
import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _signup() {
    // Add Firebase signup logic here
    Navigator.of(context).push(fadePageTransition(SkillScreen())); // 👉 Go to Skills after signup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              controller: emailController,
              labelText: "Email",
              icon: Icons.email,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: passwordController,
              labelText: "Password",
              obscureText: true,
              icon: Icons.lock,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: "Sign Up",
              onTap: _signup,
            ),
          ],
        ),
      ),
    );
  }
}
