import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:skill_exchange_app/models/user_model.dart' as app_model;
import 'package:skill_exchange_app/services/user_service.dart';
import 'package:skill_exchange_app/widgets/skill_card.dart';
import 'package:skill_exchange_app/widgets/user_card.dart';
import 'package:skill_exchange_app/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'profile_screen.dart';
import '../theme/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  // Enhanced featured skills with sparkling colors
  final List<Map<String, dynamic>> _featuredSkills = [
    {
      'name': 'Web Development',
      'icon': Icons.code_rounded,
      'users': 12,
      'color': Colors.blue,
      'gradient': [Color(0xFF2563EB), Color(0xFF7C3AED)],
      'darkGradient': [Color(0xFFFFD700), Color(0xFFFFA000)],
    },
    {
      'name': 'UI/UX Design',
      'icon': Icons.design_services_rounded,
      'users': 8,
      'color': Colors.purple,
      'gradient': [Color(0xFF7C3AED), Color(0xFFDB2777)],
      'darkGradient': [Color(0xFFFF69B4), Color(0xFFFF1493)],
    },
    {
      'name': 'Photography',
      'icon': Icons.camera_alt_rounded,
      'users': 5,
      'color': Colors.orange,
      'gradient': [Color(0xFFEA580C), Color(0xFFDC2626)],
      'darkGradient': [Color(0xFFFFD700), Color(0xFFFF8C00)],
    },
    {
      'name': 'Music Production',
      'icon': Icons.music_note_rounded,
      'users': 7,
      'color': Colors.green,
      'gradient': [Color(0xFF16A34A), Color(0xFF0D9488)],
      'darkGradient': [Color(0xFF00FF00), Color(0xFF32CD32)],
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFDFF),
      appBar: AppBar(
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: isDarkMode
                      ? const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                  )
                      : LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade600],
                  ),
                  shape: BoxShape.circle,
                  // REMOVED: White shadow boxShadow property
                ),
                child: Lottie.asset(
                  'assets/animations/skill_learning.json',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Skill Exchange',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: isDarkMode ? Colors.amber : colorScheme.onSurface,
                  // ADDED: More attractive text shadow
                  shadows: isDarkMode
                      ? [
                    Shadow(
                      color: Colors.amber.withOpacity(0.6),
                      blurRadius: 10,
                      offset: Offset(2, 2),
                    ),
                  ]
                      : [
                    Shadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 8,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : colorScheme.surface,
        elevation: 8,
        shadowColor: isDarkMode ? Colors.black54 : const Color(0x1A000000),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: isDarkMode ? Colors.amber : colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_rounded,
              color: isDarkMode ? Colors.amber : colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
          // Enhanced Theme Toggle Button - REMOVED white shadow
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
              )
                  : LinearGradient(
                colors: [Colors.pink.shade400, Colors.purple.shade600],
              ),
              shape: BoxShape.circle,
              // REMOVED: Problematic boxShadow
            ),
            child: IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
          if (_errorMessage != null)
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: isDarkMode ? Colors.amber : colorScheme.onSurface,
              ),
              onPressed: _refreshData,
            ),
        ],
      ),
      body: Stack(
        children: [
          _buildMainContent(isDarkMode),
          if (_showSuccessMessage)
            _buildSuccessBanner(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isDarkMode),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
          )
              : LinearGradient(
            colors: [Colors.blue.shade600, Colors.purple.shade600],
          ),
          shape: BoxShape.circle,
          // REMOVED: White shadow boxShadow property
        ),
        child: FloatingActionButton(
          onPressed: _refreshData,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.refresh_rounded,
              color: isDarkMode ? Colors.black : Colors.white),
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isDarkMode) {
    final colorScheme = Theme.of(context).colorScheme;

    return _isLoading
        ? const LoadingIndicator(message: 'Loading users...')
        : _errorMessage != null
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/animations/loading_animation.json', width: 100, height: 100),
          const SizedBox(height: 20),
          Text(
            _errorMessage!,
            style: TextStyle(
                color: isDarkMode ? Colors.white : colorScheme.onSurfaceVariant,
                fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
              )
                  : LinearGradient(
                colors: [Colors.blue.shade600, Colors.purple.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Try Again',
                  style: TextStyle(color: isDarkMode ? Colors.black : Colors.white)),
            ),
          ),
        ],
      ),
    )
        : IndexedStack(
      index: _currentIndex,
      children: _buildTabs(isDarkMode),
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

  BottomNavigationBar _buildBottomNavigationBar(bool isDarkMode) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      selectedItemColor: isDarkMode ? Colors.amber : Colors.blue.shade600,
      unselectedItemColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
      elevation: 8,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      items: [
        BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: _currentIndex == 0
                    ? (isDarkMode
                    ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)])
                    : LinearGradient(colors: [Colors.blue.shade600, Colors.purple.shade600]))
                    : const LinearGradient(colors: [Colors.transparent, Colors.transparent]),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.home_rounded),
            ),
            label: 'Home'
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: _currentIndex == 1
                  ? (isDarkMode
                  ? const LinearGradient(colors: [Color(0xFFFF69B4), Color(0xFFFF1493)])
                  : LinearGradient(colors: [Colors.pink.shade600, Colors.purple.shade600]))
                  : const LinearGradient(colors: [Colors.transparent, Colors.transparent]),
              shape: BoxShape.circle,
            ),
            child: const Badge(label: Text('3'), child: Icon(Icons.message_rounded)),
          ),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: _currentIndex == 2
                  ? (isDarkMode
                  ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)])
                  : LinearGradient(colors: [Colors.blue.shade600, Colors.purple.shade600]))
                  : const LinearGradient(colors: [Colors.transparent, Colors.transparent]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded),
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  List<Widget> _buildTabs(bool isDarkMode) {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: isDarkMode
                      ? const LinearGradient(
                    colors: [Color(0xFF2A1F0A), Color(0xFF1A1406)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : LinearGradient(
                    colors: [Colors.blue.shade50, Colors.purple.shade50],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    // REMOVED: Problematic amber shadow in dark mode
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isDarkMode ? Colors.amber.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back! 👋',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.amber : const Color(0xFF1E40AF),
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
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('🔥 Available Skills',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.amber : colorScheme.onSurface
                    )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isDarkMode
                        ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)])
                        : LinearGradient(colors: [Colors.blue.shade400, Colors.purple.shade600]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('See All',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      )),
                ),
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
                      gradient: isDarkMode
                          ? List<Color>.from(skill['darkGradient'])
                          : List<Color>.from(skill['gradient']),
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
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.amber : colorScheme.onSurface
                    )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.amber.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${_users.length} users',
                      style: TextStyle(
                        color: isDarkMode ? Colors.amber : Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // UPDATED: Enhanced User Cards with corner highlights and better colors
            ..._users.map((user) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildEnhancedUserCard(user, isDarkMode),
            )),
            if (_users.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  gradient: isDarkMode
                      ? const LinearGradient(colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)])
                      : LinearGradient(colors: [Colors.grey.shade50, Colors.grey.shade100]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Lottie.asset('assets/animations/welcome_animation.json', width: 120, height: 120),
                    const SizedBox(height: 16),
                    Text('No users found nearby',
                        style: TextStyle(
                            color: isDarkMode ? Colors.grey.shade400 : colorScheme.onSurfaceVariant,
                            fontSize: 16
                        )),
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
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.amber : colorScheme.onSurface
                )),
            const SizedBox(height: 10),
            Text('We\'re working on something amazing',
                style: TextStyle(color: isDarkMode ? Colors.grey.shade400 : colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
      const ProfileScreen(),
    ];
  }

  // NEW: Enhanced User Card with corner highlights and better colors
  Widget _buildEnhancedUserCard(app_model.User user, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? LinearGradient(
          colors: [Color(0xFF2A2A2A), Color(0xFF1E1E1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : LinearGradient(
          colors: [Colors.white, Color(0xFFF8FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.6) : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Corner highlights
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDarkMode ? Colors.amber.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                    Colors.transparent
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDarkMode ? Colors.amber.withOpacity(0.3) : Colors.purple.withOpacity(0.3),
                    Colors.transparent
                  ],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(16),
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    topRight: Radius.circular(16)
                ),
              ),
            ),
          ),
          // User Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isDarkMode ? Colors.amber.shade800 : Colors.blue.shade200,
                      child: Icon(
                        Icons.person,
                        color: isDarkMode ? Colors.amber.shade200 : Colors.blue.shade800,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name ?? 'Unknown User',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            user.email ?? 'No email',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Skills with colorful tags
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: (user.skills ?? []).take(3).map((skill) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: _getSkillGradient(skill, isDarkMode),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getSkillColor(skill).withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get gradient for skill tags
  LinearGradient _getSkillGradient(String skill, bool isDarkMode) {
    final color = _getSkillColor(skill);
    if (isDarkMode) {
      return LinearGradient(
        colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
      );
    } else {
      return LinearGradient(
        colors: [color, color.withOpacity(0.8)],
      );
    }
  }

  // Helper method to assign colors to skills
  Color _getSkillColor(String skill) {
    final skillColors = {
      'Web Development': Colors.blue,
      'UI/UX Design': Colors.purple,
      'Photography': Colors.orange,
      'Music Production': Colors.green,
      'Language Teaching': Colors.red,
      'Cooking': Colors.pink,
    };
    return skillColors[skill] ?? Colors.grey;
  }
}