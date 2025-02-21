import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/screens/create_habits_screens/create_CF_habit_screen.dart';
import 'package:stubit/screens/create_habits_screens/create_COF_habit_screen.dart';
import 'package:stubit/screens/create_habits_screens/create_FT_habit_screen.dart';
import 'package:stubit/screens/create_habits_screens/create_L_habit_screen.dart';
import 'package:stubit/screens/create_habits_screens/create_T_habit_screen.dart';

class HabitCategoryDetails extends StatefulWidget {
  const HabitCategoryDetails({
    super.key,
    required this.categoryName,
    required this.description,
    required this.habits,
    required this.image,
    required this.onHabitCreated,
  });

  final String categoryName;
  final String description;
  final List<Habit> habits;
  final AssetImage image;
  final void Function() onHabitCreated;

  @override
  State<HabitCategoryDetails> createState() => _HabitCategoryDetailsState();
}

class _HabitCategoryDetailsState extends State<HabitCategoryDetails> {
  Habit? _selectedHabit;

  void _loadCreatingHabitForm() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (_selectedHabit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Te falta seleccionar algún hábito.'),
        ),
      );
      return;
    }

    final habitStrategy = _selectedHabit!.strategy;
    bool habitWasCreated = false;

    if (habitStrategy == "TF") {
      habitWasCreated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => CreateFtHabitScreen(
                habit: _selectedHabit!,
              ),
            ),
          ) ??
          false;
    } else if (habitStrategy == "T") {
      habitWasCreated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => CreateTHabitScreen(
                habit: _selectedHabit!,
              ),
            ),
          ) ??
          false;
    } else if (habitStrategy == "CF") {
      habitWasCreated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => CreateCfHabitScreen(
                habit: _selectedHabit!,
              ),
            ),
          ) ??
          false;
    } else if (habitStrategy == "L") {
      habitWasCreated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => CreateLHabitScreen(
                habit: _selectedHabit!,
              ),
            ),
          ) ??
          false;
    } else if (habitStrategy == "COF") {
      habitWasCreated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => CreateCofHabitScreen(
                habit: _selectedHabit!,
              ),
            ),
          ) ??
          false;
    } else if (habitStrategy == "TP") {}

    if (habitWasCreated) {
      widget.onHabitCreated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "¿Qué tipo de hábito te gustaría desarrollar?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              Container(
                width: 280,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(5, 5),
                    ),
                  ],
                  image: DecorationImage(
                    image: widget.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              Text(
                widget.categoryName,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              if (widget.habits.isNotEmpty)
                DropdownButtonFormField(
                  dropdownColor: Colors.black,
                  items: widget.habits.map((habit) {
                    return DropdownMenuItem(
                      value: habit,
                      child: Text(
                        habit.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _selectedHabit = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Selecciona un hábito',
                  ),
                ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () {
                  _loadCreatingHabitForm();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color.fromRGBO(121, 30, 198, 1),
                ),
                child: Text(
                  "Continuar",
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    decorationColor: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
