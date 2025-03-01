import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/util/util.dart';
import 'package:stubit/widgets/confirmation_dialog.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class RegisterCfHabit extends StatefulWidget {
  const RegisterCfHabit({
    super.key,
    required this.habit,
  });

  final Habit habit;

  @override
  State<RegisterCfHabit> createState() => _CreateFtHabitScreenState();
}

class _CreateFtHabitScreenState extends State<RegisterCfHabit> {
  final _currentUser = FirebaseAuth.instance.currentUser!;
  final _formKey = GlobalKey<FormState>();

  late String _date;
  bool _confirmationBoxIsSelected = false,
      _isLoading = true,
      _changesWereMade = false;
  int _selectedDifficulty = 0;

  // Controllers.
  final TextEditingController _answerOneController = TextEditingController();
  final TextEditingController _answerTwoController = TextEditingController();

  // Validators.
  String? _answerValidator(String? answer) {
    if (answer == null || answer.trim().isEmpty) {
      return 'Pregunta obligatoria.';
    }

    return null;
  }

  void _registerHabit() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

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

      final answerOne = _answerOneController.text.toString();
      final answerTwo = _answerTwoController.text.toString();

      final userId = _currentUser.uid.toString();
      final now = Timestamp.now();

      try {
        await Future.wait([
          _firestore
              .collection("user_data")
              .doc(userId)
              .collection("habits")
              .doc(widget.habit.id)
              .collection("habit_log")
              .doc("daily_form")
              .set(
            {
              "createdAt": now,
              "answerOne": answerOne,
              "answerTwo": answerTwo,
              "confirmation": _confirmationBoxIsSelected,
              "difficulty": _selectedDifficulty,
            },
            SetOptions(
              merge: true,
            ),
          ),
          _firestore
              .collection("user_data")
              .doc(userId)
              .collection("habits")
              .doc(widget.habit.id)
              .collection("habit_log")
              .doc(_date)
              .set({
            "difficulty": _selectedDifficulty,
            "answeOne": answerOne,
            "answerTwo": answerTwo,
          })
        ]);

        // TODO: mostrar las gemas obtenidas con la frase motivacional.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Felicidades! Registro del día completado."),
          ),
        );

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Hubo un problema al guardar el registro. Inténtalo más tarde.",
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadFormData() async {
    final userId = _currentUser.uid.toString();
    final doc = await _firestore
        .collection("user_data")
        .doc(userId)
        .collection("habits")
        .doc(widget.habit.id)
        .collection("habit_log")
        .doc("daily_form")
        .get();

    if (doc.exists) {
      final createdAt = (doc.data()?['createdAt'] as Timestamp).toDate();
      final now = DateTime.now();
      if (isDifferentDay(createdAt, now)) {
        await _firestore
            .collection("user_data")
            .doc(userId)
            .collection("habits")
            .doc(widget.habit.id)
            .collection("habit_log")
            .doc("daily_form")
            .delete();
        setState(() {
          _isLoading = false;
          _confirmationBoxIsSelected = false;
        });
      } else {
        setState(() {
          _confirmationBoxIsSelected = doc.data()?['confirmation'];
          _selectedDifficulty = doc.data()?['difficulty'];
          _isLoading = false;
        });

        _answerOneController.text = doc.data()?['answerOne'];
        _answerTwoController.text = doc.data()?['answerTwo'];
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _handleBackButtonPressed() async {
    if (_changesWereMade) {
      final bool? confirmation = await showConfirmationDialog(
        context,
        "Salir del registro",
        "Se perderán los cambios realizados.",
        "Continuar",
        "Cancelar",
      );
      return confirmation ?? false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    _loadFormData();
    _date = getDateAsString();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _handleBackButtonPressed();
      },
      child: Scaffold(
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Center(
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
                              widget.habit.name,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            TextFormField(
                              maxLines: 3,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Describe brevemente lo que hiciste',
                                counterText: '',
                              ),
                              onChanged: (value) {
                                _changesWereMade = true;
                              },
                              controller: _answerOneController,
                              validator: _answerValidator,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            TextFormField(
                              maxLines: 3,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              onChanged: (value) {
                                _changesWereMade = true;
                              },
                              decoration: const InputDecoration(
                                labelText:
                                    '¿Qué aprendiste durante la actividad?',
                                counterText: '',
                              ),
                              controller: _answerTwoController,
                              validator: _answerValidator,
                            ),
                            const SizedBox(
                              height: 16,
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
                              initialRating: _selectedDifficulty.toDouble(),
                              itemBuilder: (ctx, _) => const Icon(
                                Icons.local_fire_department,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (difficulty) {
                                setState(() {
                                  _selectedDifficulty = difficulty.toInt();
                                });
                                _changesWereMade = true;
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
                                backgroundColor:
                                    const Color.fromRGBO(121, 30, 198, 1),
                              ),
                              child: Text(
                                "Completar",
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
                              onPressed: _handleBackButtonPressed,
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
      ),
    );
  }
}
