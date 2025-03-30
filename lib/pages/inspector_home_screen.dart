import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:q_alert/color_palette.dart';
import 'package:q_alert/services/inspector_service.dart';
import 'package:q_alert/services/socket_service.dart';
import 'package:q_alert/pages/login_screen.dart';
import 'package:q_alert/widgets/gradient_button.dart'; 

class InspectorHomeScreen extends StatefulWidget {
  final String employeeNumber;
  final String firstName;
  final String lastName;
  final String area;
  final SocketService socketService; 

  const InspectorHomeScreen({
    super.key,
    required this.employeeNumber,
    required this.firstName,
    required this.lastName,
    required this.area,
    required this.socketService,
  });

  @override
  _InspectorHomeScreenState createState() => _InspectorHomeScreenState();
}

class _InspectorHomeScreenState extends State<InspectorHomeScreen> {
  List<Map<String, dynamic>> _pendingRequests = [];
  final List<Map<String, dynamic>> _attendedRequests = []; // List for attended requests
  List<Map<String, dynamic>> _completedRequests = []; // List for completed requests
  bool _isLoading = true;
  late InspectorService _inspectorService;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _inspectorService = InspectorService(socketService: widget.socketService);
    _loadPendingRequests();
    _loadCompletedRequests(); // Load completed requests
    _setupSocketListeners();
     _updateTime();
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
      Future.delayed(const Duration(seconds: 1), _updateTime);
    }
  }

   Future<void> _loadRequests() async {
    try {
      final pending = await InspectorService.getPendingRequests();
      final completed = await InspectorService.getCompletedRequests();
      
      setState(() {
        _pendingRequests = widget.area.isEmpty 
            ? pending 
            : pending.where((r) => r['area'] == widget.area).toList();
        
        _completedRequests = widget.area.isEmpty
            ? completed
            : completed.where((r) => r['area'] == widget.area).toList();
        
        _isLoading = false;
      });
    } catch (error) {
      _showError('Error al cargar solicitudes: $error');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPendingRequests() async {
    try {
      var requests = await InspectorService.getPendingRequests(); // Fetch pending requests for the inspector's area
      if (widget.area.isNotEmpty) {
        requests = requests.where((request) => request['area'] == widget.area).toList(); // Filter by area
      }
      setState(() {
        _pendingRequests = requests;
        _isLoading = false;
      });
    } catch (error) {
      print('Error al cargar las solicitudes pendientes: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las solicitudes pendientes: $error')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setupSocketListeners() {
    widget.socketService.onNewRequest = (data) {
      _loadPendingRequests();
    };
  }

   void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colorpalette.gradient3,
      ),
    );
  }


  Future<void> _loadCompletedRequests() async {
    print('Fetching completed requests...'); // Debugging

    try {
      var requests = await InspectorService.getCompletedRequests(); // Fetch completed requests for the inspector's area
      if (widget.area.isNotEmpty) {
        requests = requests.where((request) => request['area'] == widget.area).toList(); // Filter by area
      }
      print('Completed requests fetched: $requests'); // Debugging

      setState(() {
        _completedRequests = requests;
      });
    } catch (error) {
      print('Error al cargar las solicitudes completadas: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las solicitudes completadas: $error')),
      );
    }
  }

 /* Future<void> _approveRequest(String requestId, String operatorId) async {
    try {
      await _inspectorService.approveRequest(requestId, operatorId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud aprobada correctamente')),
      );
      _loadPendingRequests();
    } catch (error) {
      print('Error al aprobar la solicitud: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al aprobar la solicitud: $error')),
      );
    }
  }*/

 /* Future<void> _rejectRequest(String requestId, String operatorId) async {
    try {
      await _inspectorService.rejectRequest(requestId, operatorId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud rechazada correctamente')),
      );
      _loadPendingRequests();
    } catch (error) {
      print('Error al rechazar la solicitud: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al rechazar la solicitud: $error')),
      );
    }
  }*/

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  /*Future<void> _markAsCompleted(Map<String, dynamic> request) async {
    try {
      await InspectorService.completeRequest(
        widget.employeeNumber,
        request['_id'],
      );
      await _loadRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud marcada como completada'),
          backgroundColor: Colorpalette.gradient1,
        ),
      );
    } catch (e) {
      _showError('Error al completar solicitud: $e');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colorpalette.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.construction, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Inspector - ${widget.area}',
              style: const TextStyle(fontSize: 18),
            ),
            const Spacer(),
            Text(
              _currentTime,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        backgroundColor: Colorpalette.gradient1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: isWideScreen
                  ? _buildWideLayout()
                  : _buildMobileLayout(),
            ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel de solicitudes pendientes
        Expanded(
          flex: 2,
          child: _buildRequestSection(
            title: 'Solicitudes Pendientes',
            requests: _pendingRequests,
            emptyMessage: 'No hay solicitudes pendientes',
            isPending: true,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Panel de solicitudes completadas
        Expanded(
          flex: 3,
          child: _buildRequestSection(
            title: 'Historial de Solicitudes',
            requests: _completedRequests,
            emptyMessage: 'No hay solicitudes completadas',
            isPending: false,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildRequestSection(
            title: 'Solicitudes Pendientes',
            requests: _pendingRequests,
            emptyMessage: 'No hay solicitudes pendientes',
            isPending: true,
          ),
          const SizedBox(height: 20),
          _buildRequestSection(
            title: 'Historial de Solicitudes',
            requests: _completedRequests,
            emptyMessage: 'No hay solicitudes completadas',
            isPending: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestSection({
    required String title,
    required List<Map<String, dynamic>> requests,
    required String emptyMessage,
    required bool isPending,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colorpalette.borderColor,
                  ),
                ),
                const Spacer(),
                Text(
                  'Total: ${requests.length}',
                  style: TextStyle(
                    color: Colorpalette.gradient1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            requests.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        emptyMessage,
                        style: TextStyle(color: Colorpalette.borderColor.withOpacity(0.6)),
                      ),
                    ),
                  )
                : isPending
                    ? _buildPendingRequestsList(requests)
                    : _buildCompletedRequestsList(requests),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestsList(List<Map<String, dynamic>> requests) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(
          request: request,
          isPending: true,
          //onComplete: () => _markAsCompleted(request),
        );
      },
    );
  }

  Widget _buildCompletedRequestsList(List<Map<String, dynamic>> requests) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const Divider(height: 16),
      itemBuilder: (context, index) {
        return _buildRequestCard(
          request: requests[index],
          isPending: false,
        );
      },
    );
  }

  Widget _buildRequestCard({required Map<String, dynamic> request,
  required bool isPending,
  VoidCallback? onComplete,
}) {
  final operatorName = request['operatorName'] ?? 
      '${request['operator'][0]['firstName']} ${request['operator'][0]['lastName']}';
  
  final date = request['date'] != null 
      ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(request['date']))
      : 'Fecha no disponible';

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de la tarjeta
          Row(
            children: [
              Icon(
                isPending ? Icons.pending_actions : Icons.check_circle,
                color: isPending ? Colorpalette.gradient3 : Colorpalette.gradient1,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  operatorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colorpalette.borderColor,
                  ),
                ),
              ),
              if (!isPending) 
                Text(date, style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          
          // Detalles de la solicitud
          _buildDetailRow('Área:', request['area']),
          if (isPending) ...[
            _buildDetailRow('Pieza:', request['piece']),
            _buildDetailRow('Complemento:', request['complement']),
          ],
          
          // Botón de acción (solo para pendientes)
          if (isPending && onComplete != null) ...[
            const SizedBox(height: 12),
            GradientButton(
              onPressed: onComplete,
              text: 'Marcar como Completada',
              gradientColors: [
                Colorpalette.gradient3,
                Colorpalette.gradient4,
              ],
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ],
        ],
      ),
    ),
  );
}

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colorpalette.gradient1,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colorpalette.borderColor),
            ),
          ),
        ],
      ),
    );
  }
}