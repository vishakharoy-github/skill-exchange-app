import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class SkillCard extends StatelessWidget {
  final String skill;
  final IconData icon;
  final int users;
  final Color color;
  final List<Color> gradient;

  const SkillCard({
    super.key,
    required this.skill,
    required this.icon,
    required this.users,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Color(0xFFFFD700), Color(0xFFFFA000)] // Gold gradient for dark mode
                : gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDarkMode
              ? [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 25,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.amber.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
          border: isDarkMode
              ? Border.all(color: Colors.amber.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: isDarkMode
                      ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                      : [],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const Spacer(),
              Text(
                skill,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.people_rounded, color: Colors.white70, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '$users people',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}