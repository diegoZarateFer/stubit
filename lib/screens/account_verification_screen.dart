import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/screens/home_screen.dart';

class AccountVerificationScreen extends StatefulWidget {
  const AccountVerificationScreen({super.key});

  @override
  State<AccountVerificationScreen> createState() =>
      _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  User? _user;
  bool _isEmailVerified = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _sendVerificationEmail();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        _checkEmailVerification();
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeUser() {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _checkEmailVerification();
    }
  }

  Future<void> _checkEmailVerification() async {
    if (_user != null) {
      await _user?.reload();
      _user = FirebaseAuth.instance.currentUser;
      setState(() {
        _isEmailVerified = _user?.emailVerified ?? false;
      });
      if (_isEmailVerified) {
        _timer?.cancel();
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      await _user?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correo de verificación enviado.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar el correo: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.only(top: 32, left: 32, right: 32),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Stu - Bit',
                    style: GoogleFonts.satisfy(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.asset(
                    'assets/images/stubit_logo.png',
                    height: 60,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _isEmailVerified
                        ? '¡Enhorabuena, tu cuenta ha sido verificada!'
                        : 'Verificación de cuenta',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isEmailVerified
                        ? '¡Ya puedes comenzar a mejorar tus hábitos con Stu - Bit!'
                        : 'Ve a tu correo para verificar tu cuenta y poder comenzar a utilizar la app.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!_isEmailVerified)
                    TextButton(
                      onPressed: _sendVerificationEmail,
                      child: const Text(
                        'No recibí el código. Reenviar.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  if (_isEmailVerified)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (ctx) => const HomeScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        "Comenzar",
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// return WillPopScope(
//       onWillPop: () async {
//         return false;
//       },
//       child: Scaffold(
//         body: Container(
//           width: double.infinity,
//           height: double.infinity,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color.fromRGBO(139, 34, 227, 1),
//                   Colors.black,
//                 ]),
//           ),
//           child: Padding(
//               padding: const EdgeInsets.only(
//                 top: 32,
//                 left: 32,
//                 right: 32,
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Text(
//                       'Stu - Bit',
//                       style: GoogleFonts.satisfy(
//                         textStyle: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 32,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 8,
//                     ),
//                     Image.asset(
//                       'assets/images/stubit_logo.png',
//                       height: 60,
//                     ),
//                     const SizedBox(
//                       height: 16,
//                     ),
//                     Text(
//                       'Verificación de cuenta',
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.poppins(
//                         textStyle: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 28,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 16,
//                     ),
//                     Text(
//                       'Favor de revisar su correo electrónico ahí encontrará el código para verificar su cuenta.',
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.poppins(
//                         textStyle: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 4,
//                     ),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextFormField(
//                             maxLength: 4,
//                             keyboardType: const TextInputType.numberWithOptions(),
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(
//                               color: Colors.white,
//                             ),
//                             decoration: const InputDecoration(
//                               labelText: 'Código de verificación',
//                               counterText: '',
//                             ),
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 4,
//                         ),
//                         const Expanded(
//                           child: const CountDownTimer(
//                             initialTime: 300,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     const SizedBox(
//                       height: 4,
//                     ),
//                     TextButton(
//                       onPressed: () {},
//                       child: const Text(
//                         'No recibí el código. Reenviar.',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white,
//                           decoration: TextDecoration.underline,
//                           decorationColor: Colors.white,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 16,
//                     ),
//                     ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         backgroundColor: Colors.white,
//                       ),
//                       child: const Text(
//                         "Verificar cuenta",
//                         style: TextStyle(
//                           color: Colors.black,
//                           decoration: TextDecoration.underline,
//                           decorationColor: Colors.black,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 4,
//                     ),
//                     const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Expanded(
//                           child: Divider(
//                             color: Colors.white,
//                             thickness: 3,
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 8.0),
//                           child: Text(
//                             'o',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                               fontSize: 22,
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: Divider(
//                             color: Colors.white,
//                             thickness: 3,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 4,
//                     ),
//                     TextButton(
//                       onPressed: () {},
//                       child: const Text(
//                         'Ya tengo una cuenta. Inicar sesión',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white,
//                           decoration: TextDecoration.underline,
//                           decorationColor: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               )),
//         ),
//       ),
//     );
