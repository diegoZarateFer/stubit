import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/util/util.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class RegisterCofHabit extends StatefulWidget {
  const RegisterCofHabit({
    super.key,
    required this.habit,
    required this.dailyTarget,
  });

  final Habit habit;
  final int dailyTarget;

  @override
  State<RegisterCofHabit> createState() => _CreateFtHabitScreenState();
}

class _CreateFtHabitScreenState extends State<RegisterCofHabit> {
  final _currentUser = FirebaseAuth.instance.currentUser!;

  bool _confirmationBoxIsSelected = false;

  late int _dailyTarget;
  int _counter = 0;

  void _registerHabit() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    if (!_confirmationBoxIsSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Falta confirmar que se realizó la actividad.',
          ),
        ),
      );
      return;
    }

    final userId = _currentUser.uid.toString();
    final date = getDateAsString();
    try {
      await _firestore
          .collection("user_data")
          .doc(userId)
          .collection("habits")
          .doc(widget.habit.id)
          .collection("habit_log")
          .doc(date)
          .set({
        "counter": _counter,
        "unit": widget.habit.unit,
        "dailyTarget": _dailyTarget,
      });

      // TODO: mostrar las gemas obtenidas con la frase motivacional.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Felicidades! Registro del día completado."),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Hubo un problema al guardar el registro. Inténtalo más tarde.",
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _dailyTarget = widget.dailyTarget;
  }

  @override
  Widget build(BuildContext context) {
    double targetPercentage = _counter.toDouble() / _dailyTarget > 1
        ? 1
        : _counter.toDouble() / _dailyTarget;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              Text(
                "REGISTRO DE HÁBITO",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Image.asset(
                "assets/images/calendar.png",
                height: 60,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                "Lectura",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Objetivo diario: ",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    "$_dailyTarget ${widget.habit.unit}.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 32,
              ),
              CircularPercentIndicator(
                radius: 75,
                lineWidth: 5,
                percent: targetPercentage,
                center: Text(
                  "$_counter",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: const Color.fromARGB(178, 158, 158, 158),
                progressColor: const Color.fromARGB(255, 228, 200, 247),
              ),
              const SizedBox(
                height: 32,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _counter = max(_counter - 1, 0);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Icon(
                      Icons.remove,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _counter++;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(
                    child: Checkbox(
                      shape: const CircleBorder(),
                      value: _confirmationBoxIsSelected,
                      onChanged: (bool? isSelected) {
                        setState(() {
                          _confirmationBoxIsSelected = isSelected ?? false;
                        });
                      },
                    ),
                  ),
                  Text(
                    "Confirmo que hoy realicé este hábito",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: _registerHabit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color.fromRGBO(121, 30, 198, 1),
                ),
                child: Text(
                  "Registrar",
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    decorationColor: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  "Cancelar",
                  style: GoogleFonts.openSans(
                    color: Colors.black,
                    decorationColor: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
