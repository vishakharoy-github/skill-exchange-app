import 'package:flutter/material.dart';
import 'skill_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome to Skill Exchange!"),
            const SizedBox(height: 20),
            ElevatedButton(
              // Navigate to SkillScreen when this button is pressed
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SkillScreen()),
              ),
              child: const Text("Go to Skills"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}

