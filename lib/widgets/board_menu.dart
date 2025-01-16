import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const double btnWidth = 115.0;

class BoardMenu extends StatelessWidget {
  const BoardMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          height: 50,
          color: Colors.black,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            onPressed: () {},
            child: SizedBox(
              width: btnWidth,
              child: Center(
                child: Text(
                  "Añadir actividad",
                  style: GoogleFonts.openSans(
                    color: Colors.black,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
