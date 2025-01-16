import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/priority.dart';
import 'package:stubit/models/task_status.dart';
import 'package:stubit/widgets/confirmation_dialog.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({
    super.key,
    required this.taskId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
  });

  final String taskId;
  final String title;
  final String description;
  final String priority;
  final String status;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final List<Priority> _priorities = const [
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

  bool madeChanges = false;
  final _formKey = GlobalKey<FormState>();
  User? _currentUser;

  // Controllers
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedPriority, _selectedTaskStatus;

  // Validators
  String? _taskNameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo está vacío.';
    }

    return null;
  }

  String? _descriptionValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo está vacío.';
    }

    return null;
  }

  String? _priorityValidator(value) {
    if (value == null) {
      return 'Falta establecer una prioridad a la actividad.';
    }

    return null;
  }

  String? _statusValidator(value) {
    if (value == null) {
      return 'Falta establecer un estado a la actividad.';
    }

    return null;
  }

  void _onDismiss() async {
    if (madeChanges) {
      final bool? saveChanges = await showConfirmationDialog(
        context,
        "Guardar cambios",
        "¿Deseas guardar los cambios realizados?",
        "Guardar",
        "No guardar",
      );
      if (saveChanges ?? false) {
        _saveForm();
        return;
      }
    }

    Navigator.of(context).pop();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _saveTask();
    }
  }

  Future<void> _deleteTask() async {
    final bool? delete = await showConfirmationDialog(
        context,
        "Eliminar actividad",
        "¿Seguro(a) que deseas eliminar la actividad?",
        "Eliminar",
        "Cancelar");

    if (delete ?? false) {
      try {
        await FirebaseFirestore.instance
            .collection("user_data")
            .doc(_currentUser!.uid.toString())
            .collection("tasks")
            .doc(widget.taskId)
            .delete();

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Se ha eliminado la actividad correctamente."),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      } catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Ha ocurrido un error inesperado. Intente más tarde.'),
          ),
        );
      }
    }
  }

  Future<void> _saveTask() async {
    try {
      await FirebaseFirestore.instance
          .collection("user_data")
          .doc(_currentUser!.uid.toString())
          .collection("tasks")
          .doc(widget.taskId)
          .set({
        "title": _taskNameController.text,
        "description": _descriptionController.text,
        "priority": _selectedPriority,
        "status": _selectedTaskStatus,
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Se han guardado los cambios."),
          duration: Duration(seconds: 3),
        ),
      );

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
    _taskNameController.text = widget.title;
    _descriptionController.text = widget.description;
    _selectedPriority = widget.priority;
    _selectedTaskStatus = widget.status;
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    super.dispose();
    _taskNameController.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: _onDismiss,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "DETALLES DE ACTIVIDAD",
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
                      'assets/images/calendar.png',
                      height: 80,
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    TextFormField(
                      maxLength: 35,
                      controller: _taskNameController,
                      validator: _taskNameValidator,
                      onChanged: (value) {
                        madeChanges = true;
                      },
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: 'Título de la actividad',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      maxLength: 250,
                      controller: _descriptionController,
                      maxLines: 3,
                      validator: _descriptionValidator,
                      onChanged: (value) {
                        madeChanges = true;
                      },
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: 'Descripción',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    DropdownButtonFormField(
                      value: _selectedPriority,
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
                        madeChanges = true;
                        setState(() {
                          _selectedPriority = priority;
                        });
                      },
                      validator: _priorityValidator,
                      dropdownColor: const Color(0xFF181A25),
                      decoration: const InputDecoration(
                        labelText: 'Prioridad',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    DropdownButtonFormField(
                      value: _selectedTaskStatus,
                      items: taskStatus.map((status) {
                        return DropdownMenuItem(
                          value: status.identifier,
                          child: Row(
                            children: [
                              status.icon,
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                status.name,
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
                      onChanged: (status) {
                        madeChanges = true;
                        setState(() {
                          _selectedTaskStatus = status;
                        });
                      },
                      validator: _statusValidator,
                      dropdownColor: const Color(0xFF181A25),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF181A25),
                        labelText: 'Estado',
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
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
                        backgroundColor: const Color.fromRGBO(121, 30, 198, 1),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ElevatedButton.icon(
                      onPressed: _deleteTask,
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      label: Text(
                        "Eliminar",
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
