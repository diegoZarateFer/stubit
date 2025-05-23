import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/habit.dart';

Map<String, num> _numberOfWeeksOptions = {
  "1 semana": 1,
  "2 semanas": 2,
  "3 semanas": 3,
  "4 semanas": 4,
  "5 semanas": 5,
  "6 semanas": 6,
  "7 semanas": 7,
  "8 semanas": 8,
  "9 semanas": 9,
  "10 semanas": 10,
  "Indefinidamente": double.infinity,
};

final List<String> _hours = List.generate(
  13,
  (index) => index > 9 ? index.toString() : "0${index.toString()}",
);

final List<String> _minutes = List.generate(
  60,
  (index) => index > 9 ? index.toString() : "0${index.toString()}",
);

class CreateTHabitScreen extends StatefulWidget {
  const CreateTHabitScreen({
    super.key,
    required this.habit,
    this.initialNumberOfMinutes = 0,
    this.initialNumberOfHours = 7,
  });

  final Habit habit;
  final int initialNumberOfMinutes, initialNumberOfHours;

  @override
  State<CreateTHabitScreen> createState() => _CreateFtHabitScreenState();
}

class _CreateFtHabitScreenState extends State<CreateTHabitScreen> {
  User? _currentUser;
  final _formKey = GlobalKey<FormState>();

  num? _selectedNumberOfWeeks;

  late FixedExtentScrollController _scrollHoursController,
      _scrollMinutesController;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _scrollHoursController =
        FixedExtentScrollController(initialItem: widget.initialNumberOfHours);
    _scrollMinutesController =
        FixedExtentScrollController(initialItem: widget.initialNumberOfMinutes);
  }

  String? _habitDurationValidator(selectedDuration) {
    if (selectedDuration == null) {
      return "Campo obligatorio";
    }

    return null;
  }

  Future<bool> showRecomendationDialog(
      BuildContext context, totalNumberOfDays) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "La magia de los 21 días",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/magic.png',
                    height: 80,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Con la configuración actual, tu actividad tendrá una duración de $totalNumberOfDays días. Te recomendamos dedicar al menos 21 días para obtener mejores resultados.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    "Ahora no",
                    style: TextStyle(
                      color: Color.fromRGBO(121, 30, 198, 1),
                      fontSize: 14,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(121, 30, 198, 1),
                  ),
                  child: Text(
                    "¡Acepto el reto!",
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      decorationColor: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _saveForm() async {
    int selectedHours = _scrollHoursController.selectedItem % _hours.length;
    int selectedMinutes =
        _scrollMinutesController.selectedItem % _minutes.length;

    int selectedTotalMinutes = selectedHours * 60 + selectedMinutes;

    ScaffoldMessenger.of(context).clearSnackBars();
    if (selectedTotalMinutes < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes dedicar al menos 10 minutos a esta actividad.'),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final Map<String, dynamic> habitParameters = {
        "allotedTime": selectedTotalMinutes,
        "minutes": selectedMinutes,
        "hours": selectedHours,
        "numberOfWeeks": _selectedNumberOfWeeks,
      };

      if (_selectedNumberOfWeeks != double.infinity &&
          _selectedNumberOfWeeks! * 7 < 21) {
        final bool confirmation =
            await showRecomendationDialog(context, _selectedNumberOfWeeks! * 7);
        if (confirmation) {
          return;
        }
      }

      final now = Timestamp.now();
      try {
        // Saving habit information.
        await FirebaseFirestore.instance
            .collection("user_data")
            .doc(_currentUser!.uid.toString())
            .collection("habits")
            .doc(widget.habit.id)
            .set({
          "name": widget.habit.name,
          "strategy": widget.habit.strategy,
          "category": widget.habit.category,
          "description": widget.habit.description,
          "habitParameters": habitParameters,
          "streak": 0,
          "last_log": now,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Hábito agregado correctamente!'),
          ),
        );
        Navigator.pop(context, true);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ha ocurrido un error al crear el hábito. Intentalo más tarde.',
            ),
          ),
        );
      }
    }
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
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      "CREACIÓN DE HÁBITO",
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
                    Text(
                      "¿Cuánto tiempo quieres dedicar a la actividad por día?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CupertinoPageScaffold(
                      backgroundColor: Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 128,
                              child: CupertinoPicker(
                                looping: true,
                                itemExtent: 32,
                                scrollController: _scrollHoursController,
                                onSelectedItemChanged: (value) {},
                                children: _hours
                                    .map(
                                      (hour) => Center(
                                        child: Text(hour),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                          const Text(
                            "horas",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 128,
                              child: CupertinoPicker(
                                looping: true,
                                itemExtent: 32,
                                scrollController: _scrollMinutesController,
                                onSelectedItemChanged: (value) {},
                                children: _minutes
                                    .map(
                                      (minute) => Center(
                                        child: Text(minute),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                          const Text(
                            "min.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    DropdownButtonFormField(
                      dropdownColor: Colors.black,
                      validator: _habitDurationValidator,
                      items: _numberOfWeeksOptions.keys.toList().map((option) {
                        return DropdownMenuItem(
                          value: _numberOfWeeksOptions[option],
                          child: Text(
                            option,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (numberOfWeeks) {
                        _selectedNumberOfWeeks = numberOfWeeks!;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Duración del hábito.',
                      ),
                      menuMaxHeight: 256,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: const Color.fromRGBO(121, 30, 198, 1),
                      ),
                      child: Text(
                        "Aceptar",
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
        ),
      ),
    );
  }
}
