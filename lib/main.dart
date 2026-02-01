import 'package:flutter/material.dart';
import 'widgets/control_bar.dart';
import 'widgets/status_display.dart';
import 'widgets/jedi_app_bar.dart';
import 'services/pioneer_service.dart';
import 'widgets/volume_slider.dart';
import 'widgets/station_list.dart';
import 'senderliste.dart';

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: PioneerRadioApp()),
);

class PioneerRadioApp extends StatefulWidget {
  const PioneerRadioApp({super.key});
  @override
  State<PioneerRadioApp> createState() => _PioneerRadioAppState();
}

class _PioneerRadioAppState extends State<PioneerRadioApp> {
  // Service instanziieren
  double _currentVolume = 0.3; // Startwert (entspricht ca. 060VL)
  final PioneerService _pioneer = PioneerService();

  String _currentStation = "Kein Sender gewählt";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070A),
      appBar: const JediAppBar(title: 'jedi pioneer'),

      // Die Column stapelt alles von oben nach unten
      body: Column(
        children: [
          // 1. Ganz oben: Die Statusanzeige
          StatusDisplay(currentStation: _currentStation),

          // 2. Die Mitte: Die Liste (Expanded füllt den Platz aus)
          // In deiner Column in der main.dart:
          Expanded(
            child: StationList(
              currentStation: _currentStation,
              onStationTap: (name, url) async {
                setState(() => _currentStation = name);
                await _pioneer.playStation(name, url);

                // 1. Korrekturwert aus der senderliste.dart holen
                final selectedStation = stations.firstWhere(
                  (s) => s['name'] == name,
                  orElse: () => {'vol': '1.0'},
                );
                double factor =
                    double.tryParse(selectedStation['vol'] ?? '1.0') ?? 1.0;

                // 2. Ziel-Lautstärke berechnen (Standard 0.32 * Faktor)
                double newVolume = 0.32 * factor;
                if (newVolume > 1.0) newVolume = 1.0;

                // 3. ENTSCHEIDEND: Den Slider-Wert im UI aktualisieren!
                setState(() {
                  _currentVolume = newVolume;
                });

                // 4. Befehl an den Pioneer senden
                await _pioneer.setVolume(newVolume);
              },
            ),
          ),

          // 3. VOR der BottomBar: Dein neuer leuchtender Volume-Slider
          // ... nach dem Expanded(child: ListView...)
          VolumeSlider(
            value: _currentVolume,
            onChanged: (v) => setState(() => _currentVolume = v),
            onChangeEnd: (v) => _pioneer.setVolume(v),
          ),

          // ... vor der bottomNavigationBar
        ],
      ),

      // 4. Ganz unten: Die ControlBar
      bottomNavigationBar: ControlBar(
        onControlTap: (code) => _pioneer.sendControl(code),
      ),
    );
  }
}
