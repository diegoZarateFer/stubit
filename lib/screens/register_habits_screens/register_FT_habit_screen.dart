import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/util/util.dart';
import 'package:stubit/widgets/confirmation_dialog.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

final List<String> _hours = List.generate(
  13,
  (index) => index > 9 ? index.toString() : "0${index.toString()}",
);

final List<String> _minutes = List.generate(
  60,
  (index) => index > 9 ? index.toString() : "0${index.toString()}",
);

class RegisterFtHabitScreen extends StatefulWidget {
  const RegisterFtHabitScreen({
    super.key,
    required this.habit,
    required this.targetNumberOfMinutes,
  });

  final Habit habit;
  final int targetNumberOfMinutes;

  @override
  State<RegisterFtHabitScreen> createState() => _CreateFtHabitScreenState();
}

class _CreateFtHabitScreenState extends State<RegisterFtHabitScreen> {
  final _currentUser = FirebaseAuth.instance.currentUser!;
  bool _confirmationBoxIsSelected = false,
      _isLoading = false,
      _changesWereMade = false;
  int _selectedDifficulty = 0, _selectedTotalMinutes = 0;

  late String _date;
  late FixedExtentScrollController _scrollHoursController,
      _scrollMinutesController;

  // Controllers.
  final TextEditingController _descriptionController = TextEditingController();

  void _onSelectedTimeChange() {
    final selectedHours = _scrollHoursController.selectedItem % _hours.length;
    final selectedMinutes =
        _scrollMinutesController.selectedItem % _minutes.length;

    setState(() {
      _selectedTotalMinutes = selectedHours * 60 + selectedMinutes;
    });
  }

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

    final activityDescription = _descriptionController.text.toString();
    final selectedHours = _scrollHoursController.selectedItem % _hours.length;
    final selectedMinutes =
        _scrollMinutesController.selectedItem % _minutes.length;
    Map<String, dynamic> registeredData = activityDescription.trim().isEmpty
        ? {
            "time": _selectedTotalMinutes,
            "difficulty": _selectedDifficulty,
            "hours": selectedHours,
            "minutes": selectedMinutes,
          }
        : {
            "time": _selectedTotalMinutes,
            "difficulty": _selectedDifficulty,
            "activityDescription": activityDescription,
            "hours": selectedHours,
            "minutes": selectedMinutes,
          };

    Map<String, dynamic> lastRegisteredData = {
      "createdAt": now,
      "hours": selectedHours,
      "minutes": selectedMinutes,
      "confirmation": _confirmationBoxIsSelected,
      "difficulty": _selectedDifficulty,
      "description": activityDescription,
    };

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
              lastRegisteredData,
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
            .set(registeredData),
      ]);

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
          _isLoading = false;
        });
      } else {
        setState(() {
          _confirmationBoxIsSelected = doc.data()?['confirmation'];
          _selectedDifficulty = doc.data()?['difficulty'];
          _isLoading = false;
        });

        _scrollHoursController.animateToItem(
          doc.data()?['hours'],
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );

        _scrollMinutesController.animateToItem(
          doc.data()?['minutes'],
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );

        _descriptionController.text = doc.data()?['description'];
        _changesWereMade = false;
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _handleBackButtonPressed() async {
    if (_changesWereMade) {
      final bool? confirmation = await showConfirmationDialog(
        context,
        "Salir del registro",
        "Se perderán los cambios realizados.",
        "Continuar",
        "Cancelar",
      );
      return confirmation ?? false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    _scrollHoursController = FixedExtentScrollController(initialItem: 0);
    _scrollMinutesController = FixedExtentScrollController(initialItem: 0);
    _loadFormData();
    _date = getDateAsString();
  }

  @override
  Widget build(BuildContext context) {
    double targetPercentage =
        _selectedTotalMinutes.toDouble() / widget.targetNumberOfMinutes > 1
            ? 1
            : _selectedTotalMinutes.toDouble() / widget.targetNumberOfMinutes;

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
                          Text(
                            "¿Cuánto tiempo dedicaste a esta actividad hoy?",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          CupertinoPageScaffold(
                            backgroundColor: Colors.transparent,
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 128,
                                    child: CupertinoPicker(
                                      looping: true,
                                      itemExtent: 32,
                                      scrollController: _scrollHoursController,
                                      onSelectedItemChanged: (index) {
                                        _onSelectedTimeChange();
                                        _changesWereMade = true;
                                      },
                                      children: _hours
                                          .map(
                                            (hour) => Center(
                                              child: Text(hour),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                                const Text(
                                  "horas",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 128,
                                    child: CupertinoPicker(
                                      looping: true,
                                      itemExtent: 32,
                                      scrollController:
                                          _scrollMinutesController,
                                      onSelectedItemChanged: (index) {
                                        _onSelectedTimeChange();
                                        _changesWereMade = true;
                                      },
                                      children: _minutes
                                          .map(
                                            (minute) => Center(
                                              child: Text(minute),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                                const Text(
                                  "min.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          CircularPercentIndicator(
                            radius: 50,
                            lineWidth: 5,
                            percent: targetPercentage,
                            center: Text(
                              "${(targetPercentage * 100).toStringAsFixed(1)}%",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor:
                                const Color.fromARGB(178, 158, 158, 158),
                            progressColor:
                                const Color.fromARGB(255, 228, 200, 247),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            maxLines: 4,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Describe brevemente lo que hiciste',
                              counterText: '',
                            ),
                            controller: _descriptionController,
                            onChanged: (_) {
                              _changesWereMade = true;
                            },
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            "Del 1 al 5 que tanto trabajo te costó realizar hoy este hábito",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          RatingBar.builder(
                            itemCount: 5,
                            initialRating: _selectedDifficulty.toDouble(),
                            unratedColor: Colors.white,
                            itemBuilder: (ctx, _) => const Icon(
                              Icons.local_fire_department,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (difficulty) {
                              setState(() {
                                _selectedDifficulty = difficulty.toInt();
                              });
                              _changesWereMade = true;
                            },
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
                          const SizedBox(
                            height: 16,
                          ),
                          ElevatedButton(
                            onPressed: _registerHabit,
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
                              final confirmation = await _handleBackButtonPressed();
                              if(confirmation) {
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
