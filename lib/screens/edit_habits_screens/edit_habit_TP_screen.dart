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

final List<String> _minutesForWork = List.generate(
  46,
  (index) => "${index + 15}",
);

final List<String> _minutesForRest = List.generate(
  56,
  (index) => index + 5 <= 9 ? "0${index + 5}" : "${index + 5}",
);

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class EditHabitTpScreen extends StatefulWidget {
  const EditHabitTpScreen({
    super.key,
    required this.habit,
  });

  final Habit habit;

  @override
  State<EditHabitTpScreen> createState() => _EditHabitTpScreenState();
}

class _EditHabitTpScreenState extends State<EditHabitTpScreen> {
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

  final TextEditingController _selectedNumberOfCylcesController =
      TextEditingController();

  List<String> _selectedDaysOfWeek = [];
  num? _selectedNumberOfWeeks;

  bool _isLoading = true, _hasError = false, _changesWereMade = false;

  int _totalTime = 0;
  int _workInterval = 15, _restInterval = 5;

  late FixedExtentScrollController _scrollWorkIntervalController,
      _scrollRestIntervalController;

  @override
  void initState() {
    super.initState();
    _scrollWorkIntervalController = FixedExtentScrollController();
    _scrollRestIntervalController = FixedExtentScrollController();
    _loadFormData();
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
      _scrollWorkIntervalController.animateToItem(
        habitParameters['workInterval'],
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );

      _scrollRestIntervalController.animateToItem(
        habitParameters['restInterval'],
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );

      _selectedNumberOfCylcesController.text =
          habitParameters['cycles'].toString();
      List<dynamic> fetchedDaysOfWeek = habitParameters['days'];
      setState(() {
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

        _selectedNumberOfWeeks = habitParameters['numberOfWeeks'];
        _isLoading = false;
      });
      _updateTotalTime();
    } else {
      setState(() {
        _hasError = false;
        _isLoading = false;
      });
    }
  }

  String? _numberOfCyclesValidator(selectedDailyTarget) {
    if (selectedDailyTarget == null ||
        selectedDailyTarget.toString().trim() == '') {
      return 'Campo obligatorio.';
    }
    return null;
  }

  String? _habitDurationValidator(selectedDuration) {
    if (selectedDuration == null) {
      return "Campo obligatorio";
    }

    return null;
  }

  void _updateTotalTime() {
    int cycles = int.tryParse(_selectedNumberOfCylcesController.text) ?? 0;
    setState(() {
      _totalTime = (_restInterval + _workInterval) * cycles;
    });
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

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      ScaffoldMessenger.of(context).clearSnackBars();
      if (_selectedNumberOfWeeks == double.infinity &&
          _selectedDaysOfWeek.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Debes seleccionar los días a la semana que dedicarás a esta actividad.'),
          ),
        );
        return;
      }

      if (_selectedNumberOfWeeks != double.infinity &&
          _selectedNumberOfWeeks! * _selectedDaysOfWeek.length < 21) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'En total debes dedicar al menos 21 días a esta actividad.',
            ),
          ),
        );
        return;
      }

      int cycles = int.tryParse(_selectedNumberOfCylcesController.text) ?? 0;
      final Map<String, dynamic> habitParameters = {
        "workInterval": _workInterval,
        "restInterval": _restInterval,
        "cycles": cycles,
        "numberOfWeeks": _selectedNumberOfWeeks,
        "days": _selectedDaysOfWeek,
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
            content: Text('Se han guardado los cambios!'),
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
                                  height: 32,
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      "Bloque de trabajo",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 60,
                                    ),
                                    Text(
                                      "Bloque de descanso",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
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
                                            onSelectedItemChanged: (index) {
                                              _workInterval = int.tryParse(
                                                  _minutesForWork[index %
                                                      _minutesForWork.length])!;
                                              _updateTotalTime();
                                            },
                                            children: _minutesForWork
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
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: 128,
                                          child: CupertinoPicker(
                                            itemExtent: 32,
                                            looping: true,
                                            onSelectedItemChanged: (index) {
                                              _restInterval = int.tryParse(
                                                  _minutesForRest[index %
                                                      _minutesForRest.length])!;
                                              _updateTotalTime();
                                            },
                                            children: _minutesForRest
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        maxLength: 3,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        validator: _numberOfCyclesValidator,
                                        controller:
                                            _selectedNumberOfCylcesController,
                                        onChanged: (value) {
                                          _updateTotalTime();
                                        },
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: const InputDecoration(
                                          counterText: '',
                                          labelText: 'Número de ciclos',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Tiempo total: $_totalTime minutos por día.",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 32,
                                ),
                                DropdownButtonFormField<String>(
                                  value: _getKeyFromValue(),
                                  dropdownColor: Colors.black,
                                  validator: _habitDurationValidator,
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
                                  onChanged: (String? selectedKey) {
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
                                    setState(() {
                                      _selectedDaysOfWeek = value;
                                    });
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
