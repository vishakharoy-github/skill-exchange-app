import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'widgets/loading_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Track theme mode
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

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
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: _themeMode,
        home: AuthWrapper(changeTheme: _changeTheme),
        routes: {
          '/login': (context) => LoginScreen(changeTheme: _changeTheme),
          '/signup': (context) => SignupScreen(changeTheme: _changeTheme),
          '/home': (context) => HomeScreen(changeTheme: _changeTheme),
        },
        // ADD THIS to preserve navigation state during theme changes
        navigatorKey: NavigatorKey.navigatorKey,
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFFFF6B6B),
        secondary: Color(0xFF4ECDC4),
        surface: Color(0xFFFFFFFF),
        background: Color(0xFFF0F4FF),
        onBackground: Color(0xFF374151),
      ),
      scaffoldBackgroundColor: Color(0xFFF0F4FF),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF8B5CF6),
        secondary: Color(0xFF10B981),
        surface: Color(0xFF1F2937),
        background: Color(0xFF111827),
        onBackground: Colors.white,
      ),
      scaffoldBackgroundColor: Color(0xFF111827),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1F2937),
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ADD THIS CLASS to manage navigation state
class NavigatorKey {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class AuthWrapper extends StatelessWidget {
  final Function(ThemeMode) changeTheme;

  const AuthWrapper({super.key, required this.changeTheme});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.userState,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: LoadingIndicator(message: 'Checking authentication...'),
          );
        }

        if (snapshot.hasData && authService.isLoggedIn) {
          return HomeScreen(changeTheme: changeTheme);
        }

        return LoginScreen(changeTheme: changeTheme);
      },
    );
  }
}