import 'package:flutter/material.dart';



class SupervisorHomeScreen extends StatelessWidget {
  final String employeeNumber;
  final String firstName;
  final String lastName;
  final String area;

  const SupervisorHomeScreen({
    required this.employeeNumber,
    required this.firstName,
    required this.lastName,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $firstName $lastName'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Employee Number: $employeeNumber'),
            Text('Area: $area'),
          ],
        ),
      ),
    );
  }
}
