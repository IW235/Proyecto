import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:q_alert/connections/constant.dart';
import 'package:q_alert/services/socket_service.dart';



class InspectorService {
  static Future<List<Map<String, dynamic>>> getCompletedRequests() async {
    final url = Uri.parse("${ApiConstants.baseUrl}/api/requests/completed");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load completed requests');
    }
  }

   final SocketService socketService;

     InspectorService({required this.socketService});
  // Obtener todas las solicitudes pendientes
  static Future<List<Map<String, dynamic>>> getPendingRequests() async {
    try {
      final url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.requestsEndpoint}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> requests = json.decode(response.body);
        return requests.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load pending requests');
      }
    } catch (e) {
      print('Error al obtener las solicitudes pendientes: $e');
      throw Exception('Failed to load pending requests: $e');
    }
  }

// Aprobar una solicitud
  Future<void> approveRequest(String requestId, String operatorId) async {
    try {
      final url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.requestsEndpoint}/$requestId/approve");
      final response = await http.put(url);

      if (response.statusCode == 200) {
        // Notificar al operador en tiempo real
        socketService.sendNotification(operatorId, 'Solicitud aprobada');
      } else {
        throw Exception('Failed to approve request');
      }
    } catch (e) {
      print('Error al aprobar la solicitud: $e');
      throw Exception('Failed to approve request: $e');
    }
  }

  // Rechazar una solicitud
  Future<void> rejectRequest(String requestId, String operatorId) async {
    try {
      final url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.requestsEndpoint}/$requestId/reject");
      final response = await http.put(url);

      if (response.statusCode == 200) {
        // Notificar al operador en tiempo real
        socketService.sendNotification(operatorId, 'Solicitud rechazada');
      } else {
        throw Exception('Failed to reject request');
      }
    } catch (e) {
      print('Error al rechazar la solicitud: $e');
      throw Exception('Failed to reject request: $e');
    }
  }

  static completeRequest(String employeeNumber, request) {}
}
