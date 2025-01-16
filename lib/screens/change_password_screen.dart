import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  User? _currentUser;
  final _formKey = GlobalKey<FormState>();

  bool _hasChangedPassword = false;

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showNewConfirmationPassword = false;

  // Controllers
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newPasswordConfirmationController =
      TextEditingController();

  // Validators
  String? _validatePassword(String? currentPassword) {
    String errorMessage = "Contraseña incorrecta";
    if (currentPassword == null || currentPassword.trim().isEmpty) {
      return "Ingresa tu contaseña.";
    }

    if (currentPassword.length < 8) {
      return errorMessage;
    }

    final upperCharacterExp = RegExp(r'^(?=.*[A-Z])');
    if (!upperCharacterExp.hasMatch(currentPassword)) {
      return errorMessage;
    }

    final numberExp = RegExp(r'^(?=.*\d)');
    if (!numberExp.hasMatch(currentPassword)) {
      return errorMessage;
    }

    return null;
  }

  String? _validateNewPassword(String? newPassword) {
    if (newPassword == null || newPassword.trim().isEmpty) {
      return 'Ingresa la nueva contraseña.';
    }

    if (newPassword.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }

    final upperCharacterExp = RegExp(r'^(?=.*[A-Z])');
    if (!upperCharacterExp.hasMatch(newPassword)) {
      return 'La contraseña debe contener al menos una letra mayúscula';
    }

    final numberExp = RegExp(r'^(?=.*\d)');
    if (!numberExp.hasMatch(newPassword)) {
      return 'La contraseña debe contener al menos un número.';
    }

    return null;
  }

  String? _confirmNewPasswordValidator(String? value) {
    String? validity = _validateNewPassword(value);
    if (validity == null) {
      return _newPasswordController.text ==
              _newPasswordConfirmationController.text
          ? null
          : 'Las contraseñas no coinciden.';
    }

    return validity;
  }

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _newPasswordConfirmationController.dispose();
  }

  void _closeScreen() {
    Navigator.of(context).pop();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _updatePassword();
    }
  }

  Future<void> _updatePassword() async {
    try {
      final enteredPassword = _passwordController.text.toString();
      final credential = EmailAuthProvider.credential(
        email: _currentUser!.email.toString(),
        password: enteredPassword,
      );

      await _currentUser!.reauthenticateWithCredential(credential);

      final enteredNewPassword = _newPasswordController.text.toString();
      await _currentUser!.updatePassword(enteredNewPassword);
      setState(() {
        _hasChangedPassword = true;
      });
    } catch (error) {
      if (error is FirebaseAuthException) {
        ScaffoldMessenger.of(context).clearSnackBars();
        switch (error.code) {
          case "invalid-credential":
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    "La contraseña es incorrecta. Por favor, inténtalo de nuevo."),
                duration: Duration(seconds: 3),
              ),
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    "Ha ocurrido un error inesperado. Por favor, inténtalo más tarde."),
                duration: Duration(seconds: 3),
              ),
            );
            break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: _closeScreen,
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _hasChangedPassword
                      ? [
                          Text(
                            "Cambiar contraseña",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          Image.asset(
                            'assets/images/change_password.png',
                            height: 80,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            "¡Contraseña reestablecida exitosamente!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          ElevatedButton.icon(
                            onPressed: _closeScreen,
                            icon: const Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                            label: Text(
                              "Listo",
                              style: GoogleFonts.openSans(
                                color: Colors.white,
                                decorationColor: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor:
                                  const Color.fromRGBO(121, 30, 198, 1),
                            ),
                          ),
                        ]
                      : [
                          Text(
                            "Cambiar contraseña",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Image.asset(
                            'assets/images/change_password.png',
                            height: 80,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            obscureText: !_showCurrentPassword,
                            maxLength: 30,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              labelText: 'Contraseña actual',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showCurrentPassword =
                                        !_showCurrentPassword;
                                  });
                                },
                                icon: Icon(
                                  _showCurrentPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                            validator: _validatePassword,
                            controller: _passwordController,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            obscureText: !_showNewPassword,
                            maxLength: 30,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              labelText: 'Nueva contraseña',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showNewPassword = !_showNewPassword;
                                  });
                                },
                                icon: Icon(
                                  _showNewPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                            validator: _validateNewPassword,
                            controller: _newPasswordController,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            obscureText: !_showNewConfirmationPassword,
                            maxLength: 30,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              labelText: 'Confirmar la nueva contraseña',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showNewConfirmationPassword =
                                        !_showNewConfirmationPassword;
                                  });
                                },
                                icon: Icon(
                                  _showNewConfirmationPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                            validator: _confirmNewPasswordValidator,
                            controller: _newPasswordConfirmationController,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          ElevatedButton.icon(
                            onPressed: _saveForm,
                            icon: const Icon(
                              Icons.save,
                              color: Colors.white,
                            ),
                            label: Text(
                              "Guardar",
                              style: GoogleFonts.openSans(
                                color: Colors.white,
                                decorationColor: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor:
                                  const Color.fromRGBO(121, 30, 198, 1),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          ElevatedButton.icon(
                            onPressed: _closeScreen,
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                            label: Text(
                              "Cancelar",
                              style: GoogleFonts.openSans(
                                color: Colors.red,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.red,
                                fontSize: 18,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
