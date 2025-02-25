import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class RegisterTpHabit extends StatefulWidget {
  const RegisterTpHabit({
    super.key,
  });

  @override
  State<RegisterTpHabit> createState() => _CreateFtHabitScreenState();
}

class _CreateFtHabitScreenState extends State<RegisterTpHabit> {
  late int _workInterval,
      _restInterval,
      _remainingSeconds,
      _targetNumberOfCycles;

  int _completedCycles = 0;

  bool _workIntervalIsActive = true,
      _timerIsPaused = true,
      _targetCompleted = false,
      _runningAditionalCycle = false,
      _confirmationBoxIsSelected = false;

  Timer? _timer;

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

    if (_timer != null) {
      _timer!.cancel();
    }
  }

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerIsPaused) return;
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        if (_runningAditionalCycle) {
          setState(() {
            _runningAditionalCycle = false;
            _completedCycles++;
          });
          return;
        }

        if (!_workIntervalIsActive ||
            _completedCycles == _targetNumberOfCycles - 1) {
          setState(() {
            _completedCycles++;
          });
        }

        _workIntervalIsActive = !_workIntervalIsActive;
        setState(() {
          _remainingSeconds =
              _workIntervalIsActive ? _workInterval : _restInterval;
        });

        if (_completedCycles < _targetNumberOfCycles) {
          _startTimer();
        } else {
          setState(() {
            _targetCompleted = true;
          });
        }
      }
    });
  }

  String _formatTime(int numberOfSeconds) {
    int minutes = numberOfSeconds ~/ 60;
    int seconds = numberOfSeconds % 60;

    String formattedMinutes = minutes <= 9 ? "0$minutes" : "$minutes";
    String formattedSeconds = seconds <= 9 ? "0$seconds" : "$seconds";

    return "$formattedMinutes : $formattedSeconds";
  }

  @override
  void initState() {
    // TODO: get the times from the DB.
    super.initState();

    _workInterval = 10;
    _restInterval = 5;
    _targetNumberOfCycles = 2;
    _remainingSeconds = _workInterval;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double timerPercentage = _workIntervalIsActive
        ? _remainingSeconds / _workInterval
        : _remainingSeconds / _restInterval;

    String timerTitle = _targetCompleted && !_runningAditionalCycle
        ? "Enhorabuena, ¡has terminado!"
        : _timerIsPaused
            ? "Pausado"
            : _workIntervalIsActive
                ? "Concentrate en tu actividad"
                : "Descanso";

    final timerButtonIcon = _targetCompleted && !_runningAditionalCycle
        ? Icons.add
        : _timerIsPaused
            ? Icons.play_arrow
            : Icons.pause;

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
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF181A25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        16,
                      ),
                      child: Column(
                        children: [
                          Text(
                            timerTitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Ciclos completados:",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                "$_completedCycles / $_targetNumberOfCycles",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          CircularPercentIndicator(
                            radius: 75,
                            lineWidth: 5,
                            percent: timerPercentage,
                            center: Text(
                              _formatTime(_remainingSeconds),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor:
                                const Color.fromARGB(178, 158, 158, 158),
                            progressColor: _timerIsPaused
                                ? const Color.fromARGB(255, 71, 70, 72)
                                : const Color.fromARGB(255, 228, 200, 247),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (!_runningAditionalCycle && _targetCompleted) {
                                setState(() {
                                  _timerIsPaused = false;
                                  _runningAditionalCycle = true;
                                  _workIntervalIsActive = true;
                                });
                                _remainingSeconds = _workInterval;
                              } else {
                                setState(() {
                                  _timerIsPaused = !_timerIsPaused;
                                });
                              }

                              _startTimer();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: Icon(
                              timerButtonIcon,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  if (_targetCompleted)
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
                  if (_targetCompleted)
                    const SizedBox(
                      height: 16,
                    ),
                  ElevatedButton(
                    onPressed: _targetCompleted ? _registerHabit : null,
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
