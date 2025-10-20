import 'package:flutter/material.dart';
import 'package:skill_exchange_app/screens/home_screen.dart';
import 'package:skill_exchange_app/services/user_service.dart';
import 'package:provider/provider.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final List<String> _allSkills = [
    'Web Development', 'Mobile Development', 'UI/UX Design',
    'Graphic Design', 'Digital Marketing', 'Content Writing',
    'Photography', 'Video Editing', 'Music Production',
    'Cooking', 'Language Teaching', 'Data Science',
    'Machine Learning', 'Blockchain', 'Cloud Computing'
  ];

  final List<String> _selectedSkills = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Skills'),
        actions: [
          TextButton(
            onPressed: _selectedSkills.isNotEmpty
                ? () {
              Provider.of<UserService>(context, listen: false)
                  .updateUserSkills(_selectedSkills);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
                : null,
            child: Text(
              'Done',
              style: TextStyle(
                color: _selectedSkills.isNotEmpty
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What skills do you have?',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Select at least 3 skills you can teach others',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3,
                ),
                itemCount: _allSkills.length,
                itemBuilder: (context, index) {
                  final skill = _allSkills[index];
                  final isSelected = _selectedSkills.contains(skill);

                  return FilterChip(
                    label: Text(skill),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSkills.add(skill);
                        } else {
                          _selectedSkills.remove(skill);
                        }
                      });
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}