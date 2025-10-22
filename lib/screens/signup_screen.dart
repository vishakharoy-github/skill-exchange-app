import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:skill_exchange_app/screens/login_screen.dart';
import 'package:skill_exchange_app/screens/skill_screen.dart'; // ADD THIS IMPORT
import 'package:skill_exchange_app/services/auth_service.dart';
import 'package:skill_exchange_app/widgets/custom_button.dart';
import 'package:skill_exchange_app/widgets/custom_textfield.dart';
import 'package:skill_exchange_app/widgets/loading_indicator.dart';
import 'package:skill_exchange_app/widgets/success_animation.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _RegistrationSuccessScreen extends StatelessWidget {
  final VoidCallback onAnimationComplete;

  const _RegistrationSuccessScreen({required this.onAnimationComplete});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), onAnimationComplete);

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/success_checkmark.json',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            Text(
              'Account Created!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Redirecting to skills selection...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Store context in a local variable to avoid using BuildContext across async gaps
    final currentContext = context;

    // Show loading dialog
    showDialog(
      context: currentContext,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: LoadingIndicator(message: 'Creating your account...'),
      ),
    );

    try {
      final authService = Provider.of<AuthService>(currentContext, listen: false);
      await authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      // Close loading dialog
      Navigator.pop(currentContext);

      // Show success animation
      _showRegistrationSuccess();

    } catch (e) {
      // Close loading dialog
      Navigator.pop(currentContext);

      if (!mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text('Signup failed: ${e.toString()}')),
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRegistrationSuccess() {
    if (!mounted) return;

    // Navigate directly to a success screen that will auto-redirect to SkillScreen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => _RegistrationSuccessScreen(
          onAnimationComplete: () {
            Navigator.of(context).pushAndRemoveUntil(
              // CHANGE THIS: Navigate to SkillScreen instead of InterestsScreen
              MaterialPageRoute(builder: (context) => const SkillScreen()),
                  (route) => false,
            );
          },
        ),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.teal.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Lottie animation for signup
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Lottie.asset(
                          'assets/animations/skill_learning.json',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 30),

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Join our community of skill sharers',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),

                      SlideTransition(
                        position: _slideAnimation,
                        child: CustomTextField(
                          controller: _nameController,
                          hintText: 'Full Name',
                          prefixIcon: Icons.person_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      SlideTransition(
                        position: _slideAnimation,
                        child: CustomTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      SlideTransition(
                        position: _slideAnimation,
                        child: CustomTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: true,
                          prefixIcon: Icons.lock_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      SlideTransition(
                        position: _slideAnimation,
                        child: CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm Password',
                          obscureText: true,
                          prefixIcon: Icons.lock_reset_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 30),

                      ScaleTransition(
                        scale: _fadeAnimation,
                        child: CustomButton(
                          text: 'Create Account',
                          onPressed: _isLoading ? null : _signup,
                          isLoading: _isLoading,
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade600,
                              Colors.teal.shade600,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: _isLoading ? null : () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}