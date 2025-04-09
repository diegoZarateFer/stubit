import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/widgets/image_button.dart';
import 'package:stubit/widgets/gemsinfodialog.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class BooksCounter extends StatelessWidget {
  const BooksCounter({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userId = currentUser.uid.toString();
    final docRef = _firestore
        .collection("user_data")
        .doc(userId)
        .collection("gems")
        .doc("user_gems");

    return Row(
      children: [
        StreamBuilder(
          stream: docRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Icon(Icons.error),
              );
            }

            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return Text(
                "0",
                style: GoogleFonts.dmSans(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final collectedGems = data['collectedGems'];

            return Row(
              children: [
                ImageButton(
                  imagePath: "assets/images/book.png",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          GemsInfoDialog(gems: collectedGems ?? 0),
                    );
                  },
                ),
                Text(
                  collectedGems.toString(),
                  style: GoogleFonts.dmSans(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
