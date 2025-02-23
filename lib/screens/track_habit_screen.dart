import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/widgets/calendar.dart';
import 'package:stubit/widgets/image_button.dart';
import 'package:stubit/widgets/user_button.dart';

class TrackHabitScreen extends StatefulWidget {
  const TrackHabitScreen({
    super.key,
  });

  @override
  State<TrackHabitScreen> createState() => _TrackHabitScreenState();
}

class _TrackHabitScreenState extends State<TrackHabitScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 8,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/calendar.png",
                    height: 60,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Lectura",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Calendar(),
                  const SizedBox(height: 16),
                  Container(
                    width: 60,
                    height: 80,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/fire.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "100",
                          style: GoogleFonts.koHo(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
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
