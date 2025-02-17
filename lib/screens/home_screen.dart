import 'package:flutter/material.dart';
import 'package:stubit/screens/board_screen.dart';
import 'package:stubit/screens/create_task_screen.dart';
import 'package:stubit/screens/habits_menu_screen.dart';
import 'package:stubit/screens/habits_screen.dart';
import 'package:stubit/widgets/bottom_navigator.dart';
import 'package:stubit/widgets/image_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/widgets/user_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFloatingButtonPressed() {
    int currentTabIndex = _tabController.index;
    if (currentTabIndex == 0) {
      // Add a new habit
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const HabitsMenuScreen(),
        ),
      );
    } else {
      // Add a new task to the board.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const CreateTaskScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromRGBO(139, 34, 227, 1),
            actions: [
              ImageButton(
                imagePath: "assets/images/book.png",
                onPressed: () {},
              ),
              Text(
                '0',
                style: GoogleFonts.dmSans(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Stu - Bit',
                style: GoogleFonts.satisfy(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                  ),
                ),
              ),
              const Spacer(),
              const UserButton(),
            ],
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
            child: TabBarView(
              controller: _tabController,
              children: const [
                HabitsScreen(),
                BoardScreen(),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _onFloatingButtonPressed,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            child: const Icon(
              Icons.add,
              size: 40,
            ),
          ),
          bottomNavigationBar: BottomNavigator(
            tabController: _tabController,
          ),
        ),
      ),
    );
  }
}
