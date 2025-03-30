import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:q_alert/color_palette.dart';
import 'package:q_alert/pages/inspector_wait_screen.dart';
import 'package:q_alert/pages/login_screen.dart'; 
import 'package:q_alert/services/operator_service.dart';
import 'package:q_alert/services/socket_service.dart';
import 'package:q_alert/widgets/gradient_button.dart';

class OperatorHomeScreen extends StatefulWidget {
  final String employeeNumber;
  final String firstName;
  final String lastName;
  final String area;
  final SocketService socketService;

  const OperatorHomeScreen({
    super.key,
    required this.employeeNumber,
    required this.firstName,
    required this.lastName,
    required this.area,
    required this.socketService,
  });

  @override
  State<OperatorHomeScreen> createState() => _OperatorHomeScreenState();
}

class _OperatorHomeScreenState extends State<OperatorHomeScreen> {
  String _currentTime = '';
  String? _selectedPiece;
  String? _selectedComplement;
  List<Map<String, dynamic>> _pieces = [];
  List<Map<String, dynamic>> _complements = [];

  @override
  void initState() {
    super.initState();
    _loadPieces();
    _updateTime();
  }

  Future<void> _loadPieces() async {
    try {
      final pieces = await OperatorService.loadPieces(widget.area);
      setState(() {
        _pieces = pieces;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las piezas: $e'),
        backgroundColor: Colorpalette.gradient3,
        ),
      );
    }
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
      Future.delayed(Duration(seconds: 1), _updateTime);
    }
  }

  Future<void> _sendRequest() async {
    try {
      final requestData = {
        'operatorId': widget.employeeNumber,
        'operatorName': '${widget.firstName} ${widget.lastName}',
        'area': widget.area,
        'piece': _selectedPiece,
        'complement': _selectedComplement,
      };

      await OperatorService.sendRequest(requestData);

      String inspectorName = await OperatorService.getInspectorName(widget.area);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InspectorWaitScreen(
            piece: _selectedPiece!,
            complement: _selectedComplement!,
            inspectorName: inspectorName,
            employeeNumber: widget.employeeNumber,
            firstName: widget.firstName,
            lastName: widget.lastName,
            area: widget.area,
            socketService: widget.socketService,
          ),
        ),
      );

      widget.socketService.sendRequest(
        widget.employeeNumber,
        'Nueva solicitud de ${widget.firstName} ${widget.lastName}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud enviada correctamente'),
        backgroundColor: Colorpalette.gradient1,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar la solicitud: $e'),
        backgroundColor: Colorpalette.gradient3,
        ),
      );
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: Colorpalette.backgroundColor,
      appBar: AppBar(
        title: const Text('QAlert - Operador'),
        backgroundColor: Colorpalette.gradient1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con información del usuario
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido, ${widget.firstName} ${widget.lastName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colorpalette.borderColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.badge, size: 16, color: Colorpalette.gradient1),
                        const SizedBox(width: 8),
                        Text(
                          widget.employeeNumber,
                          style: const TextStyle(color: Colorpalette.borderColor),
                        ),
                        const Spacer(),
                        const Icon(Icons.access_time, size: 16, color: Colorpalette.gradient1),
                        const SizedBox(width: 8),
                        Text(
                          _currentTime,
                          style: const TextStyle(color: Colorpalette.borderColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 16, color: Colorpalette.gradient1),
                        const SizedBox(width: 8),
                        Text(
                          widget.area,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colorpalette.borderColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sección de revisión
            const Text(
              'Solicitud de Revisión',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colorpalette.borderColor,
              ),
            ),
            const SizedBox(height: 12),

            // Selector de pieza
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedPiece,
                  hint: const Text('Selecciona una pieza'),
                  icon: const Icon(Icons.arrow_drop_down, color: Colorpalette.gradient1),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    try {
                      final selectedPiece = _pieces.firstWhere(
                        (piece) => piece['pieceName'] == newValue,
                      );

                      final List<Map<String, dynamic>> complements =
                          (selectedPiece['complements'] as List<dynamic>)
                              .cast<Map<String, dynamic>>();

                      setState(() {
                        _selectedPiece = newValue;
                        _selectedComplement = null;
                        _complements = complements;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al seleccionar la pieza: $e'),
                          backgroundColor: Colorpalette.gradient3,
                        ),
                      );
                    }
                  },
                  items: _pieces
                      .map<DropdownMenuItem<String>>((Map<String, dynamic> piece) {
                    return DropdownMenuItem<String>(
                      value: piece['pieceName'],
                      child: Text(
                        piece['pieceName'],
                        style: const TextStyle(color: Colorpalette.borderColor),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            if (_selectedPiece != null) const SizedBox(height: 16),

            // Selector de complemento (solo si hay pieza seleccionada)
            if (_selectedPiece != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedComplement,
                    hint: const Text('Selecciona un complemento'),
                    icon: const Icon(Icons.arrow_drop_down, color: Colorpalette.gradient1),
                    underline: const SizedBox(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedComplement = newValue;
                      });
                    },
                    items: _complements.map<DropdownMenuItem<String>>(
                        (Map<String, dynamic> complement) {
                      return DropdownMenuItem<String>(
                        value: complement['complementName'],
                        child: Text(
                          complement['complementName'],
                          style: const TextStyle(color: Colorpalette.borderColor),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // Resumen y botón de enviar (solo si ambos están seleccionados)
            if (_selectedPiece != null && _selectedComplement != null) ...[
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen de la solicitud:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colorpalette.borderColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Pieza:', _selectedPiece!),
                      const SizedBox(height: 8),
                      _buildDetailRow('Complemento:', _selectedComplement!),
                      const SizedBox(height: 20),
                      GradientButton(
                        onPressed: _sendRequest,
                        text: 'Enviar Solicitud',
                        gradientColors: [
                          Colorpalette.gradient3,
                          Colorpalette.gradient4,
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colorpalette.gradient1,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colorpalette.borderColor),
          ),
        ),
      ],
    );
  }
}