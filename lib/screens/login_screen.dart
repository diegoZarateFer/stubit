import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/screens/account_verification_screen.dart';
import 'package:stubit/screens/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stubit/screens/home_screen.dart';
import 'package:stubit/screens/ForgotPasswordScreen.dart';

final _firebase = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variables
  bool _showPassword = false;

  // Methods
  void _showRegisterScreen(context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const AuthScreen(
          isLogin: false,
        ),
      ),
    );
  }

  // Email validator.
  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tu correo.';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, ingresa un correo válido';
    }
    return null;
  }

  String? _passwordValidator(String? password) {
    if (password == null || password.trim().isEmpty) {
      return 'Ingresa tu contraseña.';
    }

    String message = "Revisa la contraseña ingresada.";
    if (password.length < 8) {
      return message;
    }

    final upperCharacterExp = RegExp(r'^(?=.*[A-Z])');
    if (!upperCharacterExp.hasMatch(password)) {
      return message;
    }

    final numberExp = RegExp(r'^(?=.*\d)');
    if (!numberExp.hasMatch(password)) {
      return message;
    }

    return null;
  }

  Future<void> _loginUser() async {
    try {
      final userCredentials = await _firebase.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final user = userCredentials.user;
      if (user != null) {
        if (user.emailVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Revisa tu correo electrónico para completar la verificación de tu cuenta.'),
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AccountVerificationScreen(),
            ),
          );
        }
      }

      if (!user!.emailVerified) {}
    } on FirebaseAuthException catch (error) {
      String errorMessage =
          "Algo salió mal. Por favor, intentalo de nuevo más tarde.";
      if (error.code == "invalid-credential") {
        errorMessage =
            "Correo electrónico o contraseña incorrectos. Por favor, inténtalo de nuevo.";
      } else if (error.code == "wrong-password") {
        errorMessage = "La contraseña proporcionada es incorrecta.";
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(
            seconds: 3,
          ),
        ),
      );
    }
  }

  // Save user data.
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _loginUser();
    }
  }

  @override
  void dispose() {
    //Disposing the controllers.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Stu - Bit',
                  style: GoogleFonts.satisfy(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Image.asset(
                  'assets/images/stubit_logo.png',
                  height: 60,
                ),
                const SizedBox(
                  height: 16,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Iniciar Sesión',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      TextButton(
                        onPressed: () {
                          _showRegisterScreen(context);
                        },
                        child: const Text(
                          '¿No tienes cuenta registrada? Registrate aquí.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 50,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico',
                          hintText: 'Ej. alguien@ejemplo.com',
                          counterText: '',
                        ),
                        validator: _emailValidator,
                        controller: _emailController,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        obscureText: !_showPassword,
                        maxLength: 30,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          labelText: 'Contraseña',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: _passwordValidator,
                        controller: _passwordController,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          '¿Necesitas ayuda? Olvidé mi contraseña',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: _saveForm,
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
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
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
    );
  }
}
