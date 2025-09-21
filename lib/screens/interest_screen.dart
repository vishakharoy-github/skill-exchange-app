import 'package:flutter/material.dart';

class InterestScreen extends StatelessWidget {
  const InterestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Interests')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Select Your Interests"),
            // You can add more UI elements like buttons or checkboxes to let the user select interests.
          ],
        ),
      ),
    );
  }
}
