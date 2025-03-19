import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/widgets/apology.dart';
import 'package:stubit/widgets/confirmation_dialog.dart';

Map<String, num> _numberOfWeeksOptions = {
  "3 semanas": 3,
  "4 semanas": 4,
  "5 semanas": 5,
  "6 semanas": 6,
  "7 semanas": 7,
  "8 semanas": 8,
  "9 semanas": 9,
  "10 semanas": 10,
  "Indefinidamente": double.infinity,
};

final List<String> _hours = List.generate(
  13,
  (index) => index > 9 ? index.toString() : "0${index.toString()}",
);

final List<String> _minutes = List.generate(
  60,
  (index) => index > 9 ? index.toString() : "0${index.toString()}",
);

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class EditTHabitScreen extends StatefulWidget {
  const EditTHabitScreen({
    super.key,
    required this.habit,
    this.initialNumberOfMinutes = 0,
    this.initialNumberOfHours = 7,
  });

  final Habit habit;
  final int initialNumberOfMinutes, initialNumberOfHours;

  @override
  State<EditTHabitScreen> createState() => _CreateFtHabitScreenState();
}

class _CreateFtHabitScreenState extends State<EditTHabitScreen> {
  final _currentUser = FirebaseAuth.instance.currentUser!;

  final _formKey = GlobalKey<FormState>();

  num? _selectedNumberOfWeeks;

  late FixedExtentScrollController _scrollHoursController,
      _scrollMinutesController;

  bool _isLoading = true, _hasError = false, _changesWereMade = false;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  String? _habitDurationValidator(selectedDuration) {
    if (selectedDuration == null) {
      return "Campo obligatorio";
    }

    return null;
  }

  void _saveForm() async {
    int selectedHours = _scrollHoursController.selectedItem % _hours.length;
    int selectedMinutes =
        _scrollMinutesController.selectedItem % _minutes.length;

    int selectedTotalMinutes = selectedHours * 60 + selectedMinutes;

    ScaffoldMessenger.of(context).clearSnackBars();
    if (selectedTotalMinutes < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes dedicar al menos 10 minutos a esta actividad.'),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final Map<String, dynamic> habitParameters = {
        "allotedTime": selectedTotalMinutes,
        "numberOfWeeks": _selectedNumberOfWeeks,
        "minutes": selectedMinutes,
        "hours": selectedHours,
      };

      try {
        // Saving habit information.
        await FirebaseFirestore.instance
            .collection("user_data")
            .doc(_currentUser.uid.toString())
            .collection("habits")
            .doc(widget.habit.id)
            .set({
          "name": widget.habit.name,
          "strategy": widget.habit.strategy,
          "category": widget.habit.category,
          "description": widget.habit.description,
          "habitParameters": habitParameters,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Se ha guardado los cambios!'),
          ),
        );
        Navigator.pop(context, true);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ha ocurrido un error al guardar los cambios. Intentalo más tarde.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadFormData() async {
    final userId = _currentUser.uid.toString();
    final doc = await _firestore
        .collection("user_data")
        .doc(userId)
        .collection("habits")
        .doc(widget.habit.id)
        .get();

    if (doc.exists) {
      final habitParameters = doc.data()?['habitParameters'];
      _scrollHoursController = FixedExtentScrollController(
        initialItem: habitParameters['hours'],
      );
      _scrollMinutesController =
          FixedExtentScrollController(initialItem: habitParameters['minutes']);

      setState(() {
        _selectedNumberOfWeeks = habitParameters['numberOfWeeks'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasError = false;
        _isLoading = false;
      });
    }
  }

  Future<bool> _handleBackButtonPressed() async {
    if (_changesWereMade) {
      final bool? confirmation = await showConfirmationDialog(
        context,
        "Salir",
        "Se perderán los cambios realizados.",
        "Continuar",
        "Cancelar",
      );
      return confirmation ?? false;
    }

    return true;
  }

  String? _getKeyFromValue() {
    return _numberOfWeeksOptions.entries
            .firstWhere(
              (entry) => entry.value == _selectedNumberOfWeeks,
              orElse: () => const MapEntry("", -1),
            )
            .key
            .isNotEmpty
        ? _numberOfWeeksOptions.entries
            .firstWhere((entry) => entry.value == _selectedNumberOfWeeks)
            .key
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _handleBackButtonPressed();
      },
      child: Scaffold(
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
          child: _hasError
              ? const Apology(
                  message:
                      "Lo sentimos. Ha ocurrido un error inesperado, inténtalo de nuevo más tarde.",
                )
              : _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  "MODIFICAR HÁBITO",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Image.asset(
                                  "assets/images/calendar.png",
                                  height: 60,
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  widget.habit.name,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  "¿Cuánto tiempo quieres dedicar a la actividad por día?",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                CupertinoPageScaffold(
                                  backgroundColor: Colors.transparent,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 128,
                                          child: CupertinoPicker(
                                            looping: true,
                                            itemExtent: 32,
                                            scrollController:
                                                _scrollHoursController,
                                            onSelectedItemChanged: (value) {
                                              _changesWereMade = true;
                                            },
                                            children: _hours
                                                .map(
                                                  (hour) => Center(
                                                    child: Text(hour),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        "horas",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: 128,
                                          child: CupertinoPicker(
                                            looping: true,
                                            itemExtent: 32,
                                            scrollController:
                                                _scrollMinutesController,
                                            onSelectedItemChanged: (value) {
                                              _changesWereMade = true;
                                            },
                                            children: _minutes
                                                .map(
                                                  (minute) => Center(
                                                    child: Text(minute),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        "min.",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 32,
                                ),
                                DropdownButtonFormField<String>(
                                  value: _getKeyFromValue(),
                                  dropdownColor: Colors.black,
                                  validator: _habitDurationValidator,
                                  items: _numberOfWeeksOptions.keys
                                      .map((String option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(
                                        option,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? selectedKey) {
                                    _changesWereMade = true;
                                    setState(() {
                                      if (selectedKey != null) {
                                        _selectedNumberOfWeeks =
                                            _numberOfWeeksOptions[selectedKey]!;
                                      }
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Duración del hábito.',
                                  ),
                                  menuMaxHeight: 256,
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                ElevatedButton(
                                  onPressed: _saveForm,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor:
                                        const Color.fromRGBO(121, 30, 198, 1),
                                  ),
                                  child: Text(
                                    "Guardar",
                                    style: GoogleFonts.openSans(
                                      color: Colors.white,
                                      decorationColor: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final confirmation =
                                        await _handleBackButtonPressed();
                                    if (confirmation) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                  child: Text(
                                    "Cancelar",
                                    style: GoogleFonts.openSans(
                                      color: Colors.black,
                                      decorationColor: Colors.black,
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
      ),
    );
  }
}
