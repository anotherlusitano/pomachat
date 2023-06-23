import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ValidatedTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final int maxLenght;
  final int? maxLines;
  final List<TextInputFormatter>? filters;

  const ValidatedTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.maxLenght,
    this.filters,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLength: maxLenght,
      decoration: InputDecoration(
        counterText: "",
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        fillColor: Colors.grey.shade200,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      maxLines: maxLines,
      inputFormatters: filters,
    );
  }
}
