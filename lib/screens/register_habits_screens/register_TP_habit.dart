import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/data/phrases.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/util/util.dart';
import 'package:stubit/widgets/confirmation_dialog.dart';
import 'package:stubit/widgets/gems_dialog.dart';
import 'package:stubit/widgets/pomodoro_timer.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class RegisterTpHabit extends StatefulWidget {
  const RegisterTpHabit({
    super.key,
    required this.habit,
    required this.workInterval,
    required this.restInterval,
    required this.targetNumberOfCycles,
  });

  final Habit habit;
  final int workInterval, restInterval, targetNumberOfCycles;

  @override
  State<RegisterTpHabit> createState() => _CreateFtHabitScreenState();
}

class _CreateFtHabitScreenState extends State<RegisterTpHabit> {
  final _currentUser = FirebaseAuth.instance.currentUser!;

  late String _date;
  late int _remainingSeconds;
  late bool _workIntervalIsActive;

  int _completedCycles = 0;
  bool _isLoading = true, _hasBeenCompleted = false;

  late bool _targetIsCompleted;

  String _getPhrase() {
    int randomIndex = Random().nextInt(5);
    return motivationalPhrases[widget.habit.category]?[randomIndex] ??
        "El único fracaso real es rendirse.";
  }

  Future<void> _registerHabit() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    final userId = _currentUser.uid.toString();
    final now = Timestamp.now();

    final givenGems = assignGems();

    try {
      await Future.wait([
        if (!_hasBeenCompleted)
          _firestore
              .collection("user_data")
              .doc(userId)
              .collection("gems")
              .doc("user_gems")
              .update({
            "collectedGems": FieldValue.increment(givenGems),
          }),
        _firestore
            .collection("user_data")
            .doc(userId)
            .collection("habits")
            .doc(widget.habit.id)
            .collection("habit_log")
            .doc("daily_form")
            .set(
          {
            "createdAt": now,
            "completedCycles": _completedCycles,
            "hasBeenCompleted": true,
            "remainingSeconds": _remainingSeconds,
            "workIntervalIsActive": _workIntervalIsActive,
          },
          SetOptions(
            merge: true,
          ),
        ),
        _firestore
            .collection("user_data")
            .doc(userId)
            .collection("habits")
            .doc(widget.habit.id)
            .collection("habit_log")
            .doc(_date)
            .set({
          "completedCycles": _completedCycles,
          "restInterval": widget.restInterval,
          "workInterval": widget.workInterval,
          "targetCycles": widget.targetNumberOfCycles,
        })
      ]);

      if (!_hasBeenCompleted) {
        final phrase = _getPhrase();
        await showDialog(
          context: context,
          builder: (ctx) => GemsDialog(
              title: "¡Felicidades, obtuviste $givenGems libros de estudio!",
              message: phrase),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !_hasBeenCompleted
                ? "¡Felicidades! Registro del día completado."
                : "Se han guardado los cambios.",
          ),
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

  Future<void> _saveFormData() async {
    final userId = _currentUser.uid.toString();
    final now = Timestamp.now();
    try {
      _firestore
          .collection("user_data")
          .doc(userId)
          .collection("habits")
          .doc(widget.habit.id)
          .collection("habit_log")
          .doc("daily_form")
          .set(
        {
          "createdAt": now,
          "completedCycles": _completedCycles,
          "remainingSeconds": _remainingSeconds,
          "hasBeenCompleted": _hasBeenCompleted,
          "workIntervalIsActive": _workIntervalIsActive,
        },
        SetOptions(
          merge: true,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Se ha guardado tu avance."),
        ),
      );
    } catch (e) {
      const SnackBar(
        content: Text(
          "Hubo un problema al guardar el avance. Inténtalo más tarde.",
        ),
      );
    }
  }

  Future<void> _loadFormData() async {
    final userId = _currentUser.uid.toString();
    final doc = await _firestore
        .collection("user_data")
        .doc(userId)
        .collection("habits")
        .doc(widget.habit.id)
        .collection("habit_log")
        .doc("daily_form")
        .get();

    if (doc.exists) {
      final createdAt = (doc.data()?['createdAt'] as Timestamp).toDate();
      final now = DateTime.now();
      if (isDifferentDay(createdAt, now)) {
        await _firestore
            .collection("user_data")
            .doc(userId)
            .collection("habits")
            .doc(widget.habit.id)
            .collection("habit_log")
            .doc("daily_form")
            .delete();
        setState(() {
          _completedCycles = 0;
          _remainingSeconds = widget.workInterval;
          _workIntervalIsActive = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _completedCycles = doc.data()?['completedCycles'];
          _remainingSeconds = doc.data()?['remainingSeconds'];
          _workIntervalIsActive = doc.data()?['workIntervalIsActive'];
          _hasBeenCompleted = doc.data()?['hasBeenCompleted'];
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _completedCycles = 0;
        _remainingSeconds = widget.workInterval;
        _workIntervalIsActive = true;
        _isLoading = false;
      });
    }

    _targetIsCompleted = _completedCycles >= widget.targetNumberOfCycles;
  }

  Future<bool> _handleBackButtonPressed() async {
    final bool? confirmation = await showConfirmationDialog(
      context,
      "Salir del registro",
      "Se pausará el temporizador.",
      "Continuar",
      "Cancelar",
    );

    if (confirmation ?? false) {
      await _saveFormData();
      return true;
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    _loadFormData();
    _date = getDateAsString();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _handleBackButtonPressed();
      },
      child: Scaffold(
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
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Column(
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
                            widget.habit.name,
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
                                "Tiempo para trabajo:",
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                "${widget.workInterval} mins.",
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Tiempo de descanso:",
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                "${widget.restInterval} mins.",
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
                          PomodoroTimer(
                            workInterval: widget.workInterval,
                            restInterval: widget.restInterval,
                            completedCycles: _completedCycles,
                            remainingTime: _remainingSeconds,
                            workIntervalIsActive: _workIntervalIsActive,
                            onUpdateTimer: (bool workIntervalIsActive,
                                int remainingSeconds) {
                              _remainingSeconds = remainingSeconds;
                              _workIntervalIsActive = workIntervalIsActive;
                            },
                            onCycleComplete: (int completedCycles) {
                              _completedCycles = completedCycles;
                            },
                            targetNumberOfCycles: widget.targetNumberOfCycles,
                            onFinish: (int completedCycles) {
                              setState(() {
                                _targetIsCompleted = true;
                              });
                              _completedCycles = completedCycles;
                            },
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          ElevatedButton(
                            onPressed:
                                _targetIsCompleted ? _registerHabit : null,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor:
                                  const Color.fromRGBO(121, 30, 198, 1),
                            ),
                            child: Text(
                              "Completar",
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
                            onPressed: () async {
                              final confirmation =
                                  await _handleBackButtonPressed();
                              if (confirmation) {
                                Navigator.of(context).pop();
                              }
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
          ),
        ),
      ),
    );
  }
}
