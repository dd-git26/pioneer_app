//import 'package:flutter/material.dart';

// Eine einfache Liste mit deinen Sendern

const List<Map<String, String>> stations = [
  {
    'name': 'WDR 2',
    'url':
        'http://wdr-wdr2-ruhrgebiet.icecastssl.wdr.de/wdr/wdr2/ruhrgebiet/mp3/128/stream.mp3',
    'genre': 'Pop',
    'logo': 'assets/logos/wdr2.png', // Beispiel für ein Logo, falls benötigt
  },
  {
    'name': 'Radio Superfly',
    'url': 'http://stream01.superfly.fm:8080/live128',
    'genre': 'Soul/Funk',
    'logo': 'assets/logos/superfly.png',
    'vol': '0.7', // Dieser Sender ist von Haus aus sehr laut
  },
  {
    'name': 'Dortmund 91.2',
    'url': 'http://radio912-live.cast.addradio.de/radio912/live/mp3/high',
    'logo': 'assets/logos/912.png',
  },
  {
    'name': 'N-JOY',
    'url': 'http://icecast.ndr.de/ndr/njoy/live/mp3/128/stream.mp3',
    'genre': 'Pop',
    'logo': 'assets/logos/njoy.png',
  },
  {
    'name': 'Deutschlandfunk NOVA',
    'url': 'http://st03.sslstream.dlf.de/dlf/03/128/mp3/stream.mp3',
    'genre': 'Dance',
    'logo': 'assets/logos/nova.png',
  },
];
