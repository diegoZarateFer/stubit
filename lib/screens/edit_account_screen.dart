import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/widgets/confirmation_dialog.dart';
import 'package:stubit/widgets/gender_selector.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  User? _currentUser;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _hasEdited = false;

  late DateTime _birthDate;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _gender, _documentID;

  // Validators.
  String? _nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tu nombre';
    }

    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Por favor, ingresa un nombre válido';
    }
    return null;
  }

  String? _dateValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu fecha de nacimiento';
    }

    DateTime selectedDate = DateTime.parse(value);
    DateTime referenceDate = DateTime(2008, 1, 1);

    if (selectedDate.isAfter(referenceDate)) {
      return 'La edad mínima es de 16 años';
    }

    return null;
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _updateAccountData();
    }
  }

  Future<void> _updateAccountData() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    try {
      await _firestore
          .collection("user_data")
          .doc(_currentUser!.uid.toString())
          .collection("account")
          .doc(_documentID)
          .update({
        "birthday": _dateController.text.toString(),
        "gender": _gender,
        "last_name": _lastNameController.text.toString(),
        "name": _nameController.text.toString(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tu información ha sido actualizada."),
          duration: Duration(seconds: 3),
        ),
      );

      _closeScreen();
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'Algo salió mal. Inteta de nuevo más tarde.',
          ),
        ),
      );
    }
  }

  Future<void> _loadAccountData() async {
    final querySnapshot = await _firestore
        .collection("user_data")
        .doc(_currentUser!.uid.toString())
        .collection("account")
        .get();

    _nameController.text = querySnapshot.docs[0]["name"];
    _lastNameController.text = querySnapshot.docs[0]["last_name"];
    _dateController.text = querySnapshot.docs[0]["birthday"];
    _gender = querySnapshot.docs[0]["gender"];
    _documentID = querySnapshot.docs[0].id;
    _birthDate = DateTime.parse(querySnapshot.docs[0]["birthday"]);
    setState(() {
      _isLoading = false;
    });
  }

  void _closeScreen() {
    Navigator.of(context).pop();
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = _birthDate;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void _showConfirmationDialog() async {
    if (_hasEdited) {
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

    _closeScreen();
  }

  void _onChange(value) {
    setState(() {
      _hasEdited = true;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: _showConfirmationDialog,
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
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Editar datos de mi perfil",
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
                            "assets/images/edit_profile.png",
                            height: 60,
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          TextFormField(
                            maxLength: 35,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              counterText: '',
                              labelText: 'Nombre',
                            ),
                            controller: _nameController,
                            validator: _nameValidator,
                            onChanged: _onChange,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            maxLength: 35,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              counterText: '',
                              labelText: 'Apellidos',
                            ),
                            controller: _lastNameController,
                            validator: _nameValidator,
                            onChanged: _onChange,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Fecha de Nacimiento',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            onTap: () {
                              _selectDate(context);
                            },
                            controller: _dateController,
                            validator: _dateValidator,
                            onChanged: _onChange,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          GenderSelector(
                            selectedGender: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value;
                                _hasEdited = true;
                              });
                            },
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
                              backgroundColor:
                                  const Color.fromRGBO(121, 30, 198, 1),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          ElevatedButton.icon(
                            onPressed: _closeScreen,
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
