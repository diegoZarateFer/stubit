import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/screens/account_details_screen.dart';
import 'package:stubit/screens/auth_wrapper.dart';
import 'package:stubit/screens/faq_screen.dart';
import 'package:stubit/widgets/confirmation_dialog.dart';

const double btnWidth = 115.0;

class UserMenu extends StatefulWidget {
  const UserMenu({super.key});

  @override
  State<UserMenu> createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  // ✅ Función para limpiar el campo "token"
  Future<void> _removeUserToken() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await FirebaseMessaging.instance.getToken();

    if (user == null || token == null) return;

    try {
      final accountCollection = await FirebaseFirestore.instance
          .collection("user_data")
          .doc(user.uid)
          .collection("account")
          .get();

      for (var doc in accountCollection.docs) {
        final data = doc.data();
        if (data.containsKey("token") && data["token"] == token) {
          await doc.reference.update({"token": ""}); // 🧹 Vacía el campo
          print("✅ Token limpiado correctamente");
          break;
        }
      }
    } catch (e) {
      print("❌ Error al limpiar el token: $e");
    }
  }

  // ✅ Cierre de sesión con limpieza de token
  void _logout() async {
    final bool? logout = await showConfirmationDialog(
      context,
      "Cerrar Sesión",
      "¿Estás seguro(a) que deseas salir?",
      "Cerrar Sesión",
      "Cancelar",
    );

    if (logout ?? false) {
      await _removeUserToken(); // 👈 Primero limpiar el token
      await FirebaseAuth.instance.signOut(); // Luego cerrar sesión

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: ((ctx) => AuthWrapper()),
        ),
      );
    }
  }

  void _showProfileInformation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const AccountDetailsScreen(),
      ),
    );
  }

  void _showFaqScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const FaqScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          height: 50,
          color: Colors.black,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            onPressed: _showProfileInformation,
            child: SizedBox(
              width: btnWidth,
              child: Center(
                child: Text(
                  "Consultar Perfil",
                  style: GoogleFonts.openSans(
                    color: Colors.black,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          height: 50,
          color: Colors.black,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            onPressed: _showFaqScreen,
            child: SizedBox(
              width: btnWidth,
              child: Center(
                child: Text(
                  "Preguntas Frecuentes",
                  style: GoogleFonts.openSans(
                    color: Colors.black,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          height: 50,
          color: Colors.black,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            onPressed: _logout,
            child: SizedBox(
              width: btnWidth,
              child: Center(
                child: Text(
                  "Cerrar Sesión",
                  style: GoogleFonts.openSans(
                    color: Colors.black,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
