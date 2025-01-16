import 'package:flutter/material.dart';

class TaskStatus {
  const TaskStatus({
    required this.identifier,
    required this.name,
    required this.icon,
  });

  final String identifier;
  final String name;
  final Icon icon;
}

final List<TaskStatus> taskStatus = [
  const TaskStatus(
    identifier: "pendiente",
    name: "Pendiente",
    icon: Icon(
      Icons.assignment,
      color: Colors.white,
    ),
  ),
  const TaskStatus(
    identifier: "proceso",
    name: "En Proceso",
    icon: Icon(
      Icons.hourglass_empty,
      color: Colors.white,
    ),
  ),
  const TaskStatus(
    identifier: "completado",
    name: "Completado",
    icon: Icon(
      Icons.check,
      color: Colors.white,
    ),
  ),
];
