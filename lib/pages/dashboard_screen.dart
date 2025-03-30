/*import 'package:flutter/material.dart';
import 'package:q_alert/pages/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void singOut() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Congratulations! Our integration is working successfully.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => singOut(),
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:q_alert/services/socket_service.dart';
import 'package:q_alert/pages/login_screen.dart';


class DashboardScreen extends StatefulWidget {
  final SocketService socketService;

  const DashboardScreen({super.key, required this.socketService});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
  
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _message = '';
  void singOut() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  void initState() {
    super.initState();

    // Escuchar nuevos mensajes
    widget.socketService.onNewRequest = (data) {
      setState(() {
        _message = data['message']; // Actualizar la interfaz con el mensaje recibido
      });
    };
  }

  void sendRequest() {
    // Enviar una solicitud al servidor
    widget.socketService.sendRequest('user1', 'Nueva solicitud de user1');
  }

  @override
  void dispose() {
    // Desconectar el socket al cerrar la pantalla
    widget.socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message), // Mostrar el mensaje recibido
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendRequest,
              child: Text('Enviar Solicitud'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => singOut(),
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
