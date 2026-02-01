// services/pioneer_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;

class PioneerService {
  final String ip = '192.168.178.33';
  final String rendererUrl = 'http://192.168.178.33:8080/AVTransport/ctrl';

  // Port 8102 Steuerung (Lautstärke, Input)
  Future<void> sendControl(String cmd) async {
    try {
      Socket socket = await Socket.connect(
        ip,
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

  // In deiner PioneerService Klasse hinzufügen:
  Future<void> setVolume(double value) async {
    // Wir rechnen den Slider (0.0 - 1.0) auf Pioneer-Werte (z.B. 0 - 185) um.
    int volLevel = (value * 185).round();

    // Pioneer braucht immer 3 Stellen (z.B. 045 statt 45)
    String volString = volLevel.toString().padLeft(3, '0');

    await sendControl('${volString}VL');
  }

  // DLNA / Radio Logik
  Future<void> playStation(String name, String url) async {
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

    await _postSoap('Stop', '<InstanceID>0</InstanceID>');
    await _postSoap(
      'SetAVTransportURI',
      '<InstanceID>0</InstanceID><CurrentURI>$url</CurrentURI><CurrentURIMetaData>$metaData</CurrentURIMetaData>',
    );
    await Future.delayed(const Duration(milliseconds: 800));
    await _postSoap('Play', '<InstanceID>0</InstanceID><Speed>1</Speed>');
  }

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
}
