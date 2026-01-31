import 'package:flutter/material.dart';

class StatusDisplay extends StatelessWidget {
  final String currentStation;

  const StatusDisplay({super.key, required this.currentStation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      color: const Color.fromARGB(255, 10, 37, 127),
      child: Text(
        "AKTUELLER SENDER: $currentStation",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.yellow,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
