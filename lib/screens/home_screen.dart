import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:skill_exchange_app/models/user_model.dart' as app_model;
import 'package:skill_exchange_app/services/user_service.dart';
import 'package:skill_exchange_app/widgets/skill_card.dart';
import 'package:skill_exchange_app/widgets/user_card.dart';
import 'package:skill_exchange_app/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) changeTheme; // ADD THIS

  const HomeScreen({super.key, required this.changeTheme}); // UPDATE THIS

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final List<app_model.User> _users = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _showSuccessMessage = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Sample featured skills with colors
  final List<Map<String, dynamic>> _featuredSkills = [
    {
      'name': 'Web Development',
      'icon': Icons.code_rounded,
      'users': 12,
      'color': Colors.blue,
      'gradient': [Color(0xFF2563EB), Color(0xFF7C3AED)],
    },
    {
      'name': 'UI/UX Design',
      'icon': Icons.design_services_rounded,
      'users': 8,
      'color': Colors.purple,
      'gradient': [Color(0xFF7C3AED), Color(0xFFDB2777)],
    },
    {
      'name': 'Photography',
      'icon': Icons.camera_alt_rounded,
      'users': 5,
      'color': Colors.orange,
      'gradient': [Color(0xFFEA580C), Color(0xFFDC2626)],
    },
    {
      'name': 'Music Production',
      'icon': Icons.music_note_rounded,
      'users': 7,
      'color': Colors.green,
      'gradient': [Color(0xFF16A34A), Color(0xFF0D9488)],
    },
  ];

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

    _animationController.forward();
    _loadUsers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSuccessMessage = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final users = await userService.getAllUsers();
      setState(() {
        _users.addAll(users);
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load users: ${e.toString()}';
      });
    }
  }

  void _refreshData() {
    setState(() {
      _isLoading = true;
      _users.clear();
      _errorMessage = null;
    });
    _loadUsers();
  }

  void _toggleTheme() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    widget.changeTheme(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  // REMOVE all these theme methods since we're using the system theme now:
  // ThemeData get _theme { ... }
  // Color _getBackgroundColor() { ... }
  // Color _getTextColor() { ... }
  // Color _getSubtitleColor() { ... }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            children: [
              Lottie.asset(
                'assets/animations/skill_learning.json',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Text(
                'Skill Exchange',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shadowColor: isDarkMode ? Colors.black54 : const Color(0x1A000000),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_rounded,
              color: colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDarkMode ? Colors.amber : colorScheme.onSurface,
            ),
            onPressed: _toggleTheme,
          ),
          if (_errorMessage != null)
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: colorScheme.onSurface,
              ),
              onPressed: _refreshData,
            ),
        ],
      ),
      body: Stack(
        children: [
          _buildMainContent(),
          if (_showSuccessMessage)
            _buildSuccessBanner(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.refresh_rounded, color: colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildMainContent() {
    final colorScheme = Theme.of(context).colorScheme;

    return _isLoading
        ? const LoadingIndicator(message: 'Loading users...')
        : _errorMessage != null
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/loading_animation.json',
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 20),
          Text(
            _errorMessage!,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Try Again', style: TextStyle(color: colorScheme.onPrimary)),
          ),
        ],
      ),
    )
        : IndexedStack(
      index: _currentIndex,
      children: _buildTabs(),
    );
  }

  Widget _buildSuccessBanner() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: _showSuccessMessage ? 80 : 0,
        curve: Curves.easeInOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF16A34A), Color(0xFF0D9488)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/success_checkmark.json',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              const Text(
                'Login Successful!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(
          icon: Badge(label: Text('3'), child: Icon(Icons.message_rounded)),
          label: 'Messages',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }

  List<Widget> _buildTabs() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return [
      SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [const Color(0xFF1E40AF), const Color(0xFF6B21A8)]
                          : [const Color(0xFFDBEAFE), const Color(0xFFF3E8FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back! 👋',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : const Color(0xFF1E40AF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Discover new skills and connect with amazing people',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? const Color(0xFFB0BEC5) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('🔥 Available Skills',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onBackground)),
                Text('See All',
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _featuredSkills.length,
                itemBuilder: (context, index) {
                  final skill = _featuredSkills[index];
                  return Container(
                    width: 160,
                    margin: EdgeInsets.only(right: index == _featuredSkills.length - 1 ? 0 : 16),
                    child: SkillCard(
                      skill: skill['name'],
                      icon: skill['icon'],
                      users: skill['users'],
                      color: skill['color'],
                      gradient: List<Color>.from(skill['gradient']),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('👥 People Near You',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onBackground)),
                Text('${_users.length} users',
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            ..._users.map((user) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: UserCard(user: user),
            )),
            if (_users.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Lottie.asset('assets/animations/welcome_animation.json', width: 120, height: 120),
                    const SizedBox(height: 16),
                    Text('No users found nearby',
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16)),
                  ],
                ),
              ),
          ],
        ),
      ),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/loading_animation.json', width: 150, height: 150),
            const SizedBox(height: 20),
            Text('Messages Coming Soon!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onBackground)),
            const SizedBox(height: 10),
            Text('We\'re working on something amazing',
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
      const ProfileScreen(), // This will now properly detect the theme
    ];
  }
}