import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Apology extends StatelessWidget {
  const Apology({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Spacer(),
          Text(
            'Algo salió mal :(',
            style: GoogleFonts.poppins(
              fontSize: 31,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(30),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
