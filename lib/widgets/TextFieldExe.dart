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
      style: const TextStyle(
        color: Color(0xFF000000),
        fontSize: 15,
        letterSpacing: 0.3,
      ),

      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Color(0xFF999999),
          fontSize: 13,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.5,
        ),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF000000),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF666666), size: 20),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(color: Color(0xFF000000), width: 1.5),
        ),
      ),
    );
  }
}
