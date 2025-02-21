import 'package:flutter/material.dart';
import 'package:q_alert/pages/dashboard_screen.dart';
//import 'pages/dashboard_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:q_alert/services/auth_service.dart';

import 'package:q_alert/widgets/gradient_button.dart';
import 'package:q_alert/widgets/login_field.dart';




class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isNotValid = false;
  late SharedPreferences preferences;

  void loginUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
    var token = await AuthService.loginUser(
        emailController.text, passwordController.text);

      if (token != null) {
        print('Login successful');
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()));
      } else {
        print('Login failed');
      }
    } else {
      setState(() {
        _isNotValid = true;
      });
    }
  }

  /*void signUp() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const SignUp()));
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height *
                    0.4, //40% de la pantalla
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/imagen/avionPaginaInicio.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.6, //60% de la pantalla
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: 60),
                        Text('Log in',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 50,
                            )),
                        /*SizedBox(height: 50),
                LoginField(
                  iconPath: 'assets/icon/iniciar-sesion.png',
                  buttonLabel: 'Ejemplo',
                ),*/
                        SizedBox(height: 20),
                        //Image.asset('assets/icon/iniciar-sesion.png', height: 100),
                        //SizedBox(height: 40),
                        LoginField(emailController, hintText: 'Email'),
                        SizedBox(height: 15),
                        LoginField(passwordController, hintText: 'Password', isPassword: true),
                        SizedBox(height: 20),
                        GradientButton(
                          onPressed: () {
                          loginUser();
                          },
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Desarrollado por KaibaCorp',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4 -
                50, //Posicion de la interseccion
            left: MediaQuery.of(context).size.width / 2 -
                50, //Centrado de forma horizontal
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/icon/iniciar-sesion.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
