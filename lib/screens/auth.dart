import 'package:flutter/material.dart';
import 'package:stubit/screens/create_account_screen.dart';
import 'package:stubit/screens/login_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.isLogin,
  });

  final bool isLogin;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(139, 34, 227, 1),
                Colors.black,
              ]),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 32,
            left: 32,
            right: 32,
          ),
          child: widget.isLogin
              ? const LoginScreen()
              : const CreateAccountScreen(),
        ),
      ),
    );
  }
}
