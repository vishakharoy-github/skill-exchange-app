import 'package:flutter/material.dart';
import 'package:skill_exchange_app/widgets/custom_button.dart';

class SkillScreen extends StatefulWidget {
  const SkillScreen({super.key});

  @override
  State<SkillScreen> createState() => _SkillScreenState();
}

class _SkillScreenState extends State<SkillScreen> {
  final List<String> _allSkills = [
    'Web Development', 'Mobile Development', 'UI/UX Design',
    'Graphic Design', 'Digital Marketing', 'Content Writing',
    'Photography', 'Video Editing', 'Music Production',
    'Cooking', 'Language Teaching', 'Data Science',
    'Machine Learning', 'Blockchain', 'Cloud Computing'
  ];

  final List<String> _selectedSkills = [];

  void _navigateToNextScreen() {
    // Add your navigation logic here
    // Navigator.push(context, MaterialPageRoute(builder: (context) => NextScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Skills'),
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
            const SizedBox(height: 20),
            CustomButton(
              text: 'Continue',
              onPressed: _selectedSkills.isNotEmpty ? _navigateToNextScreen : null,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

