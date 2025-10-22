import 'package:flutter/material.dart';
import 'package:skill_exchange_app/screens/interests_screen.dart';
import 'package:skill_exchange_app/services/user_service.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class SkillScreen extends StatefulWidget {
  const SkillScreen({super.key});

  @override
  State<SkillScreen> createState() => _SkillScreenState();
}

class _SkillScreenState extends State<SkillScreen> with SingleTickerProviderStateMixin {
  final List<String> _allSkills = [
    'Web Development', 'Mobile Development', 'UI/UX Design',
    'Graphic Design', 'Digital Marketing', 'Content Writing',
    'Photography', 'Video Editing', 'Music Production',
    'Cooking', 'Language Teaching', 'Data Science',
    'Machine Learning', 'Blockchain', 'Cloud Computing',
    'AI Development', 'Game Design', 'Cybersecurity',
    'Public Speaking', 'Creative Writing', 'Fitness Training'
  ];

  final List<String> _selectedSkills = [];
  bool _isSaving = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveSkillsAndNavigate() async {
    print('🎯 Continue button pressed with ${_selectedSkills.length} skills');

    if (_selectedSkills.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least 3 skills'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      print('🔄 Saving skills to database...');
      await Provider.of<UserService>(context, listen: false)
          .updateUserSkills(_selectedSkills);

      if (!mounted) {
        print('❌ Not mounted, returning');
        return;
      }

      print('✅ Skills saved successfully, navigating to Interests Screen');

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const InterestsScreen()),
            (route) => false,
      );

    } catch (e) {
      print('❌ Error in _saveSkillsAndNavigate: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save skills: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔄 SkillScreen building...');
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFDFF),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Theme Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: isDarkMode
                    ? const LinearGradient(
                  colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [Colors.white, Colors.grey.shade50],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Back Button
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.amber.withOpacity(0.2) : colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_rounded,
                          color: isDarkMode ? Colors.amber : colorScheme.primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title
                  Expanded(
                    child: Text(
                      'Select Your Skills',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.amber : colorScheme.onSurface,
                      ),
                    ),
                  ),

                  // Theme Toggle Button
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: isDarkMode
                          ? const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                      )
                          : LinearGradient(
                        colors: [Colors.pink.shade400, Colors.purple.shade600],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (isDarkMode)
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What skills do you excel at?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select skills you can teach others (minimum 3)',
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey.shade400 : colorScheme.onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Selected skills counter
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if (isDarkMode)
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 25,
                                  spreadRadius: 2,
                                ),
                              BoxShadow(
                                color: Colors.black.withOpacity(isDarkMode ? 0.5 : 0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isDarkMode ? Colors.amber.withOpacity(0.4) : Colors.blue.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Selected Skills',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.amber.shade300 : colorScheme.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.amber.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDarkMode ? Colors.amber : Colors.blue,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  '${_selectedSkills.length}/3',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.amber : Colors.blue,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Skills Grid
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 2.2,
                          ),
                          itemCount: _allSkills.length,
                          itemBuilder: (context, index) {
                            final skill = _allSkills[index];
                            final isSelected = _selectedSkills.contains(skill);
                            return _buildSkillCard(skill, isSelected, isDarkMode);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Continue Button
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: isDarkMode
                                ? const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                                : LinearGradient(
                              colors: [Colors.blue.shade600, Colors.purple.shade600],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if (isDarkMode)
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _selectedSkills.length >= 3 && !_isSaving ? _saveSkillsAndNavigate : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isSaving
                                ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDarkMode ? Colors.black : Colors.white,
                                ),
                              ),
                            )
                                : Text(
                              'Continue to Interests',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom guidance
                    if (_selectedSkills.length < 3)
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange.withOpacity(0.4)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: Colors.orange, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Select ${3 - _selectedSkills.length} more skill${_selectedSkills.length == 2 ? '' : 's'} to continue',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillCard(String skill, bool isSelected, bool isDarkMode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: isSelected
            ? (isDarkMode
            ? const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ))
            : (isDarkMode
            ? const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
        )
            : LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
        )),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isSelected && isDarkMode)
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          if (isSelected && isDarkMode)
            BoxShadow(
              color: Colors.amber.withOpacity(0.6),
              blurRadius: 30,
              spreadRadius: 1,
            ),
          if (isSelected && !isDarkMode)
            BoxShadow(
              color: Colors.blue.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.5 : 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isSelected
              ? (isDarkMode ? Colors.amber : Colors.blue)
              : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
          width: isSelected ? 2.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedSkills.remove(skill);
              } else {
                _selectedSkills.add(skill);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDarkMode ? Colors.black : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? (isDarkMode ? Colors.amber : Colors.blue)
                          : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
                      width: 2,
                    ),
                    boxShadow: isSelected && isDarkMode
                        ? [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 10)]
                        : [],
                  ),
                  child: isSelected
                      ? Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: isDarkMode ? Colors.amber : Colors.blue,
                  )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? (isDarkMode ? Colors.black : Colors.white)
                          : (isDarkMode ? Colors.white : Colors.black87),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}