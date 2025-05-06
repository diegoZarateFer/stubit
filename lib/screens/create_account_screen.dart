import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/screens/account_verification_screen.dart';
import 'package:stubit/screens/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stubit/widgets/gender_selector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final _firebase = FirebaseAuth.instance;
FirebaseFirestore _firestore = FirebaseFirestore.instance;

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedGender = "Masculino";

  // Variables
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  // Methods.
  String? _validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      return 'Ingresa tu contraseña.';
    }

    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }

    final upperCharacterExp = RegExp(r'^(?=.*[A-Z])');
    if (!upperCharacterExp.hasMatch(password)) {
      return 'La contraseña debe contener al menos una letra mayúscula';
    }

    final numberExp = RegExp(r'^(?=.*\d)');
    if (!numberExp.hasMatch(password)) {
      return 'La contraseña debe contener al menos un número.';
    }

    return null;
  }

  void _showLoginScreen(context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const AuthScreen(isLogin: true),
      ),
    );
  }

  // Name & last name validator.
  String? _nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tu nombre';
    }

    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Por favor, ingresa un nombre válido';
    }
    return null;
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

  String? _passwordValidator(String? value) {
    return _validatePassword(value);
  }

  String? _confirmPasswordValidator(String? value) {
    String? validity = _validatePassword(value);
    if (validity == null) {
      return _passwordController.text == _confirmPasswordController.text
          ? null
          : 'Las contraseñas no coinciden.';
    }

    return validity;
  }

  String? _dateValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu fecha de nacimiento';
    }

    DateTime selectedDate = DateTime.parse(value);
    DateTime referenceDate = DateTime(2008, 1, 1);

    if (selectedDate.isAfter(referenceDate)) {
      return 'La edad mínima es de 16 años';
    }

    return null;
  }

  // Date Picker.
  Future<void> _selectDate(BuildContext context) async {
    final initialDate = DateTime(2008, 1, 1);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2021),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: const InputDecorationTheme(
              hintStyle: TextStyle(color: Colors.white70),
            ),
            textTheme: const TextTheme(
              titleMedium: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              bodyLarge: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _register() async {
    try {
      // Creating user account.
      UserCredential credential =
          await _firebase.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Saving user account data.
      final user = credential.user;
      if (user != null) {
        final userId = user.uid.toString();

        String? fcmToken = await FirebaseMessaging.instance.getToken();

        await Future.wait([
          _firestore
              .collection("user_data")
              .doc(userId)
              .collection("account")
              .add({
            "name": _nameController.text.toString(),
            "last_name": _lastNameController.text.toString(),
            "gender": _selectedGender,
            "birthday": _dateController.text.toString(),
            "token": fcmToken,
          }),
          _firestore
              .collection("user_data")
              .doc(userId)
              .collection("gems")
              .doc("user_gems")
              .set({
            "collectedGems": 0,
          }),
        ]);
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const AccountVerificationScreen(),
        ),
      );
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      if (error.code == "email-already-in-use") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Esta dirección de correo electrónico ya está en uso. Ingresa a tu cuenta o crea una nueva con una dirección diferente.",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Algo salió mal. Inteta de nuevo más tarde.",
            ),
          ),
        );
      }
    }
  }

  // Save user data.
  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _register();
    }
  }

  @override
  void dispose() {
    //Disposing the controllers.
    _nameController.dispose();
    _lastNameController.dispose();
    _dateController.dispose();
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
                height: 4,
              ),
              Image.asset(
                'assets/images/stubit_logo.png',
                height: 40,
              ),
              const SizedBox(
                height: 8,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Crea tu cuenta',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      maxLength: 30,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Nombre(s)',
                        hintText: 'Ej. Juan Antonio',
                        counterText: '',
                      ),
                      controller: _nameController,
                      validator: _nameValidator,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      maxLength: 30,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: 'Apellidos',
                        hintText: 'Ej. Pérez González',
                      ),
                      controller: _lastNameController,
                      validator: _nameValidator,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GenderSelector(
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      selectedGender: _selectedGender,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Fecha de Nacimiento',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectDate(context);
                      },
                      controller: _dateController,
                      validator: _dateValidator,
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
                      height: 20,
                    ),
                    TextFormField(
                      obscureText: !_showConfirmPassword,
                      maxLength: 30,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: 'Confirmar contraseña',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showConfirmPassword = !_showConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _showConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: _confirmPasswordValidator,
                      controller: _confirmPasswordController,
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
                        "Registrarse",
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    TextButton(
                      onPressed: () {
                        _showLoginScreen(context);
                      },
                      child: const Text(
                        'Ya tengo una cuenta. Iniciar sesión.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
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
    );
  }
}
