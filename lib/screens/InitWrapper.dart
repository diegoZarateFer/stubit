import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stubit/screens/auth_wrapper.dart';
import 'package:stubit/screens/welcome.dart';

class InitWrapper extends StatelessWidget {
  const InitWrapper({super.key});

  Future<bool> checkIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;
    return !hasSeenWelcome;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkIfFirstTime(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const ConcentricAnimationOnboarding(); // <== Asegúrate de usar esta clase
        } else {
          return const AuthWrapper();
        }
      },
    );
  }
}
