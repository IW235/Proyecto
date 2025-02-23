import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:q_alert/pages/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'color_palette.dart';
import 'pages/login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  runApp(MyApp(tokens:preferences.getString('token'),));
}

class MyApp extends StatelessWidget {

  final tokens;
  const MyApp({super.key, this.tokens});

  //Este es el widget principal
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Q Alerts',
      theme: ThemeData(
          primaryColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: (tokens != null && JwtDecoder.isExpired(tokens) == false)
      ? DashboardScreen()
      : LoginScreen(),


    );
  }
}
