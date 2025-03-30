import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:q_alert/color_palette.dart';
import 'package:q_alert/services/operator_service.dart';
import 'package:q_alert/pages/operator_home_screen.dart';
import 'package:q_alert/services/socket_service.dart';
import 'package:q_alert/widgets/gradient_button.dart';

class InspectorWaitScreen extends StatefulWidget {
  final String piece;
  final String complement;
  final String inspectorName;
  final String employeeNumber;
  final String firstName;
  final String lastName;
  final String area;
  final SocketService socketService;

  const InspectorWaitScreen({
    super.key,
    required this.piece,
    required this.complement,
    required this.inspectorName,
    required this.employeeNumber,
    required this.firstName,
    required this.lastName,
    required this.area,
    required this.socketService,
  });

  @override
  _InspectorWaitScreenState createState() => _InspectorWaitScreenState();
}

class _InspectorWaitScreenState extends State<InspectorWaitScreen> {
  final TextEditingController inspectorNumberController =
      TextEditingController();
  final TextEditingController inspectorPasswordController =
      TextEditingController();
  String _currentTime = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
      Future.delayed(Duration(seconds: 1), _updateTime);
    }
  }

  void completeInspection() async {
    final inspectorNumber = inspectorNumberController.text;
    final password = inspectorPasswordController.text;

    // Validate inputs
    if (inspectorNumber.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, ingrese el número y la contraseña del inspector.'),
          backgroundColor: Colorpalette.gradient3,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Call the backend to mark the inspection as completed
    try {
      final response = await OperatorService.completeInspection(
        inspectorNumber,
        password,
        widget.piece,
        widget.complement,
        widget.employeeNumber,
        widget.firstName,
        widget.lastName,
        widget.area,
      );

      if (response) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inspección completada exitosamente.'),
            backgroundColor: Colorpalette.gradient1,
          ),
        );

        // Navegar de vuelta a la pantalla del operador
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OperatorHomeScreen(
              employeeNumber: widget.employeeNumber,
              firstName: widget.firstName,
              lastName: widget.lastName,
              area: widget.area,
              socketService: widget.socketService,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Error al completar la inspección. Por favor, verifique sus credenciales.'),
            backgroundColor: Colorpalette.gradient3,
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Error al completar la inspección';
      if (e.toString().contains('Inspector not found')) {
        errorMessage = 'No se encontró un inspector con ese número de empleado';
      } else if (e.toString().contains('Incorrect password')) {
        errorMessage = 'La contraseña proporcionada es incorrecta';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colorpalette.gradient3,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorpalette.backgroundColor,
      appBar: AppBar(
        title: const Text('Esperando Inspector'),
        backgroundColor: Colorpalette.gradient1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la solicitud
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
                      'Detalles de la Solicitud',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colorpalette.borderColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Pieza:', widget.piece),
                    const SizedBox(height: 8),
                    _buildDetailRow('Complemento:', widget.complement),
                    const SizedBox(height: 8),
                    _buildDetailRow('Inspector:', widget.inspectorName),
                    const SizedBox(height: 8),
                    _buildDetailRow('Hora:', _currentTime),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Formulario de verificación
            const Text(
              'Verificación del Inspector',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colorpalette.borderColor,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: inspectorNumberController,
                      decoration: InputDecoration(
                        labelText: 'Número de Inspector',
                        prefixIcon:
                            Icon(Icons.badge, color: Colorpalette.gradient1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: inspectorPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon:
                            Icon(Icons.lock, color: Colorpalette.gradient1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colorpalette.gradient3),
                ),
              )
            else
              GradientButton(
                onPressed: completeInspection,
                text: 'Marcar como Completada',
                gradientColors: [
                  Colorpalette.gradient3,
                  Colorpalette.gradient4,
                ],
              ),
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
