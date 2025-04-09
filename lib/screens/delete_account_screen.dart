import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/screens/auth_wrapper.dart';
import 'package:stubit/widgets/confirmation_dialog.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _currentUser = FirebaseAuth.instance.currentUser!;

  //Form Key.
  final _formKey = GlobalKey<FormState>();

  // Variables
  bool _showPassword = false;

  final TextEditingController _passwordController = TextEditingController();

  String? _validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      return 'Ingresa tu contraseña.';
    }

    String message = "Contraseña incorrecta.";
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

  Future<void> _deleteHabit(habitId) async {
    CollectionReference logRef = _firestore
        .collection("user_data")
        .doc(_currentUser.uid.toString())
        .collection("habits")
        .doc(habitId)
        .collection("habit_log");

    var snapshot = await logRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    await _firestore
        .collection("user_data")
        .doc(_currentUser.uid.toString())
        .collection("habits")
        .doc(habitId)
        .delete();
  }

  Future<void> _deleteAccount() async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: _currentUser.email.toString(),
        password: _passwordController.text,
      );

      // Delete all user information.
      await _currentUser.reauthenticateWithCredential(credential);

      // Delete account data.
      QuerySnapshot accountDocs = await _firestore
          .collection("user_data")
          .doc(_currentUser.uid.toString())
          .collection("account")
          .get();

      accountDocs.docs[0].reference.delete();

      // Delete gems data
      QuerySnapshot gemsDoc = await _firestore
          .collection("user_data")
          .doc(_currentUser.uid.toString())
          .collection("gems")
          .get();

      if (gemsDoc.size > 0) {
        gemsDoc.docs[0].reference.delete();
      }

      // Delete tasks data.
      QuerySnapshot taskDocs = await _firestore
          .collection("user_data")
          .doc(_currentUser.uid.toString())
          .collection("tasks")
          .get();

      for (final taskDoc in taskDocs.docs) {
        final taskId = taskDoc.id;
        await _firestore
            .collection("user_data")
            .doc(_currentUser.uid.toString())
            .collection("tasks")
            .doc(taskId)
            .delete();
      }

      // Delete habits
      final habitsSnapshot = await _firestore
          .collection("user_data")
          .doc(_currentUser.uid.toString())
          .collection("habits")
          .get();

      for (final habitDoc in habitsSnapshot.docs) {
        final habitId = habitDoc.id;
        await _deleteHabit(habitId);
      }

      // Delete user document.
      await _firestore
          .collection("user_data")
          .doc(_currentUser.uid.toString())
          .delete();

      await _currentUser.delete();

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tu cuenta ha sido eliminada correctamente."),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => AuthWrapper(),
        ),
      );
    } on FirebaseAuthException catch (error) {
      String errorMessage =
          "Lo sentimos. No hemos podido eliminar tu cuenta debido a un error inesperado. Intentalo más tarde.";
      if (error.code == "invalid-credential") {
        errorMessage =
            "La contraseña es incorrecta. Por favor, inténtalo de nuevo.";
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final bool? deleteAccount = await showConfirmationDialog(
        context,
        "Eliminar mi cuenta",
        "¿Estás seguro(a) de que deseas eliminar tu cuenta? Esta acción es irreversible y perderás todos tus datos.",
        "Si, eliminar mi cuenta",
        "Cancelar",
      );

      if (deleteAccount ?? false) {
        await _deleteAccount();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
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
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      "Eliminar mi cuenta",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Icon(
                      Icons.delete_forever,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      "¿Segur@ que deseas borrar tu cuenta?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Todos tus datos serán eliminados de forma permanente. Esta acción no puede deshacerse.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    Text(
                      "Ingresa tu contraseña para confirmar la eliminación de tu cuenta.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
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
                      validator: _validatePassword,
                      controller: _passwordController,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ElevatedButton.icon(
                      onPressed: _saveForm,
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Aceptar",
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
                        backgroundColor: const Color.fromRGBO(121, 30, 198, 1),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
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
