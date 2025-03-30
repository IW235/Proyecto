import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:q_alert/pages/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_screen.dart';
import 'services/socket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Q Alerts',
      theme: ThemeData(
        primaryColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(), // Se usa AuthWrapper para manejar la lógica de autenticación
    );
  }
}


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // Obtener el token de SharedPreferences
  Future<String?> getToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('token');
  }

  // Verificar si el token es válido
  bool isTokenValid(String? token) {
    if (token == null || token.isEmpty) return false;
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      print('Error decoding token: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          final token = snapshot.data;
          final socketService = SocketService(); // Inicializar el servicio WebSocket

          if (isTokenValid(token)) {
            // Pasar el servicio WebSocket a la pantalla del dashboard
            return DashboardScreen(socketService: socketService);
          } else {
            // Si el token no es válido, redirigir al login
            return LoginScreen();
          }
        }
      },
    );
  }
}
