import 'package:flutter/material.dart';

class CustomTextFieldExe extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final bool obscure;

  const CustomTextFieldExe({
    super.key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Color(0xFF000000)),

      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF666666)),
        prefixIcon: Icon(icon, color: const Color(0xFF000000)),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(color: Color(0xFF000000), width: 1),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(color: Color(0xFF000000), width: 2),
        ),
      ),
    );
  }
}
