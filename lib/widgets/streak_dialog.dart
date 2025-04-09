import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/screens/register_habits_screens/register_habit.dart';

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
  StateMachineController? _controller;
  SMINumber? _progressParam;
  double _progress = 80;

  void _onRiveInit(Artboard artboard) {
    _controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (_controller != null) {
      artboard.addController(_controller!);
      _progressParam = _controller!.findInput<double>('%') as SMINumber?;
      if (_progressParam != null) {
        _progressParam!.value = _progress;
      }
    }
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: RiveAnimation.asset(
              'assets/images/streak.riv',
              fit: BoxFit.contain,
              onInit: _onRiveInit,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Actualmente llevas $_progress% de tu objetivo',
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
