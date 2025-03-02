import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

final player = AudioPlayer();

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({
    super.key,
    required this.workInterval,
    required this.restInterval,
    required this.targetNumberOfCycles,
    required this.completedCycles,
    required this.remainingTime,
    required this.workIntervalIsActive,
    required this.onCycleComplete,
    required this.onFinish,
    required this.onUpdateTimer,
  });

  final int workInterval,
      restInterval,
      targetNumberOfCycles,
      completedCycles,
      remainingTime;
  final bool workIntervalIsActive;
  final void Function(int) onFinish;
  final void Function(int) onCycleComplete;
  final void Function(bool, int) onUpdateTimer;

  @override
  State<StatefulWidget> createState() {
    return _PomodoroTimerState();
  }
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  bool _hastStarted = false,
      _workIntervalIsActive = true,
      _timerIsPaused = true,
      _runningAditionalCycle = false;

  Timer? _timer;
  late int _completedCycles, _remainingSeconds, _workInterval, _restInterval;
  late bool _targetCompleted;

  void _playAlertSound() async {
    await player.setSourceAsset('sounds/ding.wav');
    await player.resume();
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

        _playAlertSound();
        if (_runningAditionalCycle) {
          setState(() {
            _runningAditionalCycle = false;
            _completedCycles++;
          });

          widget.onFinish(_completedCycles);
          return;
        }

        if (!_workIntervalIsActive ||
            _completedCycles == widget.targetNumberOfCycles - 1) {
          setState(() {
            _completedCycles++;
          });
          widget.onCycleComplete(_completedCycles);
        }

        _workIntervalIsActive = !_workIntervalIsActive;
        setState(() {
          _remainingSeconds =
              _workIntervalIsActive ? _workInterval : _restInterval;
        });

        if (_completedCycles < widget.targetNumberOfCycles) {
          widget.onUpdateTimer(_workIntervalIsActive, _remainingSeconds);
          _startTimer();
        } else {
          setState(() {
            _targetCompleted = true;
            widget.onFinish(_completedCycles);
          });
        }
      }

      if (_remainingSeconds % 10 == 0) {
        widget.onUpdateTimer(_workIntervalIsActive, _remainingSeconds);
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
    super.initState();
    _workInterval = widget.workInterval * 60;
    _restInterval = widget.restInterval * 60;
    _remainingSeconds = widget.remainingTime;
    _completedCycles = widget.completedCycles;
    _workIntervalIsActive = widget.workIntervalIsActive;
    _targetCompleted = widget.completedCycles == widget.targetNumberOfCycles;
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    double timerPercentage = _workIntervalIsActive
        ? _remainingSeconds / _workInterval
        : _remainingSeconds / _restInterval;

    String timerTitle = !_hastStarted
        ? "Prepárate para comenzar"
        : _targetCompleted && !_runningAditionalCycle
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

    return Container(
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
                  "$_completedCycles / ${widget.targetNumberOfCycles}",
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
              backgroundColor: const Color.fromARGB(178, 158, 158, 158),
              progressColor: _timerIsPaused
                  ? const Color.fromARGB(255, 71, 70, 72)
                  : const Color.fromARGB(255, 228, 200, 247),
            ),
            const SizedBox(
              height: 8,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hastStarted = true;
                });

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
    );
  }
}
