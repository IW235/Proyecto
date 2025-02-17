import 'package:flutter/material.dart';
import 'color_palette.dart';
import 'pages/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //Este es el widget principal
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colorpalette.backgroundColor,
      ),
      home: const LoginScreen(),
    );
  }
}
