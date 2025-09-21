// widgets/animated_button.dart
import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const AnimatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _animation,
        child: ElevatedButton(
          onPressed: null,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
