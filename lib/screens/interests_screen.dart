import 'package:flutter/material.dart';
import 'package:skill_exchange_app/screens/home_screen.dart';
import 'package:skill_exchange_app/services/user_service.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> with SingleTickerProviderStateMixin {
  final List<String> _allInterests = [
    'Artificial Intelligence', 'Blockchain Technology', 'Cloud Computing',
    'Data Science', 'Cybersecurity', 'Internet of Things',
    'Augmented Reality', 'Virtual Reality', 'Robotics',
    'Sustainable Tech', 'EdTech', 'HealthTech',
    'FinTech', 'E-commerce', 'Digital Marketing',
    'Content Creation', 'Gaming', 'Cryptocurrency',
    'NFTs', 'Web3', 'Metaverse', 'UI/UX Design',
    'Mobile Development', 'Web Development', 'Music Production',
    'Photography', 'Creative Writing', 'Public Speaking'
  ];

  final List<String> _selectedInterests = [];
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

  Future<void> _saveInterestsAndNavigate() async {
    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least 1 interest'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await Provider.of<UserService>(context, listen: false)
          .updateUserInterests(_selectedInterests);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
      );

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save interests: ${e.toString()}'),
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
                      color: isDarkMode ? Colors.purple.withOpacity(0.2) : colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_rounded,
                          color: isDarkMode ? Colors.purple : colorScheme.primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title
                  Expanded(
                    child: Text(
                      'Select Your Interests',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.purple : colorScheme.onSurface,
                      ),
                    ),
                  ),

                  // Theme Toggle Button
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: isDarkMode
                          ? const LinearGradient(
                        colors: [Color(0xFF7B1FA2), Color(0xFF4A148C)],
                      )
                          : LinearGradient(
                        colors: [Colors.pink.shade400, Colors.purple.shade600],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (isDarkMode)
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.4),
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
                              'What are you interested in learning?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select topics you want to learn from others',
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

                    // Selected interests counter
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: isDarkMode
                                ? const LinearGradient(
                              colors: [Color(0xFF2D1B4E), Color(0xFF1A1035)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                                : LinearGradient(
                              colors: [Colors.purple.shade50, Colors.deepPurple.shade50],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if (isDarkMode)
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.3),
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
                              color: isDarkMode ? Colors.purple.withOpacity(0.4) : Colors.purple.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Selected Interests',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.purple.shade300 : colorScheme.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.purple.withOpacity(0.2) : Colors.purple.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDarkMode ? Colors.purple : Colors.purple,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  '${_selectedInterests.length} selected',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.purple : Colors.purple,
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

                    // Interests Grid
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
                          itemCount: _allInterests.length,
                          itemBuilder: (context, index) {
                            final interest = _allInterests[index];
                            final isSelected = _selectedInterests.contains(interest);
                            return _buildInterestCard(interest, isSelected, isDarkMode);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Continue to Home Button
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: isDarkMode
                                ? const LinearGradient(
                              colors: [Color(0xFF7B1FA2), Color(0xFF4A148C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                                : LinearGradient(
                              colors: [Colors.purple.shade600, Colors.deepPurple.shade600],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if (isDarkMode)
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.4),
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
                            onPressed: _selectedInterests.isNotEmpty && !_isSaving ? _saveInterestsAndNavigate : null,
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
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : Text(
                              'Continue to Home',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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

  Widget _buildInterestCard(String interest, bool isSelected, bool isDarkMode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: isSelected
            ? (isDarkMode
            ? const LinearGradient(
          colors: [Color(0xFF7B1FA2), Color(0xFF4A148C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : LinearGradient(
          colors: [Colors.purple.shade400, Colors.deepPurple.shade600],
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
              color: Colors.purple.withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          if (isSelected && isDarkMode)
            BoxShadow(
              color: Colors.white.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.5 : 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isSelected
              ? (isDarkMode ? Colors.purple : Colors.deepPurple)
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
                _selectedInterests.remove(interest);
              } else {
                _selectedInterests.add(interest);
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
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? (isDarkMode ? Colors.purple : Colors.deepPurple)
                          : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: isDarkMode ? Colors.purple : Colors.deepPurple,
                  )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    interest,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
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