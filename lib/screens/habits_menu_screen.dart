import 'package:flutter/material.dart';
import 'package:stubit/data/habits.dart';
import 'package:stubit/widgets/habit_category_details.dart';

class HabitsMenuScreen extends StatefulWidget {
  const HabitsMenuScreen({super.key});

  @override
  State<HabitsMenuScreen> createState() => _HabitsMenuScreenState();
}

class _HabitsMenuScreenState extends State<HabitsMenuScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageViewController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  void _handlePageViewChanged(int currentPageIndex) {
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(139, 34, 227, 1),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: Container(
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
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView(
              controller: _pageViewController,
              onPageChanged: _handlePageViewChanged,
              children: [
                HabitCategoryDetails(
                  categoryName: "Hábitos de estudio",
                  description:
                      "Son prácticas o rutinas que ayudan a mejorar la eficiencia y efectividad en el aprendizaje.",
                  habits:
                      habits.where((habit) => habit.category == "c1").toList(),
                  image: const AssetImage("assets/images/study_habits.jpg"),
                ),
                HabitCategoryDetails(
                  categoryName: "Hábitos físicos y de salud",
                  description:
                      "Actividades que una persona adopta para mantener o mejorar su bienestar físico y mental.  Están relacionados con la alimentación, el ejercicio físico, el descanso y la salud mental.",
                  habits:
                      habits.where((habit) => habit.category == "c2").toList(),
                  image: const AssetImage("assets/images/health_habits.png"),
                ),
                HabitCategoryDetails(
                  categoryName: "Hábitos de autocuidado",
                  description:
                      "Actividades que una persona realiza para cuidar su bienestar emocional, físico y mental. Promueven el equilibrio emocional y físico.",
                  habits:
                      habits.where((habit) => habit.category == "c3").toList(),
                  image: const AssetImage("assets/images/selfcare_habits.jpg"),
                ),
                HabitCategoryDetails(
                  categoryName: "Hábitos sociales",
                  description:
                      "Ayudan a una persona a interactuar de manera efectiva y positiva con los demás, fortaleciendo sus relaciones interpersonales.",
                  habits:
                      habits.where((habit) => habit.category == "c4").toList(),
                  image: const AssetImage("assets/images/social_habits.jpg"),
                ),
                HabitCategoryDetails(
                  categoryName: "Hábitos mentales",
                  description:
                      "Patrones de pensamiento que se repiten de manera automática. Influyen en la forma en que percibimos y reaccionamos ante el mundo.",
                  habits:
                      habits.where((habit) => habit.category == "c5").toList(),
                  image: const AssetImage("assets/images/mental_habits.jpg"),
                ),
                const HabitCategoryDetails(
                  categoryName: "Crea un hábito a tu medida",
                  description:
                      "¿No encontraste algún hábito para ti? ¡No hay problema! También puedes integrar rutinas que se ajusten a ti.",
                  habits: [],
                  image: AssetImage("assets/images/custom_habit.jpg"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    ;
  }
}
