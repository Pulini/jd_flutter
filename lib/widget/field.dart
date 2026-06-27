import 'package:flutter/material.dart';

class LoginField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  const LoginField({
    super.key,
    this.controller,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.textInputAction,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintStyle: const TextStyle(color: Colors.white),
        counterStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(prefixIcon, size: 20, color: Colors.white),
        suffixIcon: suffix,
        labelStyle: const TextStyle(color: Colors.white),
        label: Text(hint),
      ),
    );
  }
}
