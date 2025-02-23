import 'package:flutter/material.dart';
import 'package:q_alert/pages/dashboard_screen.dart';
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isNotValid = false;
  bool _isLoading = false; // Para mostrar un indicador de carga
  late SharedPreferences preferences;

  void loginUser() async {
    // Validar campos vacíos
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        _isNotValid = true;
      });
      return;
    }

    setState(() {
      _isLoading = true; // Mostrar indicador de carga
    });

    try {
      // Intentar iniciar sesión
      //print('Enviando solicitud de login...');
      //print('Email: ${emailController.text}');
      //print('Password: ${passwordController.text}');

      var token = await AuthService.loginUser(
        emailController.text,
        passwordController.text,
      );

      if (token != null) {
        print('Login exitoso. Token recibido: $token');

        // Guardar el token en SharedPreferences (si es necesario)
        preferences = await SharedPreferences.getInstance();
        preferences.setString('token', token);

        // Navegar a la pantalla de Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        print('Login fallido. No se recibió token.');
        // Mostrar mensaje de error si el inicio de sesión falla
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo o contraseña incorrectos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error en el login: $e');
      // Manejar errores de conexión o del servidor
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Ocultar indicador de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/imagen/avionPaginaInicio.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        const Text(
                          'Log in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 50,
                          ),
                        ),
                        const SizedBox(height: 20),
                        LoginField(
                          controller: emailController, // Pasar el controlador
                          hintText: 'Email', // Pasar el texto de sugerencia
                        ),
                        const SizedBox(height: 15),
                        LoginField(
                          controller: passwordController, // Pasar el controlador
                          hintText: 'Password', // Pasar el texto de sugerencia
                          isPassword: true, // Indicar que es un campo de contraseña
                        ),
                        const SizedBox(height: 20),
                        if (_isLoading)
                          const CircularProgressIndicator() // Indicador de carga
                        else
                          GradientButton(
                            onPressed: loginUser, // Pasar la función de login
                          ),
                        const SizedBox(height: 20),
                        const Text(
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
            top: MediaQuery.of(context).size.height * 0.4 - 50,
            left: MediaQuery.of(context).size.width / 2 - 50,
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