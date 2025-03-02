import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/screens/create_habits_screens/create_custom_habit.dart';

class CustomHabitDetails extends StatefulWidget {
  const CustomHabitDetails({
    super.key,
    required this.categoryName,
    required this.description,
    required this.image,
    required this.onHabitCreated,
  });

  final String categoryName;
  final String description;
  final AssetImage image;
  final void Function() onHabitCreated;

  @override
  State<CustomHabitDetails> createState() => _CustomHabitDetailsState();
}

class _CustomHabitDetailsState extends State<CustomHabitDetails> {
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
              ElevatedButton(
                onPressed: () async {
                  final habitWasCreated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const CreateCustomHabit(),
                        ),
                      ) ??
                      false;

                  if (habitWasCreated) {
                    widget.onHabitCreated();
                  }
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
