import 'package:SkillExchange/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/skill_screen.dart';
import 'screens/interest_screen.dart';
import 'screens/home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // For Flutter Web, you'll need to pass FirebaseOptions manually
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'your-api-key',
        appId: 'your-app-id',
        messagingSenderId: 'your-sender-id',
        projectId: 'your-project-id',
        storageBucket: 'your-storage-bucket',
        authDomain: 'your-auth-domain',
      ),
    );
    print("✅ Firebase initialized");
  } catch (e) {
    print("❌ Firebase init error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skill Exchange',
      theme: customTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) =>  LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/skills': (context) =>  SkillScreen(),
        '/interests': (context) => InterestScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

