import 'package:flutter/material.dart';

class InputCustomizado extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool autoFocus;
  final bool obscure;
  final TextInputType type;

  InputCustomizado(
      {@required this.controller,
      @required this.hint,
      this.obscure = false,
      this.autoFocus = false,
      this.type = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autoFocus,
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      style: TextStyle(
        fontSize: 20,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
