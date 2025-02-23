import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

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
    this.initialNumberOfHours = 7,
  });

  final int initialNumberOfMinutes, initialNumberOfHours;

  @override
  State<RegisterTHabitScreen> createState() => _CreateFtHabitScreenState();
}

class _CreateFtHabitScreenState extends State<RegisterTHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _confirmationBoxIsSelected = false;
  int _selectedDifficulty = 0;

  late FixedExtentScrollController _scrollHoursController,
      _scrollMinutesController;

  void _registerHabit() {
    ScaffoldMessenger.of(context).clearSnackBars();
    int selectedHours = _scrollHoursController.selectedItem % _hours.length;
    int selectedMinutes =
        _scrollMinutesController.selectedItem % _minutes.length;

    int selectedTotalMinutes = selectedHours * 60 + selectedMinutes;

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
    print(selectedTotalMinutes);
  }

  @override
  void initState() {
    super.initState();
    _scrollHoursController =
        FixedExtentScrollController(initialItem: widget.initialNumberOfHours);
    _scrollMinutesController =
        FixedExtentScrollController(initialItem: widget.initialNumberOfMinutes);
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
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
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
                                onSelectedItemChanged: (index) {},
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
                                onSelectedItemChanged: (index) {},
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
                      height: 32,
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
      ),
    );
  }
}
