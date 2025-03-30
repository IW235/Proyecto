import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:q_alert/connections/constant.dart';
import 'package:q_alert/services/socket_service.dart';// Importar el servicio WebSocket

class OperatorService {
  final SocketService socketService;

  OperatorService({required this.socketService});

  // Cargar las piezas y complementos desde el backend
  static Future<List<Map<String, dynamic>>> loadPieces(String area) async {
    try {
      // Validar que el área no sea nula o esté vacía
      if (area.isEmpty) {
        throw Exception('El área no puede ser nula o vacía');
      }

      // Codificar el valor del área para que sea válido en una URL
      final encodedArea = Uri.encodeComponent(area);

      // Construir la URL dinámicamente
      final url = Uri.parse(
          "${ApiConstants.baseUrl}${ApiConstants.piecesEndpoint}?area=$encodedArea");
      print('URL de la solicitud: $url'); // Depuración

      // Hacer la solicitud HTTP
      final response = await http.get(url);
      print('Código de estado: ${response.statusCode}'); // Depuración
      print('Cuerpo de la respuesta: ${response.body}'); // Depuración

      // Procesar la respuesta
      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        final Map<String, dynamic> responseBody = json.decode(response.body);

        // Obtener la lista de piezas
        final List<dynamic> piecesList = responseBody['pieces'];

        // Convertir la lista de dinámicos a List<Map<String, dynamic>>
        return piecesList.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Failed to load pieces. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en loadPieces: $e'); // Depuración
      throw Exception('Failed to load pieces: $e');
    }
  }

  //Obtener el nombre del Inspector 
  static Future<String> getInspectorName(String area) async {
    try {
      print('Área recibida en getInspectorName: $area'); // Log para depuración
      final encodedArea = Uri.encodeComponent(area);
      print('Área codificada: $encodedArea'); // Log para depuración
      
      final url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.inspectorEndpoint}?area=$encodedArea");
      print('URL de solicitud del inspector: $url'); // Depuración
      
      final response = await http.get(url);
      print('Código de estado del inspector: ${response.statusCode}'); // Depuración
      print('Respuesta del inspector: ${response.body}'); // Depuración

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['name'] == null) {
          throw Exception('El nombre del inspector no está disponible');
        }
        return data['name'];
      } else if (response.statusCode == 404) {
        throw Exception('No se encontró un inspector asignado para esta área');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al cargar el nombre del inspector');
      }
    } catch (e) {
      print('Error en getInspectorName: $e'); // Depuración
      throw Exception('Error al cargar el nombre del inspector: $e');
    }
  }

  // Enviar la solicitud de revisión al backend (HTTP)
  static Future<void> sendRequest(Map<String, dynamic> requestData) async {
    try {
      print('=== INICIO DE ENVÍO DE SOLICITUD ===');
      print('Datos a enviar: ${jsonEncode(requestData)}');

      // Construir la URL correctamente usando ApiConstants
      final url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.requestsEndpoint}");

      // Hacer la solicitud HTTP POST
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print('Código de estado de la respuesta: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      // Verificar el código de estado de la respuesta
      if (response.statusCode != 201) {
        throw Exception(
            'Failed to send request. Status code: ${response.statusCode}');
      }

      print('=== FIN DE ENVÍO DE SOLICITUD ===');
    } catch (e) {
      print('Error en sendRequest: $e');
      throw Exception('Failed to send request: $e');
    }
  }

  // Enviar la solicitud a través de WebSocket
  void sendRequestViaWebSocket(String userId, String message) {
    socketService.sendRequest(userId, message);
  }

  static Future<bool> completeInspection(
    String inspectorNumber,
    String password,
    String piece,
    String complement,
    String operatorEmployeeNumber,
    String operatorFirstName,
    String operatorLastName,
    String area,
  ) async {
    try {
      print('=== INICIO DE COMPLETAR INSPECCIÓN ===');
      print('Datos recibidos:');
      print('Inspector: $inspectorNumber');
      print('Operador: $operatorEmployeeNumber - $operatorFirstName $operatorLastName');
      print('Área: $area');
      print('Pieza: $piece');
      print('Complemento: $complement');

      // Validar datos de entrada
      if (inspectorNumber.isEmpty || password.isEmpty || operatorEmployeeNumber.isEmpty || 
          operatorFirstName.isEmpty || operatorLastName.isEmpty || area.isEmpty) {
        print('Error: Datos de entrada incompletos');
        return false;
      }

      // Primero verificar las credenciales del inspector
      final url = Uri.parse("${ApiConstants.baseUrl}/api/users/complete-inspection");
      final credentialsData = {
        'inspectorNumber': inspectorNumber,
        'password': password,
        'piece': piece,
        'complement': complement,
      };

      print('Enviando verificación de credenciales...');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(credentialsData),
      );

      print('Respuesta de verificación de credenciales: ${response.statusCode}');
      print('Cuerpo de la respuesta de credenciales: ${response.body}');

      if (response.statusCode != 200) {
        print('Credenciales incorrectas');
        return false;
      }

      // Si las credenciales son correctas, guardar la revisión
      final revisionUrl = Uri.parse("${ApiConstants.baseUrl}/api/revisions");
      final revisionData = {
        'operator': [{
          'employeeNumber': operatorEmployeeNumber,
          'firstName': operatorFirstName,
          'lastName': operatorLastName,
        }],
        'inspector': [{
          'employeeNumber': inspectorNumber,
        }],
        'area': area,
        'date': DateTime.now().toIso8601String(),
      };

      print('Enviando datos de revisión...');
      print('Datos de revisión a enviar: ${jsonEncode(revisionData)}');

      final revisionResponse = await http.post(
        revisionUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(revisionData),
      );

      print('Respuesta de guardado de revisión: ${revisionResponse.statusCode}');
      print('Cuerpo de la respuesta: ${revisionResponse.body}');

      if (revisionResponse.statusCode == 201) {
        print('Revisión guardada exitosamente');
        return true;
      } else if (revisionResponse.statusCode == 409) {
        print('Revisión duplicada detectada');
        return false;
      } else {
        print('Error al guardar la revisión: ${revisionResponse.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error completing inspection: $e');
      return false;
    } finally {
      print('=== FIN DE COMPLETAR INSPECCIÓN ===');
    }
  }
}




/*class OperatorService {
  // Cargar las piezas y complementos desde el backend
  static Future<List<Map<String, dynamic>>> loadPieces(String area) async {
    final url = Uri.parse(
        "${ApiConstants.baseUrl}${ApiConstants.piecesEndpoint}?area=$area");
    print('URL de la solicitud: $url'); // Depuración

    final response = await http.get(url);
    print('Código de estado: ${response.statusCode}'); // Depuración
    print('Cuerpo de la respuesta: ${response.body}'); // Depuración

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load pieces');
    }
  }


  // Enviar la solicitud de revisión al backend
  static Future<void> sendRequest(Map<String, dynamic> requestData) async {
    // Construir la URL correctamente usando ApiConstants
    final url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.requestsEndpoint}");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send request');
    }
  }
}*/