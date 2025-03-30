import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  // Constructor
  SocketService() {
    _initSocket();
  }

  // Inicializar la conexión WebSocket
  void _initSocket() {
    socket = IO.io('http://localhost:5000', <String, dynamic>{  //192.168.100.18  localhost
      'transports': ['websocket'],
      'autoConnect': true,
    });

    // Escuchar eventos de conexión
    socket.onConnect((_) {
      print('Conectado al servidor WebSocket');
    });

    // Escuchar eventos de desconexión
    socket.onDisconnect((_) {
      print('Desconectado del servidor WebSocket');
    });

    // Escuchar eventos personalizados (por ejemplo, 'newRequest')
    socket.on('newRequest', (data) {
      print('Notificación recibida: $data');
      // Aquí puedes usar un Stream o Callback para notificar a la interfaz
      if (onNewRequest != null) {
        onNewRequest!(data);
      }
    });

    // Manejar errores de conexión
    socket.onConnectError((err) {
      print('Error de conexión: $err');
    });
  }

  // Función para enviar una solicitud
  void sendRequest(String userId, String message) {
    socket.emit('sendRequest', {
      'userId': userId,
      'message': message,
    });
  }

  // Función para enviar una notificación a un operador específico
  void sendNotification(String operatorId, String message) {
    socket.emit('sendNotification', {
      'operatorId': operatorId,
      'message': message,
    });
  }

  // Callback para notificar nuevos mensajes
  Function(dynamic)? onNewRequest;

  // Desconectar el socket
  void disconnect() {
    socket.disconnect();
  }
}