import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'senderliste.dart';
import 'widgets/control_bar.dart';
import 'widgets/status_display.dart';

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: PioneerRadioApp()),
);

class PioneerRadioApp extends StatefulWidget {
  const PioneerRadioApp({super.key});

  @override
  State<PioneerRadioApp> createState() => _PioneerRadioAppState();
}

class _PioneerRadioAppState extends State<PioneerRadioApp> {
  // --- KONFIGURATION ---
  final String rendererUrl = 'http://192.168.178.33:8080/AVTransport/ctrl';
  String _currentStation = "Kein Sender gewählt";
  // --- DIE DLNA LOGIK ---
  Future<void> playStation(String name, String url) async {
    try {
      print("Versuche Sender zu starten: $name");

      // 1. Metadaten für das Pioneer-Display vorbereiten
      final String metaData =
          '''
<DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/">
  <item id="0" parentID="-1" restricted="1">
    <dc:title>$name</dc:title>
    <upnp:class>object.item.audioItem.musicTrack</upnp:class>
    <res protocolInfo="http-get:*:audio/mpeg:*">$url</res>
  </item>
</DIDL-Lite>'''
              .replaceAll('<', '&lt;')
              .replaceAll('>', '&gt;');

      // 2. Bestehende Wiedergabe stoppen
      await _postSoap('Stop', '<InstanceID>0</InstanceID>');

      // 3. Neue URL setzen
      await _postSoap(
        'SetAVTransportURI',
        '<InstanceID>0</InstanceID><CurrentURI>$url</CurrentURI><CurrentURIMetaData>$metaData</CurrentURIMetaData>',
      );

      // 4. Play-Befehl senden
      await Future.delayed(const Duration(milliseconds: 800));
      await _postSoap('Play', '<InstanceID>0</InstanceID><Speed>1</Speed>');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$name gestartet!')));
    } catch (e) {
      print("Fehler: $e");
    }
  }

  // Hilfsfunktion für den HTTP-POST
  Future<void> _postSoap(String action, String args) async {
    final body =
        '''
<?xml version="1.0" encoding="utf-8"?>
<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
   <s:Body>
      <u:$action xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">$args</u:$action>
   </s:Body>
</s:Envelope>''';

    await http.post(
      Uri.parse(rendererUrl),
      headers: {
        'Content-Type': 'text/xml; charset="utf-8"',
        'SOAPACTION': '"urn:schemas-upnp-org:service:AVTransport:1#$action"',
      },
      body: body,
    );
  }

  // --- ZUSÄTZLICHE FUNKTION FÜR LAUTSTÄRKE (Port 8102) ---
  Future<void> sendControl(String cmd) async {
    try {
      // Verbindung zum alten Port 8102
      Socket socket = await Socket.connect(
        '192.168.178.33',
        8102,
        timeout: const Duration(seconds: 1),
      );
      socket.add([...cmd.codeUnits, 13, 10]);
      await socket.flush();
      await socket.close();
    } catch (e) {
      print("Steuerungsfehler: $e");
    }
  }

  // --- DAS UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            // Hier erzeugen wir den Glow-Effekt um den Textbereich
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withOpacity(0.5),
                blurRadius: 60,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Text(
            'jedi pioneer',
            style: TextStyle(
              fontFamily: 'StarWars',
              fontSize: 36,
              color: Color.fromARGB(255, 250, 250, 129),
              // Zusätzlicher Glow direkt an den Buchstaben:
              shadows: [
                Shadow(
                  color: Color.fromARGB(255, 144, 144, 97),
                  blurRadius: 15.0,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor:
            Colors.blueGrey.shade900, // Passend zur ControlBar unten
      ),
      // HIER LIEGT DIE ÄNDERUNG:
      body: Column(
        children: [
          // 1. Dein Status-Feld oben anzeigen
          StatusDisplay(currentStation: _currentStation),

          // 2. Die Liste muss in ein Expanded, um den Restplatz zu füllen
          Expanded(
            child: ListView.builder(
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final station = stations[index];
                String name = station['name'] ?? 'Unbekannter Sender';
                String url = station['url'] ?? '';
                String? logoPath = station['logo'];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  child: ListTile(
                    // HIER nutzen wir die Variable jetzt:
                    leading: logoPath != null
                        ? Image.asset(
                            logoPath,
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          )
                        : const Icon(
                            Icons.radio,
                            size: 40,
                          ), // Ersatz-Icon, falls kein Logo da ist
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("Tippen zum Streamen"),
                    onTap: () async {
                      setState(() {
                        _currentStation = name;
                      });
                      playStation(name, url); // 1. Stream starten

                      // 2. Radio leiser stellen (z.B. auf Wert 151)
                      await Future.delayed(const Duration(milliseconds: 500));
                      sendControl('060VL');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: ControlBar(
        onControlTap: (code) {
          sendControl(code);
        },
      ),
    );
  }
}
