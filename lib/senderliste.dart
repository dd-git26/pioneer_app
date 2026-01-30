import 'package:flutter/material.dart';

// Eine einfache Liste mit deinen Sendern
const List<Map<String, String>> stations = [
  {
    'name': 'WDR 2',
    'url':
        'http://wdr-wdr2-ruhrgebiet.icecastssl.wdr.de/wdr/wdr2/ruhrgebiet/mp3/128/stream.mp3',
    'genre': 'Pop',
  },
  {
    'name': 'Radio Superfly',
    'url': 'http://stream01.superfly.fm:8080/live128',
    'genre': 'Soul/Funk',
  },
  {'name': 'Antenne Bayern', 'url': 'http://...'},
  {'name': 'Star Wars Radio', 'url': 'http://...'},
];
