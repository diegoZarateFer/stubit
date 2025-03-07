import 'package:flutter/material.dart';
import 'package:stubit/models/habit.dart';

class HabitLog extends StatelessWidget {
  const HabitLog({
    super.key,
    required this.habit,
  });

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    if (habit.strategy == 'CF') {}

    if (habit.strategy == 'COF') {}

    if (habit.strategy == 'TP') {}

    if (habit.strategy == 'T') {}

    if (habit.strategy == 'TF') {}

    // L
    return Center(
      child: Text("LISTA"),
    );
  }
}
