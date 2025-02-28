import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/screens/register_habits_screens/register_CF_habit.dart';
import 'package:stubit/screens/register_habits_screens/register_COF_habit.dart';
import 'package:stubit/screens/register_habits_screens/register_FT_habit_screen.dart';
import 'package:stubit/screens/register_habits_screens/register_L_habit.dart';
import 'package:stubit/screens/register_habits_screens/register_TP_habit.dart';
import 'package:stubit/screens/register_habits_screens/register_T_habit_screen.dart';
import 'package:stubit/widgets/apology.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

String apology = """
  Lo sentimos mucho pero no se ha podido conectar al servidor.
  Por favor, intentalo de nuevo más tarde.
""";

class RegisterHabit extends StatefulWidget {
  const RegisterHabit({
    super.key,
    required this.habit,
  });

  final Habit habit;

  @override
  State<RegisterHabit> createState() => _RegisterHabitState();
}

class _RegisterHabitState extends State<RegisterHabit> {
  final _currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    final userId = _currentUser.uid.toString();
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
        child: StreamBuilder(
          stream: _firestore
              .collection("user_data")
              .doc(userId)
              .collection("habits")
              .doc(widget.habit.id)
              .snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Apology(
                message: apology,
              );
            }

            if (snapshot.hasData) {
              final habitStrategy = widget.habit.strategy;
              Map<String, dynamic> loadedHabitData =
                  snapshot.data!.data() as Map<String, dynamic>;

              if (habitStrategy == 'T') {
                return RegisterTHabitScreen(
                  targetNumberOfMinutes: loadedHabitData['allotedTime'],
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
                  targetNumberOfMinutes: loadedHabitData['allotedTime'],
                  habit: widget.habit,
                );
              } else if (habitStrategy == 'TP') {
                return RegisterTpHabit(
                  habit: widget.habit,
                  workInterval: loadedHabitData['workInterval'],
                  restInterval: loadedHabitData['restInterval'],
                  targetNumberOfCycles: loadedHabitData['cycles'],
                );
              } else if (habitStrategy == 'COF') {
                return RegisterCofHabit(
                  habit: widget.habit,
                  dailyTarget: loadedHabitData['dailyTarget'],
                  unit: "páginas", // TODO: cargar parámetros del hábito.
                );
              } else {
                return const Apology(message: 'ERROR: Estrategia no válida.');
              }
            }

            return const Apology(message: 'No hay datos por mostar.');
          },
        ),
      ),
    );
  }
}
