import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:day_picker/day_picker.dart';
import 'package:stubit/models/habit.dart';

Map<String, num> _numberOfWeeksOptions = {
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

class CreateLHabitScreen extends StatefulWidget {
  const CreateLHabitScreen({
    super.key,
    required this.habit,
  });

  final Habit habit;

  @override
  State<CreateLHabitScreen> createState() => _CreateLHabitScreenState();
}

class _CreateLHabitScreenState extends State<CreateLHabitScreen> {
  final List<DayInWeek> _days = [
    DayInWeek("D", dayKey: "monday"),
    DayInWeek("L", dayKey: "tuesday"),
    DayInWeek("M", dayKey: "wednesday"),
    DayInWeek("M", dayKey: "thursday"),
    DayInWeek("J", dayKey: "friday"),
    DayInWeek("V", dayKey: "saturday"),
    DayInWeek("S", dayKey: "sunday"),
  ];

  User? _currentUser;
  final _formKey = GlobalKey<FormState>();

  List<String> _selectedDaysOfWeek = [];

  num? _selectedNumberOfWeeks;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  String? _habitDurationValidator(selectedDuration) {
    if (selectedDuration == null) {
      return "Campo obligatorio.";
    }

    return null;
  }

  void _saveForm() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedNumberOfWeeks == double.infinity &&
          _selectedDaysOfWeek.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Selecciona los días a la semana que dedicarás a esta actividad.'),
          ),
        );
        return;
      }

      if (_selectedNumberOfWeeks! * _selectedDaysOfWeek.length < 21) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'En total debes dedicar al menos 21 días a esta actividad.'),
          ),
        );
        return;
      }

      try {
        // Saving habit information.
        await FirebaseFirestore.instance
            .collection("user_data")
            .doc(_currentUser!.uid.toString())
            .collection("habits")
            .doc(widget.habit.id)
            .set({
          "days": _selectedDaysOfWeek,
          "numberOfWeeks": _selectedNumberOfWeeks,
          "name": widget.habit.name,
          "strategy": widget.habit.strategy,
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
            content:
                Text('Ha ocurrido un error inesperado. Intentalo más tarde.'),
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
                    DropdownButtonFormField(
                      validator: _habitDurationValidator,
                      dropdownColor: Colors.black,
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
                    Text(
                      "¿Que días quieres realizar el hábito?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    SelectWeekDays(
                      fontSize: 16,
                      onSelect: (value) {
                        _selectedDaysOfWeek = value;
                      },
                      days: _days,
                      unselectedDaysFillColor: const Color(0xFFA6A6A6),
                      unselectedDaysBorderColor: Colors.black,
                      selectedDaysFillColor: const Color(0xFFA557E8),
                      selectedDaysBorderColor: Colors.black,
                      selectedDayTextColor: Colors.white,
                      unSelectedDayTextColor: Colors.white,
                      borderWidth: 4,
                      backgroundColor: Colors.transparent,
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
