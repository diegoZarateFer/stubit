import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/util/util.dart';
import 'package:stubit/widgets/confirmation_dialog.dart';
import 'package:stubit/widgets/cofre_animation.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class RegisterLHabit extends StatefulWidget {
  const RegisterLHabit({
    super.key,
    required this.habit,
  });

  final Habit habit;

  @override
  State<RegisterLHabit> createState() => _CreateFtHabitScreenState();
}

class _CreateFtHabitScreenState extends State<RegisterLHabit> {
  final _currentUser = FirebaseAuth.instance.currentUser!;

  late String _date;
  List<String> _listItems = [];

  bool _confirmationBoxIsSelected = false,
      _editingList = false,
      _isLoading = true,
      _isFirstRegister = true,
      _changesWereMade = false;
  int _selectedDifficulty = 0;

  // Controllers
  final TextEditingController _textEditingController = TextEditingController();

  void _registerHabit() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    if (_listItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La lista debe contener al menos un elemento.',
          ),
        ),
      );
      return;
    }

    if (_selectedDifficulty == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona que tanto te costó realizar esta actividad.',
          ),
        ),
      );
      return;
    }

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

    final givenGems = assignGems();

    final userId = _currentUser.uid.toString();
    final now = Timestamp.now();
    try {
      Future.wait([
        if (_isFirstRegister)
          _firestore
              .collection("user_data")
              .doc(userId)
              .collection("gems")
              .doc("user_gems")
              .update({
            "collectedGems": FieldValue.increment(givenGems),
          }),
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
            "list": _listItems,
            "selectedDifficulty": _selectedDifficulty,
            "confirmation": _confirmationBoxIsSelected,
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
            .set(
          {
            "list": _listItems,
            "difficulty": _selectedDifficulty,
          },
        ),
      ]);

      if (_isFirstRegister) {
        final phrase = getPhrase(widget.habit.category);
        await showCofreAndGemsDialog(context, givenGems, phrase);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFirstRegister
                ? "¡Felicidades! Registro del día completado."
                : "Se han guardado los cambios.",
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Hubo un problema al guardar el registro. Inténtalo más tarde."),
        ),
      );
    }
  }

  Future<void> _loadFormData() async {
    final userId = _currentUser.uid.toString();
    _changesWereMade = false;
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
          _listItems = [];
          _isLoading = false;
          _confirmationBoxIsSelected = false;
          _selectedDifficulty = 0;
        });
      } else {
        setState(() {
          List<dynamic> list = doc.data()?['list'];
          _listItems = list.map((e) => e.toString()).toList();
          _selectedDifficulty = doc.data()?['selectedDifficulty'];
          _confirmationBoxIsSelected = doc.data()?['confirmation'];
          _isFirstRegister = false;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _listItems = [];
        _isLoading = false;
        _confirmationBoxIsSelected = false;
        _selectedDifficulty = 0;
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
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(
                  16,
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Column(
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
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF181A25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _listItems.length,
                                  itemBuilder: (ctx, index) {
                                    return ListTile(
                                      onTap: _textEditingController.text
                                              .trim()
                                              .isNotEmpty
                                          ? () {}
                                          : () {
                                              _textEditingController.text =
                                                  _listItems[index];
                                              setState(() {
                                                _editingList = true;
                                                _listItems.removeAt(index);
                                              });
                                            },
                                      leading: const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      title: Text(_listItems[index]),
                                      trailing: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _listItems.removeAt(index);
                                          });
                                        },
                                        icon: const Icon(Icons.delete),
                                      ),
                                    );
                                  },
                                ),
                                const Divider(),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  maxLength: 250,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Me siento agradecido por:',
                                    counterText: '',
                                  ),
                                  controller: _textEditingController,
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    String enteredText =
                                        _textEditingController.text.trim();

                                    if (enteredText.trim().isNotEmpty) {
                                      setState(() {
                                        _listItems = [
                                          ..._listItems,
                                          enteredText
                                        ];
                                      });

                                      _changesWereMade = true;
                                      _textEditingController.text = "";
                                      setState(() {
                                        _editingList = false;
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                  child: Icon(
                                    _editingList ? Icons.check : Icons.add,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
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
                                    _isFirstRegister ? "Completar" : "Guardar",
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
                                  onPressed: () async {
                                    final confirmation =
                                        await _handleBackButtonPressed();
                                    if (confirmation) {
                                      Navigator.of(context).pop();
                                    }
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
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
