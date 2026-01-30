import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

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

  // Deine Senderliste als Map (Name: URL)
  final Map<String, String> stations = {
    'WDR 2 Ruhrgebiet':
        'http://wdr-wdr2-ruhrgebiet.icecastssl.wdr.de/wdr/wdr2/ruhrgebiet/mp3/128/stream.mp3',
    '1LIVE':
        'http://wdr-1live-live.icecastssl.wdr.de/wdr/1live/live/mp3/128/stream.mp3',
    'HR3': 'http://hr-hr3-live.cast.addradio.de/hr/hr3/live/mp3/128/stream.mp3',
    'Antenne Bayern': 'http://stream.antenne.de/antenne/stream/mp3',
  };

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
        title: const Text(
          'jedi pioneer app',
          style: TextStyle(
            fontFamily: 'StarWars',
            fontSize: 36,
            color: Colors.yellow,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView.builder(
        itemCount: stations.length,
        itemBuilder: (context, index) {
          String name = stations.keys.elementAt(index);
          String url = stations.values.elementAt(index);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: ListTile(
              leading: const Icon(
                Icons.radio,
                color: Color.fromARGB(255, 21, 88, 123),
              ),
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("Tippen zum Streamen"),
              onTap: () => playStation(name, url),
            ),
          );
        },
      ),

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min, // Ganz wichtig!
        children: [
          // DEINE NEUE ZUSÄTZLICHE BAR
          Container(
            color: const Color.fromARGB(255, 227, 123, 123),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => sendControl('04FN'),
                  child: const Text('XBOX'),
                ),
                ElevatedButton(
                  onPressed: () => sendControl('25FN'),
                  child: const Text(
                    'Gaming PC',
                    style: TextStyle(fontFamily: 'StarWars', fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          BottomAppBar(
            color: Colors.blueGrey.shade900,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_down, color: Colors.white),
                  onPressed: () => sendControl('VD'), // Volume Down
                ),
                IconButton(
                  icon: const Icon(
                    Icons.volume_off,
                    color: Color.fromARGB(255, 151, 152, 151),
                  ),
                  onPressed: () => sendControl('MZ'), // Mute Toggle
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.white),
                  onPressed: () => sendControl('VU'), // Volume Up
                ),
                const VerticalDivider(color: Colors.white24),
                IconButton(
                  icon: const Icon(
                    Icons.power_settings_new,
                    color: Color.fromARGB(255, 117, 194, 2),
                  ),
                  onPressed: () => sendControl('PO'), // Power On
                ),
                //    const VerticalDivider(color: Colors.white24),
                IconButton(
                  icon: const Icon(
                    Icons.power_settings_new,
                    color: Color.fromARGB(255, 224, 88, 88),
                  ),
                  onPressed: () => sendControl('PF'), // Power Off
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
