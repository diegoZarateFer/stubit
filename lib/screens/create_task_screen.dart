import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/priority.dart';

const List<Priority> _priorities = [
  Priority(
    name: "alta",
    color: Colors.red,
  ),
  Priority(
    name: "media",
    color: Colors.yellow,
  ),
  Priority(
    name: "baja",
    color: Colors.green,
  ),
];

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  User? _currentUser;
  final _formKey = GlobalKey<FormState>();

  //Controllers.
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedPriority = "";

  // Validators.
  String? _taskNameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Falta el nombre de la actividad.';
    }

    return null;
  }

  String? _dateValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Selecciona una fecha.';
    }

    DateTime selectedDate = DateTime.parse(value);

    DateTime today = DateTime.now();
    DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

    if (selectedDate.isBefore(todayDateOnly)) {
      return 'La fecha no puede ser anterior.';
    }

    return null;
  }

  String? _descriptionValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Falta la descripción de la actividad.';
    }

    return null;
  }

  String? _priorityValidator(value) {
    if (value == null) {
      return 'Falta establecer una prioridad a la actividad.';
    }

    return null;
  }

  //Functions.
  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await createTask();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
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

  Future<void> createTask() async {
    final taskName = _taskNameController.text.trim();
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("user_data")
          .doc(_currentUser!.uid.toString())
          .collection("tasks")
          .where('title', isEqualTo: taskName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya existe una tarea con el mismo nombre.'),
          ),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection("user_data")
          .doc(_currentUser!.uid.toString())
          .collection("tasks")
          .add({
        "title": taskName,
        "description": _descriptionController.text,
        "priority": _selectedPriority,
        "status": "pendiente",
        "date": _dateController.text.toString(),
      });

      // Redirect to the board.
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ha ocurrido un error inesperado. Intente más tarde.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    super.dispose();
    _taskNameController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      "NUEVA ACTIVIDAD",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Image.asset(
                      'assets/images/calendar.png',
                      height: 80,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      maxLength: 50,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: 'Título de la actividad',
                      ),
                      controller: _taskNameController,
                      validator: _taskNameValidator,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      maxLength: 250,
                      maxLines: 3,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: 'Descripción',
                      ),
                      controller: _descriptionController,
                      validator: _descriptionValidator,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Selecciona una fecha',
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
                      height: 16,
                    ),
                    DropdownButtonFormField(
                      dropdownColor: Colors.black,
                      items: _priorities.map((priority) {
                        final String name = priority.name[0].toUpperCase() +
                            priority.name.substring(1);
                        return DropdownMenuItem(
                          value: priority.name,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: priority.color,
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (priority) {
                        setState(() {
                          _selectedPriority = priority;
                        });
                      },
                      validator: _priorityValidator,
                      decoration: const InputDecoration(
                        labelText: 'Prioridad',
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: const Color.fromRGBO(121, 30, 198, 1),
                      ),
                      child: Text(
                        "Agregar",
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
    );
  }
}
