import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final String hint;
  final bool obscure;
  final bool hasSvgPrefix;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final double? prefixIconSize;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const InputField({
    super.key,
    required this.hint,
    this.obscure = false,
    this.hasSvgPrefix = false,
    this.controller,
    this.prefixIcon,
    this.prefixIconColor,
    this.prefixIconSize,
    this.validator,
    this.keyboardType,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.grey, width: 1.5),
      ),
      child: Center(
        child: TextFormField(
          controller: widget.controller,
          obscureText: _isObscure,
          cursorColor: Colors.orange,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            errorStyle: const TextStyle(height: 0),
            contentPadding: EdgeInsets.only(
              left: widget.hasSvgPrefix ? 42 : 0,
              top: 8,
              bottom: 8,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: widget.prefixIconColor ?? Colors.grey,
                    size: widget.prefixIconSize ?? 20,
                  )
                : null,
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _isObscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
