import 'package:flutter/material.dart';
import 'package:q_alert/color_palette.dart'; //  paleta de colores

class LoginField extends StatelessWidget {
  final TextEditingController controller; // Agrega el controlador
  final String hintText;
  final bool isPassword;
  final IconData? icon;

  const LoginField({
    super.key,
    required this.controller, // requerir el controlador
    required this.hintText,
    this.isPassword = false,
    this.icon,
  });

  @override
   Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: Colorpalette.borderColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colorpalette.borderColor.withOpacity(0.5)),
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: Colorpalette.borderColor.withOpacity(0.7),
              )
            : null,
        filled: true,
        fillColor: Colorpalette.whiteColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colorpalette.borderColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colorpalette.gradient3,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
    );
  }
}

/*class _LoginFieldState extends State<LoginField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: TextFormField(
        controller: widget.controller, // Usa el controlador
        obscureText: widget.isPassword ? _obscureText : false,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(27),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colorpalette.borderColor,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colorpalette.gradient2,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          hintText: widget.hintText,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}*/
