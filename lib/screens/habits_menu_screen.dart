import 'package:flutter/material.dart';
import 'package:stubit/widgets/image_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/widgets/user_button.dart';

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
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView(
                  controller: _pageViewController,
                  onPageChanged: _handlePageViewChanged,
                  children: [
                    Center(child: Text("Página 1"),),
                    Center(child: Text("Página 2"),),
                    Center(child: Text("Página 3"),),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
