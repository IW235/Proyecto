import 'package:flutter/material.dart';
import 'package:q_alert/color_palette.dart';
//import 'package:q_alert/pages/login_screen.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed; // Cambia "Null Function()" a "VoidCallback"
  final String text;
  final List<Color> gradientColors;
  final EdgeInsetsGeometry? padding;

  const GradientButton({
    super.key,
    required this.onPressed, // Corrige el constructor
    required this.text,
    this.gradientColors = const [
      Colorpalette.gradient3,
      Colorpalette.gradient4,
    ], 
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
