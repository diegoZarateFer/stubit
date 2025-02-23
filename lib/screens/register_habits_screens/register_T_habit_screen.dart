import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

final List<String> _hours = List.generate(
  13,
  (index) => index > 9 ? index.toString() : "0${index.toString()}",
);

final List<String> _minutes = List.generate(
  60,
  (index) => index > 9 ? index.toString() : "0${index.toString()}",
);

class RegisterTHabitScreen extends StatefulWidget {
  const RegisterTHabitScreen({
    super.key,
    this.initialNumberOfMinutes = 0,
    this.initialNumberOfHours = 0,
  });

  final int initialNumberOfMinutes, initialNumberOfHours;

  @override
  State<RegisterTHabitScreen> createState() => _CreateFtHabitScreenState();
}

class _CreateFtHabitScreenState extends State<RegisterTHabitScreen> {
  bool _confirmationBoxIsSelected = false;
  int _selectedDifficulty = 0, _selectedTotalMinutes = 0;

  late int _targetTime;

  late FixedExtentScrollController _scrollHoursController,
      _scrollMinutesController;

  void _onSelectedTimeChange() {
    int selectedHours = _scrollHoursController.selectedItem % _hours.length;
    int selectedMinutes =
        _scrollMinutesController.selectedItem % _minutes.length;

    setState(() {
      _selectedTotalMinutes = selectedHours * 60 + selectedMinutes;
    });
  }

  void _registerHabit() {
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

    print(_selectedDifficulty);
    print(_confirmationBoxIsSelected);
    print(_selectedTotalMinutes);
  }

  @override
  void initState() {
    super.initState();
    // TODO: Get daily time from DB.
    _targetTime = 480;
    _scrollHoursController =
        FixedExtentScrollController(initialItem: widget.initialNumberOfHours);
    _scrollMinutesController =
        FixedExtentScrollController(initialItem: widget.initialNumberOfMinutes);
  }

  @override
  Widget build(BuildContext context) {
    double targetPercentage = _selectedTotalMinutes.toDouble() / _targetTime > 1
        ? 1
        : _selectedTotalMinutes.toDouble() / _targetTime;

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
        child: Center(
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
                    "Dormir adecuadamente.",
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
                              scrollController: _scrollMinutesController,
                              onSelectedItemChanged: (index) {
                                _onSelectedTimeChange();
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
                    backgroundColor: const Color.fromARGB(178, 158, 158, 158),
                    progressColor: const Color.fromARGB(255, 228, 200, 247),
                  ),
                  const SizedBox(
                    height: 8,
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
                    unratedColor: Colors.white,
                    itemBuilder: (ctx, _) => const Icon(
                      Icons.local_fire_department,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (difficulty) {
                      setState(() {
                        _selectedDifficulty = difficulty.toInt();
                      });
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
        ),
      ),
    );
  }
}
