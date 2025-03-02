import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/screens/register_habits_screens/register_habit.dart';
import 'package:stubit/screens/track_habit_screen.dart';
import 'package:stubit/util/util.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class HabitItem extends StatefulWidget {
  const HabitItem({
    super.key,
    required this.habit,
    required this.onTap,
    required this.habitParameters,
  });

  final Habit habit;
  final Map<String, dynamic> habitParameters;
  final void Function() onTap;

  @override
  State<HabitItem> createState() => _HabitItemState();
}

class _HabitItemState extends State<HabitItem> {
  bool _isCompleted = false;
  final _currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> _loadHabitData() async {
    final userId = _currentUser.uid.toString();
    final date = getDateAsString();
    final doc = await _firestore
        .collection("user_data")
        .doc(userId)
        .collection("habits")
        .doc(widget.habit.id)
        .collection("habit_log")
        .doc(date)
        .get();

    if (doc.exists) {
      setState(() {
        _isCompleted = true;
      });
    }
  }

  String _getRegisterHabitText() {
    if (widget.habit.strategy == 'TP') {
      return _isCompleted ? "Agregar ciclo" : "Registrar";
    }

    if (widget.habit.strategy == 'COF') {
      return "Agregar a registro";
    }
    return _isCompleted ? "Modificar registro" : "Registrar";
  }

  Icon _getRegisterHabitIcon() {
    if (widget.habit.strategy == 'TP') {
      return Icon(_isCompleted ? Icons.add : Icons.check);
    }

    if (widget.habit.strategy == 'COF') {
      return const Icon(Icons.add);
    }
    return Icon(_isCompleted ? Icons.edit_calendar_outlined : Icons.check);
  }

  void _showMenuAction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (ctx) {
        final registerHabitText = _getRegisterHabitText();
        final registerHabitIcon = _getRegisterHabitIcon();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                widget.habit.name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: registerHabitIcon,
              title: Text(registerHabitText),
              onTap: () async {
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
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Seguimiento'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const TrackHabitScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar hábito'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar hábito'),
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadHabitData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showMenuAction(context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(
          bottom: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF292D39),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                textAlign: TextAlign.center,
                widget.habit.name,
                softWrap: true,
                maxLines: 2,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  decoration: _isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.white,
                  decorationThickness: 3,
                ),
              ),
            ),
            Icon(
              Icons.local_fire_department,
              color: _isCompleted ? Colors.amber : Colors.grey,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}
