import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/screens/auth.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void showAuthScreen(context, isLogin) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AuthScreen(
          isLogin: isLogin,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Stu - Bit',
                  style: GoogleFonts.satisfy(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Image.asset(
                  'assets/images/stubit_logo.png',
                  height: 80,
                ),
                const SizedBox(
                  height: 64,
                ),
                ElevatedButton(
                  onPressed: () {
                    showAuthScreen(context, false);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: const Color.fromRGBO(121, 30, 198, 1),
                  ),
                  child: const Text(
                    "Crear Cuenta",
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  onPressed: () {
                    showAuthScreen(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    "Iniciar Sesión",
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
