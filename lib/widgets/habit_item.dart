import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/screens/edit_habits_screens/edit_T_habit_screen.dart';
import 'package:stubit/screens/edit_habits_screens/edit_habit_CF_screen.dart';
import 'package:stubit/screens/edit_habits_screens/edit_habit_COF_screen.dart';
import 'package:stubit/screens/edit_habits_screens/edit_habit_FT_screen.dart';
import 'package:stubit/screens/edit_habits_screens/edit_habit_L_screen.dart';
import 'package:stubit/screens/edit_habits_screens/edit_habit_TP_screen.dart';
import 'package:stubit/screens/register_habits_screens/register_habit.dart';
import 'package:stubit/screens/track_habit_screen.dart';
import 'package:stubit/util/util.dart';
import 'package:stubit/widgets/confirmation_dialog.dart';
import 'package:stubit/widgets/pay_streak_dialog.dart';
import 'package:stubit/widgets/streak_dialog.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class HabitItem extends StatefulWidget {
  const HabitItem({
    super.key,
    required this.habit,
    required this.habitParameters,
    required this.streak,
  });

  final Habit habit;
  final Map<String, dynamic> habitParameters;
  final int streak;

  @override
  State<HabitItem> createState() => _HabitItemState();
}

class _HabitItemState extends State<HabitItem> {
  List<DateTime> _missedDays = [];
  bool _isCompleted = false, _streakIsActive = false;
  final _currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> _loadHabitData() async {
    _loadStreakState();
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

  Future<void> _deleteHabitLog(String userId) async {
    try {
      CollectionReference logRef = _firestore
          .collection("user_data")
          .doc(userId)
          .collection("habits")
          .doc(widget.habit.id)
          .collection("habit_log");

      var snapshot = await logRef.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Falló la eliminación del LOG.');
    }
  }

  bool _habitIsActiveToday() {
    final dayOfWeek = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
    List<dynamic>? loadedDays = widget.habitParameters['days'];
    if (loadedDays == null) {
      return true;
    }

    List<String> days = loadedDays.map((item) => item.toString()).toList();
    return days.contains(dayOfWeek);
  }

  Future<void> _loadStreakState() async {
    _missedDays = [];
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    List<dynamic> loadedDays = widget.habitParameters['days'] ??
        [
          "monday",
          "tuesday",
          "wednesday",
          "thursday",
          "friday",
          "saturday",
          "sunday"
        ];

    final userId = _currentUser.uid.toString();
    final snapshot = await _firestore
        .collection("user_data")
        .doc(userId)
        .collection("habits")
        .doc(widget.habit.id)
        .get();

    final lastLog = (snapshot.data()?['last_log'] as Timestamp).toDate();
    final lastLogDate = DateTime(lastLog.year, lastLog.month, lastLog.day);

    DateTime day = lastLogDate.add(const Duration(days: 1));
    while (day.isBefore(date)) {
      final dayOfWeek = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
      if (loadedDays.contains(dayOfWeek)) {
        _missedDays.add(day);
      }

      day = day.add(const Duration(days: 1));
    }

    setState(() {
      _streakIsActive = _missedDays.isEmpty;
    });
  }

  void _showEditHabitScreen() {
    if (widget.habit.strategy == 'T') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => EditTHabitScreen(habit: widget.habit),
        ),
      );
    } else if (widget.habit.strategy == 'TP') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => EditHabitTpScreen(habit: widget.habit),
        ),
      );
    } else if (widget.habit.strategy == 'L') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => EditHabitLScreen(habit: widget.habit),
        ),
      );
    } else if (widget.habit.strategy == 'COF') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => EditHabitCofScreen(
            habit: widget.habit,
            unit: widget.habit.unit,
          ),
        ),
      );
    } else if (widget.habit.strategy == 'TF') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => EditHabitFtScreen(
            habit: widget.habit,
          ),
        ),
      );
    } else if (widget.habit.strategy == 'CF') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => EditHabitCfScreen(
            habit: widget.habit,
          ),
        ),
      );
    }
  }

  void _showProgressDialog() async {
    if (_streakIsActive) {
      await showDialog(
        context: context,
        builder: (ctx) => StreakDialog(
          isRegistered: _isCompleted,
          habit: widget.habit,
          habitParameters: widget.habitParameters,
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (ctx) => PayStreakDialog(
          habit: widget.habit,
          habitParameters: widget.habitParameters,
          currentStreak: widget.streak,
          missedDays: _missedDays,
        ),
      );
    }
    await _loadHabitData();
  }

  void _showMenuAction(BuildContext context) {
    final bool isActive = _habitIsActiveToday();
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
                await _loadHabitData();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Seguimiento'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => TrackHabitScreen(
                      habit: widget.habit,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar hábito'),
              onTap: _showEditHabitScreen,
            ),
            if (isActive && !_isCompleted)
              ListTile(
                leading: const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                ),
                title: const Text(
                  '¡Mantén tu racha!',
                  style: TextStyle(
                    color: Colors.amber,
                  ),
                ),
                onTap: () {},
              ),
            ListTile(
              leading: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              title: const Text(
                'Eliminar hábito',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: () async {
                bool deleteConfirmation = await showConfirmationDialog(
                      ctx,
                      "Eliminar hábito",
                      "Se borrará toda la información de tu hábito permanentemente.",
                      "Eliminar",
                      "Cancelar",
                    ) ??
                    false;

                ScaffoldMessenger.of(context).clearSnackBars();
                final userId = _currentUser.uid.toString();
                if (deleteConfirmation) {
                  Navigator.of(ctx).pop();
                  final rootContext =
                      Navigator.of(context, rootNavigator: true).context;
                  try {
                    await _deleteHabitLog(userId);
                    await _firestore
                        .collection("user_data")
                        .doc(userId)
                        .collection("habits")
                        .doc(widget.habit.id)
                        .delete();
                    ScaffoldMessenger.of(rootContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Se ha eliminado el hábito.',
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(rootContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No se ha podido completar la acción. Por favor, inténtalo más tarde',
                        ),
                      ),
                    );
                  }
                }
              },
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
      onTap: _showProgressDialog,
      onLongPress: () {
        _showMenuAction(context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(
          bottom: 16,
        ),
        decoration: BoxDecoration(
          color: !_streakIsActive
              ? const Color.fromARGB(255, 121, 30, 2)
              : _isCompleted
                  ? const Color.fromARGB(242, 16, 16, 16)
                  : const Color(0xFF292D39),
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
                  fontStyle: _isCompleted ? FontStyle.italic : null,
                  color: Colors.white,
                  fontSize: 14,
                  decorationColor: Colors.white,
                  decorationThickness: 3,
                ),
              ),
            ),
            Icon(
              _streakIsActive ? Icons.local_fire_department : Icons.flash_off,
              color:
                  _streakIsActive && _isCompleted ? Colors.amber : Colors.grey,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}
