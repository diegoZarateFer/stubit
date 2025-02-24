import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterLHabit extends StatefulWidget {
  const RegisterLHabit({
    super.key,
  });

  @override
  State<RegisterLHabit> createState() => _CreateFtHabitScreenState();
}

class _CreateFtHabitScreenState extends State<RegisterLHabit> {
  List<String> _listItems = [];

  bool _confirmationBoxIsSelected = false, _editingList = false;
  int _selectedDifficulty = 0;

  // Controllers
  final TextEditingController _textEditingController = TextEditingController();

  void _registerHabit() {
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

    print(_selectedDifficulty);
    print(_confirmationBoxIsSelected);
    print(_listItems.toString());
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(
                16,
              ),
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
                    "Practicar la gratitud",
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
                              onTap: () {
                                _textEditingController.text = _listItems[index];
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
                          maxLines: 2,
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
                                _listItems = [..._listItems, enteredText];
                              });

                              _textEditingController.text = "";

                              setState(() {
                                _editingList = !_editingList;
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
