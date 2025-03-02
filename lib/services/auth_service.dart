import 'dart:convert';
import 'package:http/http.dart' as http;
import '../connections/constant.dart';

class AuthService {
  // Método para iniciar sesión
  static Future<Map<String,dynamic>?> loginUser(String employeeNumber, String password) async {   ///email
    try {
      // Construir la URL completa
      final url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}");

      // Realizar la solicitud HTTP POST al endpoint de login
      final response = await http.post(
        url, // Usar la URL completa
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employeeNumber': employeeNumber,
          'password': password,
        }),
      );

      // Verificar el código de estado de la respuesta
      if (response.statusCode == 200) {
        // Si la respuesta es exitosa, decodificar el JSON
        final data = jsonDecode(response.body);
        if (data['token'] != null && data['user'] != null) {
          print('Login successful, token: ${data['token']}');
          return data; // Devolver el token
        } else {
          print('Error: No token received in response');
          return null;
        }
      } else {
        // Si la respuesta no es exitosa, mostrar el error
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      // Manejar errores de conexión o del servidor
      print('Login error: $e');
      return null;
    }
  }
}