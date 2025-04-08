import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GemsInfoDialog extends StatelessWidget {
  final int gems;

  const GemsInfoDialog({super.key, required this.gems});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF292D39),
      title: Center(
        child: Text(
          'Tus gemas',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/book.png',
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 10),
          Text(
            '$gems Gemas',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 7, 218, 255),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Las gemas te permiten recuperar las rachas que has perdido. ¡Puedes conseguirlas completando hábitos!',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cerrar",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
