import 'package:flutter/material.dart';

class PlantsPage extends StatelessWidget {
  const PlantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, size: 64, color: Color(0xFF2E7D32)),
            SizedBox(height: 16),
            Text(
              'Ösümlikler',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Dermanlyk ösümlikler boýunça gözleg we maglumat.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF4E6E50)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
