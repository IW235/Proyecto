import 'package:flutter/material.dart';
import 'package:q_alert/pages/inspector_home_screen.dart';
import 'package:q_alert/pages/supervisor_home_screen.dart';
import 'package:q_alert/services/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:q_alert/services/auth_service.dart';
import 'package:q_alert/widgets/gradient_button.dart';
import 'package:q_alert/color_palette.dart';
import 'package:q_alert/widgets/login_field.dart';
import 'package:q_alert/pages/operator_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController employeeNumController =
      TextEditingController(); //emailController
  final TextEditingController passwordController = TextEditingController();
  bool _isNotValid = false;
  bool _isLoading = false; // Para mostrar un indicador de carga
  late SharedPreferences preferences;

  //Validar el formato del número de empleado
  bool _validateEmployeeNumber(String employeeNumber) {
    if (employeeNumber.length != 6) return false;
    if (employeeNumber[0] != '8' &&
        employeeNumber[0] != '5' &&
        employeeNumber[0] != '3') {
      return false;
    }
    return true;
  }

  //Validar el formato de la contraseña
  bool _validatePassword(String password) {
    if (password.length != 8) return false;
    return true;
  }

  //Función para iniciar sesión
  void loginUser() async {
    // Validar campos vacíos
    if (employeeNumController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        _isNotValid = true;
      });
      return;
    }

    //Validar numero de empleado y contraseña
    if (!_validateEmployeeNumber(employeeNumController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Employee number must be 6 digits long and start with 8, 5 or 3.'),
          backgroundColor: Colors.red,
        ),
      );
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

      //Llamar al servicio de autenticación
      var response = await AuthService.loginUser(
        employeeNumController.text,
        passwordController.text,
      );

      //Verificar si la respuesta es válida
      if (response != null &&
          response['token'] != null &&
          response['user'] != null) {
        //print('Login exitoso. Token recibido: $token');

        // Guardar el token en SharedPreferences (si es necesario)
        preferences = await SharedPreferences.getInstance();
        preferences.setString('token', response['token']);

        //Obtener los datos del usuario
        final user = response['user'] as Map<String, dynamic>;
        final role = user['role'] as String;
        final employeeNumber = user['employeeNumber'] as String;
        final firstName = user['firstName'] as String;
        final lastName = user['lastName'] as String;
        final area = user['area'] as String;

        // Navegar a la pantalla según el rol
        switch (role) {
          case 'Operator':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OperatorHomeScreen(
                  employeeNumber: employeeNumber,
                  firstName: firstName,
                  lastName: lastName,
                  area: area,
                  socketService: SocketService(),
                ),
                //const DashboardScreen()
              ),
            );
            break;
          case 'Inspector':
            //Navega a la pantalla del Inspector
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => InspectorHomeScreen(
                  employeeNumber: employeeNumber,
                  firstName: firstName,
                  lastName: lastName,
                  area: area,
                  socketService: SocketService(),
                ),
              ),
            );
            break;
          case 'Supervisor':
            //Navega a la pantalla sel Supervisor
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SupervisorHomeScreen(
                  employeeNumber: employeeNumber,
                  firstName: firstName,
                  lastName: lastName,
                  area: area,
                ),
              ),
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Role not recognized')),
            );
        }
      } else {
        //print('Login fallido. No se recibió token.');
        // Mostrar mensaje de error si el inicio de sesión falla
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Usuario o contraseña incorrectos. Intente nuevamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      //print('Error en el login: $e');
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600; // Umbral para diseño móvil
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colorpalette.gradient1,
              Colorpalette.gradient2,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 500,
                ),
                decoration: BoxDecoration(
                  color: Colorpalette.whiteColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo y título
                      Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colorpalette.whiteColor,
                              border: Border.all(
                                color: Colorpalette.gradient5,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Image.asset(
                                'assets/icon/iniciar-sesion.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'QAlert',
                            style: TextStyle(
                              fontSize: isMobile ? 28 : 32,
                              fontWeight: FontWeight.bold,
                              color: Colorpalette.borderColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Inicio de sesión',
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 20,
                              color: Colorpalette.borderColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      // Campos de formulario
                      LoginField(
                        controller: employeeNumController,
                        hintText: 'Número de empleado',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 15),
                      LoginField(
                        controller: passwordController,
                        hintText: 'Contraseña',
                        isPassword: true,
                        icon: Icons.lock_outline,
                      ),

                      const SizedBox(height: 25),

                      // Botón de login
                      if (_isLoading)
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colorpalette.gradient3,
                          ),
                        )
                      else
                        GradientButton(
                          onPressed: loginUser,
                          text: 'Iniciar sesión',
                          gradientColors: [
                            Colorpalette.gradient3,
                            Colorpalette.gradient4,
                          ],
                        ),

                      const SizedBox(height: 20),
                      // Footer

                      Text(
                        'Desarrollado por KaibaCorp',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: Colorpalette.borderColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        /*Positioned(
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
          ),*/
      ),
    );
  }
}
