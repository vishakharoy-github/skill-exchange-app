import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:skill_exchange_app/models/user_model.dart' as app_model;
import 'package:skill_exchange_app/services/user_service.dart';
import 'package:skill_exchange_app/services/auth_service.dart';
import 'package:skill_exchange_app/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _aboutMeController = TextEditingController();
  bool _isEditing = false;
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

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing && _currentUser != null) {
        _saveBioChanges();
      }
    });
  }

  void _saveBioChanges() {
    if (_currentUser == null) return;

    final userService = Provider.of<UserService>(context, listen: false);
    userService.updateUserBio(_currentUser!.id, _aboutMeController.text);

    setState(() {
      _currentUser = _currentUser!.copyWith(bio: _aboutMeController.text);
    });
  }

  Future<void> _showSignOutDialog() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                Icon(
                  Icons.warning_amber_rounded,
                  color: isDarkMode ? const Color(0xFFFFD93D) : const Color(0xFFFF6B6B),
                  size: 60,
                ),
                const SizedBox(height: 20),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to sign out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontFamily: 'Poppins',
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
                      child: CustomButton(
                        text: 'Sign Out',
                        onPressed: () {
                          Navigator.of(context).pop();
                          _signOut();
                        },
                        backgroundColor: Colors.white,
                        textColor: isDarkMode ? const Color(0xFF6B21A8) : const Color(0xFFFF6B6B),
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

  // Color scheme getters
  LinearGradient _getBackgroundGradient(bool isDarkMode) {
    return isDarkMode
        ? const LinearGradient(
      colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E), Color(0xFF16213E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFFFFFBFF), Color(0xFFF0F4FF), Color(0xFFE6F0FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  LinearGradient _getProfileHeaderGradient(bool isDarkMode) {
    return isDarkMode
        ? const LinearGradient(
      colors: [Color(0xFF6B21A8), Color(0xFF7C3AED), Color(0xFF8B5CF6)],
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
      colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
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
      colors: [Color(0xFFDC2626), Color(0xFFEF4444), Color(0xFFF87171)],
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
      colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)],
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
      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF8B5CF6)],
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
      colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
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
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
      const Color(0xFF84CC16),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                    color: isDarkMode ? Colors.white : const Color(0xFF374151),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
                if (!_isLoading)
                  const SizedBox(height: 20),
                CustomButton(
                  text: 'Retry',
                  onPressed: _loadCurrentUser,
                  gradient: _getProfileHeaderGradient(isDarkMode),
                  textColor: Colors.white,
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
                  color: isDarkMode ? const Color(0xFF6B21A8).withOpacity(0.4) : const Color(0xFFFF6B6B).withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    shadows: [
                      Shadow(
                        blurRadius: 12,
                        color: Colors.black26,
                        offset: Offset(2, 2),
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
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                // Email
                Text(
                  _currentUser!.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontFamily: 'Poppins',
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
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
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
            fontFamily: 'Poppins',
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
            color: isDarkMode ? const Color(0xFF059669).withOpacity(0.4) : const Color(0xFF00B4D8).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
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
                child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              const Text(
                'My Skills',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
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
                    fontFamily: 'Poppins',
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
                        fontFamily: 'Poppins',
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
            color: isDarkMode ? const Color(0xFFDC2626).withOpacity(0.4) : const Color(0xFF8B5CF6).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
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
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              const Text(
                'My Interests',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
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
                  ],
                ),
                child: Text(
                  interest,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    fontFamily: 'Poppins',
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
            color: isDarkMode ? const Color(0xFFF59E0B).withOpacity(0.4) : const Color(0xFFEC4899).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
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
                child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              const Text(
                'About Me',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _isEditing
              ? TextField(
            controller: _aboutMeController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tell the world about your amazing self...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontFamily: 'Poppins'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              contentPadding: const EdgeInsets.all(20),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Poppins'),
          )
              : Text(
            _aboutMeController.text.isNotEmpty ? _aboutMeController.text : 'I\'m an enthusiastic IT student ready to conquer the world! 🚀',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.95),
              height: 1.6,
              fontFamily: 'Poppins',
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
          child: CustomButton(
            text: _isEditing ? 'Save Changes' : 'Edit Profile',
            onPressed: _toggleEdit,
            gradient: _getActionGradient(isDarkMode),
            textColor: Colors.white,
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
                color: isDarkMode ? const Color(0xFFDC2626).withOpacity(0.4) : const Color(0xFF8B5CF6).withOpacity(0.4),
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
              ? [const Color(0xFF374151), const Color(0xFF4B5563)]
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
              const Text(
                'Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Sign Out',
            onPressed: _showSignOutDialog,
            backgroundColor: Colors.white,
            textColor: isDarkMode ? const Color(0xFF374151) : const Color(0xFF6B7280),
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