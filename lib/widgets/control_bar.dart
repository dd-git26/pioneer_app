import 'package:flutter/material.dart';

class ControlBar extends StatelessWidget {
  final Function(String) onControlTap;

  const ControlBar({super.key, required this.onControlTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 130, // Höhe vergrößert für zwei Zeilen
      color: Colors.blueGrey.shade900,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(color: Colors.white10, height: 10),

          // ZEILE 2: Deine Gaming-Buttons (Xbox & PC)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.videogame_asset, color: Colors.green),
                label: const Text(
                  "XBOX",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  onControlTap('04FN'); // 1. Kanal auf DVD/Xbox schalten
                  await Future.delayed(
                    const Duration(milliseconds: 300),
                  ); // Kurze Pause
                  onControlTap(
                    '100VL',
                  ); // 2. Lautstärke auf einen festen Wert setzen (z.B. 181)
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.computer, color: Colors.blue),
                label: const Text(
                  "GAMING PC",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () =>
                    onControlTap('25FN'), // Beispiel-Code für Eingang
              ),
            ],
          ),
          // --- DER LEUCHTENDE TRENNSTRICH (GLOW) ---
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            height: 2, // Die Dicke des Strichs
            decoration: BoxDecoration(
              color: Colors.cyanAccent, // Die Kernfarbe des Strichs
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(
                    0.8,
                  ), // Farbe des Leuchtens
                  blurRadius: 10, // Wie weit das Licht strahlt
                  spreadRadius: 2, // Wie dick der Kern des Leuchtens ist
                ),
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          // ZEILE 1: Lautstärke & Power
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.volume_down, color: Colors.white),
                onPressed: () => onControlTap('VD'),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.white),
                onPressed: () => onControlTap('VU'),
              ),
              const VerticalDivider(
                color: Color.fromARGB(255, 250, 236, 143),
                indent: 5,
                endIndent: 5,
              ),
              IconButton(
                icon: const Icon(
                  Icons.power_settings_new,
                  color: Colors.greenAccent,
                ),
                onPressed: () => onControlTap('PO'),
              ),
              IconButton(
                icon: const Icon(
                  Icons.power_settings_new,
                  color: Colors.redAccent,
                ),
                onPressed: () => onControlTap('PF'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
