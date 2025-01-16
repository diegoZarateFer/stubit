import 'package:flutter/material.dart';

class DissmisibleBackground extends StatelessWidget {
  const DissmisibleBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color.fromARGB(125, 0, 0, 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

class DissmisibleSecondaryBackground extends StatelessWidget {
  const DissmisibleSecondaryBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: const Color.fromARGB(110, 247, 14, 56),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
