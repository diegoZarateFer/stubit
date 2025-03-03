import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/screens/create_habits_screens/create_CF_habit_screen.dart';
import 'package:stubit/screens/create_habits_screens/create_COF_habit_screen.dart';
import 'package:stubit/screens/create_habits_screens/create_FT_habit_screen.dart';
import 'package:stubit/screens/create_habits_screens/create_L_habit_screen.dart';
import 'package:stubit/screens/create_habits_screens/create_TP_habit_screen.dart';
import 'package:stubit/screens/create_habits_screens/create_T_habit_screen.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class CreateCustomHabit extends StatelessWidget {
  const CreateCustomHabit({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.only(top: 64),
              child: Column(
                children: [
                  Text(
                    "Selecciona una técnica",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _images.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () async {
                            final habitWasCreated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => SecondPage(
                                      heroTag: index,
                                    ),
                                  ),
                                ) ??
                                false;

                            if (habitWasCreated) {
                              Navigator.pop(context, true);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Hero(
                                  tag: index,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      _images[index],
                                      width: 200,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _titles[index],
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

class SecondPage extends StatefulWidget {
  final int heroTag;

  const SecondPage({
    super.key,
    required this.heroTag,
  });

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final TextEditingController _activityController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _loadCreatingHabitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String habitStrategy = "TP";
      if (widget.heroTag == 1) {
        habitStrategy = "TF";
      } else if (widget.heroTag == 2) {
        habitStrategy = "T";
      } else if (widget.heroTag == 3) {
        habitStrategy = "CF";
      } else if (widget.heroTag == 4) {
        habitStrategy = "L";
      } else if (widget.heroTag == 5) {
        habitStrategy = "COF";
      }

      Habit customHabit = Habit(
        id: _uuid.v4(),
        name: _activityController.text.toString(),
        description: "",
        category: "custom",
        strategy: habitStrategy,
      );

      bool habitWasCreated = false;
      if (habitStrategy == "TP") {
        habitWasCreated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => CreateTpHabitScreen(
                  habit: customHabit,
                ),
              ),
            ) ??
            false;
      } else if (habitStrategy == "TF") {
        habitWasCreated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => CreateFtHabitScreen(
                  habit: customHabit,
                ),
              ),
            ) ??
            false;
      } else if (habitStrategy == "T") {
        habitWasCreated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => CreateTHabitScreen(
                  habit: customHabit,
                ),
              ),
            ) ??
            false;
      } else if (habitStrategy == "L") {
        habitWasCreated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => CreateLHabitScreen(
                  habit: customHabit,
                ),
              ),
            ) ??
            false;
      } else if (habitStrategy == "CF") {
        habitWasCreated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => CreateCfHabitScreen(
                  habit: customHabit,
                ),
              ),
            ) ??
            false;
      } else if (habitStrategy == "COF") {
        habitWasCreated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => CreateCofHabitScreen(
                  habit: customHabit,
                ),
              ),
            ) ??
            false;
      }

      if (habitWasCreated) {
        Navigator.pop(context, habitWasCreated);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Hero(
                  tag: widget.heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      _images[widget.heroTag],
                      width: 250,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _titles[widget.heroTag],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    _resume[widget.heroTag],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLength: 30,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la actividad',
                        counterText: '',
                      ),
                      controller: _activityController,
                      validator: (value) {
                        if (value == null || value.trim().length < 3) {
                          return 'El nombre debe contener al menos 3 caracteres.';
                        }

                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: _loadCreatingHabitForm,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: const Color.fromRGBO(121, 30, 198, 1),
                  ),
                  child: Text(
                    "Crear",
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
      ),
    );
  }
}

final List<String> _images = [
  'assets/images/Tec_POM.png',
  'assets/images/Tec_CyF.png',
  'assets/images/Tec_FyC.png',
  'assets/images/Tec_FyL.png',
  'assets/images/Tec_T.png',
  'assets/images/Tec_TyF.png'
];

final List<String> _titles = [
  'Técnica Pomodoro',
  'Tiempo y frecuencia',
  'Tiempo',
  'Cuestionario y frecuencia',
  'Frecuencia y lista',
  'Frecuencia y cuantitativo',
];

final List<String> _resume = [
  'La Técnica Pomodoro ayuda a mejorar la productividad dividiendo el trabajo en intervalos de trabajo con descansos cortos.',
  'Esta técnica es recomendada para definir tiempo y días específicos.',
  'Se enfoca en actividades que deben realizarse sí o sí.',
  'Define los días de práctica con cuestionarios.',
  'Lista actividades diarias obligatorias.',
  'Cuenta repeticiones diarias.',
];
