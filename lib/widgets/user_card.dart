import 'package:flutter/material.dart';
import 'package:skill_exchange_app/models/user_model.dart' as app_model;

class UserCard extends StatelessWidget {
  final app_model.User user;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            user.name[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: user.skills
                  .take(3)
                  .map((skill) => Chip(
                label: Text(skill),
                backgroundColor: Color.lerp(
                  Theme.of(context).colorScheme.primary,
                  Colors.transparent,
                  0.9, // 10% opacity
                ),
                labelStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                ),
              ))
                  .toList(),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.message, color: Theme.of(context).primaryColor),
          onPressed: onTap,
        ),
      ),
    );
  }
}