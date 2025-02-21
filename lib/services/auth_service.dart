import 'dart:convert';
import 'package:http/http.dart' as http;
import '../connections/constant.dart';

class AuthService {
  static Future<String?> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
}
