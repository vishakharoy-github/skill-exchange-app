import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:skill_exchange_app/models/user_model.dart' as app_model;
import 'package:skill_exchange_app/services/user_service.dart';
import 'package:skill_exchange_app/services/auth_service.dart';
import 'package:skill_exchange_app/widgets/custom_button.dart';
import 'package:skill_exchange_app/screens/edit_profile_screen.dart';
import '../theme/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _aboutMeController = TextEditingController();
  app_model.User? _currentUser;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  void _loadCurrentUser() async {
    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final currentUser = await userService.getCurrentUser();
      if (currentUser != null) {
        setState(() {
          _currentUser = currentUser;
          _aboutMeController.text = currentUser.bio ?? 'I\'m an enthusiastic IT student.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showSignOutDialog() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: _getDialogGradient(isDarkMode),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isDarkMode
                        ? const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                    )
                        : const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to sign out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        textColor: Colors.white,
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isDarkMode
                              ? const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                          )
                              : const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CustomButton(
                          text: 'Sign Out',
                          onPressed: () {
                            Navigator.of(context).pop();
                            _signOut();
                          },
                          backgroundColor: Colors.transparent,
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Signed out successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // Enhanced color scheme getters with sparkling theme
  LinearGradient _getBackgroundGradient(bool isDarkMode) {
    return isDarkMode
        ? const LinearGradient(
      colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A), Color(0xFF2A1F0A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFFFAFDFF), Color(0xFFF0F4FF), Color(0xFFE6F0FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  LinearGradient _getProfileHeaderGradient(bool isDarkMode) {
    return isDarkMode
        ? const LinearGradient(
      colors: [Color(0xFFFFD700), Color(0xFFFFA000), Color(0xFFFF8C00)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFFD93D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  LinearGradient _getSkillsGradient(bool isDarkMode) {
    return isDarkMode
        ? const LinearGradient(
      colors: [Color(0xFF2A1F0A), Color(0xFF1A1406), Color(0xFF3D2E00)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFF00B4D8), Color(0xFF0096C7), Color(0xFF0077B6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  LinearGradient _getInterestsGradient(bool isDarkMode) {
    return isDarkMode
        ? const LinearGradient(
      colors: [Color(0xFF2D1B4E), Color(0xFF1A1035), Color(0xFF4A148C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA), Color(0xFFC4B5FD)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  LinearGradient _getAboutMeGradient(bool isDarkMode) {
    return isDarkMode
        ? const LinearGradient(
      colors: [Color(0xFF1A0F33), Color(0xFF2D1B4E), Color(0xFF4A148C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFFEC4899), Color(0xFFF472B6), Color(0xFFF9A8D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  LinearGradient _getActionGradient(bool isDarkMode) {
    return isDarkMode
        ? const LinearGradient(
      colors: [Color(0xFFFFD700), Color(0xFFFFA000), Color(0xFFFF8C00)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFFD93D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  LinearGradient _getDialogGradient(bool isDarkMode) {
    return isDarkMode
        ? const LinearGradient(
      colors: [Color(0xFF2A1F0A), Color(0xFF1A1406), Color(0xFF3D2E00)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFFD93D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color _getSkillTagColor(bool isDarkMode, int index) {
    final darkColors = [
      const Color(0xFFFFD700),
      const Color(0xFFFFA000),
      const Color(0xFFFF69B4),
      const Color(0xFF00FF00),
      const Color(0xFF00BFFF),
      const Color(0xFFFF1493),
      const Color(0xFF32CD32),
    ];
    final lightColors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFD93D),
      const Color(0xFF6BCF7F),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF00B4D8),
    ];
    return isDarkMode ? darkColors[index % darkColors.length] : lightColors[index % lightColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    if (_isLoading || _currentUser == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: _getBackgroundGradient(isDarkMode),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/animations/loading_animation.json', width: 120, height: 120),
                const SizedBox(height: 20),
                Text(
                  _isLoading ? 'Loading your profile...' : 'No user data found',
                  style: TextStyle(
                    color: isDarkMode ? Colors.amber : const Color(0xFF374151),
                    fontSize: 16,
                  ),
                ),
                if (!_isLoading)
                  const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    gradient: _getProfileHeaderGradient(isDarkMode),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CustomButton(
                    text: 'Retry',
                    onPressed: _loadCurrentUser,
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _getBackgroundGradient(isDarkMode),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildProfileHeader(isDarkMode),
              const SizedBox(height: 24),
              _buildSkillsSection(isDarkMode),
              const SizedBox(height: 24),
              _buildInterestsSection(isDarkMode),
              const SizedBox(height: 24),
              _buildAboutMeSection(isDarkMode),
              const SizedBox(height: 32),
              _buildActionButtons(isDarkMode),
              const SizedBox(height: 16),
              _buildSignOutButton(isDarkMode),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: _getProfileHeaderGradient(isDarkMode),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? const Color(0xFFFFD700).withOpacity(0.4)
                      : const Color(0xFFFF6B6B).withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
                if (isDarkMode)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Column(
              children: [
                // Profile Avatar
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.8), width: 4),
                        gradient: const LinearGradient(
                          colors: [Color(0x4DFFFFFF), Color(0x1AFFFFFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                          if (isDarkMode)
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: Lottie.asset(
                        'assets/animations/skill_learning.json',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.verified, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Name
                Text(
                  _currentUser!.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 12,
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  _currentUser!.title ?? 'Skill Enthusiast',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // Email
                Text(
                  _currentUser!.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(_currentUser!.skills.length.toString(), 'Skills', isDarkMode),
                    _buildStatItem('0', 'Connections', isDarkMode),
                    _buildStatItem('0', 'Exchanges', isDarkMode),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, bool isDarkMode) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            boxShadow: [
              if (isDarkMode)
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(bool isDarkMode) {
    final userSkills = _currentUser!.skills;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: _getSkillsGradient(isDarkMode),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? const Color(0xFFFFD700).withOpacity(0.3)
                : const Color(0xFF00B4D8).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          if (isDarkMode)
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.rocket_launch_rounded,
                    color: isDarkMode ? Colors.amber : Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Text(
                'My Skills',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  userSkills.length.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: userSkills.asMap().entries.map((entry) {
              final index = entry.key;
              final skill = entry.value;
              final skillColor = _getSkillTagColor(isDarkMode, index);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: skillColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: skillColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    if (isDarkMode)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getSkillIcon(skill), size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      skill,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(bool isDarkMode) {
    final userInterests = _currentUser!.interests;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: _getInterestsGradient(isDarkMode),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? const Color(0xFF7B1FA2).withOpacity(0.4)
                : const Color(0xFF8B5CF6).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          if (isDarkMode)
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome_rounded,
                    color: isDarkMode ? Colors.purple.shade300 : Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Text(
                'My Interests',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: userInterests.asMap().entries.map((entry) {
              final index = entry.key;
              final interest = entry.value;
              final interestColor = _getSkillTagColor(isDarkMode, index);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(
                  color: interestColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: interestColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                    if (isDarkMode)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Text(
                  interest,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    shadows: [
                      Shadow(
                        blurRadius: 3,
                        color: Colors.black26,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutMeSection(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: _getAboutMeGradient(isDarkMode),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? const Color(0xFF7B1FA2).withOpacity(0.4)
                : const Color(0xFFEC4899).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          if (isDarkMode)
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.psychology_rounded,
                    color: isDarkMode ? Colors.purple.shade300 : Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Text(
                'About Me',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _aboutMeController.text.isNotEmpty ? _aboutMeController.text : 'No bio added yet.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.95),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: _getActionGradient(isDarkMode),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? const Color(0xFFFFD700).withOpacity(0.4)
                      : const Color(0xFFFF6B6B).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CustomButton(
              text: 'Edit Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(currentUser: _currentUser!),
                  ),
                );
              },
              backgroundColor: Colors.transparent,
              textColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: _getInterestsGradient(isDarkMode),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? const Color(0xFF7B1FA2).withOpacity(0.4)
                    : const Color(0xFF8B5CF6).withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.share_rounded, color: Colors.white, size: 26),
        ),
      ],
    );
  }

  Widget _buildSignOutButton(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)]
              : [const Color(0xFF6B7280), const Color(0xFF9CA3AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Text(
                'Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
              )
                  : const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomButton(
              text: 'Sign Out',
              onPressed: _showSignOutDialog,
              backgroundColor: Colors.transparent,
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSkillIcon(String skill) {
    switch (skill.toLowerCase()) {
      case 'web development': return Icons.web_rounded;
      case 'mobile development': return Icons.phone_android_rounded;
      case 'ui/ux design': return Icons.design_services_rounded;
      case 'graphic design': return Icons.palette_rounded;
      case 'video editing': return Icons.video_library_rounded;
      case 'cooking': return Icons.restaurant_rounded;
      case 'machine learning': return Icons.psychology_rounded;
      default: return Icons.code_rounded;
    }
  }
}