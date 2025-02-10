import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:day_picker/day_picker.dart';

final List<DayInWeek> _days = [
  DayInWeek("D", dayKey: "monday"),
  DayInWeek("L", dayKey: "tuesday"),
  DayInWeek("M", dayKey: "wednesday"),
  DayInWeek("M", dayKey: "thursday"),
  DayInWeek("J", dayKey: "friday"),
  DayInWeek("V", dayKey: "saturday"),
  DayInWeek("S", dayKey: "sunday"),
];

final List<String> _options = [
  "3 semanas",
  "4 semanas",
  "5 semanas",
  "6 semanas",
  "7 semanas",
  "9 semanas",
  "10 semanas",
  "Indefinidamente"
];

class EditHabitLScreen extends StatefulWidget {
  const EditHabitLScreen({super.key});

  @override
  State<EditHabitLScreen> createState() => _EditHabi();
}

class _EditHabi extends State<EditHabitLScreen> {
  final _formKey = GlobalKey<FormState>();

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
                      "MODIFICAR HÁBITO",
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
                      "Hacer una lista de cosas por las que me siento agradecido.",
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
                      "Ingresa la duración del hábito",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    DropdownButtonFormField(
                      dropdownColor: Colors.black,
                      items: _options.map((option) {
                        return DropdownMenuItem(
                          value: option,
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
                      onChanged: (priority) {},
                      decoration: const InputDecoration(
                        labelText: 'Duración del hábito.',
                      ),
                      menuMaxHeight: 256,
                    ),
                    const SizedBox(
                      height: 32,
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
                      onSelect: (value) {},
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: const Color.fromRGBO(121, 30, 198, 1),
                      ),
                      child: Text(
                        "Guardar",
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
