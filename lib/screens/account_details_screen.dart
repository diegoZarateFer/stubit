import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/screens/auth_wrapper.dart';
import 'package:stubit/screens/change_password_screen.dart';
import 'package:stubit/screens/delete_account_screen.dart';
import 'package:stubit/screens/edit_account_screen.dart';
import 'package:stubit/widgets/confirmation_dialog.dart';
import 'package:stubit/widgets/gender_selector.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => AccountDetailsScreenState();
}

class AccountDetailsScreenState extends State<AccountDetailsScreen> {
  User? _currentUser;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadAccountData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAccountData() async {
    final querySnapshot = await _firestore
        .collection("user_data")
        .doc(_currentUser!.uid.toString())
        .collection("account")
        .get();

    final loadedData = {
      "name": querySnapshot.docs[0]["name"],
      "lastname": querySnapshot.docs[0]["last_name"],
      "birthday": querySnapshot.docs[0]["birthday"],
      "gender": querySnapshot.docs[0]["gender"],
    };

    setState(() {
      _isLoading = false;
      _userData = loadedData;
    });
  }

  void _logout() async {
    final bool? logout = await showConfirmationDialog(context, "Cerrar Sesión",
        "¿Estás seguro(a) que deseas salir?", "Cerrar Sesión", "Cancelar");
    if (logout ?? false) {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: ((ctx) => AuthWrapper()),
        ),
      );
    }
  }

  void _showChangePasswordScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const ChangePasswordScreen(),
      ),
    );
  }

  void _showDeleteAccountScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const DeleteAccountScreen(),
      ),
    );
  }

  void _showEditAccountDataScreen() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (ctx) => const EditAccountScreen(),
      ),
    )
        .then((value) {
      _loadAccountData();
    });
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
        actions: [
          IconButton(
            onPressed: _showEditAccountDataScreen,
            icon: const Icon(
              Icons.edit,
            ),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
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
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "¡Hola, ${_userData!["name"]}!",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          TextFormField(
                            maxLength: 35,
                            initialValue: _userData!["lastname"],
                            readOnly: true,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              counterText: '',
                              labelText: 'Apellidos',
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            initialValue: _userData!["birthday"],
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Fecha de Nacimiento',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          GenderSelector(
                            selectedGender: _userData!["gender"],
                            readOnly: true,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            maxLength: 50,
                            initialValue: _currentUser!.email,
                            readOnly: true,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Correo Electrónico',
                              hintText: 'Ej. alguien@ejemplo.com',
                              counterText: '',
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          ElevatedButton(
                            onPressed: _showChangePasswordScreen,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor:
                                  const Color.fromRGBO(121, 30, 198, 1),
                            ),
                            child: Text(
                              "Cambiar Contraseña",
                              style: GoogleFonts.openSans(
                                color: Colors.white,
                                decorationColor: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.white,
                                  thickness: 3,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  'o',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.white,
                                  thickness: 3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          ElevatedButton(
                            onPressed: _showDeleteAccountScreen,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: Text(
                              "Borrar cuenta",
                              style: GoogleFonts.openSans(
                                color: Colors.red,
                                decorationColor: Colors.red,
                                decoration: TextDecoration.underline,
                                fontSize: 18,
                              ),
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
