import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.invalidText,
    required this.hintText,
    required this.obscureText,
    required this.inputType,
    this.initialValue,
    this.isAreaText = false,
    this.border = true,
  }) : super(key: key);

  final TextEditingController controller;
  final TextInputType inputType;
  final String invalidText, hintText;
  final String? initialValue;
  final bool obscureText;
  final bool isAreaText;
  final bool border;

  @override
  State<CustomTextFormField> createState() => CustomTextFormFieldState();
}

class CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _isVisibility = false;
  void changeVisibility() {
    setState(() {
      _isVisibility = !_isVisibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: widget.isAreaText ? 3 : 1,
      maxLines: widget.isAreaText ? 3 : 1,
      maxLength: widget.isAreaText ? 100 : null,
      initialValue: widget.initialValue,
      obscureText: widget.obscureText && !_isVisibility,
      controller: widget.controller,
      validator: (value) {
        if (!(widget.inputType == TextInputType.text) &&
            (value == null || value.isEmpty)) {
          return widget.invalidText;
        } else if (widget.inputType == TextInputType.emailAddress &&
            !EmailValidator.validate(value!)) {
          return "Invalid email adress";
        } else if (widget.inputType == TextInputType.visiblePassword &&
            value!.length < 6) {
          return "Password length must be longer than 6 characters";
        } else if (widget.inputType == TextInputType.text) {
          return null;
        }
        return null;
      },
      keyboardType: widget.inputType,
      decoration: InputDecoration(
        label: Text(widget.hintText),
        suffixIcon: widget.obscureText
            ? (_isVisibility
                ? IconButton(
                    onPressed: changeVisibility,
                    icon: const Icon(Icons.visibility))
                : IconButton(
                    onPressed: changeVisibility,
                    icon: const Icon(Icons.visibility_off)))
            : null,
        border: widget.border ? const OutlineInputBorder() : InputBorder.none,
        hintText: widget.hintText,
        contentPadding: widget.isAreaText
            ? const EdgeInsets.only(
                top: 8.0,
                right: 8.0,
                left: 10.0,
                bottom: 20.0,
              )
            : const EdgeInsets.only(
                top: 8.0,
                right: 8.0,
                left: 10.0,
              ),
      ),
    );
  }
}
