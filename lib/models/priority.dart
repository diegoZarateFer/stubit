import 'package:flutter/material.dart';

enum Priorities { alta, media, baja }

class Priority {
  const Priority({
    required this.name,
    required this.color,
  });
  final String name;
  final Color color;
}

Map<String,Color> priorityColor = {
  "alta": Colors.red,
  "media": Colors.yellow,
  "baja": Colors.green,
};

