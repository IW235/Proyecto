import 'package:flutter/material.dart';
//import 'package:flutter_svg/svg.dart';
import 'package:q_alert/color_palette.dart';

/*class LoginField extends StatelessWidget {
  final String iconPath;
  final String buttonLabel;
  final double horizontalPadding;

  const LoginField(
      {super.key,
      required this.iconPath,
      required this.buttonLabel,
      this.horizontalPadding = 100});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
        onPressed: () {},
        icon: SvgPicture.asset(iconPath,
            width: 25, color: Colorpalette.whiteColor),
        label: Text(buttonLabel,
            style:
                const TextStyle(color: Colorpalette.whiteColor, fontSize: 17)),
        style: TextButton.styleFrom(
          padding:
              EdgeInsets.symmetric(vertical: 30, horizontal: horizontalPadding),
          shape: RoundedRectangleBorder(
              side: const BorderSide(
                color: Colorpalette.borderColor,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(10)),
        ));
  }
}*/

class LoginField extends StatefulWidget {
  final String hintText;
  final bool isPassword;

  const LoginField(TextEditingController emailController, 
      {super.key, required this.hintText, this.isPassword = false});

  @override
  _LoginFieldState createState() => _LoginFieldState();
}

class _LoginFieldState extends State<LoginField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: TextFormField(
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
              borderRadius: BorderRadius.circular(10)),
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
}
