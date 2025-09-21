import 'package:flutter/material.dart';
import '../widgets/skill_chip.dart';
import '../widgets/custom_button.dart';
import 'interest_screen.dart'; // Import InterestScreen

class SkillScreen extends StatefulWidget {
  const SkillScreen({super.key});

  @override
  State<SkillScreen> createState() => _SkillScreenState();
}

class _SkillScreenState extends State<SkillScreen> {
  List<String> skills = ['Flutter', 'Design', 'Marketing'];
  List<String> selectedSkills = [];

  void toggleSkill(String skill) {
    setState(() {
      if (selectedSkills.contains(skill)) {
        selectedSkills.remove(skill);
      } else {
        selectedSkills.add(skill);
      }
    });
  }

  void _continue() {
    print('Navigating to InterestScreen...');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InterestScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Skills')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              children: skills.map((skill) {
                return SkillChip(
                  skill: skill,
                  isSelected: selectedSkills.contains(skill),
                  onTap: () => toggleSkill(skill),
                );
              }).toList(),
            ),
            const Spacer(),
            CustomButton(
              text: "Continue",
              onTap: _continue,
            ),
          ],
        ),
      ),
    );
  }
}


