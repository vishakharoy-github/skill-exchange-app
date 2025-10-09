import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:skill_exchange_app/firebase_options.dart';
import 'package:skill_exchange_app/screens/splash_screen.dart';
import 'package:skill_exchange_app/screens/login_screen.dart'; // Add this import
import 'package:skill_exchange_app/screens/signup_screen.dart'; // Add this import
import 'package:skill_exchange_app/screens/home_screen.dart'; // Add this import
import 'package:skill_exchange_app/services/auth_service.dart';
import 'package:skill_exchange_app/services/user_service.dart';
import 'package:skill_exchange_app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully'); // Use debugPrint instead of print
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e'); // Use debugPrint instead of print
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => UserService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Skill Exchange',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}