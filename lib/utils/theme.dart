// utils/theme.dart
import 'package:flutter/material.dart';

final ThemeData customTheme = ThemeData(
  primarySwatch: Colors.deepPurple,
  scaffoldBackgroundColor: Colors.white,
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    bodyMedium: TextStyle(fontSize: 14),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  ),
);
