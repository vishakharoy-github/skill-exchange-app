import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:skill_exchange_app/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  final Function(ThemeMode) changeTheme; // ADD THIS

  const SplashScreen({super.key, required this.changeTheme}); // UPDATE THIS

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Store context in local variable to avoid async gap issues
    final currentContext = context;

    // Direct navigation after a short delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          currentContext,
          MaterialPageRoute(
            builder: (context) => LoginScreen(changeTheme: widget.changeTheme), // FIXED: Add changeTheme
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace Icon with Lottie animation
            Lottie.asset(
              'assets/animations/splash_animation.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              'Skill Exchange',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Learn. Share. Grow.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            // Remove the CircularProgressIndicator since the animation will show progress
          ],
        ),
      ),
    );
  }
}