import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart' as rive;
import 'package:stubit/models/habit.dart';
import 'package:stubit/screens/register_habits_screens/register_habit.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StreakDialog extends StatefulWidget {
  const StreakDialog({
    super.key,
    required this.isRegistered,
    required this.habit,
    required this.habitParameters,
  });

  final bool isRegistered;
  final Habit habit;
  final Map<String, dynamic> habitParameters;

  @override
  State<StreakDialog> createState() => _StreakDialogState();
}

class _StreakDialogState extends State<StreakDialog> {
  final _currentUser = FirebaseAuth.instance.currentUser!;
  bool _isLoading = true;
  rive.StateMachineController? _controller;
  rive.SMINumber? _progressParam;
  late double? _targetProgress;
  double _currentProgress = 0;

  Timer? _timer;
  late String _currentAnimation;

  void _onRiveInit(rive.Artboard artboard) {
    _controller =
        rive.StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (_controller != null) {
      artboard.addController(_controller!);
      _progressParam = _controller!.findInput<double>('%') as rive.SMINumber?;
      if (_progressParam != null) {
        _progressParam!.value = _targetProgress ?? 0;
        _startProgressAnimation();
      }
    }
  }

  void _startProgressAnimation() {
    const step = 1.0;
    const duration = Duration(milliseconds: 30);

    _timer = Timer.periodic(duration, (timer) {
      if (_currentProgress >= (_targetProgress ?? 0)) {
        _currentProgress = (_targetProgress ?? 0);
        _progressParam?.value = _currentProgress;
        timer.cancel();

        if (_targetProgress == 100) {
          setState(() {
            _currentAnimation = 'congratulations.riv';
          });
        }
      } else {
        _currentProgress += step;
        _progressParam?.value = _currentProgress;
      }
    });
  }

  void _loadHabitProgress() async {
    // Obtener la racha actual y obtener el numero total de días.
    final userId = _currentUser.uid.toString();
    final docSnaps = await _firestore
        .collection("user_data")
        .doc(userId)
        .collection("habits")
        .doc(widget.habit.id)
        .get();

    if (docSnaps.exists) {
      final data = docSnaps.data();
      Map<String, dynamic> habitParameters = data?['habitParameters'];
      num numberOfWeeks = habitParameters['numberOfWeeks'];
      int totalTime = 0;

      if (widget.habit.strategy == 'T') {
        totalTime = numberOfWeeks.toInt() * 7;
      } else {
        final numberOfDays = (habitParameters['days'] as List<dynamic>).length;
        if (numberOfWeeks != double.infinity) {
          totalTime = numberOfDays * numberOfWeeks.toInt();
        }
      }

      int streak = (docSnaps['streak'] as num).toInt();

      setState(() {
        _targetProgress = numberOfWeeks == double.infinity
            ? null
            : 100 * (streak / totalTime);

        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _currentAnimation = widget.isRegistered ? 'streak_days' : 'streak';
    _loadHabitProgress();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF292D39),
      title: Center(
        child: Text(
          'Registrar día',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      content: _isLoading
          ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            )
          : _targetProgress == null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/images/progress.png",
                      height: 80,
                    ),
                    if (widget.isRegistered)
                      const SizedBox(
                        height: 8,
                      ),
                    if (widget.isRegistered)
                      Text(
                        '¡Felicidades, hoy ya realizaste esta actividad!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.amber,
                        ),
                      ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: rive.RiveAnimation.asset(
                        _currentAnimation == 'congratulations'
                            ? 'assets/images/congratulations.riv'
                            : _currentAnimation == "streak_days"
                                ? 'assets/images/streak_days.riv'
                                : 'assets/images/streak.riv',
                        fit: BoxFit.contain,
                        onInit: _onRiveInit,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Actualmente llevas ${_targetProgress!.toInt()}% de tu objetivo',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    if (widget.isRegistered)
                      const SizedBox(
                        height: 8,
                      ),
                    if (widget.isRegistered)
                      Text(
                        '¡Felicidades, hoy ya realizaste esta actividad!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.amber,
                        ),
                      ),
                  ],
                ),
      actions: [
        if (!widget.isRegistered)
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => RegisterHabit(
                    habit: widget.habit,
                    habitParameters: widget.habitParameters,
                  ),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text("¡Registra tu día!"),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cerrar"),
        ),
      ],
    );
  }
}
