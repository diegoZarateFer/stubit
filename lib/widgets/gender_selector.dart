import 'package:flutter/material.dart';

const List<String> _genders = ['Masculino', 'Femenino', 'Otro'];

class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    this.onChanged,
    this.selectedGender,
    this.readOnly = false,
  });

  final void Function(String?)? onChanged;
  final String? selectedGender;
  final bool readOnly;

  String? _genderValidator(value) {
    if (value == null) {
      return 'Selecciona tu género.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      value: selectedGender,
      dropdownColor: Colors.black,
      items: _genders.map((gender) {
        return DropdownMenuItem(
          value: gender,
          child: Text(
            gender,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
      onChanged: readOnly ? null : onChanged,
      validator: _genderValidator,
      decoration: const InputDecoration(
        labelText: 'Género',
      ),
      icon: readOnly
          ? const SizedBox.shrink()
          : const Icon(Icons.arrow_drop_down),
    );
  }
}
