import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/util/util.dart';

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
  bool _confirmationBoxIsSelected = false;
  int _selectedDifficulty = 0;

  // Controllers.
  final TextEditingController _questionOneController = TextEditingController();
  final TextEditingController _questionTwoController = TextEditingController();

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

      final answerOne = _questionOneController.text.toString();
      final answerTwo = _questionTwoController.text.toString();

      final userId = _currentUser.uid.toString();
      final date = getDateAsString();

      try {
        await _firestore
            .collection("user_data")
            .doc(userId)
            .collection("habits")
            .doc(widget.habit.id)
            .collection("habit_log")
            .doc(date)
            .set({
          "difficulty": _selectedDifficulty,
          "answeOne": answerOne,
          "answerTwo": answerTwo,
        });

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                  controller: _questionOneController,
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
                  decoration: const InputDecoration(
                    labelText: '¿Qué aprendiste durante la actividad?',
                    counterText: '',
                  ),
                  controller: _questionTwoController,
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
                            _confirmationBoxIsSelected = isSelected ?? false;
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
    );
  }
}
