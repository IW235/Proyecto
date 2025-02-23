import 'package:flutter/material.dart';
import 'package:q_alert/color_palette.dart';
//import 'package:q_alert/pages/login_screen.dart';


class GradientButton extends StatelessWidget {
  final VoidCallback onPressed; // Cambia "Null Function()" a "VoidCallback"

  const GradientButton({
    super.key,
    required this.onPressed, // Corrige el constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colorpalette.gradient3,
            Colorpalette.gradient4,
            Colorpalette.gradient5,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: ElevatedButton(
        onPressed: onPressed, // Usa el parámetro onPressed
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(395, 55),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Text(
          'Log In',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
    );
  }
}