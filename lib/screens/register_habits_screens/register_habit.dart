import 'package:flutter/material.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/screens/register_habits_screens/register_CF_habit.dart';
import 'package:stubit/screens/register_habits_screens/register_COF_habit.dart';
import 'package:stubit/screens/register_habits_screens/register_FT_habit_screen.dart';
import 'package:stubit/screens/register_habits_screens/register_L_habit.dart';
import 'package:stubit/screens/register_habits_screens/register_TP_habit.dart';
import 'package:stubit/screens/register_habits_screens/register_T_habit_screen.dart';

String apology = """
  Lo sentimos mucho pero no se ha podido conectar al servidor.
  Por favor, intentalo de nuevo más tarde.
""";

class RegisterHabit extends StatefulWidget {
  const RegisterHabit({
    super.key,
    required this.habit,
    required this.habitParameters,
    this.dailyFormData,
  });

  final Habit habit;
  final Map<String, dynamic> habitParameters;
  final Map<String, dynamic>? dailyFormData;

  @override
  State<RegisterHabit> createState() => _RegisterHabitState();
}

class _RegisterHabitState extends State<RegisterHabit> {
  late Map<String, dynamic> _habitParameters;

  @override
  void initState() {
    super.initState();
    _habitParameters = widget.habitParameters;
  }

  Widget _loadRegisterHabitForm() {
    final habitStrategy = widget.habit.strategy;

    // TODO: enviar también los datos del último registro que se tenga.
    if (habitStrategy == 'T') {
      return RegisterTHabitScreen(
        targetNumberOfMinutes: _habitParameters['allotedTime'],
        habit: widget.habit,
      );
    } else if (habitStrategy == 'CF') {
      return RegisterCfHabit(
        habit: widget.habit,
      );
    } else if (habitStrategy == 'L') {
      return RegisterLHabit(
        habit: widget.habit,
      );
    } else if (habitStrategy == 'TF') {
      return RegisterFtHabitScreen(
        targetNumberOfMinutes: _habitParameters['allotedTime'],
        habit: widget.habit,
      );
    } else if (habitStrategy == 'TP') {
      return RegisterTpHabit(
        habit: widget.habit,
        workInterval: _habitParameters['workInterval'],
        restInterval: _habitParameters['restInterval'],
        targetNumberOfCycles: _habitParameters['cycles'],
      );
    } else {
      return RegisterCofHabit(
        habit: widget.habit,
        dailyTarget: _habitParameters['dailyTarget'],
        unit: _habitParameters['unit'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(139, 34, 227, 1),
              Colors.black,
            ],
          ),
        ),
        child: _loadRegisterHabitForm(),
      ),
    );
  }
}
