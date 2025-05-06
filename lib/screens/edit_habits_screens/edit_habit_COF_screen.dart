import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:day_picker/day_picker.dart';
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

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class EditHabitCofScreen extends StatefulWidget {
  const EditHabitCofScreen({
    super.key,
    required this.habit,
    this.unit,
  });

  final Habit habit;
  final String? unit;

  @override
  State<EditHabitCofScreen> createState() => _EditHabitCofScreenState();
}

class _EditHabitCofScreenState extends State<EditHabitCofScreen> {
  final _currentUser = FirebaseAuth.instance.currentUser!;
  List<DayInWeek> _days = [
    DayInWeek("D", dayKey: "sunday"),
    DayInWeek("L", dayKey: "monday"),
    DayInWeek("M", dayKey: "tuesday"),
    DayInWeek("M", dayKey: "wednesday"),
    DayInWeek("J", dayKey: "thursday"),
    DayInWeek("V", dayKey: "friday"),
    DayInWeek("S", dayKey: "saturday"),
  ];

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true, _hasError = false, _changesWereMade = false;

  late String? _unit;
  late String _habitName;
  List<String> _selectedDaysOfWeek = [];
  num? _selectedNumberOfWeeks;

  final TextEditingController _dailyTargetController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  String? _dailyTargetvalidator(selectedDailyTarget) {
    if (selectedDailyTarget == null ||
        selectedDailyTarget.toString().trim() == '') {
      return 'Campo obligatorio.';
    }
    return null;
  }

  String? _habitDurationValidator(selectedDuration) {
    if (selectedDuration == null) {
      return "Campo obligatorio.";
    }

    return null;
  }

  Future<bool> showRecomendationDialog(
      BuildContext context, totalNumberOfDays) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "La magia de los 21 días",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/magic.png',
                    height: 80,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Con la configuración actual, tu actividad tendrá una duración de $totalNumberOfDays días. Te recomendamos dedicar al menos 21 días para obtener mejores resultados.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    "Ahora no",
                    style: TextStyle(
                      color: Color.fromRGBO(121, 30, 198, 1),
                      fontSize: 14,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(121, 30, 198, 1),
                  ),
                  child: Text(
                    "¡Acepto el reto!",
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      decorationColor: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      ScaffoldMessenger.of(context).clearSnackBars();
      if (_selectedNumberOfWeeks == double.infinity &&
          _selectedDaysOfWeek.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Selecciona los días a la semana que dedicarás a esta actividad.'),
          ),
        );
        return;
      }

      if (_selectedNumberOfWeeks != double.infinity &&
          _selectedNumberOfWeeks! * _selectedDaysOfWeek.length < 21) {
        final bool confirmation = await showRecomendationDialog(
            context, _selectedNumberOfWeeks! * _selectedDaysOfWeek.length);
        if (confirmation) {
          return;
        }
      }

      final Map<String, dynamic> habitParameters = {
        "dailyTarget": int.tryParse(_dailyTargetController.text),
        "days": _selectedDaysOfWeek,
        "numberOfWeeks": _selectedNumberOfWeeks,
        "unit": _unit ?? _unitController.text.toString(),
      };

      try {
        // Saving habit information.
        await FirebaseFirestore.instance
            .collection("user_data")
            .doc(_currentUser.uid.toString())
            .collection("habits")
            .doc(widget.habit.id)
            .update({
          "name": _habitName,
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
      List<dynamic> fetchedDaysOfWeek = habitParameters['days'];

      setState(() {
        _selectedNumberOfWeeks = habitParameters['numberOfWeeks'];
        _selectedDaysOfWeek =
            fetchedDaysOfWeek.map((item) => item.toString()).toList();
        _days = [
          DayInWeek(
            "D",
            dayKey: "sunday",
            isSelected: _selectedDaysOfWeek.contains("sunday"),
          ),
          DayInWeek(
            "L",
            dayKey: "monday",
            isSelected: _selectedDaysOfWeek.contains("monday"),
          ),
          DayInWeek(
            "M",
            dayKey: "tuesday",
            isSelected: _selectedDaysOfWeek.contains("tuesday"),
          ),
          DayInWeek(
            "M",
            dayKey: "wednesday",
            isSelected: _selectedDaysOfWeek.contains("wednesday"),
          ),
          DayInWeek(
            "J",
            dayKey: "thursday",
            isSelected: _selectedDaysOfWeek.contains("thursday"),
          ),
          DayInWeek(
            "V",
            dayKey: "friday",
            isSelected: _selectedDaysOfWeek.contains("friday"),
          ),
          DayInWeek(
            "S",
            dayKey: "saturday",
            isSelected: _selectedDaysOfWeek.contains("saturday"),
          ),
        ];

        _unit = habitParameters['unit'];
        _dailyTargetController.text = habitParameters['dailyTarget'].toString();
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasError = false;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _unit = widget.unit;
    _habitName = widget.habit.name;
    _loadFormData();
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

  Future<void> _showEditNameDialog() async {
    final dialogFormKey = GlobalKey<FormState>();
    TextEditingController nameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: dialogFormKey,
            child: TextFormField(
              maxLength: 40,
              textAlign: TextAlign.center,
              controller: nameController,
              validator: (value) {
                if (value == null || value.trim().length <= 3) {
                  return 'Debe contener al menos 4 caracteres';
                }

                return null;
              },
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                counterText: '',
                labelText: 'Renombar hábito',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) {
                  dialogFormKey.currentState!.save();

                  setState(() {
                    _habitName = nameController.text;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _habitName,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    if (widget.habit.category == 'custom')
                                      const SizedBox(
                                        width: 4,
                                      ),
                                    if (widget.habit.category == 'custom')
                                      IconButton(
                                        onPressed: _showEditNameDialog,
                                        icon: const Icon(
                                          Icons.drive_file_rename_outline,
                                          color: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 32,
                                ),
                                Text(
                                  "Objetivo diario",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        maxLength: 3,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: _dailyTargetController,
                                        validator: _dailyTargetvalidator,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: const InputDecoration(
                                          counterText: '',
                                          labelText: 'Objetivo diario',
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          _unit!,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 32,
                                ),
                                Text(
                                  "Ingresa el número de semanas",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                DropdownButtonFormField<String>(
                                  value: _getKeyFromValue(),
                                  validator: _habitDurationValidator,
                                  dropdownColor: Colors.black,
                                  items: _numberOfWeeksOptions.keys
                                      .toList()
                                      .map((option) {
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
                                  onChanged: (selectedKey) {
                                    setState(() {
                                      _changesWereMade = true;
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
                                Text(
                                  "¿Que días quieres realizar el hábito?",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                SelectWeekDays(
                                  fontSize: 16,
                                  onSelect: (value) {
                                    _selectedDaysOfWeek = value;
                                  },
                                  days: _days,
                                  unselectedDaysFillColor:
                                      const Color(0xFFA6A6A6),
                                  unselectedDaysBorderColor: Colors.black,
                                  selectedDaysFillColor:
                                      const Color(0xFFA557E8),
                                  selectedDaysBorderColor: Colors.black,
                                  selectedDayTextColor: Colors.white,
                                  unSelectedDayTextColor: Colors.white,
                                  borderWidth: 4,
                                  backgroundColor: Colors.transparent,
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
                                    "Aceptar",
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
                                  onPressed: () {
                                    Navigator.of(context).pop();
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
