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

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _aboutMeController = TextEditingController();
  bool _isEditing = false;
  app_model.User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
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
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Sign Out',
            style: TextStyle(
              color: isDarkMode ? Colors.white : const Color(0xFF374151),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: TextStyle(
              color: isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Signed out successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
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
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _aboutMeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading || _currentUser == null) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/animations/loading_animation.json', width: 100, height: 100),
              const SizedBox(height: 20),
              Text(
                _isLoading ? 'Loading profile...' : 'No user data found',
                style: TextStyle(color: isDarkMode ? Colors.white : const Color(0xFF374151), fontSize: 16),
              ),
              if (!_isLoading)
                TextButton(onPressed: _loadCurrentUser, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(isDarkMode),
            const SizedBox(height: 32),
            _buildSkillsSection(isDarkMode),
            const SizedBox(height: 32),
            _buildInterestsSection(isDarkMode),
            const SizedBox(height: 32),
            _buildAboutMeSection(isDarkMode),
            const SizedBox(height: 40),
            _buildActionButtons(isDarkMode),
            const SizedBox(height: 20),
            _buildSignOutButton(isDarkMode), // ADDED: Sign out button
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDarkMode) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color(0xFF1E40AF), const Color(0xFF6B21A8)]
                : [const Color(0xFF2563EB), const Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    gradient: const LinearGradient(
                      colors: [Color(0x4DFFFFFF), Color(0x1AFFFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Lottie.asset(
                    'assets/animations/skill_learning.json',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(_currentUser!.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_currentUser!.title ?? 'Skill Enthusiast', style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 16)),
            const SizedBox(height: 8),
            Text(_currentUser!.email, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 14)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(_currentUser!.skills.length.toString(), 'Skills'),
                _buildStatItem('45', 'Connections'),
                _buildStatItem('8', 'Exchanges'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 12)),
      ],
    );
  }

  Widget _buildSkillsSection(bool isDarkMode) {
    final userSkills = _currentUser!.skills;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code_rounded, color: isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), size: 24),
                const SizedBox(width: 12),
                Text('My Skills', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF374151))),
                const Spacer(),
                Badge(label: Text(userSkills.length.toString()), backgroundColor: isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF2563EB)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: userSkills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode ? [const Color(0xFF374151), const Color(0xFF4B5563)] : [const Color(0xFFE5E7EB), const Color(0xFFD1D5DB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDarkMode ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getSkillIcon(skill), size: 16, color: isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF2563EB)),
                      const SizedBox(width: 8),
                      Text(skill, style: TextStyle(color: isDarkMode ? Colors.white : const Color(0xFF374151), fontWeight: FontWeight.w500, fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsSection(bool isDarkMode) {
    final userInterests = _currentUser!.interests;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite_rounded, color: isDarkMode ? const Color(0xFFF87171) : const Color(0xFFDC2626), size: 24),
                const SizedBox(width: 12),
                Text('Interests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF374151))),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: userInterests.asMap().entries.map((entry) {
                final index = entry.key;
                final interest = entry.value;
                final colors = _getInterestColor(index);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Text(interest, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutMeSection(bool isDarkMode) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_rounded, color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669), size: 24),
                const SizedBox(width: 12),
                Text('About Me', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF374151))),
              ],
            ),
            const SizedBox(height: 16),
            _isEditing
                ? TextField(
              controller: _aboutMeController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us about yourself...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB))),
                filled: true,
                fillColor: isDarkMode ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : const Color(0xFF374151)),
            )
                : Text(
              _aboutMeController.text.isNotEmpty ? _aboutMeController.text : 'I\'m an enthusiastic IT student.',
              style: TextStyle(fontSize: 16, color: isDarkMode ? const Color(0xFFB0BEC5) : const Color(0xFF6B7280), height: 1.5),
            ),
          ],
        ),
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
            gradient: LinearGradient(
              colors: isDarkMode ? [const Color(0xFF60A5FA), const Color(0xFFC084FC)] : [const Color(0xFF2563EB), const Color(0xFF7C3AED)],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.share_rounded, color: isDarkMode ? Colors.white : const Color(0xFF374151)),
        ),
      ],
    );
  }

  // ADDED: Sign out button
  Widget _buildSignOutButton(bool isDarkMode) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.logout_rounded, color: Colors.red, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Sign Out',
              onPressed: _showSignOutDialog,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              isOutlined: true,
            ),
          ],
        ),
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

  List<Color> _getInterestColor(int index) {
    final colors = [
      [const Color(0xFFEF4444), const Color(0xFFDC2626)],
      [const Color(0xFF10B981), const Color(0xFF059669)],
      [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
      [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      [const Color(0xFFEC4899), const Color(0xFFDB2777)],
    ];
    return colors[index % colors.length];
  }
}