// skill_chip.dart
import 'package:flutter/material.dart';

class SkillChip extends StatelessWidget {
  final String skill;
  final bool isSelected;
  final VoidCallback onTap;

  const SkillChip({
    super.key,
    required this.skill,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(skill),
        backgroundColor: isSelected ? Colors.blue : Colors.grey,
      ),
    );
  }
}
