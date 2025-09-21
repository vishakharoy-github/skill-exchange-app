import 'package:flutter/material.dart';

class InterestChip extends StatelessWidget {
  final String interest;
  final bool isSelected;
  final VoidCallback onTap;

  const InterestChip({
    super.key,
    required this.interest,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(interest),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.deepPurple,
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
