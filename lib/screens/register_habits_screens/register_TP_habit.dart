import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/widgets/pomodoro_timer.dart';

class RegisterTpHabit extends StatefulWidget {
  const RegisterTpHabit({
    super.key,
  });

  @override
  State<RegisterTpHabit> createState() => _CreateFtHabitScreenState();
}

class _CreateFtHabitScreenState extends State<RegisterTpHabit> {
  late int _workInterval, _restInterval, _targetNumberOfCycles;
  int _completedCycles = 0;
  bool _confirmationBoxIsSelected = false, _targetIsCompleted = false;

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

    print(_confirmationBoxIsSelected);
    print(_completedCycles);
  }

  @override
  void initState() {
    // TODO: get the times from the DB.
    super.initState();

    _workInterval = 10;
    _restInterval = 5;
    _targetNumberOfCycles = 2;
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
                    "Estudiar",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  PomodoroTimer(
                    workInterval: _workInterval,
                    restInterval: _restInterval,
                    targetNumberOfCycles: _targetNumberOfCycles,
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
                  if (_targetIsCompleted)
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
                  if (_targetIsCompleted)
                    const SizedBox(
                      height: 16,
                    ),
                  ElevatedButton(
                    onPressed: _targetIsCompleted ? _registerHabit : null,
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
