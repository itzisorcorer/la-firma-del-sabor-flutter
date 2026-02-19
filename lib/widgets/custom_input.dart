import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType type;
  final bool isPassword;
  final TextEditingController controller;

  const CustomInput({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.type = TextInputType.text,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    // Semantics ayuda a TalkBack a entender mejor el campo
    return Semantics(
      label: "Campo de texto para $label",
      textField: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: TextFormField(
          controller: controller,
          keyboardType: type,
          obscureText: isPassword,
          decoration: InputDecoration(
            labelText: label, // TalkBack lee esto automáticamente
            hintText: hint,   // Y esto si el usuario pide ayuda
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese $label'; // TalkBack lee el error al fallar
            }
            return null;
          },
        ),
      ),
    );
  }
}