import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PayStreakDialog extends StatefulWidget {
  const PayStreakDialog({
    super.key,
  });

  @override
  State<PayStreakDialog> createState() => _PayStreakDialogState();
}

class _PayStreakDialogState extends State<PayStreakDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF292D39),
      title: Center(
        child: Text(
          '¡No pierdas tu racha!',
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
            height: 60,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            ' ¡Cuidado! Estás a punto de perder tu racha. Usa 30 gemas ahora y sigue sumando éxitos.',
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
          onPressed: () async {},
          child: const Text("¡Mantener mi racha!"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("No, gracias"),
        ),
      ],
    );
  }
}
