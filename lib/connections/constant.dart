class ApiConstants {
  static const String baseUrl = 'http://192.168.100.16:5000';  /// Luisangely:http://192.168.100.16  Escuela:http://10.1.124.120:5000 Casa: 192.168.100.18:5000 otra 10.1.100.22
  static const String loginEndpoint = '/api/auth/login'; // Solo el endpoint
  static const String piecesEndpoint = '/api/pieces';
  static const String requestsEndpoint = '/api/requests';
  static const String inspectorEndpoint = '/api/users/inspector'; // Actualizado para coincidir con la ruta del backend
  //static const String registerEndpoint = '/api/auth/register'; //Solo el endpoint
  // Add other endpoints as needed
}

