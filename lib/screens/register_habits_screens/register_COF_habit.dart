import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/util/util.dart';
import 'package:stubit/widgets/confirmation_dialog.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class RegisterCofHabit extends StatefulWidget {
  const RegisterCofHabit({
    super.key,
    required this.habit,
    required this.dailyTarget,
    required this.unit,
  });

  final Habit habit;
  final int dailyTarget;
  final String unit;

  @override
  State<RegisterCofHabit> createState() => _CreateFtHabitScreenState();
}

class _CreateFtHabitScreenState extends State<RegisterCofHabit> {
  final _currentUser = FirebaseAuth.instance.currentUser!;

  late String _date;
  bool _confirmationBoxIsSelected = false,
      _isLoading = true,
      _changesWereMade = false;

  late int _dailyTarget;
  int _counter = 0;
  late String _unit;

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
    final now = Timestamp.now();
    try {
      await Future.wait([
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
            "counter": _counter,
            "confirmation": _confirmationBoxIsSelected,
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
          "counter": _counter,
          "unit": _unit,
          "dailyTarget": _dailyTarget,
        }),
      ]);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Felicidades! Registro del día completado."),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      const SnackBar(
        content: Text(
          "Hubo un problema al guardar el registro. Inténtalo más tarde.",
        ),
      );
    }
  }

  void _saveFormData() async {
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
          "counter": _counter,
          "confirmation": _confirmationBoxIsSelected,
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

      Navigator.of(context).pop();
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
      if (now.difference(createdAt).inDays >= 1) {
        await _firestore
            .collection("user_data")
            .doc(userId)
            .collection("habits")
            .doc(widget.habit.id)
            .collection("habit_log")
            .doc("daily_form")
            .delete();
        setState(() {
          _counter = 0;
          _isLoading = false;
          _confirmationBoxIsSelected = false;
        });
      } else {
        setState(() {
          _counter = doc.data()?['counter'];
          _confirmationBoxIsSelected = doc.data()?['confirmation'];
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleCancelButtonPressed() async {
    if (_changesWereMade) {
      final bool? confirmation = await showConfirmationDialog(
          context,
          "Salir del registro",
          "Se perderán los cambios realizados.",
          "Continuar",
          "Cancelar");
      if (confirmation ?? false) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFormData();
    _date = getDateAsString();
    _dailyTarget = widget.dailyTarget;
    _unit = widget.unit;
  }

  @override
  Widget build(BuildContext context) {
    bool isCompleted = _counter >= _dailyTarget;
    double targetPercentage = _counter.toDouble() / _dailyTarget > 1
        ? 1
        : _counter.toDouble() / _dailyTarget;

    return Center(
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
                          "$_dailyTarget $_unit.",
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
                            if (_counter > 0) {
                              setState(() {
                                _counter--;
                                _changesWereMade = true;
                              });
                            }

                            if (_counter < _dailyTarget) {
                              setState(() {
                                _confirmationBoxIsSelected = false;
                              });
                            }
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
                              _changesWereMade = true;
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
                    if (isCompleted)
                      Row(
                        children: [
                          Expanded(
                            child: Checkbox(
                              shape: const CircleBorder(),
                              value: _confirmationBoxIsSelected,
                              onChanged: (bool? isSelected) {
                                setState(() {
                                  _confirmationBoxIsSelected =
                                      isSelected ?? false;
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
                    if (isCompleted)
                      const SizedBox(
                        height: 16,
                      ),
                    ElevatedButton(
                      onPressed: isCompleted ? _registerHabit : _saveFormData,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: const Color.fromRGBO(121, 30, 198, 1),
                      ),
                      child: Text(
                        isCompleted ? "Completar" : "Guardar",
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
                      onPressed: _handleCancelButtonPressed,
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
