import 'package:flutter/material.dart';

class ImageButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const ImageButton({
    super.key,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset(imagePath),
      iconSize: 24.0,
      onPressed: onPressed,
    );
  }
}