import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stubit/screens/board_screen.dart';
import 'package:stubit/screens/create_task_screen.dart';
import 'package:stubit/screens/habits_menu.dart';
import 'package:stubit/screens/habits_screen.dart';
import 'package:stubit/widgets/books_counter.dart';
import 'package:stubit/widgets/bottom_navigator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/widgets/user_button.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _currentUser = FirebaseAuth.instance.currentUser!;
  bool _isLoading = true;
  late int _numberOfActiveHabits;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadActiveHabits();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadActiveHabits() async {
    final userId = _currentUser.uid.toString();
    final querySnapshot = await _firestore
        .collection("user_data")
        .doc(userId)
        .collection("habits")
        .get();

    setState(() {
      _isLoading = false;
      _numberOfActiveHabits = querySnapshot.docs.length;
    });
  }

  void _onFloatingButtonPressed() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    int currentTabIndex = _tabController.index;
    if (currentTabIndex == 0) {
      // Add a new habit
      if (_numberOfActiveHabits == 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "¡Solamente puedes tener 5 hábitos activos a la vez!",
            ),
          ),
        );
        return;
      }
      bool habitWasCreated = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const HabitsMenuScreen(),
        ),
      );

      if (habitWasCreated) {
        _numberOfActiveHabits++;
      }
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
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color.fromRGBO(139, 34, 227, 1),
                  actions: [
                    const BooksCounter(),
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
                    children: [
                      HabitsScreen(
                        onHabitDelete: () {
                          _numberOfActiveHabits--;
                        },
                      ),
                      const BoardScreen(),
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
