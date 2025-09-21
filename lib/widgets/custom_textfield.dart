import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextInputType? keyboardType; // Add keyboardType here
  final IconData? icon; // Optional icon

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.keyboardType, // Add this line to accept keyboardType
    this.icon, // Optional icon parameter
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,  // Pass it to the TextField widget
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixIcon: icon != null ? Icon(icon) : null, // Handle icon if passed
      ),
    );
  }
}
