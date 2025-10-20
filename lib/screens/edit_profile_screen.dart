import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_exchange_app/models/user_model.dart' as app_model;
import 'package:skill_exchange_app/services/user_service.dart';
import 'package:skill_exchange_app/widgets/custom_button.dart';
import 'package:skill_exchange_app/widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  final app_model.User currentUser;

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _skillController;
  late TextEditingController _interestController;

  List<String> _skills = [];
  List<String> _interests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.name);
    _bioController = TextEditingController(text: widget.currentUser.bio ?? '');
    _skillController = TextEditingController();
    _interestController = TextEditingController();

    _skills = List.from(widget.currentUser.skills);
    _interests = List.from(widget.currentUser.interests);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      widget.currentUser.profileImage ??
                          'https://i.postimg.cc/wjlhzZ6c/vishakhaprofessionalphoto.jpg',
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Name Field
              CustomTextField(
                controller: _nameController,
                hintText: 'Full Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Bio Field
              CustomTextField(
                controller: _bioController,
                hintText: 'About Me',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please tell us about yourself';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Skills Section
              _buildEditableChipsSection(
                title: 'Skills',
                chips: _skills,
                controller: _skillController,
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
              const SizedBox(height: 20),

              // Interests Section
              _buildEditableChipsSection(
                title: 'Interests',
                chips: _interests,
                controller: _interestController,
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
              const SizedBox(height: 30),

              // Save Button
              CustomButton(
                text: 'Save Changes',
                onPressed: _isLoading ? null : _saveProfile,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableChipsSection({
    required String title,
    required List<String> chips,
    required TextEditingController controller,
    required Function(String) onAdd,
    required Function(String) onRemove,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Input row
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller,
                    hintText: 'Add $title',
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        onAdd(value.trim());
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      onAdd(controller.text.trim());
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips.map((item) => Chip(
                label: Text(item),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => onRemove(item),
              )).toList(),
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
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $e')),
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

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _skillController.dispose();
    _interestController.dispose();
    super.dispose();
  }
}