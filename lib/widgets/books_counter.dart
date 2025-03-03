import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/widgets/image_button.dart';

class BooksCounter extends StatelessWidget {
  const BooksCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ImageButton(
          imagePath: "assets/images/book.png",
          onPressed: () {},
        ),
        Text(
          '100',
          style: GoogleFonts.dmSans(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}
