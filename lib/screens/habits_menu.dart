import 'package:flutter/material.dart';
import 'package:stubit/data/habits.dart';
import 'package:stubit/widgets/custom_habit_details.dart';
import 'package:stubit/widgets/habit_category_details.dart';

class HabitsMenuScreen extends StatefulWidget {
  const HabitsMenuScreen({super.key});

  @override
  State<HabitsMenuScreen> createState() => _HabitsMenuScreenState();
}

class _HabitsMenuScreenState extends State<HabitsMenuScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;

    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _closeMenu() {
    print("Hola");
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  onHabitCreated: _closeMenu,
                ),
                HabitCategoryDetails(
                  categoryName: "Hábitos físicos y de salud",
                  description:
                      "Actividades que una persona adopta para mantener o mejorar su bienestar físico y mental.  Están relacionados con la alimentación, el ejercicio físico, el descanso y la salud mental.",
                  habits:
                      habits.where((habit) => habit.category == "c2").toList(),
                  image: const AssetImage("assets/images/health_habits.png"),
                  onHabitCreated: _closeMenu,
                ),
                HabitCategoryDetails(
                  categoryName: "Hábitos de autocuidado",
                  description:
                      "Actividades que una persona realiza para cuidar su bienestar emocional, físico y mental. Promueven el equilibrio emocional y físico.",
                  habits:
                      habits.where((habit) => habit.category == "c3").toList(),
                  image: const AssetImage("assets/images/selfcare_habits.jpg"),
                  onHabitCreated: _closeMenu,
                ),
                HabitCategoryDetails(
                  categoryName: "Hábitos sociales",
                  description:
                      "Ayudan a una persona a interactuar de manera efectiva y positiva con los demás, fortaleciendo sus relaciones interpersonales.",
                  habits:
                      habits.where((habit) => habit.category == "c4").toList(),
                  image: const AssetImage("assets/images/social_habits.jpg"),
                  onHabitCreated: _closeMenu,
                ),
                HabitCategoryDetails(
                  categoryName: "Hábitos mentales",
                  description:
                      "Patrones de pensamiento que se repiten de manera automática. Influyen en la forma en que percibimos y reaccionamos ante el mundo.",
                  habits:
                      habits.where((habit) => habit.category == "c5").toList(),
                  image: const AssetImage("assets/images/mental_habits.jpg"),
                  onHabitCreated: _closeMenu,
                ),
                CustomHabitDetails(
                  categoryName: "Crea un hábito a tu medida",
                  description:
                      "¿No encontraste algún hábito para ti? ¡No hay problema! También puedes integrar rutinas que se ajusten a ti.",
                  image: const AssetImage("assets/images/custom_habit.jpg"),
                  onHabitCreated: _closeMenu,
                ),
              ],
            ),
            PageIndicator(
              currentPageIndex: _currentPageIndex,
              tabController: _tabController,
              onUpdateCurrentPageIndex: _updateCurrentPageIndex,
            ),
          ],
        ),
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.currentPageIndex,
    required this.tabController,
    required this.onUpdateCurrentPageIndex,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            splashRadius: 16,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 0) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex - 1);
            },
            icon: const Icon(
              Icons.arrow_left_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          TabPageSelector(
            controller: tabController,
          ),
          IconButton(
            splashRadius: 16,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 5) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex + 1);
            },
            icon: const Icon(
              Icons.arrow_right_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
