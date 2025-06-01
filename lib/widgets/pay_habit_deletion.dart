import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/habit.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class PayHabitDeletion extends StatefulWidget {
  const PayHabitDeletion({
    super.key,
    required this.habitParameters,
    required this.habit,
  });

  final Habit habit;
  final Map<String, dynamic> habitParameters;

  @override
  State<PayHabitDeletion> createState() => _PayHabitDeletionState();
}

class _PayHabitDeletionState extends State<PayHabitDeletion> {
  final _currentUser = FirebaseAuth.instance.currentUser!;
  late int _deletionCost, _availableGems;

  bool _isLoading = true;

  Future<void> _loadAvailableGems() async {
    final userId = _currentUser.uid.toString();
    final docSnapshot = await _firestore
        .collection("user_data")
        .doc(userId)
        .collection("gems")
        .doc("user_gems")
        .get();

    setState(() {
      _availableGems = docSnapshot.data()?['collectedGems'];
      _isLoading = false;
    });
  }

  Future<void> _chargeUser() async {
    final userId = _currentUser.uid.toString();
    await _firestore
        .collection('user_data')
        .doc(userId)
        .collection('gems')
        .doc('user_gems')
        .update({
      "collectedGems": FieldValue.increment(-_deletionCost),
    });
  }

  @override
  void initState() {
    super.initState();
    _deletionCost = Random().nextInt(10) + 10;
    _loadAvailableGems();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const AlertDialog(
            backgroundColor: Color(0xFF292D39),
            content: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : _availableGems >= _deletionCost
            ? AlertDialog(
                backgroundColor: const Color(0xFF292D39),
                title: Center(
                  child: Text(
                    'Eliminar hábito',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/surrender.png',
                      height: 80,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'Parece que deseas eliminar este hábito permanentemente. Esta operación te costará: ',
                          ),
                          TextSpan(
                            text: '$_deletionCost',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(
                            text: ' gemas.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _chargeUser();
                      Navigator.of(context).pop(true);
                    },
                    child: const Text("Eliminar hábito"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text("Cancelar"),
                  ),
                ],
              )
            : AlertDialog(
                title: Center(
                  child: Text(
                    'No es posible eliminar este hábito',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Se necesitan ',
                          ),
                          TextSpan(
                            text: '$_deletionCost',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(
                            text:
                                ' gemas para eliminar este hábito pero solamente tienes ',
                          ),
                          TextSpan(
                            text: '$_availableGems',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(
                            text: ' gemas.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
  }
}
