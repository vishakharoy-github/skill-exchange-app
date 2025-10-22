import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_exchange_app/models/user_model.dart' as app_model;
import 'package:skill_exchange_app/services/user_service.dart';
import 'package:skill_exchange_app/widgets/custom_button.dart';
import 'package:skill_exchange_app/widgets/custom_textfield.dart';
import 'package:skill_exchange_app/theme/theme_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final app_model.User currentUser;

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _skillController;
  late TextEditingController _interestController;

  List<String> _skills = [];
  List<String> _interests = [];
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.name);
    _bioController = TextEditingController(text: widget.currentUser.bio ?? '');
    _skillController = TextEditingController();
    _interestController = TextEditingController();

    _skills = List.from(widget.currentUser.skills);
    _interests = List.from(widget.currentUser.interests);

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
    _nameController.dispose();
    _bioController.dispose();
    _skillController.dispose();
    _interestController.dispose();
    super.dispose();
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
            // Custom App Bar
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
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.amber : colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (_isLoading)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDarkMode ? Colors.amber : colorScheme.primary,
                        ),
                      ),
                    ),
                  // 👇 THEME TOGGLE BUTTON ADDED HERE 👇
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
                  // 👆 THEME TOGGLE BUTTON ADDED HERE 👆
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Profile Image Section
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
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
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                if (isDarkMode)
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.2),
                                    blurRadius: 25,
                                    spreadRadius: 2,
                                  ),
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
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: isDarkMode
                                            ? const LinearGradient(
                                          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                            : LinearGradient(
                                          colors: [Colors.blue.shade400, Colors.purple.shade600],
                                        ),
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
                                      child: CircleAvatar(
                                        radius: 56,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: NetworkImage(
                                          widget.currentUser.profileImage ??
                                              'https://i.postimg.cc/wjlhzZ6c/vishakhaprofessionalphoto.jpg',
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: isDarkMode
                                              ? const LinearGradient(
                                            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                                          )
                                              : LinearGradient(
                                            colors: [Colors.blue.shade400, Colors.purple.shade600],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tap to change photo',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.amber.shade300 : colorScheme.onSurfaceVariant,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Name Field
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildStyledTextField(
                            controller: _nameController,
                            hintText: 'Full Name',
                            icon: Icons.person_rounded,
                            isDarkMode: isDarkMode,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bio Field
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildStyledTextField(
                            controller: _bioController,
                            hintText: 'Tell us about yourself...',
                            icon: Icons.description_rounded,
                            isDarkMode: isDarkMode,
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please tell us about yourself';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Skills Section
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildEditableChipsSection(
                            title: 'Skills',
                            icon: Icons.work_rounded,
                            chips: _skills,
                            controller: _skillController,
                            isDarkMode: isDarkMode,
                            onAdd: (skill) {
                              if (skill.trim().isNotEmpty && !_skills.contains(skill.trim())) {
                                setState(() {
                                  _skills.add(skill.trim());
                                });
                                _skillController.clear();
                              }
                            },
                            onRemove: (skill) {
                              setState(() {
                                _skills.remove(skill);
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Interests Section
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildEditableChipsSection(
                            title: 'Interests',
                            icon: Icons.favorite_rounded,
                            chips: _interests,
                            controller: _interestController,
                            isDarkMode: isDarkMode,
                            onAdd: (interest) {
                              if (interest.trim().isNotEmpty && !_interests.contains(interest.trim())) {
                                setState(() {
                                  _interests.add(interest.trim());
                                });
                                _interestController.clear();
                              }
                            },
                            onRemove: (interest) {
                              setState(() {
                                _interests.remove(interest);
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
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
                            child: CustomButton(
                              text: 'Save Changes',
                              onPressed: _isLoading ? null : _saveProfile,
                              isLoading: _isLoading,
                              backgroundColor: Colors.transparent,
                              textColor: isDarkMode ? Colors.black : Colors.white,
                            ),
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
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isDarkMode,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
        )
            : LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomTextField(
          controller: controller,
          hintText: hintText,
          maxLines: maxLines,
          validator: validator,
          prefixIcon: icon,
        ),
      ),
    );
  }

  Widget _buildEditableChipsSection({
    required String title,
    required IconData icon,
    required List<String> chips,
    required TextEditingController controller,
    required bool isDarkMode,
    required Function(String) onAdd,
    required Function(String) onRemove,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
        )
            : LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
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
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.amber : Colors.blue.shade800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.amber.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${chips.length}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.amber : Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Input Section
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'Add a $title...',
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            onAdd(value.trim());
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: isDarkMode
                          ? const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                      )
                          : LinearGradient(
                        colors: [Colors.blue.shade400, Colors.purple.shade600],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          onAdd(controller.text.trim());
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Chips Grid
            if (chips.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900.withOpacity(0.5) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No $title added yet',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: chips.map((item) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: isDarkMode
                          ? const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : LinearGradient(
                        colors: [Colors.blue.shade400, Colors.purple.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        if (isDarkMode)
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
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
                    child: Chip(
                      label: Text(
                        item,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      deleteIcon: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                      onDeleted: () => onRemove(item),
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userService = Provider.of<UserService>(context, listen: false);
        await userService.updateUserProfile({
          'name': _nameController.text.trim(),
          'bio': _bioController.text.trim(),
          'skills': _skills,
          'interests': _interests,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}