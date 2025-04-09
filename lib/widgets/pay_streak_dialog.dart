import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/util/util.dart';
import 'package:intl/intl.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class PayStreakDialog extends StatefulWidget {
  const PayStreakDialog({
    super.key,
    required this.habitParameters,
    required this.habit,
    required this.currentStreak,
    required this.missedDays,
  });

  final Habit habit;
  final Map<String, dynamic> habitParameters;
  final List<DateTime> missedDays;
  final int currentStreak;

  @override
  State<PayStreakDialog> createState() => _PayStreakDialogState();
}

class _PayStreakDialogState extends State<PayStreakDialog> {
  final _currentUser = FirebaseAuth.instance.currentUser!;
  late int _streakCost, _availableGems;

  bool _isLoading = true;

  Future<void> _loadAvailableGems() async {
    final userId = _currentUser.uid.toString();
    final docSnapshot = await _firestore
        .collection("user_data")
        .doc(userId)
        .collection("gems")
        .doc("user_gems")
        .get();

    setState(() {
      _availableGems = docSnapshot.data()?['collectedGems'];
      _isLoading = false;
    });
  }

  Future<void> _completeMissingDays() async {
    final userId = _currentUser.uid.toString();
    for (DateTime day in widget.missedDays) {
      String date = DateFormat('yyyy-MM-dd').format(day);
      await _firestore
          .collection("user_data")
          .doc(userId)
          .collection("habits")
          .doc(widget.habit.id)
          .collection("habit_log")
          .doc(date)
          .set({
        "payed": true,
        "gemsPayed": _streakCost,
      });
    }
  }

  void _loseStreak() async {
    final now = Timestamp.now();
    final userId = _currentUser.uid.toString();
    try {
      await _firestore
          .collection("user_data")
          .doc(userId)
          .collection("habits")
          .doc(widget.habit.id)
          .update({
        "streak": 0,
        "last_log": now,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tu racha ha terminado. ¡Siempre puedes empezar una nueva!',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ha ocurrido un error al guardar tu información. Intentalo más tarde.',
          ),
        ),
      );
    }
  }

  void _keepStreak() async {
    final userId = _currentUser.uid.toString();
    DateTime now = DateTime.now();
    try {
      await Future.wait([
        _completeMissingDays(),
        _firestore
            .collection("user_data")
            .doc(userId)
            .collection("gems")
            .doc("user_gems")
            .update({
          "collectedGems": FieldValue.increment(-_streakCost),
        }),
        _firestore
            .collection("user_data")
            .doc(userId)
            .collection("habits")
            .doc(widget.habit.id)
            .update({
          "streak": FieldValue.increment(1),
          "last_log": now,
        }),
      ]);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '¡Felicidades, tu racha sigue en pie!',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ha ocurrido un error al guardar tu información. Intentalo más tarde.',
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _streakCost = widget.currentStreak * getStreakCost(widget.currentStreak);
    _loadAvailableGems();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const AlertDialog(
            backgroundColor: Color(0xFF292D39),
            content: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : _availableGems >= _streakCost
            ? AlertDialog(
                backgroundColor: const Color(0xFF292D39),
                title: Center(
                  child: Text(
                    '¡No pierdas tu racha!',
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
                    Image.asset(
                      'assets/images/book.png',
                      height: 60,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                '¡Cuidado! Estás a punto de perder tu racha. Usa ',
                          ),
                          TextSpan(
                            text: '$_streakCost',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(
                            text: ' gemas ahora y sigue sumando éxitos.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: _keepStreak,
                    child: const Text("¡Mantener mi racha!"),
                  ),
                  TextButton(
                    onPressed: _loseStreak,
                    child: const Text("No, gracias"),
                  ),
                ],
              )
            : AlertDialog(
                title: Center(
                  child: Text(
                    '¡Oh no! Racha terminada.',
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
                    Image.asset(
                      'assets/images/lost_streak.png',
                      height: 80,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Se necesitan ',
                          ),
                          TextSpan(
                            text: '$_streakCost',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(
                            text:
                                ' gemas para mantener tu racha, pero solamente tienes ',
                          ),
                          TextSpan(
                            text: '$_availableGems',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(
                            text: ' gemas.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: _loseStreak,
                    child: const Text("Aceptar"),
                  ),
                ],
              );
  }
}
