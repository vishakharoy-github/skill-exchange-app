import 'package:flutter/material.dart';
import 'package:skill_exchange_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face'),
            ),
            const SizedBox(height: 16),
            Text(
              authService.currentUser?.email?.split('@').first ?? 'User',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              authService.currentUser?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            _buildInfoCard(
              context,
              title: 'My Skills',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkillChip('Web Development'),
                  _buildSkillChip('Flutter'),
                  _buildSkillChip('UI/UX Design'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Interests',
              content: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInterestChip('Mobile Development'),
                  _buildInterestChip('Photography'),
                  _buildInterestChip('Music'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'About Me',
              content: const Text(
                'Passionate developer with 3+ years of experience in web and mobile development. Love to learn and share knowledge!',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                authService.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String title, required Widget content}) {
    return Card(
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
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Chip(
      label: Text(skill),
      backgroundColor: Colors.blue[50],
      labelStyle: const TextStyle(color: Colors.blue),
    );
  }

  Widget _buildInterestChip(String interest) {
    return Chip(
      label: Text(interest),
      backgroundColor: Colors.green[50],
      labelStyle: const TextStyle(color: Colors.green),
    );
  }
}